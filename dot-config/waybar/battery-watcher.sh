#!/bin/bash
# Monitors UPower for any device state change and signals waybar
# to immediately refresh the custom/battery module (SIGRTMIN+8).

upower --monitor | while IFS= read -r line; do
    echo "$line" | grep -q "device changed" || continue
    WAYBAR_PID=$(pgrep -x waybar | head -1)
    [ -n "$WAYBAR_PID" ] && kill -SIGRTMIN+8 "$WAYBAR_PID"
done
