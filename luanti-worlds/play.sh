#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
world_dir="$worlds_dir/edu_village_river_01"
source "$worlds_dir/world-session.sh"
flatpak run org.luanti.luanti \
  --world "$world_dir" --config "$world_dir/luanti.conf" \
  --logfile "$world_dir/debug.txt" --go "$@"
