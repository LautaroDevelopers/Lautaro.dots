#!/usr/bin/env bash
# Ajusta el volumen del dispositivo de hardware activo (no el sink virtual
# de EasyEffects, que es solo paso intermedio).
PCT="$1"

SPEAKERS="alsa_output.pci-0000_00_1b.0.analog-stereo"
HDMI="alsa_output.pci-0000_00_03.0.hdmi-stereo"

TARGET=$(cat "$HOME/.cache/eww-audio-output" 2>/dev/null || echo "speakers")
SINK=$([[ "$TARGET" == "hdmi" ]] && echo "$HDMI" || echo "$SPEAKERS")

pactl set-sink-volume "$SINK" "${PCT}%"
