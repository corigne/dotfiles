# Dotfiles

Wayland-first dotfiles with one managed desktop and one stock recovery desktop:

- `niri`: primary desktop, niri + Noctalia + Noctalia Greeter
- Plasma: stock recovery session, installed without custom desktop configuration
- `common`: shell, terminals, editors, and shared tools

GNU Stow owns user configuration. A small POSIX shell adapter owns only
desktop packages and unavoidable root integration such as greetd, PAM, and
portal policy. It does not manage or converge the whole Arch system.

## Layout

```text
packages/common/       shared home configuration
packages/niri/         niri configuration
packages/noctalia/     Noctalia configuration
archive/i3/            historical i3/polybar reference; never installed
modules/scripts/       scripts Git submodule; bin/ is linked into ~/.local/bin
system/arch/           Niri, Plasma fallback, and owned root integration
bin/                   profile and desktop-system commands
docs/                  migration, governance, and troubleshooting notes
```

## Architecture handoff

Cross-repository ownership, live runtime wiring, host-local boundaries, the
private Niri build, update workflow, validation, and recovery are documented in
the Obsidian vault:

```text
~/Documents/vault/notes/systems/Dotfiles - Niri + Noctalia Architecture.md
```

Repository topology:

| Path | Repository | Role |
|---|---|---|
| `~/.dotfiles` | `git@github.com:corigne/dotfiles.git` | Profiles, manifests, root templates, docs |
| `~/.dotfiles/modules/scripts` | `git@github.com:corigne/scripts.git` | Shared desktop commands linked into `~/.local/bin` |
| `~/.dotfiles/packages/common/dot-config/nvim` | `git@github.com:corigne/dot-neovim.git` | Neovim configuration |
| `~/.dotfiles/packages/common/dot-config/tmux` | `git@github.com:corigne/dot-tmux.git` | tmux configuration |
| `~/Projects/niri` | `https://github.com/corigne/niri-private.git` | Private `blur-opacity` Niri branch |

## Clone

```sh
git clone --recurse-submodules git@github.com:corigne/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Required bootstrap tools:

```sh
sudo pacman -S --needed git stow
```

No Python provisioning framework is required.

## Quick start

```sh
cd ~/.dotfiles
./bin/dotfiles-profile plan niri
./bin/dotfiles-profile apply niri
./bin/desktop-system arch niri plan
./bin/desktop-system arch niri apply
./bin/desktop-system arch niri verify
./bin/desktop-system arch niri activate
```

Review each plan before applying it. `activate` enables greetd for the next
boot; it does not replace the current session. Select **Niri** in Noctalia
Greeter.

## Apply a user profile

Preview first:

```sh
./bin/dotfiles-profile plan niri
```

The plan groups package and script changes, prints `+` for links, `-` for
removals, and reports `no changes` for an already-applied section. A
`BLOCKED` result is a real Stow conflict that must be resolved before apply;
routine directory traversal is intentionally hidden. Large initial plans show
counts by default; append `--verbose` to list every affected path.

Apply:

```sh
./bin/dotfiles-profile apply niri
```

Other commands:

```sh
./bin/desktop-system arch niri check
./bin/dotfiles-profile status
./bin/dotfiles-profile audit niri
./bin/dotfiles-profile unstow niri
```

The Niri profile links shared configuration through `common`. The Niri session
initializes GTK interface and monospace defaults to `Maple Mono NF CN`;
Noctalia uses the same family. Plasma uses its stock session configuration.

Wallpaper collection state lives under
`$XDG_STATE_HOME/wallpaper-collection/state.json`, independent of either
compositor. Use `Mod+Ctrl+Escape` for the main collection,
`Mod+Shift+Escape` for the SFW collection, and `Mod+Alt+Escape` for the animated
collection. `Mod+Escape` advances within the selected collection through
the active desktop backend. Niri's shortcut-inhibit toggle moves to
`Mod+Ctrl+Alt+Escape`. Animated selections use
the repository-owned Noctalia `mpvpaper` plugin to keep distinct per-output
animation visible through background effects.

The collection scripts are the only wallpaper queue owner. The tracked
Noctalia profile disables native fixed-directory automation in
`zz-wallpaper-collection.toml`; scripts never rewrite shell configuration.
Niri starts `wallpaper-collection.timer`, which advances the authoritative
queue every five minutes through the portable `wallpaper-next` dispatcher.

`wluma` is not started by either desktop profile. Webcam ALS caused distracting
camera activity, Noctalia displayed an OSD for every automatic brightness
change, and screen capture exposed a Mesa fence failure on the hybrid-GPU
laptop. Noctalia owns manual brightness controls instead.

Noctalia runs as a Niri-started user service with `Restart=on-failure`.
Noctalia 5.1 can disconnect from Niri while acquiring the session lock before
suspend: Niri reports `ext_session_lock_v1` error 3 (`DUPLICATE_OUTPUT`), which
removes the bar and wallpaper together. The service is a temporary recovery
measure for the upstream lock lifecycle bug. Remove the service and restore
direct Niri startup after the upstream fix is installed and a suspend/resume
test passes.

Niri starts EasyEffects and `udiskie --tray` once per session. Noctalia owns
idle, polkit, notifications, clipboard, bar, and wallpaper. Plasma remains
stock and owns its services only during a Plasma session. Hardware-specific
overlays such as BongoCat belong in ignored host-local configuration.

## Multi-host rollout

Trial niri + Noctalia on the current host first. `ishimura` is the next Arch
target after acceptance.

Shared configuration stays identical across hosts. Hardware-specific outputs,
input devices, GPU settings, and exceptional bindings belong in each host's
untracked `~/.config/niri/local.kdl`. Desktop-system package records and
root-file backups live in each host's local XDG state directory, so applying or
removing a profile on one machine cannot affect another.

`ishimura` follows the same strict-Niri profile. Its monitor/GPU overrides stay
in `local.kdl`; generated Noctalia state is never copied between hosts.

### Existing installations

The old repository layout used `stow --dotfiles .`. Preview its one-time
migration:

```sh
./bin/dotfiles-profile migrate-legacy plan
```

Apply after reviewing the exact paths:

```sh
./bin/dotfiles-profile migrate-legacy apply
./bin/dotfiles-profile plan niri
```

Migration removes only symlinks resolving into retired paths inside this
repository. Existing real `dev.env` and Copilot settings receive timestamped
sibling backups before Stow takes ownership. Arbitrary files and external
symlinks remain untouched.

## Desktop-system setup on Arch

`desktop-system` exists because home-directory Stow packages cannot:

- install pacman/AUR packages;
- manage `/etc/greetd/config.toml`;
- manage `/etc/pam.d/greetd` so TPM/password login unlocks GNOME Keyring;
- manage desktop portal policy under `/etc`;
- install Noctalia Greeter state owned by its system account;
- enable a system display-manager service;
- manage `/etc/NetworkManager/dispatcher.d/09-timezone`, which runs `tzupdate`
  on network `up` so the system timezone follows IP geolocation after travel.
- on battery-equipped hosts, suspend through systemd at 15% and use
  battery-aware suspend-then-hibernate to preserve the session before
  exhaustion.

The timezone dispatcher is common root integration applied with the Niri
system setup. Its `tzupdate` dependency is tracked in the Niri AUR manifest.

Laptop power policy uses UPower only to request systemd's generic `Sleep`
operation at 15%. systemd selects `suspend-then-hibernate`, enters deep suspend,
then hibernates on the built-in 5% ACPI battery alarm or after two hours,
whichever comes first. RTC wake requires firmware wake-alarm support. NVIDIA
sleep services are enabled only when an NVIDIA GPU is present.

Its scope stops there. It never inventories unrelated packages, edits unrelated
`/etc`, performs generic orphan cleanup, or removes packages it did not record
as introduced by a desktop profile.

The niri profile currently uses `xwayland-satellite-git` because stable 0.8.2
breaks Steam dropdown and context-menu focus. Return to the repository package
after Arch ships xwayland-satellite 0.8.3 or newer.

Preview:

```sh
./bin/desktop-system arch niri plan
```

Apply after reviewing package and file changes:

```sh
./bin/desktop-system arch niri apply
```

Post-install verification and explicit greetd activation:

```sh
./bin/desktop-system arch niri verify
./bin/desktop-system arch niri activate
```

The niri profile uses official Arch packages where available. AUR-only packages
are isolated in `system/arch/packages/niri.aur.txt` and installed through
`paru`; review their PKGBUILDs before applying.

Removal is profile-scoped and interactive:

```sh
./bin/desktop-system arch niri remove
```

Rollback restores original root files and removes root files first created by
the adapter:

```sh
./bin/desktop-system arch niri rollback
```

`apply` does not enable greetd. `activate` verifies installed files, prints TTY
recovery commands, and enables greetd without rebooting. Keep a TTY or
root-capable shell open before activation.

## Niri configuration

`packages/niri/dot-config/niri/config.kdl` starts from upstream's canonical
default config. Existing niri bindings stay canonical. Personal bindings are
added only where upstream has no equivalent:

| Binding | Action |
|---|---|
| `Mod+T` | Ghostty |
| `Mod+D` | Noctalia launcher |
| `Mod+Ctrl+L` | Noctalia lock |
| `Mod+N` | Yazi |
| `Mod+Shift+N` | Thunar |
| `Mod+Shift+D` | Noctalia control center |
| `Mod+Alt+V` | Noctalia clipboard |
| `Mod+F2/F3/F4` | Previous/next/play-pause |
| `Mod+Ctrl+Escape` | Random main wallpaper |
| `Mod+Shift+Escape` | Random SFW wallpaper |
| `Mod+Alt+Escape` | Random animated wallpaper |
| `Mod+Escape` | Next wallpaper |
| `Mod+Ctrl+Alt+Escape` | Toggle shortcut inhibitor |

Navigation follows one modifier grammar: plain `Mod` focuses within a
workspace, `Mod+Shift` moves within it, `Mod+Ctrl` focuses workspaces,
`Mod+Ctrl+Shift` moves columns between workspaces, `Mod+Alt` focuses monitors,
and `Mod+Alt+Shift` moves columns between monitors. Output-name bindings remain
host-local. The archived i3 config is a reference for missing actions, not a
template for forcing Niri into an i3 layout.

### First-login cheatsheet

Press `Mod+Shift+Slash` (usually `Mod+?`) to open niri's built-in hotkey
cheatsheet. It shows only active bindings and can be reopened at any time. From
a terminal inside niri, the equivalent command is:

```sh
niri msg action show-hotkey-overlay
```

Useful canonical starting points:

| Binding | Action |
|---|---|
| `Mod+Shift+Slash` | Open hotkey cheatsheet |
| `Mod+O` | Toggle overview |
| `Mod+Q` | Close focused window |
| `Mod` + H/J/K/L | Focus within workspace, crossing monitors at an edge |
| `Mod+Shift` + H/L | Move column within workspace, crossing monitors at an edge |
| `Mod` + arrows or wheel | Focus strictly within workspace |
| `Mod+Shift` + arrows or wheel | Move strictly within workspace |
| `Mod+Ctrl` + J/K, Up/Down, PageUp/PageDown, U/I, or wheel | Focus workspace |
| `Mod+Ctrl+Shift` + workspace control | Send column to another workspace without following it |
| `Mod+Alt` + H/J/K/L, arrows, or wheel | Focus monitor |
| `Mod+Alt+Shift` + monitor control | Move column between monitors |
| `Mod+Alt+PageUp/PageDown` | Focus previous/next monitor |
| `Mod+Alt+Shift+PageUp/PageDown` | Move column to previous/next monitor |
| `Mod+1..9` | Focus numbered workspace on focused monitor |
| `Mod+Ctrl+Shift+1..9` | Send column to numbered workspace without following it |
| `Mod+R` | Cycle preset column widths |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+V` | Toggle window floating |
| `Mod+Shift+E` | Exit niri with confirmation |

Use the overlay as source of truth; this table is only a learning shortlist.

### Machine-local niri settings

Copy:

```sh
cp ~/.config/niri/local.example.kdl ~/.config/niri/local.kdl
```

`local.kdl` is ignored by Git and Stow. Keep output names, monitor modes, GPU
details, touchpad quirks, and TrackPoint settings there.

Niri replaces a complete device block when a later included `input` section
defines the same device type. Keep all effective touchpad options together in
`local.kdl`; otherwise its `touchpad` block will replace shared touchpad values.

Validate after changes:

```sh
~/.local/lib/niri-private/niri validate
```

## Window rules and opacity

Rules live in `~/.config/niri/rules.kdl`.

1. Run `niri msg pick-window`.
2. Click target window and copy exact `app-id` and title.
3. Prefer anchored `app-id` regexes; use titles only when app ID cannot
   distinguish a dialog.
4. Put full-opacity exceptions after broad opacity rules.
5. Run `~/.local/lib/niri-private/niri validate`.

Example:

```kdl
window-rule {
    match app-id=r#"^org\.example\.Application$"#
    opacity 1.0
}
```

## Noctalia

Tracked config is `packages/noctalia/dot-config/noctalia/config.toml`.
Noctalia v5 merges every `*.toml` in `~/.config/noctalia/`, then applies
GUI-generated state under `~/.local/state/noctalia/`; GUI state has higher
precedence. Use tracked TOML for stable intent and GUI settings for runtime
adjustments.

Wallpaper directories require absolute paths. Copy the host-local example after
applying the profile:

```sh
cp ~/.config/noctalia/local.example ~/.config/noctalia/local.toml
```

Replace `/home/USER` with that host's home path. `local.toml` is ignored by Git
and Stow, so `ishimura` can use a different library without branching shared
configuration.

Noctalia owns:

- bar and launcher;
- notifications;
- wallpaper rotation;
- lock screen and idle/DPMS behavior;
- clipboard history;
- polkit agent;
- OSD and power/session UI.

Noctalia is the only shell layer started by the Niri profile.

## Greeter recovery

Before enabling greetd:

```sh
systemctl status display-manager.service
```

Do not enable two display managers. If graphical login fails, switch to a TTY
and run:

```sh
sudo systemctl disable --now greetd.service
~/.dotfiles/bin/desktop-system arch niri rollback
```

Inspect logs:

```sh
systemctl status greetd.service
journalctl -u greetd.service -b
```

Noctalia Greeter appearance sync remains authenticated by default. Do not add a
passwordless Polkit rule until installed shell and greeter versions support the
constrained sync action documented upstream.

The managed greetd PAM stack first offers the TPM-backed keyring token, then
passes the login password to GNOME Keyring and starts its Secret Service during
session setup. Password fallback requires the login keyring password to match
the account password.

The Arch adapter also changes the unused legacy `greetduser` account to
`/usr/bin/nologin` when that account exists. Noctalia Greeter enumerates NSS
users with UID 1000 or higher, so an interactive shell would expose that service
account in the account picker even when AccountsService marks it as a system
account.

## Portals

Niri uses:

- `xdg-desktop-portal-gnome` for screencasting;
- `xdg-desktop-portal-gtk` for file chooser and basic fallback portals;
- `gnome-keyring` for Secret portal support.

Policy is explicit in
`system/arch/xdg-desktop-portal/niri-portals.conf`. Niri explicitly selects
GNOME and GTK backends; Plasma uses KDE's backend in its own session.

The niri package includes a scoped `xdg-desktop-portal-gnome` service override
with `GDK_DEBUG=no-portals`. Without it, GTK inside the GNOME backend queries the
portal frontend while that frontend is still waiting for the backend, adding a
25-second D-Bus timeout to login and application startup. The override affects
only the portal implementation; applications continue to use portals normally.

## Scripts submodule

Desktop commands are linked from `modules/scripts/bin` into `~/.local/bin`;
desktop backends are linked from `modules/scripts/libexec` into
`~/.local/libexec/dotfiles`.
See `modules/scripts/README.md` for command categories and dependencies.

Update after the Scripts repository has published a new commit:

```sh
git submodule update --remote modules/scripts
git add modules/scripts
```

Public screenshot and wallpaper commands avoid compositor IPC and dispatch to
Niri/Noctalia or Plasma backends.

## Governance and package-source policy

See [`docs/component-governance.md`](docs/component-governance.md). Major
user-facing components require primary-source ownership, organization, package,
and disclosed-funding review before adoption. Compatibility with another
desktop is not treated as project affiliation.

## Secrets

Secrets remain in `pass`/GPG and are never stored in this repository. Never add
`.env*`, password-store contents, tokens, or credentials.
