#!/usr/bin/env bash
easyeffects --gapplication-service &

for i in $(seq 1 20); do
	pactl list short sinks 2>/dev/null | grep -q easyeffects_sink && break
	sleep 0.5
done

easyeffects -l anti-clipping >/dev/null 2>&1
pactl set-default-sink easyeffects_sink >/dev/null 2>&1

# EasyEffects no enlaza su sink al hardware por si solo; lo conectamos a la
# salida que corresponda (persistida por el switcher del widget de audio).
TARGET=$(cat "$HOME/.cache/eww-audio-output" 2>/dev/null || echo "speakers")
/home/lautaro/.config/eww/scripts/audio-switch.sh "$TARGET"