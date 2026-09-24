# Component governance review

Review date: 2026-09-24

Scope: compositor, shell, greeter, locker/idle implementation, portals,
wallpaper/notifications, and authentication agent.

Exclusion threshold:

- verified direct maintainership;
- official project or organization membership;
- disclosed funding relationship with excluded people, projects, organizations,
  or associated funds.

Compatibility, package support, mentions, or indirect community overlap are not
treated as affiliation. Missing evidence is recorded as unknown, not proof of
independence.

| Component | Upstream owner | Package source | Review result |
|---|---|---|---|
| niri | `niri-wm` / YaLTeR upstream | Arch official repository | No verified direct excluded affiliation found in reviewed primary sources |
| Noctalia | `noctalia-dev` | Arch official repository | No verified direct excluded affiliation found in reviewed primary sources |
| Noctalia Greeter | `noctalia-dev` | Noctalia-maintained AUR package | No verified direct excluded affiliation found in reviewed primary sources |
| greetd | upstream greetd project | Arch official repository | No verified direct excluded affiliation found in reviewed primary sources |
| xdg-desktop-portal-gnome | GNOME | Arch official repository | No verified direct excluded affiliation found in reviewed primary sources |
| xdg-desktop-portal-gtk | freedesktop/GNOME ecosystem | Arch official repository | No verified direct excluded affiliation found in reviewed primary sources |
| xwayland-satellite | Supreeeme upstream | Arch official repository | No verified direct excluded affiliation found in reviewed primary sources |

Primary references:

- https://github.com/niri-wm/niri
- https://niri-wm.github.io/niri/
- https://github.com/noctalia-dev/noctalia
- https://docs.noctalia.dev/
- https://github.com/noctalia-dev/noctalia-greeter
- https://github.com/kennylevinsen/greetd
- https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome
- https://github.com/Supreeeme/xwayland-satellite
- https://archlinux.org/packages/
- https://aur.archlinux.org/packages/noctalia-greeter

Before applying system setup:

1. Confirm package ownership and repository have not changed.
2. Review AUR PKGBUILDs and upstream source URLs.
3. Check current sponsor/funding disclosures and organization membership.
4. Update this file when evidence changes.
5. Reject or replace a component when a direct excluded relationship is
   verified.

This file documents evidence review, not moral or political claims about
individual contributors.
