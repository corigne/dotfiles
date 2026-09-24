---
name: package-security-audit
description: >
  Audits a package dependency for known vulnerabilities, licence issues, and
  staleness before it is added to a project. Use this skill whenever a new
  package is being considered, when asked to check whether a dependency is safe,
  or when auditing an existing lockfile.
allowed-tools: shell
---

## When to invoke

- A new `npm install`, `pip install`, `go get`, `cargo add`, or `maven` dependency is being added.
- The user asks whether a package is safe, up-to-date, or trustworthy.
- You are reviewing a `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, or `pom.xml` and spot packages worth checking.
- The user explicitly asks for a security or dependency audit.

## How to run the audit

```
bash ~/.copilot/skills/package-security-audit/audit-package.sh <name> <version> [ecosystem]
```

Supported ecosystems: `npm` (default), `pypi`, `go`, `cargo`, `maven`.

For Go modules use the full module path, e.g. `golang.org/x/net`.

Example calls:
```
bash ~/.copilot/skills/package-security-audit/audit-package.sh lodash 4.17.20 npm
bash ~/.copilot/skills/package-security-audit/audit-package.sh requests 2.28.0 pypi
bash ~/.copilot/skills/package-security-audit/audit-package.sh golang.org/x/net v0.17.0 go
```

## Interpreting the output

The script emits a single JSON object. Use this decision table:

| Field | Condition | Action |
|---|---|---|
| `risk_level` | `"critical"` | **Block.** Do not proceed. Explain the CVEs and recommend an alternative or patched version. |
| `risk_level` | `"high"` | **Warn strongly.** Surface the issues and ask the user to confirm before continuing. |
| `risk_level` | `"medium"` | **Flag.** Note the concerns but allow the user to proceed with awareness. |
| `risk_level` | `"low"` | Pass. Mention any minor notes (e.g. not latest version) briefly. |
| `vulnerabilities.critical` | > 0 | Always block, regardless of overall score. |
| `vulnerabilities.high` | > 0 | Always surface the CVE IDs and summaries explicitly. |
| `freshness.is_deprecated` | `true` | Warn. Suggest the successor package if known. |
| `freshness.days_since_release` | > 730 | Note: package may be abandoned. |
| `freshness.is_latest` | `false` | Mention the latest version available. |
| `license.is_copyleft` | `true` | Flag for commercial/proprietary projects — ask about the use case. |
| `license.spdx` | `"unknown"` | Warn: no licence detected, assume all rights reserved. |
| `scorecard.score` | < 5 | Note poor OpenSSF health score and what it may imply. |

## Output format to the user

Summarise in plain language — do not dump raw JSON at the user. Example:

> ✅ **lodash@4.17.21** — low risk (score 78/100)
> - 1 medium vulnerability: prototype pollution (GHSA-xxxx) — fixed in 4.17.21
> - MIT licence, 3 maintainers, last released 180 days ago
> - Latest version: 4.17.21 (you are on latest)

> ⚠️ **lodash@4.17.20** — medium risk (score 63/100)
> - 1 medium vulnerability: prototype pollution (GHSA-p6mc-m468-83gw) — **upgrade to 4.17.21**

> 🚫 **event-stream@3.3.6** — critical risk (score 0/100)
> - Known supply-chain backdoor (CVE-2018-16705). Do not use.

## Data sources

- **OSV.dev** — CVEs and GitHub Security Advisories
- **deps.dev** — licence, deprecation status, OpenSSF Scorecard
- **npm / PyPI registry** — latest version, maintainer count, deprecation flag
