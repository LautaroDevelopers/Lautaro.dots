#!/usr/bin/env bash
# Sigue el now-playing de TODOS los reproductores MPRIS activos a la vez.
#
# `playerctl --follow -p <nombre>` en esta versión (v2.4.1) NO respeta el
# filtro -p: devuelve metadata del player que sea que esté "más activo" en
# ese momento, sin importar cuál pediste (confirmado comparando contra la
# consulta puntual, que sí es correcta). Por eso acá no usamos --follow en
# absoluto: refrescamos con consultas puntuales (`playerctl -p X metadata`)
# cada 2s, que son lentas de reaccionar pero confiables.
#
# El widget puede pasar de uno a otro con flechas; el índice elegido se
# persiste en cache y este proceso reacciona a SIGUSR1 para refrescar y
# re-emitir al toque en vez de esperar al próximo poll.

CACHE_ART_DIR="$HOME/.cache/eww-media-art"
IDX_CACHE="$HOME/.cache/eww-media-index"
SELECTED_CACHE="$HOME/.cache/eww-media-selected-player"
mkdir -p "$CACHE_ART_DIR"
echo $$ >"$HOME/.cache/eww-media-listen.pid"

declare -A TITLE ARTIST STATUS ART LAST_ART_URL
declare -a ORDER

SEP=$'\x1f'

art_for() {
    local name="$1" url="$2" hash file
    [[ -z "$url" ]] && { printf ''; return; }
    if [[ "${LAST_ART_URL[$name]}" == "$url" ]]; then
        printf '%s' "${ART[$name]}"
        return
    fi
    hash=$(printf '%s' "$name" | md5sum | cut -d' ' -f1)
    file="$CACHE_ART_DIR/$hash.jpg"
    if [[ "$url" == http* ]]; then
        curl -s -m 5 -o "${file}.tmp" "$url" && mv "${file}.tmp" "$file"
        LAST_ART_URL["$name"]="$url"
        printf '%s' "$file"
    elif [[ "$url" == file://* ]]; then
        LAST_ART_URL["$name"]="$url"
        printf '%s' "${url#file://}"
    fi
}

refresh_all() {
    local active
    mapfile -t active < <(playerctl -l 2>/dev/null)

    for name in "${active[@]}"; do
        if [[ -z "${TITLE[$name]+x}" ]]; then
            ORDER+=("$name")
        fi
    done

    local new_order=()
    for name in "${ORDER[@]}"; do
        if printf '%s\n' "${active[@]}" | grep -qx "$name"; then
            new_order+=("$name")
        else
            unset "TITLE[$name]" "ARTIST[$name]" "STATUS[$name]" "ART[$name]" "LAST_ART_URL[$name]"
        fi
    done
    ORDER=("${new_order[@]}")

    for name in "${ORDER[@]}"; do
        local line title artist status arturl
        line=$(playerctl -p "$name" metadata --format "{{title}}${SEP}{{artist}}${SEP}{{status}}${SEP}{{mpris:artUrl}}" 2>/dev/null)
        IFS="$SEP" read -r title artist status arturl <<<"$line"
        TITLE["$name"]="$title"
        ARTIST["$name"]="$artist"
        STATUS["$name"]="$status"
        ART["$name"]=$(art_for "$name" "$arturl")
    done
}

emit() {
    local count=${#ORDER[@]}
    local idx
    idx=$(cat "$IDX_CACHE" 2>/dev/null || echo 0)

    if ((count == 0)); then
        printf '' >"$SELECTED_CACHE"
        printf '{"title":"","artist":"","status":"Stopped","art":"","player":"","index":0,"count":0,"dots":[]}\n'
        return
    fi

    ((idx < 0)) && idx=0
    ((idx >= count)) && idx=$((count - 1))
    echo "$idx" >"$IDX_CACHE"

    local p="${ORDER[$idx]}"
    printf '%s' "$p" >"$SELECTED_CACHE"

    python3 -c '
import json, sys
title, artist, status, art, player, idx, count = sys.argv[1:8]
clean_title = title
if artist and " - " in title:
    prefix, _, rest = title.partition(" - ")
    if artist.lower() in prefix.lower() or prefix.lower() in artist.lower():
        clean_title = rest.strip()
idx, count = int(idx), int(count)
print(json.dumps({
    "title": clean_title, "artist": artist, "status": status, "art": art,
    "player": player, "index": idx, "count": count,
    "dots": [i == idx for i in range(count)],
}))
' "${TITLE[$p]}" "${ARTIST[$p]}" "${STATUS[$p]}" "${ART[$p]}" "$p" "$idx" "$count"
}

cycle_emit() {
    # ignora señales nuevas mientras esta animación está en curso: si no,
    # una llega a mitad del sleep y la ejecución queda entreverada con
    # otra, y el reveal=true final nunca se aplica.
    trap '' USR1
    eww update media_reveal=false 2>/dev/null
    sleep 0.15
    refresh_all
    emit
    eww update media_reveal=true 2>/dev/null
    trap cycle_emit USR1
}

trap cycle_emit USR1

refresh_all
emit

while true; do
    sleep 2 &
    wait $!
    refresh_all
    emit
done
