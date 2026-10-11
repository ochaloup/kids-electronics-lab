#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/common/luanti-env.sh"
if (($# < 1 || $# > 2)) || [[ "$1" == --help || "$1" == -h ]]; then
  echo "Usage: $0 WORLD [MODE]"
  echo "Runs the world's edu_selftest in a disposable copy; it must log '[edu_selftest] PASS'."
  echo "EDU_SELFTEST_CONF adds config lines to that copy."
  echo "Worlds: $(world_names | tr '\n' ' ')"
  exit 1
fi
luanti_require
world_select "$1"
mode="${2:-}"
mkdir -p -- "$world_store/.tests"
test_dir="$(mktemp -d "$world_store/.tests/${mode:-default}.XXXXXX")"
python3 - "$template_dir" "$test_dir" "$mode" <<'PY'
from pathlib import Path
import os
import shutil
import sys
source, destination = map(Path, sys.argv[1:3])
mode = sys.argv[3]
shutil.copy2(source / 'world.mt', destination / 'world.mt')
shutil.copy2(source / 'luanti.conf', destination / 'luanti.conf')
shutil.copytree(source / 'worldmods', destination / 'worldmods',
                ignore=shutil.ignore_patterns('.git'))
with (destination / 'luanti.conf').open('a') as config:
    config.write('\nedu_selftest = true\nbind_address = 127.0.0.1\nport = 30099\n')
    if mode:
        config.write('edu_selftest_mode = ' + mode + '\n')
    config.write(os.environ.get('EDU_SELFTEST_CONF', '') + '\n')
PY
timeout 60 "${luanti_cmd[@]}" --quiet --server \
  --world "$test_dir" --config "$test_dir/luanti.conf" --logfile "$test_dir/debug.txt"
grep --fixed-strings "[edu_selftest] PASS: ${mode:+$mode,}" "$test_dir/debug.txt"
echo "Test artifacts: $test_dir"
