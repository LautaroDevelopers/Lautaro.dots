#!/usr/bin/env bash
# Cambia la salida física de audio (parlantes / HDMI) sin tocar el sink por
# defecto (que se queda siempre en easyeffects_sink para no perder el limitador).
TARGET="$1"

SPEAKERS="alsa_output.pci-0000_00_1b.0.analog-stereo"
HDMI="alsa_output.pci-0000_00_03.0.hdmi-stereo"

case "$TARGET" in
    speakers) NEW="$SPEAKERS"; OLD="$HDMI" ;;
    hdmi) NEW="$HDMI"; OLD="$SPEAKERS" ;;
    *) exit 1 ;;
esac

pw-link -d "easyeffects_sink:monitor_FL" "${OLD}:playback_FL" 2>/dev/null
pw-link -d "easyeffects_sink:monitor_FR" "${OLD}:playback_FR" 2>/dev/null
pw-link "easyeffects_sink:monitor_FL" "${NEW}:playback_FL" 2>/dev/null
pw-link "easyeffects_sink:monitor_FR" "${NEW}:playback_FR" 2>/dev/null

echo "$TARGET" >"$HOME/.cache/eww-audio-output"
eww update audio_output="$TARGET" 2>/dev/null

VOL=$(pactl get-sink-volume "$NEW" 2>/dev/null | grep -oP '\d+(?=%)' | head -1)
MUTED=$(pactl get-sink-mute "$NEW" 2>/dev/null | grep -q "yes" && echo true || echo false)
eww update audio_vol="{\"volume\":${VOL:-0},\"muted\":${MUTED}}" 2>/dev/null
