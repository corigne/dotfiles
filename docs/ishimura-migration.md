# Ishimura migration

Inventory date: 2026-09-24. Target: Arch Linux, host `ishimura`, user
`nexus`.

## Current state

- Kernel: `6.18.52-1-lts`.
- Desktop: Hyprland `0.56.2`, started directly by Fish on TTY1.
- No display manager or greetd service is installed.
- Niri, Noctalia, Noctalia Greeter, greetd, and xwayland-satellite are absent.
- GPU topology:
  - Radeon RX 7900 XTX at PCI `0000:03:00.0`, render node `renderD128`.
  - Ryzen integrated Radeon at PCI `0000:10:00.0`, render node `renderD129`.
  - Both connected displays belong to the RX 7900 XTX.
- Displays:
  - `DP-1`: Dell S2716DG, 2560x1440 at 59.951 Hz, position `0,0`.
  - `DP-2`: ASUS VA27AQ, 2560x1440 at 59.951 Hz, position `2560,0`.
- Pointer: Logitech G403, default acceleration.
- No backlight device or battery is present. Do not copy laptop brightness or
  `wluma` configuration to this host.
- Existing portal stack is Hyprland + GTK + KDE. Niri's GNOME portal backend
  is absent.
- Existing XDG autostarts include lxpolkit, pasystray, XApp's status-notifier
  watcher, KDE XWayland Video Bridge, FDM, and Remmina.
- Root filesystem has 173 GiB free but is 91% used. Do not perform automatic
  package or orphan cleanup.

## State that must be preserved

The existing repositories predate the profile layout and are dirty:

- `~/.dotfiles` at `05903d3`
  - modified Hypr startup: immediate lock, EasyEffects, native Hyprexpo load;
  - modified generated Copilot Fish completion;
  - timestamped Hypr backup.
- `~/Scripts` at `0af0307`
  - modified slideshow scanning, cache, daemon readiness, and quoting;
  - timestamped slideshow backup.

The generated Copilot completion should be archived, not manually ported.
Current Scripts and dotfiles `main` already contain the durable slideshow and
profile work. Preserve Ishimura's immediate lock and EasyEffects startup in its
ignored Hypr `local.lua`. Compare the native Hyprexpo load against current
shared Hypr configuration before carrying it forward.

Before changing links or repositories:

1. Save `git status`, `git diff`, submodule state, and ignored host files under
   a timestamped migration directory.
2. Keep the existing repositories intact as timestamped legacy directories.
3. Never pull, reset, rebase, or clean either dirty repository.
4. Keep `~/Scripts` as a historical working tree; the new profile uses the
   versioned `modules/scripts` submodule.

## Host-local configuration

Create Ishimura's ignored `~/.config/niri/local.kdl` from
`local.example.kdl`. Initial values should preserve the observed layout:

```kdl
output "DP-1" {
    mode "2560x1440@59.951"
    scale 1
    position x=0 y=0
}

output "DP-2" {
    mode "2560x1440@59.951"
    scale 1
    position x=2560 y=0
}

debug {
    render-drm-device "/dev/dri/by-path/pci-0000:03:00.0-render"
    ignore-drm-device "/dev/dri/by-path/pci-0000:10:00.0-render"
}
```

Do not raise refresh rates during migration even if the monitors advertise
higher modes. Establish a stable baseline first, then test refresh changes
separately.

Create `~/.config/noctalia/local.toml` with Ishimura's wallpaper directory.
Do not add laptop backlight configuration. Confirm that unavailable brightness
and battery widgets hide themselves; override the desktop bar locally only if
Noctalia renders empty controls.

Do not install or start `wluma` initially. This host has no backlight device,
and screen-content capture previously exposed Mesa fence failures on the
laptop.

## Staged migration

### 1. Preserve and stage

1. Capture the dirty state and copy ignored `local.lua`.
2. Clone current dotfiles recursively into `~/.dotfiles-next`.
3. Verify submodule commits and run shell/config validation from the staged
   clone.
4. Create Ishimura's niri and Noctalia local overrides.
5. Run profile simulations against a temporary HOME.

### 2. Prepare system wiring

From the staged clone:

```sh
./bin/desktop-system arch niri check
./bin/desktop-system arch niri plan
```

Review the exact package and root-file changes. Expected additions include
niri, Noctalia, Noctalia Greeter, greetd, xwayland-satellite, and GNOME/GTK
portal support. Keep Hyprland, Plasma, KDE portal packages, and current
applications installed.

Suppress these only in the Niri profile:

- KDE XWayland Video Bridge;
- lxpolkit, because Noctalia owns the authentication agent;
- pasystray and XApp's status-notifier watcher if they conflict with
  Noctalia's tray.

Keep FDM, Remmina, Fcitx5, NetworkManager, and Bluetooth autostarts unless a
live Niri test demonstrates a conflict.

### 3. Cut over from a TTY

1. Stop the Hypr session and remain logged into a second TTY.
2. Simulate and then unstow the legacy repository while it is still at its
   original path.
3. Rename, never delete, the old repositories to timestamped legacy paths.
4. Rename `~/.dotfiles-next` to `~/.dotfiles`.
5. Apply the `trial` profile, retaining plain Hyprland as fallback.
6. Apply and verify the Arch niri system profile.
7. Confirm Fish no longer auto-starts Hyprland.
8. Activate greetd only after every check passes.

### 4. Acceptance gates

- Noctalia Greeter shows Niri, plain Hyprland, and Plasma only.
- Only `nexus` appears as a login user.
- Niri uses RX 7900 XTX `renderD128`; connectorless iGPU is ignored.
- Both monitors retain position, scale, and 59.951 Hz baseline.
- Logitech mouse and Fcitx5 input work.
- No Hypr portal, Waybar, mako, awww, lxpolkit, or duplicate tray process runs
  in Niri.
- Noctalia owns wallpaper, notifications, lock/idle, clipboard, polkit, OSD,
  tray, and session UI.
- XWayland applications, browser screen sharing, OBS, file choosers, audio,
  screenshots, suspend/logout, and wallpaper controls work.
- Plain Hyprland still starts with immediate lock, EasyEffects, wallpaper
  slideshow, portal routing, and host-specific window rules.
- Niri remains stable through monitor power cycles and at least one reboot.

## Rollback

Keep a root-capable TTY open during activation. If greetd or Niri fails:

```sh
sudo systemctl disable --now greetd.service
~/.dotfiles/bin/desktop-system arch niri rollback
```

Unstow the new profile, restore the timestamped legacy repository names, and
restow the old tree. Do not delete staged clones, backups, or captured diffs
until both Niri and Hypr pass acceptance.
