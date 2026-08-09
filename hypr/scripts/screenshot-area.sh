#!/usr/bin/env bash
# Area screenshot: select a region with slurp, save it under ~/Pictures with
# a timestamped name, and copy it to the clipboard for pasting elsewhere.
set -euo pipefail

out_dir="$HOME/Pictures"
mkdir -p "$out_dir"
out_file="$out_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

geometry=$(slurp) || exit 0
grim -g "$geometry" "$out_file"
wl-copy < "$out_file"
notify-send "Captura guardada" "$out_file"
