#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/host-session.sh"
if [[ "${1:-}" == --saved ]]; then
  world_dir="$(python3 "$worlds_dir/worlds.py" load "${2:?Provide a saved world name}")"
  shift 2
else
  world_dir="$(python3 "$worlds_dir/worlds.py" new)"
fi
source "$worlds_dir/world-session.sh"
bash "$worlds_dir/link-world.sh" "$world_dir"
echo "Session: $(basename -- "$world_dir")"
flatpak run org.luanti.luanti \
  --world "$world_dir" --config "$world_dir/luanti.conf" \
  --logfile "$world_dir/debug.txt" --go "$@"
