#!/usr/bin/env bash
set -euo pipefail
game_dir="${1:?Usage: install-voxelibre.sh DESTINATION}"
game_version=0.92.3
game_commit=a523240fb89713ffa6302696e8275bbd7de3bd49
if [[ -f "$game_dir/game.conf" ]]; then
  echo "VoxeLibre already present: $game_dir"
  exit 0
fi
if [[ -e "$game_dir" || -L "$game_dir" ]]; then
  echo "Refusing to replace an incomplete or different game directory: $game_dir" >&2
  exit 1
fi
mkdir -p -- "$(dirname -- "$game_dir")"
stage_dir="$(mktemp -d "$(dirname -- "$game_dir")/.voxelibre-install.XXXXXX")"
echo "Downloading VoxeLibre $game_version..."
git clone --depth 1 --branch "$game_version" --single-branch \
  https://github.com/VoxeLibre/VoxeLibre.git "$stage_dir/mineclone2"
if [[ "$(git -C "$stage_dir/mineclone2" rev-parse HEAD)" != "$game_commit" ]]; then
  echo "The downloaded release does not match the pinned commit. Left at: $stage_dir" >&2
  exit 1
fi
[[ -f "$stage_dir/mineclone2/game.conf" ]]
mv -T -- "$stage_dir/mineclone2" "$game_dir"
rmdir -- "$stage_dir"
echo "Installed VoxeLibre $game_version: $game_dir"
