#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
remove_worlds=false
assume_yes=false
for argument in "$@"; do
  case "$argument" in
    --worlds) remove_worlds=true ;;
    --yes) assume_yes=true ;;
    --help|-h)
      echo "Usage: $0 [--worlds] [--yes]"
      echo "Removes what setup-host.sh installed, as recorded in its install manifest."
      echo "Pre-existing Luanti, games and mods are not recorded, so they stay."
      echo "System packages and the Flathub remote stay; other programs may use them."
      echo "--worlds also deletes all sessions and saved worlds. Without it they are kept."
      echo "--yes skips the confirmation."
      exit 0 ;;
    *) echo "Usage: $0 [--worlds] [--yes]" >&2; exit 1 ;;
  esac
done
source "$worlds_dir/common/luanti-env.sh"
luanti_require
for lock in "$store_dir"/*/.host.lock; do
  [[ -e "$lock" ]] || continue
  exec {lock_fd}>"$lock"
  if ! flock -n "$lock_fd"; then
    echo "A world is running ($(basename -- "$(dirname -- "$lock")")). Stop it before uninstalling." >&2
    exit 1
  fi
done
entries=()
if [[ -f "$install_manifest" ]]; then mapfile -t entries <"$install_manifest"; fi
echo "Luanti user data folder: $data_dir"
echo "Will remove:"
for entry in "${entries[@]}"; do echo "  ${entry#* }"; done
echo "  $store_dir/*/.tests (self-test worlds)"
if "$remove_worlds"; then
  echo "  $store_dir (ALL sessions and saved worlds)"
else
  echo "Keeping sessions and saved worlds in: $store_dir"
fi
if ! "$assume_yes"; then
  read -r -p "Continue? [y/N] " answer
  if [[ "$answer" != [yY] ]]; then echo "Nothing removed."; exit 1; fi
fi
for ((i = ${#entries[@]} - 1; i >= 0; i--)); do
  kind="${entries[i]%% *}"
  value="${entries[i]#* }"
  case "$kind" in
    path)
      if [[ "$value" != "$data_dir/"* ]]; then
        echo "Skipping a path outside the Luanti data folder: $value" >&2
      elif [[ -L "$value" ]]; then
        rm -- "$value"; echo "Removed link: $value"
      elif [[ -e "$value" ]]; then
        rm -rf -- "$value"; echo "Removed: $value"
      fi ;;
    flatpak)
      flatpak uninstall --user --noninteractive -y "$value"; echo "Uninstalled Flatpak: $value" ;;
    *) echo "Unknown manifest entry, left as is: ${entries[i]}" >&2 ;;
  esac
done
rm -rf -- "$store_dir"/*/.tests
rm -f -- "$install_manifest"
if "$remove_worlds"; then
  rm -rf -- "$store_dir"
  echo "Removed: $store_dir"
fi
echo "Uninstall complete."
