#!/usr/bin/env bash
# Traduce un nombre de salida de Hyprland (ej. "eDP-1") al índice de
# monitor que usa eww (--screen). eww no conoce los nombres de salida de
# Wayland, solo un índice GDK con un "nombre" que en realidad es el
# modelo EDID (ej. "0x03F8" o "MStar Demo") — que sí coincide con el
# campo "model" que reporta hyprctl para la misma salida. Correlacionamos
# por ahí, ya que es el único dato en común entre ambos mundos.
OUTPUT_NAME="$1"

MODEL=$(hyprctl monitors -j | python3 -c "
import json, sys
name = sys.argv[1]
for m in json.load(sys.stdin):
    if m['name'] == name:
        print(m['model'])
        break
" "$OUTPUT_NAME")

[[ -z "$MODEL" ]] && exit 1

# eww valida el nombre de la ventana antes que el monitor, así que
# necesitamos un nombre de ventana real para forzar el error de "monitor
# inválido" y sacarle la lista de esa forma. Usamos la ventana dummy
# __monitor_probe__ para no interferir con ventanas reales.
eww open __monitor_probe__ --screen 999999 2>&1 |
    grep -F "] $MODEL" |
    grep -oP '(?<=\[)\d+(?=\])' |
    head -1
