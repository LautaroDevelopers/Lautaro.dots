#!/usr/bin/env bash
# Emite el volumen/mute del dispositivo de hardware activo (parlantes o
# HDMI, según lo elegido en el widget) y se actualiza en tiempo real
# escuchando eventos de pactl (sin polling).

SPEAKERS="alsa_output.pci-0000_00_1b.0.analog-stereo"
HDMI="alsa_output.pci-0000_00_03.0.hdmi-stereo"

current_sink() {
    local target
    target=$(cat "$HOME/.cache/eww-audio-output" 2>/dev/null || echo "speakers")
    [[ "$target" == "hdmi" ]] && echo "$HDMI" || echo "$SPEAKERS"
}

emit() {
    local sink vol muted
    sink=$(current_sink)
    vol=$(pactl get-sink-volume "$sink" 2>/dev/null | grep -oP '\d+(?=%)' | head -1)
    muted=$(pactl get-sink-mute "$sink" 2>/dev/null | grep -q "yes" && echo true || echo false)
    printf '{"volume":%s,"muted":%s}\n' "${vol:-0}" "$muted"
}

emit

pactl subscribe 2>/dev/null | while read -r line; do
    [[ "$line" == *"'change' on sink"* ]] && emit
done
