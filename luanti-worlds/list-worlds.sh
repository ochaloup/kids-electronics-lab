#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/common/luanti-env.sh"
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  echo "Usage: $0 [WORLD]"
  echo "Lists saved worlds and sessions of one world, or of all worlds."
  exit 0
fi
luanti_require
echo "World store: $store_dir"
if (($#)); then names=("$1"); else mapfile -t names < <(world_names); fi
for name in "${names[@]}"; do
  world_select "$name"
  echo
  echo "== $world_name"
  worlds_py list
done
