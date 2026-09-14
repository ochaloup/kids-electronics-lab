#!/usr/bin/env bash
set -euo pipefail
worlds_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data_dir="${LUANTI_DATA_DIR:-$HOME/.var/app/org.luanti.luanti/.minetest}"
check_only=false
case "${1:-}" in
  "") ;;
  --check) check_only=true ;;
  --help|-h)
    echo "Usage: $0 [--check]"
    echo "Set up a Linux laptop to host Programming Village."
    echo "Installs missing system tools and Luanti, installs VoxeLibre, and links the bundled world."
    echo "Run as your normal user; sudo is used only for missing system packages."
    echo "--check inspects requirements without installing or changing anything."
    exit 0 ;;
  *) echo "Usage: $0 [--check]" >&2; exit 1 ;;
esac
if [[ "$(uname -s)" != Linux ]]; then
  echo "This host installer supports Linux laptops. Kids can use any supported Luanti platform." >&2
  exit 1
fi
world_dir="$worlds_dir/edu_village_river_01"
for required in world.mt worldmods/edu_village_river/init.lua worldmods/lwscratch/init.lua worldmods/xcompat/init.lua; do
  if [[ ! -f "$world_dir/$required" ]]; then
    echo "Missing project file: $world_dir/$required. Copy the complete luanti-worlds folder." >&2
    exit 1
  fi
done
missing_tools=()
for tool in flatpak git python3 ip flock fuser; do
  if ! command -v "$tool" >/dev/null; then missing_tools+=("$tool"); fi
done
if "$check_only"; then
  missing=false
  if ((${#missing_tools[@]})); then
    echo "Missing system tools: ${missing_tools[*]}"; missing=true
  else echo "OK: system tools"; fi
  if command -v flatpak >/dev/null && flatpak info org.luanti.luanti >/dev/null 2>&1; then
    echo "OK: Luanti Flatpak"
  else echo "Missing: Luanti Flatpak"; missing=true; fi
  if [[ -f "$data_dir/games/mineclone2/game.conf" ]]; then
    echo "OK: VoxeLibre"
  else echo "Missing: VoxeLibre"; missing=true; fi
  linked_world="$(readlink -f -- "$data_dir/worlds/edu_village_river_01" 2>/dev/null || true)"
  if [[ "$linked_world" == "$worlds_dir/sessions/"* && -f "$linked_world/world.mt" ]]; then
    echo "OK: world link"
  else echo "Missing or different: world link"; missing=true; fi
  echo "OK: bundled scenario, LWScratch and xcompat"
  if "$missing"; then echo "Run: $worlds_dir/setup-host.sh"; exit 1; fi
  echo "Requirements present. Start: $worlds_dir/server.sh"
  exit 0
fi
if ((EUID == 0)); then
  echo "Run this script as your normal desktop user, without sudo." >&2
  exit 1
fi
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
if flatpak info org.luanti.luanti >/dev/null 2>&1; then
  echo "Luanti Flatpak already installed."
else
  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install --user --noninteractive -y flathub org.luanti.luanti
fi
bash "$worlds_dir/install-voxelibre.sh" "$data_dir/games/mineclone2"
bash "$worlds_dir/link-world.sh"
echo "Host setup complete."
echo "Start the world: $worlds_dir/server.sh"
echo "The server prints current network addresses for the kids each time it starts."
