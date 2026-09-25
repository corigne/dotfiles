# Dotfiles

Wayland-first dotfiles with explicit desktop profiles:

- `niri`: niri + Noctalia + Noctalia Greeter
- `hypr`: retained Hyprland setup
- `trial`: both desktop configs, with session-owned services kept isolated
- `common`: shell, terminals, editors, and shared tools

GNU Stow owns user configuration. A small POSIX shell adapter owns only
desktop packages and unavoidable root integration such as greetd and portal
policy. It does not manage or converge the whole Arch system.

## Layout

```text
packages/common/       shared home configuration
packages/niri/         niri configuration
packages/noctalia/     Noctalia configuration
packages/hypr/         optional Hyprland, Waybar, mako, and wlogout profile
archive/i3/            historical i3/polybar reference; never installed
modules/scripts/       scripts Git submodule; bin/ is linked into ~/.local/bin
system/arch/           Arch package manifests and owned root templates
bin/                   profile and desktop-system commands
docs/                  migration, governance, and troubleshooting notes
```

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

## Apply a user profile

Preview first:

```sh
./bin/dotfiles-profile plan niri
```

Apply:

```sh
./bin/dotfiles-profile apply niri
```

During evaluation, keep both greeter sessions usable:

```sh
./bin/dotfiles-profile apply trial
```

`trial` installs both desktop configs but does not start either desktop's
components globally. Greeter exposes plain Hyprland as fallback while hiding
the unused UWSM-managed duplicate. After accepting niri, switch to strict
`niri`.

Other commands:

```sh
./bin/desktop-system arch niri check
./bin/dotfiles-profile status
./bin/dotfiles-profile audit niri
./bin/dotfiles-profile unstow niri
./bin/dotfiles-profile apply hypr
```

Profile switching removes links from the previously recorded profile, links the
new profile, and keeps shared files through `common`. It also disables and
stops globally enabled Hypr-only user services when selecting niri. Hypr starts
them only inside its own session.

Noctalia rotates `~/.config/noctalia/local.toml`'s wallpaper directory
automatically. Use `Mod+Ctrl+Escape` for the main collection,
`Mod+Shift+Escape` for the SFW collection, and `Mod+Alt+Escape` for the animated
collection. `Mod+Ctrl+Period` advances immediately in both desktop profiles.
Canonical niri keeps `Mod+Escape` for shortcut-inhibit toggling. The default
automation interval is five minutes.

`wluma` remains host-local because its backlight, camera, and GPU devices vary.
On the current Intel/NVIDIA host, set the `eDP-1` output to `capturer = "none"`.
Wayland screen capture otherwise imports Intel compositor frames through the
NVIDIA Vulkan device and aborts Mesa fence creation. Ambient webcam adjustment
still works; only screen-content compensation is disabled.

## Multi-host rollout

Trial niri + Noctalia on the current host first. `ishimura` is the next Arch
target after acceptance.

Shared configuration stays identical across hosts. Hardware-specific outputs,
input devices, GPU settings, and exceptional bindings belong in each host's
untracked `~/.config/niri/local.kdl`. Desktop-system package records and
root-file backups live in each host's local XDG state directory, so applying or
removing a profile on one machine cannot affect another.

Before applying on `ishimura`:

1. capture its current monitor, input, portal, greeter, and service state;
2. create its `local.kdl` from `local.example.kdl`;
3. run profile and desktop-system plan commands;
4. compare results with current-host trial findings;
5. apply without copying current host's generated Noctalia state.

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
repository. Existing real `dev.env`, Copilot settings, and legacy Waybar
watcher unit files receive timestamped sibling backups before Stow takes
ownership. Arbitrary files and external symlinks remain untouched.

## Desktop-system setup on Arch

`desktop-system` exists because home-directory Stow packages cannot:

- install pacman/AUR packages;
- manage `/etc/greetd/config.toml`;
- manage desktop portal policy under `/etc`;
- install Noctalia Greeter state owned by its system account;
- enable a system display-manager service.

Its scope stops there. It never inventories unrelated packages, edits unrelated
`/etc`, performs generic orphan cleanup, or removes packages it did not record
as introduced by a desktop profile.

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
| `Super+Alt+L` | Noctalia lock |
| `Mod+N` | Yazi |
| `Mod+Shift+N` | Thunar |
| `Mod+Shift+D` | Noctalia control center |
| `Mod+Alt+V` | Noctalia clipboard |
| `Mod+F2/F3/F4` | Previous/next/play-pause |

Navigation, movement, workspaces, overview, consume/expel, sizing, floating,
tabbed columns, screenshots, and session exit retain niri's upstream bindings.
The old i3 and current Hypr configs are references for missing actions, not
templates for forcing niri into an i3 layout.

### Machine-local niri settings

Copy:

```sh
cp ~/.config/niri/local.example.kdl ~/.config/niri/local.kdl
```

`local.kdl` is ignored by Git and Stow. Keep output names, monitor modes, GPU
details, touchpad quirks, and TrackPoint settings there.

Validate after changes:

```sh
niri validate
```

## Window rules and opacity

Rules live in `~/.config/niri/rules.kdl`.

1. Run `niri msg pick-window`.
2. Click target window and copy exact `app-id` and title.
3. Prefer anchored `app-id` regexes; use titles only when app ID cannot
   distinguish a dialog.
4. Put full-opacity exceptions after broad opacity rules.
5. Run `niri validate`.

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
precedence. Use tracked TOML for stable intent and GUI settings for trial
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

The niri profile therefore does not start Waybar, mako, tofi, clipse, awww,
hyprlock, hypridle, hyprpolkitagent, or wlogout.

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

## Portals

Niri uses:

- `xdg-desktop-portal-gnome` for screencasting;
- `xdg-desktop-portal-gtk` for file chooser and basic fallback portals;
- `gnome-keyring` for Secret portal support.

Policy is explicit in
`system/arch/xdg-desktop-portal/niri-portals.conf`. The niri session must not
start or select `xdg-desktop-portal-hyprland`.

## Scripts submodule

Desktop commands are linked from `modules/scripts/bin` into `~/.local/bin`.
See `modules/scripts/README.md` for command categories and dependencies.

Update after the Scripts repository has published a new commit:

```sh
git submodule update --remote modules/scripts
git add modules/scripts
```

Hypr-only commands use a `hypr-` prefix. Reusable screenshot, archive, and
wallpaper commands avoid compositor IPC.

## Governance and package-source policy

See [`docs/component-governance.md`](docs/component-governance.md). Major
user-facing components require primary-source ownership, organization, package,
and disclosed-funding review before adoption. Compatibility with another
desktop is not treated as project affiliation.

## Secrets

Secrets remain in `pass`/GPG and are never stored in this repository. Never add
`.env*`, password-store contents, tokens, or credentials.
