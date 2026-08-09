#!/usr/bin/env bash
PLAYER=$(cat "$HOME/.cache/eww-media-selected-player" 2>/dev/null)
ARGS=()
[[ -n "$PLAYER" ]] && ARGS=(-p "$PLAYER")

pos=$(playerctl "${ARGS[@]}" position 2>/dev/null)
length_us=$(playerctl "${ARGS[@]}" metadata mpris:length 2>/dev/null)

if [[ -n "$pos" && -n "$length_us" && "$length_us" != "0" ]]; then
    awk -v p="$pos" -v l="$length_us" 'BEGIN {
        length_s = l / 1000000
        pct = (length_s > 0) ? int(p * 100 / length_s) : 0
        if (pct > 100) pct = 100
        if (pct < 0) pct = 0
        print pct
    }'
else
    echo 0
fi
