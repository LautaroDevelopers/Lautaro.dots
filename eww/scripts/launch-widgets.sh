#!/usr/bin/env bash
# Abre los widgets de eww repartidos dinámicamente según los monitores
# conectados: el panel interno del portátil (eDP-*, convención estándar
# en Linux) recibe el set "personal"; cualquier otro monitor recibe el
# set "work". Con un solo monitor conectado, todo va junto ahí.
#
# Pensado para no tener nombres de monitor hardcodeados: agregar/sacar un
# monitor no requiere tocar este script.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PERSONAL_WIDGETS=(topleft media visualizer audio)
WORK_WIDGETS=(work-clock tasks repos)
# subset de WORK_WIDGETS que se abre si solo hay un monitor: sin
# work-clock, porque ahí ya está el reloj de topleft.
WORK_WIDGETS_SOLO=(tasks repos)

# Esperamos al SOCKET del daemon directamente, no a un comando `eww`
# cliente: si el daemon todavía no existe, cualquier `eww <subcomando>`
# (incluido `active-windows`) se auto-inicia como daemon propio en vez
# de fallar, generando un segundo daemon fantasma que compite con el
# real. Chequear el archivo del socket no tiene ese efecto secundario.
for i in $(seq 1 40); do
    socket=$(ls /run/user/"$(id -u)"/eww-server_* 2>/dev/null | head -1)
    [[ -S "$socket" ]] && break
    sleep 0.25
done
sleep 0.3

mapfile -t outputs < <(hyprctl monitors -j | python3 -c "import json,sys; [print(m['name']) for m in json.load(sys.stdin)]")

internal=""
external=()
for name in "${outputs[@]}"; do
    if [[ "$name" == eDP-* ]]; then
        internal="$name"
    else
        external+=("$name")
    fi
done
[[ -z "$internal" ]] && internal="${outputs[0]}"

open_on() {
    local output="$1"
    shift
    local idx
    idx=$("$SCRIPT_DIR/monitor-index.sh" "$output")
    [[ -z "$idx" ]] && return
    for w in "$@"; do
        eww open "$w" --screen "$idx" 2>/dev/null
    done
}

if ((${#external[@]} == 0)); then
    open_on "$internal" "${PERSONAL_WIDGETS[@]}" "${WORK_WIDGETS_SOLO[@]}"
else
    open_on "$internal" "${PERSONAL_WIDGETS[@]}"
    open_on "${external[0]}" "${WORK_WIDGETS[@]}"
fi
