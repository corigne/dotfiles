#!/usr/bin/env bash
# audit-package.sh — query OSV.dev, deps.dev, and the upstream registry for a
# package and emit a structured JSON risk summary to stdout.
#
# Usage: audit-package.sh <name> <version> [ecosystem]
#
# Ecosystems (case-insensitive): npm | pypi | go | cargo | maven
# If omitted, ecosystem is inferred from the package name format.
#
# Dependencies: curl, jq
# Exit codes: 0 = success (JSON on stdout), 1 = bad args, 2 = missing deps

set -euo pipefail

# ── helpers ───────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

require() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not found"
  done
}

require curl jq

# ── args & ecosystem normalisation ────────────────────────────────────────────

[[ $# -lt 2 ]] && die "Usage: audit-package.sh <name> <version> [ecosystem]"

PKG_NAME="$1"
PKG_VERSION="$2"
RAW_ECO="${3:-}"

# Infer ecosystem from name if not provided
if [[ -z "$RAW_ECO" ]]; then
  if [[ "$PKG_NAME" =~ ^[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+:[a-zA-Z0-9_\-]+$ ]]; then
    RAW_ECO="maven"
  elif [[ "$PKG_NAME" =~ ^(github\.com|golang\.org|gopkg\.in)/ ]]; then
    RAW_ECO="go"
  else
    RAW_ECO="npm"
  fi
fi

ECO_LOWER="${RAW_ECO,,}"

# Map to canonical names used by each API
case "$ECO_LOWER" in
  npm)     DEPDEV_SYS="npm";   OSV_ECO="npm";       ;;
  pypi)    DEPDEV_SYS="pypi";  OSV_ECO="PyPI";      ;;
  go)      DEPDEV_SYS="go";    OSV_ECO="Go";        ;;
  cargo)   DEPDEV_SYS="cargo"; OSV_ECO="crates.io"; ;;
  maven)   DEPDEV_SYS="maven"; OSV_ECO="Maven";     ;;
  *)       die "Unknown ecosystem '$RAW_ECO'. Use: npm, pypi, go, cargo, maven" ;;
esac

TMPDIR_LOCAL="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_LOCAL"' EXIT

CURL_OPTS=(-sf --max-time 15)

# ── parallel API calls ────────────────────────────────────────────────────────

# 1. OSV.dev — vulnerabilities
(curl "${CURL_OPTS[@]}" \
  -X POST "https://api.osv.dev/v1/query" \
  -H "Content-Type: application/json" \
  -d "{\"package\":{\"name\":\"${PKG_NAME}\",\"ecosystem\":\"${OSV_ECO}\"},\"version\":\"${PKG_VERSION}\"}" \
  > "$TMPDIR_LOCAL/osv.json" 2>/dev/null || echo '{"vulns":[]}' > "$TMPDIR_LOCAL/osv.json") &

# 2. deps.dev — licence, deprecation, published date, related projects
PKG_ENCODED="$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PKG_NAME}', safe=''))")"
VER_ENCODED="$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PKG_VERSION}', safe=''))")"

(curl "${CURL_OPTS[@]}" \
  "https://api.deps.dev/v3/systems/${DEPDEV_SYS}/packages/${PKG_ENCODED}/versions/${VER_ENCODED}" \
  > "$TMPDIR_LOCAL/depsdev.json" 2>/dev/null || echo '{}' > "$TMPDIR_LOCAL/depsdev.json") &

wait

# 3. deps.dev project scorecard (needs source repo from step 2)
PROJECT_KEY="$(jq -r '
  .relatedProjects // [] |
  map(select(.relationType == "SOURCE_REPO")) |
  first | .projectKey.id // ""
' "$TMPDIR_LOCAL/depsdev.json")"

if [[ -n "$PROJECT_KEY" && "$PROJECT_KEY" != "null" ]]; then
  PROJ_ENCODED="$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PROJECT_KEY}', safe=''))")"
  curl "${CURL_OPTS[@]}" \
    "https://api.deps.dev/v3/projects/${PROJ_ENCODED}" \
    > "$TMPDIR_LOCAL/project.json" 2>/dev/null || echo '{}' > "$TMPDIR_LOCAL/project.json"
else
  echo '{}' > "$TMPDIR_LOCAL/project.json"
fi

# 4. Registry freshness (npm or PyPI; others fall through gracefully)
case "$ECO_LOWER" in
  npm)
    (curl "${CURL_OPTS[@]}" \
      "https://registry.npmjs.org/${PKG_NAME}" \
      > "$TMPDIR_LOCAL/registry.json" 2>/dev/null || echo '{}' > "$TMPDIR_LOCAL/registry.json") &
    ;;
  pypi)
    (curl "${CURL_OPTS[@]}" \
      "https://pypi.org/pypi/${PKG_NAME}/json" \
      > "$TMPDIR_LOCAL/registry.json" 2>/dev/null || echo '{}' > "$TMPDIR_LOCAL/registry.json") &
    ;;
  *)
    echo '{}' > "$TMPDIR_LOCAL/registry.json" &
    ;;
esac

wait

# ── synthesise with Python (jq arithmetic is limited) ────────────────────────

python3 - "$TMPDIR_LOCAL" "$PKG_NAME" "$PKG_VERSION" "$ECO_LOWER" <<'PYEOF'
import sys, json, math
from datetime import datetime, timezone

tmpdir, pkg_name, pkg_version, ecosystem = sys.argv[1:]

def load(name):
    try:
        with open(f"{tmpdir}/{name}") as f:
            return json.load(f)
    except Exception:
        return {}

osv      = load("osv.json")
depsdev  = load("depsdev.json")
project  = load("project.json")
registry = load("registry.json")

# ── vulnerabilities ───────────────────────────────────────────────────────────

sev_map = {"CRITICAL": "critical", "HIGH": "high", "MODERATE": "medium",
           "MEDIUM": "medium", "LOW": "low", "UNKNOWN": "unknown"}

counts = {"critical": 0, "high": 0, "medium": 0, "low": 0, "unknown": 0}
vuln_details = []

for v in osv.get("vulns", []):
    # Prefer database_specific.severity (plain string: LOW/MODERATE/HIGH/CRITICAL)
    # as it's more consistently populated than the CVSS severity[] array.
    db_sev = v.get("database_specific", {}).get("severity", "")
    sev_raw = db_sev.upper() if db_sev else "UNKNOWN"
    sev = sev_map.get(sev_raw, "unknown")
    counts[sev] += 1
    vuln_details.append({
        "id": v.get("id", ""),
        "severity": sev,
        "summary": v.get("summary", "")[:120],
    })

# ── licence ───────────────────────────────────────────────────────────────────

licenses = depsdev.get("licenses", [])
license_str = licenses[0] if licenses else "unknown"

COPYLEFT = {"GPL-2.0-only","GPL-2.0-or-later","GPL-3.0-only","GPL-3.0-or-later",
            "AGPL-3.0-only","AGPL-3.0-or-later","LGPL-2.1-only","LGPL-2.1-or-later",
            "LGPL-3.0-only","LGPL-3.0-or-later","MPL-2.0","EUPL-1.2","OSL-3.0"}
is_copyleft = any(l in COPYLEFT for l in licenses)

# ── deprecation & freshness ───────────────────────────────────────────────────

is_deprecated = depsdev.get("isDeprecated", False)
published_at_str = depsdev.get("publishedAt", "")
days_since_release = None

if published_at_str:
    try:
        published = datetime.fromisoformat(published_at_str.replace("Z", "+00:00"))
        days_since_release = (datetime.now(timezone.utc) - published).days
    except Exception:
        pass

# Latest version & maintainers from registry
latest_version = None
maintainers_count = None
registry_deprecated = False

if ecosystem == "npm":
    tags = registry.get("dist-tags", {})
    latest_version = tags.get("latest")
    maintainers_count = len(registry.get("maintainers", []))
    # Check if this specific version is deprecated
    ver_info = registry.get("versions", {}).get(pkg_version, {})
    registry_deprecated = bool(ver_info.get("deprecated"))
elif ecosystem == "pypi":
    info = registry.get("info", {})
    latest_version = info.get("version")
    registry_deprecated = bool(info.get("yanked"))

is_deprecated = is_deprecated or registry_deprecated

# ── OpenSSF scorecard ─────────────────────────────────────────────────────────

scorecard_score = None
scorecard_date = None
sc = project.get("scorecard", {})
if sc:
    scorecard_score = sc.get("overallScore")
    scorecard_date  = sc.get("date", "")[:10]

# ── risk scoring ──────────────────────────────────────────────────────────────
# Start at 100, apply penalties

score = 100

score -= counts["critical"] * 25
score -= counts["high"]     * 15
score -= counts["medium"]   * 5
score -= counts["low"]      * 2

if is_deprecated:
    score -= 20

if license_str == "unknown":
    score -= 15

if days_since_release is not None and days_since_release > 730:
    score -= 15

if scorecard_score is not None:
    if scorecard_score < 3:
        score -= 20
    elif scorecard_score < 5:
        score -= 10

score = max(0, score)

if score >= 80:
    risk_level = "low"
elif score >= 60:
    risk_level = "medium"
elif score >= 40:
    risk_level = "high"
else:
    risk_level = "critical"

# ── output ────────────────────────────────────────────────────────────────────

result = {
    "package":            pkg_name,
    "version":            pkg_version,
    "ecosystem":          ecosystem,
    "risk_score":         score,
    "risk_level":         risk_level,
    "vulnerabilities": {
        "total":    sum(counts.values()),
        "critical": counts["critical"],
        "high":     counts["high"],
        "medium":   counts["medium"],
        "low":      counts["low"],
        "details":  vuln_details,
    },
    "license": {
        "spdx":       license_str,
        "is_copyleft": is_copyleft,
    },
    "freshness": {
        "latest_version":      latest_version,
        "is_latest":           (latest_version == pkg_version) if latest_version else None,
        "is_deprecated":       is_deprecated,
        "days_since_release":  days_since_release,
    },
    "maintainers_count":  maintainers_count,
    "scorecard": {
        "score": scorecard_score,
        "date":  scorecard_date,
    },
    "provenance": {
        "sources": ["osv.dev", "deps.dev", "registry"],
        "fetched_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    },
}

print(json.dumps(result, indent=2))
PYEOF
