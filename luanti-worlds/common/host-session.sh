# shellcheck shell=bash
# Shared launcher lock; keeps latest-session unambiguous and prevents two hosts.
: "${world_store:?The launcher must set world_store}"
mkdir -p -- "$world_store"
exec 8>"$world_store/.host.lock"
if ! flock -n 8; then
  echo "A teaching session is already running. Stop it before starting a fresh or saved world." >&2
  exit 1
fi
