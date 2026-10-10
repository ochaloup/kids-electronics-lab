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
    echo "Set up a Linux laptop to host Programming Village."
    echo "Installs missing system tools and Luanti, VoxeLibre, LWScratch and xcompat, then links the world."
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
template_dir="$worlds_dir/edu_village_river_01"
for required in world.mt luanti.conf worldmods/edu_village_river/init.lua; do
  if [[ ! -f "$template_dir/$required" ]]; then
    echo "Missing project file: $template_dir/$required. Copy the complete luanti-worlds folder." >&2
    exit 1
  fi
done
source "$worlds_dir/luanti-env.sh"
mod_names=(lwscratch xcompat)

run_check() {
  local missing=false tool linked
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
  if ! bash "$worlds_dir/install-mods.sh" --check "$data_dir/mods"; then missing=true; fi
  linked="$(readlink -f -- "$data_dir/worlds/edu_village_river_01" 2>/dev/null || true)"
  if [[ -L "$data_dir/worlds/edu_village_river_01" && "$(dirname -- "$linked")" == "$(realpath -- "$store_dir/sessions" 2>/dev/null)" &&
        -f "$linked/world.mt" ]]; then
    echo "OK: world link -> $linked"
  else echo "Missing or different: world link $data_dir/worlds/edu_village_river_01"; missing=true; fi
  echo "World store: $store_dir"
  if "$missing"; then echo "Run: $worlds_dir/setup-host.sh"; return 1; fi
  echo "Requirements present. Start: $worlds_dir/server.sh"
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
  bash "$worlds_dir/install-voxelibre.sh" "$data_dir/games/mineclone2"
  record "path $data_dir/games/mineclone2"
fi
new_mods=()
for name in "${mod_names[@]}"; do
  if [[ ! -e "$data_dir/mods/$name" ]]; then new_mods+=("$name"); fi
done
bash "$worlds_dir/install-mods.sh" "$data_dir/mods"
for name in "${new_mods[@]}"; do record "path $data_dir/mods/$name"; done
link="$data_dir/worlds/edu_village_river_01"
if [[ ! -e "$link" && ! -L "$link" ]]; then new_link=true; else new_link=false; fi
bash "$worlds_dir/link-world.sh"
if "$new_link"; then record "path $link"; fi
echo "Checking the installation..."
run_check
echo "Running a robot program in a disposable world to prove Luanti loads the mods..."
bash "$worlds_dir/test-world.sh" loop
echo "Host setup complete."
echo "Start the world: $worlds_dir/server.sh"
echo "The server prints current network addresses for the kids each time it starts."
echo "To remove what this setup installed: $worlds_dir/uninstall.sh"
