#!/usr/bin/env bash
set -euo pipefail
usage="Usage: install-mods.sh [--check] MODS_DIRECTORY"
check_only=false
if [[ "${1:-}" == --check ]]; then check_only=true; shift; fi
mods_dir="${1:?$usage}"
mods=(
  "lwscratch https://github.com/mt-historical/lwscratch 6815a37bf56b2914a231212588b01d07d9ef7ba3"
  "xcompat https://github.com/mt-mods/xcompat 758684dac8875d06d8c1565e323ee52c9d4daf7f"
)
status=0
for entry in "${mods[@]}"; do
  read -r name url commit <<<"$entry"
  target="$mods_dir/$name"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$(git -C "$target" rev-parse HEAD 2>/dev/null || true)" == "$commit" && -f "$target/init.lua" ]]; then
      echo "OK: $name $commit in $target"
    else
      echo "Different or incomplete $name in $target; expected commit $commit. Remove it to reinstall." >&2
      status=1
    fi
    continue
  fi
  if "$check_only"; then
    echo "Missing: $name in $target" >&2
    status=1
    continue
  fi
  mkdir -p -- "$mods_dir"
  stage_dir="$(mktemp -d "$mods_dir/.$name-install.XXXXXX")"
  echo "Downloading $name..."
  git init -q "$stage_dir/$name"
  git -C "$stage_dir/$name" fetch -q --depth 1 "$url" "$commit"
  git -C "$stage_dir/$name" -c advice.detachedHead=false checkout -q FETCH_HEAD
  if [[ "$(git -C "$stage_dir/$name" rev-parse HEAD)" != "$commit" || ! -f "$stage_dir/$name/init.lua" ]]; then
    echo "The downloaded $name does not match the pinned commit. Left at: $stage_dir" >&2
    exit 1
  fi
  mv -T -- "$stage_dir/$name" "$target"
  rmdir -- "$stage_dir"
  echo "Installed $name $commit: $target"
done
exit "$status"
