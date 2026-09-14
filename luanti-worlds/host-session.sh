# shellcheck shell=bash
# Shared launcher lock; keeps latest-session unambiguous and prevents two hosts.
: "${worlds_dir:?The launcher must set worlds_dir}"
exec 8>"$worlds_dir/.host.lock"
if ! flock -n 8; then
  echo "A teaching session is already running. Stop it before starting a fresh or saved world." >&2
  exit 1
fi
