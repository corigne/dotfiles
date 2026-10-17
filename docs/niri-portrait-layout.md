# Niri portrait-layout experiment

This experiment adds a vertical scrolling main axis to the private Niri build
for Ishimura's portrait `DP-2`. It remains private and reversible. Do not submit
this branch upstream: Niri's contribution policy prohibits LLM-created public
contributions.

Status: active and live-verified on Ishimura since 2026-10-17.

## Scope

- `DP-1` keeps Niri's normal horizontal scrolling layout.
- `DP-2` uses `main-axis "vertical"` from host-local
  `~/.config/niri/local.kdl`.
- The shared `blur-opacity` patch remains present.
- Necromorph stays on `per-window-blur`; do not enable portrait mode there.

The portrait setting changes logical layout axes:

- columns scroll from top to bottom;
- workspaces are arranged from left to right;
- column-width actions change physical height;
- window-height actions change physical width;
- logical `focus-column-left/right` actions move up/down on `DP-2`;
- logical `focus-window-up/down` actions move left/right inside a multi-window
  row.

## Provenance

| Item | Value |
|---|---|
| Private repository | `git@github.com:corigne/niri-private.git` |
| Local checkout | `~/dev/projects/niri` |
| Stable private branch | `per-window-blur` |
| Stable private commit | `8af0c0ad904cc8e658ae3b6909bcabca3ef76c52` |
| Experiment branch | `experimental/portrait-layout` |
| Portrait source | `0WD0/niri`, branch `wd/vertical-layout` |
| Portrait source tip | `7bbe4e3a383374ebf0d32e9c978ca36c43873095` |
| Port integration commit | `8a6a447a1b53b2ae6a089256455ee3419fa57741` |
| Installed binary | `~/.local/lib/niri-private/niri` |
| Installed SHA-256 | `3698834d601aa07869d083a22ca7983cbd7ad21589b0f35f2de44da0e49d384a` |
| Stable backup SHA-256 | `0c6b9b5c0902f752c48a5aaec54b8f0974563b1ac5ad43a96d63f801a2cfe9cb` |
| Upstream request | `niri-wm/niri#1071` |

The experiment transplants the 26 portrait commits beginning at
`710bfae1` and ending at `7bbe4e3a` onto `per-window-blur`. It does not merge
the stale fork branch or its unrelated history.

Three cherry-pick conflicts came from an input test removed by newer Niri.
Resolution retained the current input test architecture and the portrait
coverage in `src/input/axis_policy.rs`. Commit `8a6a447a` contains four
rebase-compatibility fixes:

- current tab hit-test variable name;
- current axis-aware workspace animation API;
- two stale imports removed.

## Build and validation

```sh
cd ~/dev/projects/niri
git switch experimental/portrait-layout
git pull --ff-only
cargo +nightly fmt --check
cargo check --workspace --all-targets
cargo test -p niri axis
cargo test --workspace
cargo build --release --locked
./target/release/niri validate
```

The 2026-10-17 build passed:

- `cargo +nightly fmt --check`;
- `cargo check --workspace --all-targets`;
- 19 focused portrait-axis tests;
- 248 full workspace tests, including existing `blur-opacity` coverage;
- wiki parsing and documentation tests;
- release build and complete config validation.

Expected installed version:

```text
niri 26.04 (8a6a447a)
```

Install only after every gate passes:

```sh
install -m 0755 \
  ~/dev/projects/niri/target/release/niri \
  ~/.local/lib/niri-private/niri
```

Niri cannot replace the running compositor process. Log out and start a new
Niri session after installing. The old process will reject `main-axis` during
automatic reload but retains its previous valid configuration until logout.

The shell command `niri` resolves to Arch's `/usr/bin/niri`, currently
`26.04 (8ed0da4)`. The session override launches the private compositor binary
instead. A version warning from `niri msg version` is therefore expected while
the packaged IPC client remains compatible. Do not replace the packaged binary.
Verify the running compositor directly:

```sh
pid=$(pgrep -n '^niri$')
readlink -f "/proc/$pid/exe"
"/proc/$pid/exe" --version
```

Expected executable and version:

```text
/home/nexus/.local/lib/niri-private/niri
niri 26.04 (8a6a447a)
```

## Host-local configuration

Ishimura owns this untracked block inside `output "DP-2"`:

```kdl
layout {
    main-axis "vertical"
}
```

No tracked shared configuration enables portrait mode. This prevents the
experiment from crossing into Necromorph or future hosts automatically.

Ishimura also lists `DP-2` in the ignored host-local file:

```text
~/.config/niri/vertical-main-axis-outputs
```

Its effective content is:

```text
# Outputs using layout { main-axis "vertical" } on this host.
DP-2
```

Tracked directional keybinds call `niri-physical-direction`, which uses this
list to keep arrow and HJKL focus/move commands physically oriented. On DP-2,
Left/Right switch horizontal workspaces and Up/Down traverse vertical columns;
Shift moves the focused column in the same physical direction. Hosts without
this file retain the normal horizontal action mapping.

The layout block and companion output list are one configuration invariant.
Adding or removing a vertical layout requires changing both. The dispatcher
does not parse KDL because host config can contain includes and arbitrary output
ordering; the explicit list keeps runtime behavior deterministic.

## Directional navigation

| Output layout | Left/Right | Up/Down | Shift+Left/Right | Shift+Up/Down |
| --- | --- | --- | --- | --- |
| Normal horizontal main axis | Focus columns | Focus windows within a column | Reorder columns | Reorder windows within a column |
| Vertical main axis | Switch workspaces | Focus vertical columns | Send column to adjacent workspace and follow it | Reorder vertical columns |

H/J/K/L use the same physical mapping. H/L request a physical monitor fallback
when the local action cannot move. On a vertical output, Niri's dynamic empty
workspace may satisfy Left/Right before monitor fallback is reached.

This mapping intentionally prioritizes the common portrait hierarchy:
workspaces horizontally, columns vertically. Direct `focus-window-up/down`
actions remain available through Niri IPC for multi-window columns but are not
assigned to the directional keys on `DP-2`.

## Partial rollback: layout only

Keep the experimental binary but remove the `layout` block above from
`~/.config/niri/local.kdl` and remove `DP-2` from
`~/.config/niri/vertical-main-axis-outputs`, then validate and reload:

```sh
~/.local/lib/niri-private/niri validate
niri msg action load-config-file
```

This immediately restores horizontal scrolling on `DP-2`.

## Full rollback: binary and layout

The exact pre-experiment binary is retained at:

```text
~/.local/lib/niri-private/backups/niri-8af0c0ad
```

Its SHA-256 is:

```text
0c6b9b5c0902f752c48a5aaec54b8f0974563b1ac5ad43a96d63f801a2cfe9cb
```

First remove the host-local `main-axis` block and remove `DP-2` from
`~/.config/niri/vertical-main-axis-outputs`. Then restore the binary:

```sh
sha256sum -c ~/.local/lib/niri-private/backups/SHA256SUMS
install -m 0755 \
  ~/.local/lib/niri-private/backups/niri-8af0c0ad \
  ~/.local/lib/niri-private/niri
~/.local/lib/niri-private/niri validate
```

Log out and start Niri again. Source checkout rollback is non-destructive:

```sh
cd ~/dev/projects/niri
git switch per-window-blur
```

Do not delete `experimental/portrait-layout`; it is the durable audit trail and
can be compared or rebuilt later.

## Dispatcher recovery

If directional binds stop responding, verify the tracked script link and
host-local list:

```sh
command -v niri-physical-direction
ls -l ~/.local/bin/niri-physical-direction
cat ~/.config/niri/vertical-main-axis-outputs
~/.local/lib/niri-private/niri validate
```

Restore script links from the scripts submodule:

```sh
stow --restow \
  --dir="$HOME/.dotfiles/modules/scripts" \
  --target="$HOME/.local/bin" \
  bin
```

The dispatcher reports IPC and configuration errors on stderr and exits
non-zero. It does not return success after a failed action.

## Verification

After the new session starts:

1. `/proc/$(pgrep -n '^niri$')/exe` resolves to the private binary and reports
   the experiment commit. The packaged `/usr/bin/niri` CLI may report its own
   version and an expected mismatch warning.
2. `DP-1` still creates and scrolls columns horizontally.
3. New windows on `DP-2` occupy half its physical height and scroll vertically.
4. `Mod+Right` on `DP-2` selects the workspace physically to the right;
   `Mod+Left` returns to the previous workspace.
5. `Mod+Up/Down` on `DP-2` traverses vertically stacked columns.
6. Shift-direction actions move the focused column along the matching physical
   axis.
7. The same keys retain standard Niri behavior on `DP-1`.
8. Overview, pointer gestures, wheel navigation, interactive move/resize, and
   screenshot UI follow the selected output axis.
9. Window blur and `blur-opacity` remain active.

### Activation record

Activated successfully on Ishimura on 2026-10-17. Live use confirmed:

- running version `niri 26.04 (8a6a447a)`;
- `DP-1` retains the horizontal layout;
- `DP-2` stacks and scrolls windows vertically;
- `DP-2` workspaces move horizontally;
- adaptive Right then Left changed and restored the focused workspace ID
  (`1 -> 4 -> 1`);
- overview and input behavior remain usable;
- window blur and `blur-opacity` remain active.

## Retirement

Track `niri-wm/niri#1071`. When upstream ships portrait layout:

1. update and validate `per-window-blur` against that release;
2. compare upstream action semantics with `niri-physical-direction`;
3. replace the host-local syntax and companion output list if upstream changed
   or internalized axis-aware key handling;
4. rebuild from `per-window-blur`;
5. complete the verification list;
6. restore Ishimura and Necromorph to the same maintained private branch;
7. retain this document and private experiment branch as historical rollback
   evidence.
