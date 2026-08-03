-- Machine-specific config  (not tracked by git / stow-ignored)
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

hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("light -A 5"))
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("light -U 5"))

------------------
---- TOUCHPAD ----
------------------

hl.device({
    name           = "pnp0c50:0b-0911:5288-touchpad",
    sensitivity    = -0.1,
    natural_scroll = false,
})
