#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/luanti-env.sh"
luanti_require
source_dir="${1:-}"
if [[ -z "$source_dir" ]]; then
  if ! source_dir="$(worlds_py latest 2>/dev/null)"; then
    source_dir="$(worlds_py new)"
  fi
fi
source_dir="$(realpath -- "$source_dir")"
if [[ ! -f "$source_dir/world.mt" || "$(dirname -- "$source_dir")" != "$(realpath -- "$store_dir/sessions")" ]]; then
  echo "Not a session in $store_dir/sessions: $source_dir" >&2
  exit 1
fi
target="$data_dir/worlds/edu_village_river_01"
# Relative, so the link also resolves inside a Flatpak sandbox.
relative="../edu-village/sessions/$(basename -- "$source_dir")"
if [[ -L "$target" ]]; then
  previous="$(readlink -- "$target")"
  if [[ "$previous" != ../edu-village/sessions/* && "$previous" != */luanti-worlds/sessions/* &&
        "$previous" != */luanti-worlds/edu_village_river_01 ]]; then
    echo "Refusing to replace a link not managed by these scripts: $target -> $previous" >&2
    exit 1
  fi
  ln -sfn -- "$relative" "$target"
elif [[ -e "$target" ]]; then
  echo "Refusing to replace an existing world: $target" >&2
  exit 1
else
  mkdir -p -- "$data_dir/worlds"
  ln -s -- "$relative" "$target"
fi
echo "Linked: $target -> $relative"
