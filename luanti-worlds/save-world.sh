#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/luanti-env.sh"
luanti_require
worlds_py save "$@"
