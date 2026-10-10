#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (($# > 1)); then
  echo "Usage: $0 [SAVED_WORLD_NAME]" >&2
  exit 1
fi
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  echo "Usage: $0 [SAVED_WORLD_NAME]"
  echo "No name: start a brand new teaching world. Name: start a copy of that saved world."
  exit 0
fi
source "$worlds_dir/luanti-env.sh"
luanti_require
if ! luanti_has_voxelibre; then
  echo "VoxeLibre is missing. Run ./luanti-worlds/setup-host.sh first." >&2
  exit 1
fi
source "$worlds_dir/host-session.sh"
# Path override is only for integration checks.
if [[ -n "${LUANTI_WORLD_DIR:-}" ]]; then
  world_dir="$LUANTI_WORLD_DIR"
elif (($#)); then
  world_dir="$(worlds_py load "$1")"
else
  world_dir="$(worlds_py new)"
fi
source "$worlds_dir/world-session.sh"
if [[ -z "${LUANTI_WORLD_DIR:-}" ]]; then
  bash "$worlds_dir/link-world.sh" "$world_dir"
fi
# A sandboxed Luanti cannot read this repository, so the config travels with the world.
cp -- "$worlds_dir/server.conf" "$world_dir/server.conf"
echo "Session: $(basename -- "$world_dir")"
echo "Starting Programming Village on UDP port 30001."
echo "On this laptop: Join Game -> address 127.0.0.1, port 30001, name ondra."
echo "On the kids' computers: use this laptop's Ethernet or Wi-Fi address:"
if command -v ip >/dev/null; then
  ip -4 -o address show scope global | awk '$2 !~ /^(lo|docker|br-|virbr|veth|wg|tun|tailscale)/ {split($4, a, "/"); print "  Address: " a[1] "    Port: 30001    (" $2 ")"}' || true
fi
echo "Each player registers a different name. Passwords can be left empty."
echo "Stop the server with Ctrl+C, or /shutdown while connected as ondra."
echo "Log: $world_dir/server.log"
echo "After stopping, save this session with: ./luanti-worlds/save-world.sh MY_SAVE_NAME"
"${luanti_cmd[@]}" --quiet --server \
  --world "$world_dir" --config "$world_dir/server.conf" \
  --logfile "$world_dir/server.log"
