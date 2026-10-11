#!/usr/bin/env bash
# Run by server.sh before Luanti starts: picks the gateway micro:bit and proves it accepts writes.
set -euo pipefail

conf="${1:?Usage: $0 SERVER_CONF_COPY}"
dev="${MICROBIT:-}"

fail() {
  echo "$1" >&2
  echo "Plug in the gateway micro:bit, choose one with MICROBIT=/dev/ttyACM0, or start with MICROBIT=none." >&2
  exit 1
}

if [[ "$dev" == none ]]; then
  echo "edu_gold_serial = none" >>"$conf"
  echo "micro:bit: none (messages go to server.log only)"
  exit 0
fi
if [[ -z "$dev" ]]; then
  shopt -s nullglob
  found=(/dev/serial/by-id/*micro*bit*)
  if ((${#found[@]} == 0)); then fail "No micro:bit found."; fi
  if ((${#found[@]} > 1)); then fail "Several micro:bits found: ${found[*]}"; fi
  dev="${found[0]}"
fi
dev="$(readlink -f -- "$dev")"
# Without clocal, Luanti's open() of the tty can wait for a carrier and freeze the whole server.
if ! timeout 2 stty -F "$dev" 115200 raw -echo clocal; then
  fail "micro:bit on $dev is not responding (stty). Your user must be in the dialout group."
fi
if ! timeout 2 tee -- "$dev" <<<PING >/dev/null; then
  fail "micro:bit on $dev is not responding."
fi
echo "edu_gold_serial = $dev" >>"$conf"
echo "micro:bit: $dev"
