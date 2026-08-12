-- Machine-specific config  (not tracked by git / stow-ignored)
-- ThinkPad P14s Gen 3 (21AK0028US) — Intel 12th gen / Alder Lake-P
-- Override gowall_theme here if needed:
-- local gowall_theme = "cat-latte"

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

--------------------
---- KEYBINDINGS ---
--------------------

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("light -A 5"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("light -U 5"))

------------------
---- TOUCHPAD ----
-- Device: SYNA8018:00 06CB:CE67 Touchpad (Synaptics RMI4 over SMBus)
-- NOTE: old config used pnp0c50 name from Pangolin 12 — wrong on P14s Gen 3
------------------

hl.device({
    name                 = "syna8018:00-06cb:ce67-touchpad",
    sensitivity          = 0.25,
    natural_scroll       = false,
    scroll_factor        = 0.4,
    -- Disable while typing uses keyboard-pairing via libinput DWT.
    -- On P14s Gen 3 the i8042 "AT Translated Set 2 keyboard" is the paired
    -- device. A libinput bug causes all i8042 devices to drop when the DWT
    -- palm-timeout fires. Disabling dwt here prevents the cascade that makes
    -- the internal keyboard stop responding until reboot.
    disable_while_typing = false,
})

--------------------
---- TRACKPOINT ----
-- Device: TPPS/2 IBM TrackPoint (PS/2 via psmouse/serio1)
-- psmouse was blacklisted on the old Pangolin — removed from grub cmdline.
-- Requires psmouse module loaded (see /etc/modules-load.d/psmouse.conf).
--------------------

hl.device({
    name          = "tpps/2-ibm-trackpoint",
    sensitivity   = 0,
    accel_profile = "adaptive",
})
