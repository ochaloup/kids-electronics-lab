# Luanti teaching worlds

Each numbered folder is one world generator: a template (`world.mt`,
`luanti.conf`, `worldmods/`), a `server.conf` for hosting and an optional
`mods.txt` of third-party mods pinned to commits. The scripts here are shared by
all worlds; their helpers live in `common/`.

| World | About |
| --- | --- |
| [01_river_turtle_village](01_river_turtle_village/README.md) | Program LWScratch robots to build a bridge |
| [02_microbit_gold_digging](02_microbit_gold_digging/README.md) | Mine gold; scores go by radio to the kids' micro:bits |

Played worlds live on each computer, never in this repository: in
`edu-worlds/<world>/` inside Luanti's user data folder. The scripts ask Luanti
for that folder (`--info` logs "Detected user path"), so it works for Flatpak,
native and macOS installs and respects `LUANTI_USER_PATH`. Set `LUANTI_BIN` if
Luanti is installed somewhere unusual.

## Fresh starts and named saves

Every command takes the world folder name first. The server starts a **brand
new world every time**; player inventories and accounts are fresh too:

```sh
./luanti-worlds/server.sh 01_river_turtle_village
```

To keep progress, stop the server with Ctrl+C or `/shutdown`, then name the
latest session. To continue later, start a copy of that save; the save itself
never changes, and existing save names are never overwritten:

```sh
./luanti-worlds/save-world.sh 01_river_turtle_village lesson-1
./luanti-worlds/server.sh 01_river_turtle_village lesson-1
```

`./luanti-worlds/list-worlds.sh [WORLD]` shows saves and session IDs. Old
sessions are kept, so a forgotten one can still be saved with
`save-world.sh WORLD NAME --session SESSION_ID`. Saving a running world is
refused. Sessions accumulate on disk; nothing is cleaned up automatically.

## Play alone

```sh
./luanti-worlds/play.sh 01_river_turtle_village
./luanti-worlds/play.sh 01_river_turtle_village --saved lesson-1
```

Each world also appears in Luanti's normal world list under its folder name.
That entry is a relative link to the latest session
(`worlds/<world> -> ../edu-worlds/<world>/sessions/<id>`), so opening it from
the menu continues that session. `link-world.sh` manages the link and refuses
to replace anything it did not create.

## Set up a host laptop

```sh
./luanti-worlds/setup-host.sh
```

It supports Linux hosts and runs as your normal user, **without sudo**; sudo is
used only for missing system packages (APT, DNF or Pacman). It reuses an
installed Luanti (Flatpak or native) or installs the Flatpak from Flathub,
installs the tested
[VoxeLibre 0.92.3](https://github.com/VoxeLibre/VoxeLibre/releases/tag/0.92.3)
if no VoxeLibre is present, installs every world's `mods.txt` into Luanti's
`mods` folder and links each world. Existing games, mods and worlds are never
replaced. It ends with `--check` and each world's self-test; setup fails if any
fails. The first run needs internet access.

```sh
./luanti-worlds/setup-host.sh --check    # inspect only, changes nothing
./luanti-worlds/uninstall.sh             # remove what setup installed, keep worlds
./luanti-worlds/uninstall.sh --worlds    # also delete all sessions and saves
```

Setup records what it installed in `edu-worlds/installed-by-setup.txt`; a
Luanti, game or mod that existed before is not recorded and stays.

VoxeLibre 0.92.1 does not start on Luanti 5.17 (`vl_hudbars` reads
`mcl_gamemode` without depending on it); 0.92.3 fixes that.

## Play together over the home network

Leave any singleplayer game first, then start the server and leave the terminal
running; the laptop must stay awake. It prints the laptop's current
Ethernet/Wi-Fi addresses and the world's port from its `server.conf`, which is
copied into the session at each start. Logs are in the session's `server.log`.

On the laptop itself, join `127.0.0.1` with the admin name from `server.conf`.
On each child's computer:

1. Install a current stable **Luanti** from the
   [official downloads page](https://www.luanti.org/en/downloads/).
2. Join the same home network as the laptop, not an isolating guest Wi-Fi.
3. Choose **Join Game**, enter the printed address and port. A game-install
   prompt is for local play and is not needed.
4. Register a different player name per child; passwords may be empty.

Kids do **not** install VoxeLibre, mods or worlds; the server sends the content
([Luanti connection guide](https://docs.luanti.org/for-players/getting-started/)).
No router port forwarding is needed, and `server_announce` is off. If a
firewall blocks the port, for example with UFW:

```sh
sudo ufw allow from 192.168.1.0/24 to any port 30001 proto udp
```

## Adding a world

Create `NN_name/` with `world.mt`, `luanti.conf`, `server.conf`, `worldmods/`
and, if needed, `mods.txt` (`name url commit` per line, enabled in `world.mt`
with `load_mod_<name> = true`). Its scenario must support `edu_selftest = true`:
run a real check, log `[edu_selftest] PASS: ...` and shut the server down.
`test-world.sh WORLD [MODE]` runs it in a disposable copy on port 30099.
An optional `prestart.sh` runs before `server.sh` starts Luanti, with the
session's `server.conf` path as its argument; a failure stops the start.

## Checks

```sh
python3 luanti-worlds/common/test_worlds.py
./luanti-worlds/test-world.sh 01_river_turtle_village loop
./luanti-worlds/test-world.sh 02_microbit_gold_digging
```
