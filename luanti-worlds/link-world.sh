#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$worlds_dir/common/luanti-env.sh"
if (($# < 1 || $# > 2)) || [[ "$1" == --help || "$1" == -h ]]; then
  echo "Usage: $0 WORLD [SESSION_DIR]"
  echo "Points Luanti's world list at a session; default: the latest, or a new one."
  echo "Worlds: $(world_names | tr '\n' ' ')"
  exit 1
fi
luanti_require
world_select "$1"
source_dir="${2:-}"
if [[ -z "$source_dir" ]]; then
  if ! source_dir="$(worlds_py latest 2>/dev/null)"; then
    source_dir="$(worlds_py new)"
  fi
fi
source_dir="$(realpath -- "$source_dir")"
if [[ ! -f "$source_dir/world.mt" || "$(dirname -- "$source_dir")" != "$(realpath -- "$world_store/sessions")" ]]; then
  echo "Not a session in $world_store/sessions: $source_dir" >&2
  exit 1
fi
target="$data_dir/worlds/$world_name"
# Relative, so the link also resolves inside a Flatpak sandbox.
managed="../$(basename -- "$store_dir")/$world_name/sessions"
relative="$managed/$(basename -- "$source_dir")"
if [[ -L "$target" ]]; then
  previous="$(readlink -- "$target")"
  if [[ "$previous" != "$managed"/* ]]; then
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
