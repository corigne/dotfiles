#!/bin/bash

STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)

[ -z "$STATUS" ] || [ -z "$CAPACITY" ] && echo '{}' && exit 1

if [ "$CAPACITY" -le 15 ] && [ "$STATUS" = "Discharging" ]; then
    CLASS="critical"
elif [ "$CAPACITY" -le 30 ] && [ "$STATUS" = "Discharging" ]; then
    CLASS="warning"
else
    CLASS="${STATUS,,}"  # lowercase: charging, discharging, full
fi

case "$STATUS" in
    Charging) ICON="󰂄" ;;
    Full)     ICON="󰚥" ;;
    *)
        icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
        idx=$(( CAPACITY / 10 ))
        [ "$idx" -gt 10 ] && idx=10
        ICON="${icons[$idx]}"
        ;;
esac

printf '{"text":"<span size='\''large'\''>%s</span>","tooltip":"%s%% | %s","class":"%s"}\n' \
    "$ICON" "$CAPACITY" "$STATUS" "$CLASS"
