#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/common/luanti-env.sh"
usage() {
  echo "Usage: $0 WORLD [SAVED_WORLD_NAME]"
  echo "No save name: start a brand new world. Save name: start a copy of that saved world."
  echo "Worlds: $(world_names | tr '\n' ' ')"
}
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then usage; exit 0; fi
if (($# < 1 || $# > 2)); then usage >&2; exit 1; fi
luanti_require
world_select "$1"
if ! luanti_has_voxelibre; then
  echo "VoxeLibre is missing. Run ./luanti-worlds/setup-host.sh first." >&2
  exit 1
fi
source "$worlds_dir/common/host-session.sh"
# Prestart runs before a session exists, so a failed check leaves no empty session behind.
conf="$(mktemp)"
trap 'rm -f -- "$conf"' EXIT
cp -- "$template_dir/server.conf" "$conf"
if [[ -f "$template_dir/prestart.sh" ]]; then bash "$template_dir/prestart.sh" "$conf"; fi
# Path override is only for integration checks.
if [[ -n "${LUANTI_WORLD_DIR:-}" ]]; then
  world_dir="$LUANTI_WORLD_DIR"
elif (($# == 2)); then
  world_dir="$(worlds_py load "$2")"
else
  world_dir="$(worlds_py new)"
fi
source "$worlds_dir/common/world-session.sh"
if [[ -z "${LUANTI_WORLD_DIR:-}" ]]; then
  bash "$worlds_dir/link-world.sh" "$world_name" "$world_dir"
fi
# A sandboxed Luanti cannot read this repository, so the config travels with the world.
mv -- "$conf" "$world_dir/server.conf"
port="$(conf_value port "$world_dir/server.conf")"
admin="$(conf_value name "$world_dir/server.conf")"
echo "Session: $(basename -- "$world_dir")"
echo "Starting $(conf_value server_name "$world_dir/server.conf") on UDP port $port."
echo "On this laptop: Join Game -> address 127.0.0.1, port $port, name $admin."
echo "On the kids' computers: use this laptop's Ethernet or Wi-Fi address:"
if command -v ip >/dev/null; then
  ip -4 -o address show scope global | awk -v port="$port" '$2 !~ /^(lo|docker|br-|virbr|veth|wg|tun|tailscale)/ {split($4, a, "/"); print "  Address: " a[1] "    Port: " port "    (" $2 ")"}' || true
fi
echo "Each player registers a different name. Passwords can be left empty."
echo "Stop the server with Ctrl+C, or /shutdown while connected as $admin."
echo "Log: $world_dir/server.log"
echo "After stopping, save this session with: ./luanti-worlds/save-world.sh $world_name MY_SAVE_NAME"
"${luanti_cmd[@]}" --quiet --server \
  --world "$world_dir" --config "$world_dir/server.conf" \
  --logfile "$world_dir/server.log"
