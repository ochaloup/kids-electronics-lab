# shellcheck shell=bash
# Sourced by the scripts: finds the Luanti runtime and asks it for its own user data folder.
: "${worlds_dir:?The script must set worlds_dir}"
luanti_cmd=()

luanti_find() {
  if [[ -n "${LUANTI_BIN:-}" ]]; then
    luanti_cmd=("$LUANTI_BIN")
  elif command -v flatpak >/dev/null && flatpak info org.luanti.luanti >/dev/null 2>&1; then
    luanti_cmd=(flatpak run org.luanti.luanti)
  elif command -v flatpak >/dev/null && flatpak info net.minetest.Minetest >/dev/null 2>&1; then
    luanti_cmd=(flatpak run net.minetest.Minetest)
  elif command -v luanti >/dev/null; then
    luanti_cmd=(luanti)
  elif command -v minetest >/dev/null; then
    luanti_cmd=(minetest)
  elif [[ -x /Applications/Luanti.app/Contents/MacOS/luanti ]]; then
    luanti_cmd=(/Applications/Luanti.app/Contents/MacOS/luanti)
  else
    return 1
  fi
}

luanti_paths() {
  local output
  output="$("${luanti_cmd[@]}" --info --worldlist path 2>&1)" || true
  data_dir="$(sed -n 's/.*Detected user path: //p' <<<"$output" | head -n 1)"
  if [[ -z "$data_dir" || ! -d "$data_dir" ]]; then
    echo "Could not detect Luanti's user data folder from: ${luanti_cmd[*]} --info --worldlist path" >&2
    echo "Set LUANTI_USER_PATH to that folder and retry." >&2
    return 1
  fi
  store_dir="$data_dir/edu-village"
  # shellcheck disable=SC2034
  install_manifest="$store_dir/installed-by-setup.txt"
}

luanti_require() {
  if ! luanti_find; then
    echo "Luanti not found. Run ./luanti-worlds/setup-host.sh, or set LUANTI_BIN to the Luanti program." >&2
    exit 1
  fi
  luanti_paths || exit 1
}

luanti_has_voxelibre() {
  local games
  games="$("${luanti_cmd[@]}" --gameid list 2>&1)" || return 1
  grep -qx mineclone2 <<<"$games"
}

worlds_py() {
  python3 "$worlds_dir/worlds.py" --root "$store_dir" "$@"
}
