# Luanti programming world: implementation and session handoff

Date: 2026-09-14, Europe/Prague.

## Latest follow-up: clean template, fresh sessions, named saves

The user subsequently requested a brand new world on every normal server start,
with a way to preserve and reopen selected worlds. This supersedes the original
"play directly in edu_village_river_01" workflow described historically below.

Implemented behavior:

- `edu_village_river_01` is now a **clean template**: configs and worldmods only.
  No SQLite player/map/mod-storage
  databases or generated runtime files remain there.
- Before clearing it, the full original practice world was preserved as
  `saved-worlds/attempts-2026-09-14`. This includes the user's robot programs,
  builds, inventories, cassettes and accounts.
- `server.sh` with no argument creates a fresh copy under `sessions/SESSION_ID`
  every time. The scene regenerates from the scenario. No previous player
  changes/programs/accounts/inventories are copied into a fresh session.
- `server.sh SAVE_NAME` starts a new session copied from a named snapshot.
  Playing does not modify that snapshot.
- `play.sh` also starts a fresh copy. `play.sh --saved SAVE_NAME` opens a saved
  copy in singleplayer.
- `save-world.sh SAVE_NAME` stores the most recent **stopped** session.
  Existing names are refused rather than overwritten. Save continued progress
  under a new name.
- `list-worlds.sh` shows named saves and retained session IDs.
- All previous session directories remain on disk, even without a named save.
  Recover a forgotten earlier session using
  `save-world.sh SAVE_NAME --session SESSION_ID`.
- Luanti's world symlink now points into `sessions`, not at the template.
  Launchers update the managed link to the selected session; opening it directly
  from the menu continues that session instead of creating a fresh one.
- `worlds.py` controls creation/snapshots/migration. Fresh creation copies only
  `world.mt`, `luanti.conf`, and `worldmods`, so even accidental runtime data in
  the template cannot leak into the next fresh session.
- `.latest-session` tracks the latest session. `host-session.sh` holds a shared
  launcher lock so two managed hosts cannot make this pointer ambiguous.
- Saving/migration require stopped worlds, using host/world locks and `fuser`
  database-open checks. Full snapshots include all runtime files and the mod
  sources, rather than a short handpicked list of database files.
- `sessions`, `saved-worlds`, pointers and locks are ignored by Git. Copy named
  saves separately when transferring progress. No automatic cleanup is done.
- Installation remains separate from startup. `setup-host.sh --check` now
  expects the world link to point at a session.

Commands for the user:

```sh
./luanti-worlds/server.sh                         # Fresh lesson each time
# Stop with Ctrl+C or /shutdown before saving
./luanti-worlds/save-world.sh lesson-1
./luanti-worlds/server.sh lesson-1                # Continue a copy
./luanti-worlds/list-worlds.sh
./luanti-worlds/server.sh attempts-2026-09-14      # Original experiments
```

"Fresh world" means the original teaching village and empty robot programs,
not a landscape without the scenario. Starting fresh also resets player
registration/inventories. The empty-password setting remains permitted.

Persistence validation includes fresh copies ignoring arbitrary old runtime
files, preserving original attempts before cleanup, SQLite/content snapshot
isolation during resumed play, rejecting duplicate save names, recovery of
older sessions, refusing running/open-database snapshots, and path-name checks.
The tests are in `test_worlds.py` and run with
`python3 luanti-worlds/test_worlds.py`.

Actual Luanti lifecycle checks passed in an isolated fixture: start fresh and
execute the bridge loop; save the completed world; start fresh again and verify
an empty bridge, empty robot program and 64 planks; reopen the named save and
verify the six completed bridge blocks and 58 remaining robot planks. All three
servers exited cleanly. Empty passwords were also verified as permitted.

The remainder records the original implementation context; use the latest
workflow above and the current README/scripts for operational commands.

Follow-up: the user requested allowing registration with an empty password.
`server.conf` now sets `disallow_empty_password = false`; launcher text and
instructions were updated. Restart the server to apply this setting. If hosting
from another laptop, copy the updated configuration there first. Existing
accounts with passwords retain their passwords. The original multiplayer test
was performed before this follow-up, with empty passwords disallowed.

## Purpose and user preferences

Build a programming environment for children approximately 11–13 years old.
The children program robots in a shared Luanti/VoxeLibre world. The first task
is building a bridge for a village, progressing from sequences to loops and
later conditions and sensors. The environment should be calm: permanent day,
no hunger, damage, PvP, or naturally spawning monsters.

The user wanted the world and source files to live in this project, under
`luanti-worlds`, and to be symlinked into the installed Luanti world directory.
They specifically wanted to install and try **LWScratch**, rather than build
a new robot programming language for this first experiment.

Later, the user requested multiplayer hosting from a laptop so the children
can join from their own computers. The laptop/network can change, so startup
must print the **current** IP addresses instead of embedding a fixed address.
Installation and server startup must remain separate scripts. The user said
another laptop already has Luanti and VoxeLibre installed.

## Earlier notes and corrections

`$K` resolved during this session to:

```text
/home/chalda/Dropbox/Knowledgebase/marinade/
```

Existing notes found there:

- `luanti-vyuka-programovani.md`, dated 2026-09-03: initial teaching-world design,
  mod comparisons, installation observations, and a failed attempt to create
  world files because of sandbox errors.
- `2026-08-02-mata--luanti-voxelibre-mob-spawns--INVESTIGATION.md`: earlier mob-cap,
  village-location and debug-mod work, with scripts saved under `$K/scripts/luanti`.

This session successfully created the teaching world. The earlier note's
"files could not be created / no teaching mods installed" status is obsolete.
Actual installed versions checked here were **Luanti Flatpak 5.16.1** and
**VoxeLibre 0.92.1**. The earlier note recorded Luanti 5.17.0; use the actual
checked version when describing this session. `/etc/os-release` in this session
reported Ubuntu 26.04.1 LTS, also different from the older environment note.

## Files and installation layout

Project root:

```text
/home/chalda/my-testing/kids-electronics-lab
```

Implemented layout:

```text
luanti-worlds/
  README.md
  SESSION-CONTEXT.md
  play.sh
  server.sh
  server.conf
  setup-host.sh
  install-voxelibre.sh
  link-world.sh
  world-session.sh
  test-world.sh
  edu_village_river_01/
    world.mt
    luanti.conf
    worldmods/
      edu_village_river/
        mod.conf
        init.lua
        selftest.lua
      lwscratch/
      xcompat/
  .tests/                   # Disposable integration-test worlds/artifacts
```

World menu title: **Programming Village - LWScratch**.

Created symlink:

```text
~/.var/app/org.luanti.luanti/.minetest/worlds/edu_village_river_01
  -> /home/chalda/my-testing/kids-electronics-lab/luanti-worlds/edu_village_river_01
```

Flatpak application ID: `org.luanti.luanti`.
Flatpak game path: `~/.var/app/org.luanti.luanti/.minetest/games/mineclone2`.
VoxeLibre's technical game ID remains `mineclone2`.

A symlink alone does not bypass Flatpak's filesystem sandbox. `link-world.sh`
also runs a per-user Flatpak override granting access specifically to the
project's `luanti-worlds` directory. It refuses to replace an existing world/link
that points somewhere else. Rerun it after relocating the project to a new host.

SQLite saves, logs, generated metadata, bundled repositories' internal `.git`
directories, lock files, and `.tests` are excluded by the project's `.gitignore`.
Source files alone regenerate a fresh village. To transfer existing progress,
copy the world directory **including its ignored save files**, after stopping
the old host. Do not assume a Git clone includes inventories, auth or builds.

## Scenario and design choices

The custom worldmod generates the scene on its first start and records
`scene_version = 1` in mod storage. Normal restarts preserve player builds.
It uses a small singlenode world with a grass platform, shallow river, three
houses, paths on both banks, glass boundary walls, a lesson board, and a stone
practice platform south of the village.

Spawn: `(-12,1,0)`, looking toward the bridge.
Bridge robot: `(-4,1,0)`, LWScratch facedir `3`, facing **+X**, toward the far bank.
Bridge gap: **six oak plank positions**, `x=-3..2, y=0, z=0`.
River water lies at `y=-1`.
Practice robot: `(-18,1,11)`, facedir `2`, facing **+Z**.
Both preplaced robots are public and start with **64 oak planks in Storage**.

On first join, each player receives a spare robot, cassette and 64 oak planks.
The scenario moves players to village spawn on joining; `/edu_home` also returns
them there. Robot programming, inventories, and scenario logic run on the server.

`world.mt` provides world identity, SQLite backends, disabled damage and survival
mode. Dedicated client/server configuration files supply engine/game settings
explicitly; arbitrary game settings should not simply be assumed to work because
they were put in `world.mt`.

The scenario additionally enforces disabled damage/PvP/hunger, frozen daylight,
and disabled natural mob/weather cycles, including VoxeLibre's tunable gamerules.
It snapshots and restores the settings it changes on shutdown, to avoid leaving
them changed when this world is opened from the usual Luanti menu.

VoxeLibre weather initialization must be deferred using `core.after(0, ...)`,
with an explicit changer label when calling `mcl_weather.change_weather`.
Calling it directly during `on_mods_loaded` caused startup errors and was fixed.

The world deliberately allows manual building for exploration. `/edu_check`
counts oak planks; it does not prove that a robot placed them. There are no
separate bridge challenges or protected plots per child yet.

## Installed third-party mods

Unmodified source and bundled licenses are included locally:

| Package | Source | Pinned commit |
| --- | --- | --- |
| LWScratch | https://github.com/mt-historical/lwscratch | `6815a37bf56b2914a231212588b01d07d9ef7ba3` |
| xcompat | https://github.com/mt-mods/xcompat | `758684dac8875d06d8c1565e323ee52c9d4daf7f` |
| VoxeLibre, if installed by our helper | https://github.com/VoxeLibre/VoxeLibre/releases/tag/0.92.1 | `e21718f68d682ba1b36292eda545c0d0c0eadc44` |

LWScratch requires **xcompat**; its optional `mcl_core` dependency supports
VoxeLibre integration. Its code is LGPL 2.1 and media CC-BY-SA 3.0. xcompat has
its bundled LICENSE. LWScratch documentation is in `readme.txt` and
`docs/lwscratch.pdf` inside its mod directory.

The default `lwscratch_use_mod_on_place = true` was kept and worked for the
tested oak plank bridge. Its movement and action delays are 0.5 and 0.2 seconds.

## Commands to use

Run from the project root:

```sh
# Singleplayer
./luanti-worlds/play.sh

# Existing Linux host with Luanti Flatpak and VoxeLibre already installed:
./luanti-worlds/link-world.sh     # Once after copying/moving the project
./luanti-worlds/server.sh        # Each time the user wants to host

# Fresh Linux host:
./luanti-worlds/setup-host.sh    # One-time installation/linking, not server start
./luanti-worlds/server.sh

# Inspect prerequisites without installing/changing anything:
./luanti-worlds/setup-host.sh --check
```

`play.sh` supplies the world-local `luanti.conf`. `server.sh` supplies
`luanti-worlds/server.conf` and uses `--server --quiet`; errors still appear in
the terminal and detailed logging is written to the world-local `server.log`.
The shorter terminal output keeps connection details visible.

Do not start singleplayer hosting and dedicated hosting of the same world at
the same time. Leave the singleplayer game (Escape -> Exit to Menu) first.
Both launchers use `world-session.sh`, which acquires `.session.lock` using
`flock` and checks whether `map.sqlite` is already open using `fuser`.
The caller shell stays alive to retain the lock while Flatpak runs. This system's
`fuser` invocation uses `fuser -s FILE`; adding `--` did not work here and was fixed.

Stop the dedicated server with **Ctrl+C**, or `/shutdown` as administrator.
The host must remain on and awake during play. Starting a server does not
automatically start a player client.

In-game commands:

| Command | Effect |
| --- | --- |
| `/edu_home` | Return to village spawn |
| `/edu_kit` | Receive another robot, cassette and 64 oak planks |
| `/edu_check` | Count the six oak bridge blocks |
| `/edu_reset_bridge` | Clear the bridge and replace its robot with an empty program and 64 planks |
| `/edu_rebuild_village` | Reset the whole scene, including builds and robots |

Reset/rebuild require `server` privilege. Save a program to a cassette before
resetting if it needs to survive replacing its robot. The reset clears the
bridge area; it is not a general locator for robots moved elsewhere.

## Multiplayer configuration and client installation

Server settings:

- IPv4 bind address: `0.0.0.0`.
- Port: **30001 UDP**.
- Public server announcement: disabled.
- Maximum players: 8.
- New player privileges: `interact,shout`.
- Administrator account name: **ondra** (`name = ondra` in server.conf).
- Empty passwords: allowed by user request; no shared default password is configured.
- Peaceful settings match the teaching-world design above.

`server.sh` reads current IPv4 addresses each time it starts and prints
**Address / Port / interface** for Ethernet and Wi-Fi. It filters common
loopback/container/VPN interfaces. Several addresses may be printed: use the
one on the children's home network. There is no fixed laptop address to edit
in the configuration. The port is intentionally fixed at 30001.

On each child's computer:

1. Install a current stable Luanti client from https://www.luanti.org/en/downloads/.
2. Connect to the same home network as the host laptop.
3. Open **Join Game**, enter an address printed by the server and port **30001**.
4. Register a distinct player name; a password is optional and may be empty.
5. Reuse that name/password on subsequent connections.

The kids **do not install LWScratch, xcompat, VoxeLibre, or this world**.
The server runs the game/mods and sends the required media and definitions to
clients automatically. A local game installation prompt is for singleplayer,
not a requirement for joining this server.

Parent joining on the host laptop: open Luanti normally, use **Join Game**,
address **127.0.0.1**, port **30001**, name **ondra**. Register that account and
choose its password on the first connection. This name receives admin
privileges. Earlier singleplayer used identity `singleplayer`; `ondra` has a
separate inventory and receives a starter kit.

The current server uses Luanti 5.16.1; exact protocol version matching is not
forced. A current stable 5.x client is the intended client. Remote client
compatibility has not yet been tested on the children's machines.

The two scenario robots are public/shared. Children should coordinate editing
them. A new robot placed from a child's inventory can be made **Private** for
that child's programming, or **Public** for collaboration.

Home-network hosting does not require router port forwarding. Guest Wi-Fi can
isolate clients and prevent connecting between devices.

## Host installer behavior and limits

`setup-host.sh` is separate from the runtime launcher. It:

1. Checks Linux and the presence of the world/scenario/bundled mod files.
2. Detects `flatpak`, `git`, `python3`, `ip`, `flock`, and `fuser`.
3. Installs missing system tools via APT (Ubuntu/Debian), DNF (Fedora), or Pacman
   (Arch), using sudo for that step only.
4. Reuses an existing Luanti Flatpak; otherwise adds Flathub for the user and
   installs the application/runtime noninteractively.
5. Calls `install-voxelibre.sh` to install the pinned tested release if the
   `games/mineclone2/game.conf` file is absent.
6. Calls `link-world.sh` to link the world and configure Flatpak filesystem access.
7. Prints the command to start the server; it does not start hosting.

Run setup **as the normal desktop user, without wrapping it in sudo**.
First-time installs need internet access. Existing game directories are preserved;
an incomplete/different existing directory is refused rather than overwritten.
The game download is staged, its actual commit checked, then moved into place.
Existing Luanti/VoxeLibre installations are not automatically upgraded.

Host launchers currently target **Linux + Luanti Flatpak**. An existing native
Luanti install alone is not used by these launchers; native Linux, Windows or
macOS hosting would need another launcher. Kids can use supported Luanti client
platforms independently of this host limitation.

`LUANTI_WORLD_DIR` in server.sh and `LUANTI_DATA_DIR` in setup/link checks were
added as path overrides useful for isolated checks. Normal usage should leave
them unset; alternate runtime data roots are not fully configured by these hooks.

## Programming controls explained to the user

Right-click a robot with an empty hand to open its programming sheet.
The large left grid is the program; the upper-right palette holds command
markers. Hover for command names and scroll the palette as needed. The right
middle grid is robot Storage; below it is player inventory. The power icon is
at the far upper-right edge. Escape closes the editor to watch execution.

One bridge-building step is:

| Row | Cell 1 | Cell 2 |
| --- | --- | --- |
| 1 | Place forward, down | Oak plank marker |
| 2 | Move forward | Empty |

The plank in the sheet specifies the material; the actual plank must be in
robot **Storage**. Six copies of those two rows build the bridge from the
reset position. The user subsequently reported that basic processing works.

The loop version uses indentation:

| Row | Cell 1 | Cell 2 | Cell 3 |
| --- | --- | --- | --- |
| 1 | Loop | Counter is less than | Number with value 6 |
| 2 | Empty | Place forward, down | Oak plank marker |
| 3 | Empty | Move forward | Empty |

The empty first cells on rows 2–3 indent them into the loop. Counter values
0 through 5 run six repetitions; at 6 the loop stops.

**Number** is a green value marker, not a keyboard key or inventory quantity.
Move it to the single top slot beside **Value**, type `6`, click the nearby
**Set** button, then move the configured marker into the program after the
counter comparison.

Cassette operations, with the cassette held in the hand:

- Save a robot program: **left-click the robot once**.
- Load into a robot: **Shift/sneak + right-click the robot**; replaces its program.
- Label or set **Read Only**: right-click while pointing into the air.
- Loading does not start execution; click the robot's power button afterward.
- Cassettes copy programs, not building materials or a robot's position.

To stop a running robot, **sneak + punch** opens its stop dialog. A robot's
Storage must be empty before it can normally be dug up according to LWScratch.
The user reported a robot disappearing after interacting by hand; the exact
cause was not established. Recovery instructions were `/edu_reset_bridge`
for the challenge robot or `/edu_kit` for a spare, plus checking inventory.

Camera shortcut verified against installed defaults: **C** cycles first-person,
third-person rear, and third-person front. No camera binding override was found.

## Firewall discussion

The user asked how to disable a firewall. Commands were explained, not executed:

```sh
sudo systemctl stop firewalld                 # Stop for the current session
sudo systemctl disable --now firewalld       # Stop now and disable at boot
sudo ufw disable                            # Disable UFW
```

This laptop's `/etc/ufw/ufw.conf` read `ENABLED=no`. That observation is not proof
that every possible firewall on another laptop is inactive.

A narrower UFW troubleshooting command in README is:

```sh
sudo ufw allow from 192.168.1.0/24 to any port 30001 proto udp
```

That subnet was an example for the network observed here; adjust it for a new
network. No firewall rules, system services or router settings were changed.

## Validation completed

- Luanti discovered the symlinked world by its menu title.
- The actual graphical client joined the generated village without Lua errors.
- Real LWScratch sequence and six-iteration loop programs ran in disposable
  dedicated-server worlds, each placing all six bridge planks, moving six steps
  east and consuming exactly six planks (64 -> 58).
- Robot formspec/inventory presence and peaceful settings were asserted.
- Tests without players must forceload **both** mapblocks crossed by the bridge
  robot (negative X and nonnegative X). Forceloading only the starting block
  initially stalled execution after crossing X=0; the integration check was fixed.
- Multiplayer launcher test detected live addresses, listened on
  `0.0.0.0:30001`, loaded the village/mods, verified admin/account settings, and
  shut down automatically with exit code 0.
- Lock checks rejected a concurrent launcher and a database already open outside
  the launcher.
- `bash -n` and `shellcheck -x` passed for the relevant setup/runtime scripts.
- `setup-host.sh --check` detected all current prerequisites.
- Real VoxeLibre download matched the pinned release commit.
- A repeat game install reused the existing game.
- An incomplete existing game directory was refused and its contents preserved.

To rerun robot integration checks, one at a time:

```sh
./luanti-worlds/test-world.sh sequence
./luanti-worlds/test-world.sh loop
```

Each takes approximately 40 seconds, creates a disposable copy under `.tests`,
and binds localhost port 30099. `edu_selftest = true` must **not** be enabled in
the playable world: it rewrites the bridge robot's program, builds the bridge
and requests server shutdown.

VoxeLibre emits biome/mapgen warnings with singlenode. These appeared during
successful tests and do not by themselves indicate scenario failure. Check
world-local `debug.txt` (singleplayer) or `server.log` (multiplayer) for Lua errors.

## Remaining checks and next steps

The user has tried basic programming and said it works. README's earlier
"graphical editor still needs a human tryout" line predates that confirmation.

Still unverified:

- Connecting from the actual children's computers over the intended home network.
- Fresh-laptop system package and Luanti Flatpak installation branches; current
  laptop already had these dependencies. Game download/reuse was tested.
- The installation type/OS on the user's other host laptop beyond their statement
  that Luanti and VoxeLibre are already installed.

The dedicated-server tests used disposable worlds and shut themselves down.
Do not assume a playable dedicated server is currently running. The graphical
world was opened for the user earlier, but current client state was not audited
when writing this handoff.

Recommended next action: copy the complete project/save to the other host, use
the separate link/setup and server commands appropriate for a Linux Flatpak
host, then test a child joining with the printed address and port 30001. Later
teaching work can add sensor/condition lessons or separate tasks per child.

## Primary references

- Luanti installation: https://www.luanti.org/en/downloads/
- Client connections and server-side mods: https://docs.luanti.org/for-players/getting-started/
- Server hosting and UDP: https://docs.luanti.org/for-server-hosts/setup/linux/
- Flatpak usage: https://docs.flatpak.org/en/latest/using-flatpak.html
- LWScratch listing: https://content.luanti.org/packages/mt-mods/lwscratch/
  (direct browsing had an anti-bot challenge; repository source was inspected.)

Project README and the implementation files remain the operational source of
truth if they change after this snapshot.
