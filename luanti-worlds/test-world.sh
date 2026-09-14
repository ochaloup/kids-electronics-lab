#!/usr/bin/env bash
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:-sequence}"
case "$mode" in sequence|loop) ;; *) echo "Usage: $0 [sequence|loop]" >&2; exit 1 ;; esac
mkdir -p -- "$worlds_dir/.tests"
test_dir="$(mktemp -d "$worlds_dir/.tests/$mode.XXXXXX")"
python3 - "$worlds_dir/edu_village_river_01" "$test_dir" "$mode" <<'PY'
from pathlib import Path
import shutil
import sys
source, destination = map(Path, sys.argv[1:3])
shutil.copy2(source / 'world.mt', destination / 'world.mt')
shutil.copy2(source / 'luanti.conf', destination / 'luanti.conf')
shutil.copytree(source / 'worldmods', destination / 'worldmods',
                ignore=shutil.ignore_patterns('.git'))
with (destination / 'luanti.conf').open('a') as config:
    config.write('\nedu_selftest = true\nedu_selftest_mode = ' + sys.argv[3] +
                 '\nbind_address = 127.0.0.1\nport = 30099\n')
PY
timeout 60 flatpak run org.luanti.luanti --quiet --server \
  --world "$test_dir" --config "$test_dir/luanti.conf" --logfile "$test_dir/debug.txt"
rg --fixed-strings "[edu_selftest] PASS: $mode," "$test_dir/debug.txt"
echo "Test artifacts: $test_dir"
