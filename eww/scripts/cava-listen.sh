#!/usr/bin/env bash
# Streams cava's raw bar values and reformats each frame as a JSON array
# for eww's deflisten. Uses pure bash (no subprocess per frame) since
# cava emits many frames per second.

cava -p "$HOME/.config/eww/scripts/cava.conf" |
while IFS=';' read -ra bars; do
	out="["
	first=1
	for v in "${bars[@]}"; do
		[[ -z "$v" ]] && continue
		if [[ $first -eq 1 ]]; then
			out+="$v"
			first=0
		else
			out+=",$v"
		fi
	done
	out+="]"
	printf '%s\n' "$out"
done