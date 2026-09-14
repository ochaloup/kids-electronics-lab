#!/usr/bin/env bash
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="${1:-}"
if [[ -z "$source_dir" ]]; then
  if ! source_dir="$(python3 "$worlds_dir/worlds.py" latest 2>/dev/null)"; then
    source_dir="$(python3 "$worlds_dir/worlds.py" new)"
  fi
fi
source_dir="$(realpath -- "$source_dir")"
if [[ ! -f "$source_dir/world.mt" ]]; then
  echo "World not found: $source_dir" >&2
  exit 1
fi
# This is the data directory used by the installed Luanti Flatpak.
target_dir="${LUANTI_DATA_DIR:-$HOME/.var/app/org.luanti.luanti/.minetest}/worlds"
target="$target_dir/edu_village_river_01"
if [[ -e "$target" || -L "$target" ]]; then
  if [[ "$(readlink -f -- "$target")" != "$source_dir" ]]; then
    previous="$(readlink -f -- "$target" || true)"
    if [[ -L "$target" && ( "$previous" == "$worlds_dir/edu_village_river_01" || "$previous" == "$worlds_dir/sessions/"* ) ]]; then
      ln -sfn -- "$source_dir" "$target"
    else
      echo "Refusing to replace an existing world: $target" >&2
      exit 1
    fi
  fi
else
  mkdir -p -- "$target_dir"
  ln -s -- "$source_dir" "$target"
fi
# A symlink alone does not give a Flatpak access to its destination.
flatpak override --user --filesystem="$worlds_dir" org.luanti.luanti
echo "Linked: $target -> $source_dir"
echo "Luanti can access: $worlds_dir"
