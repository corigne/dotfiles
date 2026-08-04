-- Hyprland config (Lua) — ported from hyprland.conf
-- Since Hyprland 0.55, hyprlang is deprecated in favor of lua.
-- https://wiki.hypr.land/Configuring/Start/

-------------------
---- INCLUDES -----
-------------------

local theme = require("frappe-theme")
require("local") -- machine-specific (monitor, device, local keybinds) — git-ignored

---------------------
---- ENVIRONMENT ----
---------------------

-- Uncomment if running outside of UWSM
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

local xdg_runtime_dir = os.getenv("XDG_RUNTIME_DIR") or ""
local ssh_auth_sock   = xdg_runtime_dir .. "/ssh-agent.socket"
hl.env("SSH_AUTH_SOCK", ssh_auth_sock)
hl.env("SSH_AGENT_SOCK", ssh_auth_sock)

hl.env("HYPRCURSOR_THEME", "catppuccin-frappe-sapphire")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")

------------------------------
---- VARS / ALIASES ----------
------------------------------

local gowall_theme    = "cat-frappe"
local scripts         = "/home/nexus/Scripts"
local terminal        = "ghostty"
local terminal_exec   = terminal .. " -e"
local menu            = "tofi-drun --drun-launch=true"
local amenu           = "tofi-run --drun-launch=true"
local lock_cmd        = scripts .. "/hyprlock.sh " .. gowall_theme
local fileManager     = "Thunar"
local cli_fileManager = terminal_exec .. " yazi"

-------------------
---- HEADLESS -----
-------------------

hl.monitor({
    output   = "HEADLESS-2",
    mode     = "1920x1080@60",
    position = "-1920x0",
    scale    = 1,
})

-------------------
---- AUTOSTART ----
-------------------

-- exec-once equivalents (run once on session start)
hl.on("hyprland.start", function()
    hl.exec_cmd(lock_cmd .. " --immediate-render")
    hl.exec_cmd("xembedsniproxy")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprctl setcursor catppuccin-frappe-sapphire 24")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("mako")
    hl.exec_cmd("dex -a")
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("clipse -listen")
    hl.exec_cmd("musicpresence")
    hl.exec_cmd("udiskie --tray")
    hl.exec_cmd(scripts .. "/wayland_slideshow.sh ~/Pictures/slideshow/ " .. gowall_theme)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
end)

-- exec equivalents (run on start and reload — guarded with pidof)
local function ensure_procs()
    hl.exec_cmd("pidof waybar || waybar")
    hl.exec_cmd("pidof bongocat || sleep 5s && bongocat --config ~/.config/bongocat.conf --watch-config")
end
hl.on("hyprland.start", ensure_procs)
hl.on("config.reloaded", ensure_procs)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in          = 10,
        gaps_out         = 14,
        border_size      = 1,
        col              = {
            active_border   = theme.blue,
            inactive_border = theme.mantle,
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },
})

hl.config({
    decoration = {
        rounding         = 4,

        active_opacity   = 0.85,
        inactive_opacity = 0.7,

        shadow           = {
            enabled      = true,
            range        = 10,
            render_power = 10,
            color        = "rgba(1a1a1a88)",
        },

        blur             = {
            size           = 10,
            passes         = 3,
            vibrancy       = 0.1696,
            ignore_opacity = false,
        },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "default", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    group = {
        col = {
            border_active   = theme.blue,
            border_inactive = theme.mantle,
        },
        merge_floated_into_tiled_on_groupbar = true,
        groupbar = {
            stacked     = true,
            font_family = "FiraCode Nerd Font",
            font_size   = 12,
            height      = 15,
            col         = {
                active   = theme.mantle,
                inactive = theme.surface0,
            },
            gradients   = true,
            text_color  = theme.text,
        },
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        kb_options   = "ctrl:nocaps",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad     = {
            disable_while_typing = true,
            clickfinger_behavior = true,
            tap_to_click         = false,
            natural_scroll       = true,
            scroll_factor        = 0.2,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.config({
    misc = {
        vrr                     = 0,
        col                     = { splash = theme.blue },

        font_family             = "FiraCode Nerd Font",
        splash_font_family      = "FiraCode Nerd Font",

        middle_click_paste      = false,
        disable_hyprland_logo   = true,
        enable_anr_dialog       = false,
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})

-----------------------
---- KEYBINDINGS ------
-----------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.exec_cmd(lock_cmd))
hl.bind(mainMod .. " + SHIFT + q", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + SHIFT + q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + e", hl.dsp.exit())
hl.bind(mainMod .. " + v", hl.dsp.exec_cmd(terminal_exec .. " --class=com.local.clipse clipse"))

hl.bind(mainMod .. " + d", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + d", hl.dsp.exec_cmd(amenu))

-- Slideshow controls
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("pkill --signal SIGUSR1 --echo -f wayland_slideshow.sh"))
hl.bind(mainMod .. " + CTRL + ESCAPE",
    hl.dsp.exec_cmd("pkill wayland_slidesh; " .. scripts .. "/wayland_slideshow.sh ~/Pictures/slideshow " .. gowall_theme))
hl.bind(mainMod .. " + SHIFT + ESCAPE",
    hl.dsp.exec_cmd("pkill wayland_slidesh; " .. scripts .. "/wayland_slideshow.sh ~/Pictures/sfw " .. gowall_theme))
hl.bind(mainMod .. " + ALT + ESCAPE",
    hl.dsp.exec_cmd("pkill wayland_slidesh; " ..
        scripts .. "/wayland_slideshow.sh ~/Pictures/animated_slideshow " .. gowall_theme))

hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd(scripts .. "/gamemode.sh"))

hl.bind(mainMod .. " + n", hl.dsp.exec_cmd(cli_fileManager))
hl.bind(mainMod .. " + SHIFT + n", hl.dsp.exec_cmd(fileManager))

-- Media
hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd("playerctl --player=spotify,vlc,audacious play-pause"))
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("playerctl --player=spotify,vlc,audacious previous"))
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("playerctl --player=spotify,vlc,audacious next"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd(scripts .. "/wayland_ss.sh"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(scripts .. "/wayland_ss_select.sh"))

-- Window toggles
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.layout("swapsplit"))

-- Group controls
hl.bind(mainMod .. " + s", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + j", hl.dsp.group.next())
hl.bind(mainMod .. " + CTRL + k", hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + down", hl.dsp.group.next())
hl.bind(mainMod .. " + CTRL + up", hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + SHIFT + j", hl.dsp.group.move_window({ forward = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + k", hl.dsp.group.move_window({ forward = false }))
hl.bind(mainMod .. " + CTRL + SHIFT + down", hl.dsp.group.move_window({ forward = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + up", hl.dsp.group.move_window({ forward = false }))

-- Focus movement
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))

-- Window movement (group-aware — equivalent to movewindoworgroup)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r", group_aware = true }))

-- Resize submap
hl.bind(mainMod .. " + r", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + h", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + j", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true })
    hl.bind("SHIFT + k", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })
    hl.bind("SHIFT + l", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + r", hl.dsp.submap("reset"))
end)

-- Passthrough submap (remote desktop input capture)
hl.bind(mainMod .. " + CTRL + SHIFT + escape", hl.dsp.submap("passthrough"))
hl.define_submap("passthrough", function()
    hl.bind("CTRL + escape", hl.dsp.submap("reset"))
end)

-- Workspaces 1–10 (key 0 = workspace 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.workspace.toggle_special("special"))
hl.bind(mainMod .. " + SHIFT + CTRL + s", hl.dsp.window.move({ workspace = "special" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------
---- WINDOWS, LAYERS, WORKSPACES -----
--------------------------------------

-- Suppress maximize requests from all apps
hl.window_rule({
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Hide empty XWayland helper windows (Wine tray/menu helpers, etc.)
hl.window_rule({
    match            = {
        xwayland      = true,
        title         = "^$",
        class         = "^$",
        initial_class = "^$",
        initial_title = "^$",
    },
    opacity          = "0.0 override 0.0 override",
    no_blur          = true,
    no_initial_focus = true,
})

-- Idle inhibit rules
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "always" })
hl.window_rule({ match = { class = "^xclicker$" }, idle_inhibit = "always" })
hl.window_rule({ match = { class = "^steam$" }, idle_inhibit = "always" })
hl.window_rule({ match = { title = "^paru.*$" }, idle_inhibit = "always" })

-- Force full opacity for media/games/UI-critical apps
local full_opacity = "^(feh|vimiv|net-runelite-client-RuneLite|jagexlauncher.exe"
    .. "|virt-manager|qemu|remote-viewer|qv4l2|gimp|swayimg|obsidian|firefox"
    .. "|org.vinegarhq.Sober|robloxstudiobeta.exe|org.remmina.Remmina|mpv|vlc"
    .. "|krita|com-ca-directory-jxplorer-JXplorer|steam_app_881100"
    .. "|rsi launcher.exe|org.jellyfin.JellyfinDesktop)$"
hl.window_rule({ match = { class = full_opacity }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = "^Battle.net$" }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = "^Black & White$" }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = "^Diablo II: Resurrected$" }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { initial_title = "^Discord Popout$" }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { class = "^org.darktable.darktable$" }, opacity = "1.0 override 1.0 override" })

-- Floating / tiling overrides
hl.window_rule({ match = { class = "^xclicker$", float = true }, tile = true })
hl.window_rule({ match = { class = "^com-ca-directory-jxplorer-JXplorer$", float = true }, tile = true })
hl.window_rule({ match = { title = "^Diablo II: Resurrected$", float = true }, tile = true })
hl.window_rule({ match = { initial_class = "steam", initial_title = "Steam" }, tile = true })
hl.window_rule({ match = { class = "^twintaillauncher$" }, tile = true })
hl.window_rule({ match = { class = "^rsi launcher.exe$" }, tile = true })
hl.window_rule({ match = { class = "^peazip$" }, float = true })

-- Battle.net apps
hl.window_rule({ match = { title = "^Diablo II: Resurrected$" }, border_size = 0, no_blur = true })
hl.window_rule({ match = { initial_title = "^Battle.net Login$" }, float = true })

-- KDE file-picker
hl.window_rule({
    match      = { class = "^org.freedesktop.impl.portal.desktop.kde$", title = "^.*(File|Save).*$" },
    float      = true,
    center     = true,
    dim_around = true,
    min_size   = "1500 750",
})

-- Clipse floating clipboard manager
hl.window_rule({
    match        = { class = "com.local.clipse" },
    float        = true,
    stay_focused = true,
    dim_around   = true,
    size         = "750 600",
})

-- GTK desktop portal (file picker, etc.)
hl.window_rule({
    match    = { class = "^xdg-desktop-portal-gtk$" },
    max_size = "1800 800",
    float    = true,
    center   = true,
})

-- Thunderbird floating dialogs
hl.window_rule({ match = { float = true, class = "^org.mozilla.Thunderbird$" }, max_size = "1600 800" })
hl.window_rule({
    match = { class = "^org.mozilla.Thunderbird$", title = "^Write:\\s.+$" },
    float = true,
    size =
    "1100 700"
})
hl.window_rule({
    match = { class = "^org.mozilla.Thunderbird$", title = "^(.*)(Reminders)(.*)$" },
    float = true,
    size =
    "900 400"
})

-- Zoom
hl.window_rule({ match = { class = "^zoom$" }, opacity = "1.0 override 1.0 override", border_size = 0 })
hl.window_rule({ match = { class = "^zoom$", float = true }, stay_focused = true })

-- IDA Pro loading dialog
hl.window_rule({
    match    = { class = "com.hex-rays.*", initial_title = "^Please wait...$" },
    float    = true,
    size     = "350 100",
    max_size = "600 250",
})

-- Udiskie tray popups
hl.window_rule({
    match    = { class = "^udiskie$" },
    max_size = "1800 800",
    float    = true,
    center   = true,
})

-- Xwaylandvideobridge hidden window
hl.window_rule({
    match            = { class = "^xwaylandvideobridge$" },
    opacity          = "0.0 override",
    no_anim          = true,
    no_initial_focus = true,
    max_size         = "1 1",
    no_blur          = true,
    no_focus         = true,
})
