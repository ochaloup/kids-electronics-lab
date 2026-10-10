#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/common/luanti-env.sh"
usage() {
  echo "Usage: $0 WORLD SAVE_NAME [--session SESSION_ID]"
  echo "Saves the latest stopped session, or the given one. Existing save names are never overwritten."
  echo "Worlds: $(world_names | tr '\n' ' ')"
}
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then usage; exit 0; fi
if (($# < 2)); then usage >&2; exit 1; fi
luanti_require
world_select "$1"
shift
worlds_py save "$@"
