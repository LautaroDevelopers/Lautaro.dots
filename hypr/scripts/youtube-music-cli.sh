#!/usr/bin/env bash
# Wrapper for @involvex/youtube-music-cli.
# The CLI spawns mpv with `detached: true`, so mpv survives as an orphan
# when the terminal window is closed (SIGHUP isn't forwarded to it, and
# the CLI's own SIGINT/SIGTERM cleanup never runs on SIGHUP). This wrapper
# explicitly kills any mpv child of the CLI process on exit, regardless
# of how the wrapper itself gets terminated.

NODE_BIN=/home/lautaro/.local/share/fnm/aliases/default/bin/node
CLI_JS=/home/lautaro/.local/share/fnm/aliases/default/lib/node_modules/@involvex/youtube-music-cli/dist/source/cli.js

"$NODE_BIN" "$CLI_JS" "$@" <&0 &
NODE_PID=$!

cleanup() {
	pkill -P "$NODE_PID" -x mpv 2>/dev/null
	kill "$NODE_PID" 2>/dev/null
}
trap cleanup EXIT INT TERM HUP

wait "$NODE_PID"
cleanup
