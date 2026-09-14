#!/usr/bin/env bash
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$worlds_dir/worlds.py" save "$@"
