#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# Override only for integration checks in a disposable world copy.
world_dir="${LUANTI_WORLD_DIR:-$worlds_dir/edu_village_river_01}"
if ! command -v flatpak >/dev/null || ! flatpak info org.luanti.luanti >/dev/null 2>&1; then
  echo "Run ./luanti-worlds/setup-host.sh to install the host requirements." >&2
  exit 1
fi
data_dir="${LUANTI_DATA_DIR:-$HOME/.var/app/org.luanti.luanti/.minetest}"
if [[ ! -f "$data_dir/games/mineclone2/game.conf" ]]; then
  echo "VoxeLibre is missing. Run ./luanti-worlds/setup-host.sh first." >&2
  exit 1
fi
source "$worlds_dir/world-session.sh"
echo "Starting Programming Village on UDP port 30001."
echo "On this laptop: Join Game -> address 127.0.0.1, port 30001, name ondra."
echo "On the kids' computers: use this laptop's Ethernet or Wi-Fi address:"
if command -v ip >/dev/null; then
  ip -4 -o address show scope global | awk '$2 !~ /^(lo|docker|br-|virbr|veth|wg|tun|tailscale)/ {split($4, a, "/"); print "  Address: " a[1] "    Port: 30001    (" $2 ")"}' || true
fi
echo "Each player registers a different name and a nonempty password."
echo "Stop the server with Ctrl+C, or /shutdown while connected as ondra."
echo "Log: $world_dir/server.log"
flatpak run org.luanti.luanti --quiet --server \
  --world "$world_dir" --config "$worlds_dir/server.conf" \
  --logfile "$world_dir/server.log"
