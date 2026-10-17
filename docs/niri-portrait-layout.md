# Niri portrait-layout experiment

This experiment adds a vertical scrolling main axis to the private Niri build
for Ishimura's portrait `DP-2`. It remains private and reversible. Do not submit
this branch upstream: Niri's contribution policy prohibits LLM-created public
contributions.

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
| Port integration commit | `8a6a447a` |
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

Expected version starts with:

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

Tracked directional keybinds call `niri-physical-direction`, which uses this
list to keep arrow and HJKL focus/move commands physically oriented. Hosts
without this file retain the normal horizontal action mapping.

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

First remove the host-local `main-axis` block. Then restore the binary:

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

## Verification

After the new session starts:

1. `niri --version` reports the experiment commit.
2. `DP-1` still creates and scrolls columns horizontally.
3. New windows on `DP-2` occupy half its physical height and scroll vertically.
4. Workspace switching on `DP-2` moves horizontally.
5. Overview, pointer gestures, wheel navigation, interactive move/resize, and
   screenshot UI follow the selected output axis.
6. Window blur and `blur-opacity` remain active.

### Activation record

Activated successfully on Ishimura on 2026-10-17. Live use confirmed:

- `DP-1` retains the horizontal layout;
- `DP-2` stacks and scrolls windows vertically;
- `DP-2` workspaces move horizontally;
- overview and input behavior remain usable;
- window blur and `blur-opacity` remain active.

## Retirement

Track `niri-wm/niri#1071`. When upstream ships portrait layout:

1. update and validate `per-window-blur` against that release;
2. replace the host-local syntax only if upstream changed it;
3. rebuild from `per-window-blur`;
4. complete the verification list;
5. restore Ishimura and Necromorph to the same maintained private branch;
6. retain this document and private experiment branch as historical rollback
   evidence.
