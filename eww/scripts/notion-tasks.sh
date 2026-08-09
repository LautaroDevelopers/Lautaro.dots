#!/usr/bin/env bash
# Trae las tareas pendientes (Estado != Listo) de la tabla "Tareas" en
# Notion, ordenadas por últimas editadas. El token vive fuera de este
# repo (~/.config/notion-widget/token, chmod 600) para que nunca termine
# versionado si este dotfiles se hace público.

TOKEN_FILE="$HOME/.config/notion-widget/token"
DATA_SOURCE="221e8d5f-3b61-80cf-9c27-000b48a09225"

[[ ! -f "$TOKEN_FILE" ]] && { echo "[]"; exit 0; }
TOKEN=$(<"$TOKEN_FILE")

curl -s -m 10 -X POST "https://api.notion.com/v1/data_sources/$DATA_SOURCE/query" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Notion-Version: 2025-09-03" \
    -H "Content-Type: application/json" \
    -d '{
        "filter": {"property": "Estado", "status": {"does_not_equal": "Listo"}},
        "sorts": [{"timestamp": "last_edited_time", "direction": "descending"}],
        "page_size": 6
    }' | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("[]")
    sys.exit()

out = []
for r in d.get("results", []):
    p = r.get("properties", {})
    nombre = "".join(t.get("plain_text", "") for t in p.get("Nombre", {}).get("title", [])) or "(sin título)"
    estado_obj = p.get("Estado", {}).get("status")
    estado = estado_obj["name"] if estado_obj else ""
    prioridad_obj = p.get("Prioridad", {}).get("select")
    prioridad = prioridad_obj["name"] if prioridad_obj else ""
    date_obj = p.get("Fecha", {}).get("date")
    fecha = date_obj["start"][:10] if date_obj else ""
    out.append({
        "id": r.get("id", ""), "name": nombre, "estado": estado,
        "prioridad": prioridad, "fecha": fecha, "url": r.get("url", ""),
    })
print(json.dumps(out))
'
