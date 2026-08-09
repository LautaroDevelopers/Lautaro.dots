#!/usr/bin/env bash
# Mutea/desmutea el dispositivo de hardware activo (no el sink virtual de
# EasyEffects).
SPEAKERS="alsa_output.pci-0000_00_1b.0.analog-stereo"
HDMI="alsa_output.pci-0000_00_03.0.hdmi-stereo"

TARGET=$(cat "$HOME/.cache/eww-audio-output" 2>/dev/null || echo "speakers")
SINK=$([[ "$TARGET" == "hdmi" ]] && echo "$HDMI" || echo "$SPEAKERS")

pactl set-sink-mute "$SINK" toggle
