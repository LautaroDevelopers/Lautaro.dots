#!/usr/bin/env python3
# Adapta la salida de scripts/audio-volume-listen.sh (volumen del
# dispositivo de hardware activo -parlantes o HDMI-, no del sink virtual
# de EasyEffects) al JSON que espera un módulo custom de waybar.
import json
import sys

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    d = json.loads(line)
    vol, muted = d["volume"], d["muted"]
    if muted:
        icon = "󰝟"
    elif vol > 60:
        icon = "󰕾"
    elif vol > 0:
        icon = "󰖀"
    else:
        icon = "󰕿"
    width = 8
    pos = round((0 if muted else vol) / 100 * (width - 1))
    segments = []
    for i in range(width):
        if i < pos:
            segments.append("<span color='#7fb4ca'>━</span>")
        elif i == pos:
            segments.append("<span color='#ffffff'>●</span>")
        else:
            segments.append("<span color='#3f3f46'>━</span>")
    bar = "".join(segments)

    out = {
        "text": f"{icon} {bar}",
        "tooltip": f"{vol}% ({'silenciado' if muted else 'activo'})",
        "class": "muted" if muted else "unmuted",
        "percentage": vol,
    }
    print(json.dumps(out), flush=True)
