# shellcheck shell=bash
# Sourced by play.sh and server.sh after setting world_dir.
# Keep the caller shell alive while Luanti runs: Flatpak may close inherited FDs.
: "${world_dir:?The launcher must set world_dir before sourcing this file}"
if [[ ! -f "$world_dir/world.mt" ]]; then
  echo "World not found: $world_dir" >&2
  exit 1
fi
exec 9>"$world_dir/.session.lock"
if ! flock -n 9; then
  echo "This world is already running. Stop its server or leave its singleplayer game first." >&2
  exit 1
fi
# Also detects a running instance started before the launcher acquired locks,
# or started directly from Luanti's menu.
if command -v fuser >/dev/null && [[ -f "$world_dir/map.sqlite" ]] &&
   fuser -s "$world_dir/map.sqlite"; then
  echo "Luanti already has this world open. Leave the singleplayer game before starting the server." >&2
  exit 1
fi
