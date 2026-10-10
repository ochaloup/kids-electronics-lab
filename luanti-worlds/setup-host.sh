#!/usr/bin/env bash
# Everything this installs is recorded for uninstall.sh; record new install steps the same way.
# shellcheck source-path=SCRIPTDIR
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
check_only=false
case "${1:-}" in
  "") ;;
  --check) check_only=true ;;
  --help|-h)
    echo "Usage: $0 [--check]"
    echo "Set up a Linux laptop to host the Luanti teaching worlds in this folder."
    echo "Installs missing system tools, Luanti, VoxeLibre and every world's mods.txt, then links each world."
    echo "Run as your normal user; sudo is used only for missing system packages."
    echo "--check inspects requirements without installing or changing anything."
    echo "Undo the installation with: $worlds_dir/uninstall.sh"
    exit 0 ;;
  *) echo "Usage: $0 [--check]" >&2; exit 1 ;;
esac
if [[ "$(uname -s)" != Linux ]]; then
  echo "This host installer supports Linux laptops. Kids can use any supported Luanti platform." >&2
  exit 1
fi
source "$worlds_dir/common/luanti-env.sh"
mapfile -t worlds < <(world_names)
if ((${#worlds[@]} == 0)); then
  echo "No world folders with a world.mt in $worlds_dir. Copy the complete luanti-worlds folder." >&2
  exit 1
fi
mod_lists=()
for name in "${worlds[@]}"; do
  for required in luanti.conf server.conf worldmods; do
    if [[ ! -e "$worlds_dir/$name/$required" ]]; then
      echo "Missing project file: $worlds_dir/$name/$required. Copy the complete luanti-worlds folder." >&2
      exit 1
    fi
  done
  if [[ -f "$worlds_dir/$name/mods.txt" ]]; then mod_lists+=("$worlds_dir/$name/mods.txt"); fi
done

install_mods() {
  if ((${#mod_lists[@]})); then bash "$worlds_dir/common/install-mods.sh" "$@" "$data_dir/mods" "${mod_lists[@]}"; fi
}

run_check() {
  local missing=false tool name link linked
  local missing_tools=()
  for tool in git python3 ip flock fuser; do
    if ! command -v "$tool" >/dev/null; then missing_tools+=("$tool"); fi
  done
  if ((${#missing_tools[@]})); then
    echo "Missing system tools: ${missing_tools[*]}"; missing=true
  else echo "OK: system tools"; fi
  if ! luanti_find; then
    echo "Missing: Luanti"
    echo "Run: $worlds_dir/setup-host.sh"
    return 1
  fi
  echo "OK: Luanti: ${luanti_cmd[*]}"
  luanti_paths || return 1
  echo "OK: Luanti user data folder: $data_dir"
  if luanti_has_voxelibre; then
    echo "OK: VoxeLibre"
  else echo "Missing: VoxeLibre"; missing=true; fi
  if ! install_mods --check; then missing=true; fi
  for name in "${worlds[@]}"; do
    link="$data_dir/worlds/$name"
    linked="$(readlink -f -- "$link" 2>/dev/null || true)"
    if [[ -L "$link" && "$(dirname -- "$linked")" == "$(realpath -- "$store_dir/$name/sessions" 2>/dev/null)" &&
          -f "$linked/world.mt" ]]; then
      echo "OK: world link $name -> $linked"
    else echo "Missing or different: world link $link"; missing=true; fi
  done
  echo "World store: $store_dir"
  if "$missing"; then echo "Run: $worlds_dir/setup-host.sh"; return 1; fi
  echo "Requirements present. Start: $worlds_dir/server.sh WORLD"
}

record() {
  mkdir -p -- "$store_dir"
  if ! grep -qxF -- "$1" "$install_manifest" 2>/dev/null; then echo "$1" >>"$install_manifest"; fi
}

if "$check_only"; then
  run_check
  exit
fi
if ((EUID == 0)); then
  echo "Run this script as your normal desktop user, without sudo." >&2
  exit 1
fi
missing_tools=()
for tool in git python3 ip flock fuser; do
  if ! command -v "$tool" >/dev/null; then missing_tools+=("$tool"); fi
done
if ! luanti_find && ! command -v flatpak >/dev/null; then missing_tools+=(flatpak); fi
if ((${#missing_tools[@]})); then
  echo "Installing missing host tools: ${missing_tools[*]}"
  if command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y flatpak git python3 iproute2 util-linux psmisc ca-certificates
  elif command -v dnf >/dev/null; then
    sudo dnf install -y flatpak git python3 iproute util-linux psmisc ca-certificates
  elif command -v pacman >/dev/null; then
    sudo pacman -S --needed flatpak git python iproute2 util-linux psmisc ca-certificates
  else
    echo "Install these tools with your Linux package manager, then rerun: ${missing_tools[*]}" >&2
    exit 1
  fi
fi
installed_luanti=false
if luanti_find; then
  echo "Luanti already installed: ${luanti_cmd[*]}"
else
  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install --user --noninteractive -y flathub org.luanti.luanti
  luanti_find
  installed_luanti=true
fi
luanti_paths
if "$installed_luanti"; then record "flatpak org.luanti.luanti"; fi
if luanti_has_voxelibre; then
  echo "VoxeLibre already installed."
else
  bash "$worlds_dir/common/install-voxelibre.sh" "$data_dir/games/mineclone2"
  record "path $data_dir/games/mineclone2"
fi
new_mods=()
if ((${#mod_lists[@]})); then
  while read -r mod _; do
    if [[ -n "$mod" && ! -e "$data_dir/mods/$mod" ]]; then new_mods+=("$mod"); fi
  done < <(cat -- "${mod_lists[@]}")
fi
install_mods
for mod in "${new_mods[@]}"; do record "path $data_dir/mods/$mod"; done
for name in "${worlds[@]}"; do
  link="$data_dir/worlds/$name"
  if [[ ! -e "$link" && ! -L "$link" ]]; then new_link=true; else new_link=false; fi
  bash "$worlds_dir/link-world.sh" "$name"
  if "$new_link"; then record "path $link"; fi
done
echo "Checking the installation..."
run_check
for name in "${worlds[@]}"; do
  echo "Running $name's self-test in a disposable world to prove Luanti loads its mods..."
  bash "$worlds_dir/test-world.sh" "$name"
done
echo "Host setup complete."
echo "Start a world: $worlds_dir/server.sh WORLD    (worlds: ${worlds[*]})"
echo "The server prints current network addresses for the kids each time it starts."
echo "To remove what this setup installed: $worlds_dir/uninstall.sh"
