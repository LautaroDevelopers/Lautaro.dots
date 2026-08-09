#!/usr/bin/env bash
raw=$(curl -s -m 5 'https://wttr.in/?format=%c|%t|%C' 2>/dev/null | tr -d '\n')
IFS='|' read -r icon temp cond <<<"$raw"

python3 -c '
import json, sys
icon, temp, cond = sys.argv[1:4]
temp = temp.lstrip("+")
print(json.dumps({"icon": icon or "?", "temp": temp or "N/A", "cond": cond or ""}))
' "$icon" "$temp" "$cond"