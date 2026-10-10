#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/common/luanti-env.sh"
usage() {
  echo "Usage: $0 WORLD [--saved SAVED_WORLD_NAME] [LUANTI_OPTIONS...]"
  echo "Worlds: $(world_names | tr '\n' ' ')"
}
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then usage; exit 0; fi
if (($# < 1)); then usage >&2; exit 1; fi
luanti_require
world_select "$1"
shift
source "$worlds_dir/common/host-session.sh"
if [[ "${1:-}" == --saved ]]; then
  world_dir="$(worlds_py load "${2:?Provide a saved world name}")"
  shift 2
else
  world_dir="$(worlds_py new)"
fi
source "$worlds_dir/common/world-session.sh"
bash "$worlds_dir/link-world.sh" "$world_name" "$world_dir"
echo "Session: $(basename -- "$world_dir")"
"${luanti_cmd[@]}" \
  --world "$world_dir" --config "$world_dir/luanti.conf" \
  --logfile "$world_dir/debug.txt" --go "$@"
