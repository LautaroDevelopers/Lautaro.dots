#!/usr/bin/env bash
# Cambia de reproductor seleccionado en el widget de media (flechas de
# click). El flock evita que un doble-click dispare dos animaciones a la
# vez; la animación en sí la maneja el listener (single-threaded), acá
# solo movemos el índice y avisamos por señal.
DIR="$1"

LOCK="$HOME/.cache/eww-media-cycle.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

IDX_CACHE="$HOME/.cache/eww-media-index"
PID_FILE="$HOME/.cache/eww-media-listen.pid"

IDX=$(cat "$IDX_CACHE" 2>/dev/null || echo 0)

case "$DIR" in
    left)
        IDX=$((IDX - 1))
        TRANS="slideright"
        ;;
    right)
        IDX=$((IDX + 1))
        TRANS="slideleft"
        ;;
    *) exit 0 ;;
esac
((IDX < 0)) && IDX=0
echo "$IDX" >"$IDX_CACHE"

eww update media_transition="$TRANS" 2>/dev/null

PID=$(cat "$PID_FILE" 2>/dev/null)
[[ -n "$PID" ]] && kill -USR1 "$PID" 2>/dev/null
