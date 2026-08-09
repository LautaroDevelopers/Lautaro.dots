#!/usr/bin/env python3
"""Espeja el volumen/mute de easyeffects_sink (que es lo que mueve el
slider nativo de waybar, @DEFAULT_SINK@) hacia el dispositivo de
hardware real (parlantes/HDMI), reusando audio-volume-set.sh y
audio-mute-toggle.sh. Así el slider sigue viéndose y comportándose
igual, pero el volumen que realmente cambia es el audible."""
import re
import subprocess

SCRIPTS_DIR = "/home/lautaro/.config/eww/scripts"
AUDIO_SET = f"{SCRIPTS_DIR}/audio-volume-set.sh"
MUTE_TOGGLE = f"{SCRIPTS_DIR}/audio-mute-toggle.sh"


def get_easyeffects_volume():
    out = subprocess.run(
        ["pactl", "get-sink-volume", "easyeffects_sink"],
        capture_output=True, text=True,
    ).stdout
    match = re.search(r"(\d+)%", out)
    return int(match.group(1)) if match else None


def get_easyeffects_muted():
    out = subprocess.run(
        ["pactl", "get-sink-mute", "easyeffects_sink"],
        capture_output=True, text=True,
    ).stdout
    return "yes" in out


def main():
    last_vol = get_easyeffects_volume()
    last_muted = get_easyeffects_muted()

    proc = subprocess.Popen(
        ["pactl", "subscribe"], stdout=subprocess.PIPE, text=True,
    )
    for line in proc.stdout:
        if "'change' on sink" not in line:
            continue

        vol = get_easyeffects_volume()
        if vol is not None and vol != last_vol:
            last_vol = vol
            subprocess.run([AUDIO_SET, str(vol)])

        muted = get_easyeffects_muted()
        if muted != last_muted:
            last_muted = muted
            subprocess.run([MUTE_TOGGLE])


if __name__ == "__main__":
    main()
