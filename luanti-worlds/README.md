# Luanti programming worlds

The clean world template and installed LWScratch mods live in
`edu_village_river_01`. Each launch creates a separate playable copy in
`sessions`. Named snapshots live in `saved-worlds`. Luanti's world directory
links to a session, so playing does not change the template.

## Fresh starts and named saves

The default server command starts a **brand new teaching world every time**:

```sh
./luanti-worlds/server.sh
```

"New" means the village, river, and robots are freshly generated, with no player
builds or robot programs from earlier sessions. It is not a blank landscape.
Player inventories and accounts are fresh too; passwords are optional.

When you want to keep a lesson's progress, stop the server with Ctrl+C or
`/shutdown`, then give the latest session a name:

```sh
./luanti-worlds/save-world.sh lesson-1
```

To continue that saved world later:

```sh
./luanti-worlds/server.sh lesson-1
```

This opens a **copy** of `saved-worlds/lesson-1`; the saved snapshot remains
unchanged. After continuing, stop and save with a new name, such as `lesson-2`.
Existing save names are never overwritten. Saved worlds include builds, robot
programs/storage, cassette data, inventories and accounts.

To see named saves and previous session IDs:

```sh
./luanti-worlds/list-worlds.sh
```

Previous session folders are retained even if you start another fresh world.
If you forgot to name a save before the next start, you can recover an older
stopped session using its ID from the list:

```sh
./luanti-worlds/save-world.sh recovered-lesson --session SESSION_ID
```

Saving a running world is refused: stop it first so all SQLite data is saved
consistently. Only one session can be hosted by these launchers at a time;
you can still join that host normally as a client.

Your original practice world was preserved as **attempts-2026-09-14** before
its player data was removed from the template. To revisit it:

```sh
./luanti-worlds/server.sh attempts-2026-09-14
```

`sessions` and `saved-worlds` are ignored by Git. Copy them separately when you
want to transfer progress to another laptop. Sessions accumulate on disk; no
automatic cleanup is performed. The Python controller is `worlds.py`.

## Play

From the project root:

```sh
./luanti-worlds/play.sh
```

This opens **Programming Village - LWScratch** directly, using its dedicated
configuration. Your existing VoxeLibre Flatpak installation supplies the game.
Each invocation starts a fresh session; give the village a moment to appear.
To explore a saved world in singleplayer:

```sh
./luanti-worlds/play.sh --saved lesson-1
```

The link is:

```text
~/.var/app/org.luanti.luanti/.minetest/worlds/edu_village_river_01
  -> /path/to/this/project/luanti-worlds/sessions/SESSION_ID
```

If you move this project, update the link and Flatpak permission with
`./luanti-worlds/link-world.sh`. The script refuses to replace a different
existing world. A link already managed by this project is updated to the
selected session. Flatpak is granted access only to this project's
`luanti-worlds` folder. Game data and logs are written into the session folder.

Selecting the linked world from Luanti's normal menu continues that linked
session. To get a fresh world, use the launchers. The scenario enforces
daylight, disabled damage/PvP/hunger, and disabled natural mob/weather cycles.
The launcher additionally supplies a small singlenode map and separate client
settings. For shared play, use the server launcher below.

## Play together over the home network

### Set up a host laptop

Copy this project to the laptop, then run these commands from the project root:

```sh
./luanti-worlds/setup-host.sh
./luanti-worlds/server.sh
```

The installer supports Linux hosts. It installs missing system tools through
APT (Ubuntu/Debian), DNF (Fedora), or Pacman (Arch), using sudo only for system
packages. Run it as your normal user, **without sudo**. It reuses an installed
Luanti Flatpak or installs it from Flathub for your user, installs the tested
[VoxeLibre 0.92.1 release](https://github.com/VoxeLibre/VoxeLibre/releases/tag/0.92.1)
if no game is installed, and links the world with its Flatpak permission.
Existing games and worlds are preserved. LWScratch and xcompat are already
included in this project; they do not need separate installation.

The first setup needs internet access; repeat runs reuse existing installations.
To inspect prerequisites without making changes:

```sh
./luanti-worlds/setup-host.sh --check
```

The kids **do not run this host installer**. They only install Luanti and connect.

If the host already has Luanti **as a Flatpak** and VoxeLibre installed, just
copy the complete project and run:

```sh
./luanti-worlds/link-world.sh
./luanti-worlds/server.sh
```

Installation, linking, and starting are separate commands. `setup-host.sh`
orchestrates the one-time setup; `server.sh` does not install anything.

### On the laptop

Leave the singleplayer world first (Escape -> Exit to Menu). The same saved world
can be opened by only one host at a time. Then, from the project root:

```sh
./luanti-worlds/server.sh
```

Leave this terminal running during the lesson. The server starts a fresh world
unless you provide a saved-world name, and listens on **UDP port 30001**. Stop it
with **Ctrl+C**; it saves the world as it shuts down. The laptop must remain on
and awake. The launcher prints current Ethernet/Wi-Fi addresses. Configuration
is in `luanti-worlds/server.conf`; logs are in that session's `server.log`.

You can play on the laptop while the dedicated server runs: open Luanti normally,
choose **Join Game**, and connect to `127.0.0.1`, port `30001`. Register the name
**ondra** on the first connection; a password is optional. That name is configured
as the administrator and can use `/edu_reset_bridge`, `/edu_rebuild_village`,
and `/shutdown`. Use the same password on later connections. The earlier
singleplayer identity was `singleplayer`; `ondra` starts with a new inventory
and receives a robot kit.

### On each child's computer

1. Install a current stable **Luanti** from the
   [official downloads page](https://www.luanti.org/en/downloads/).
   Windows: download and extract the build, then run the Luanti application.
   macOS: install the downloaded application. Linux: use the download page's
   distribution instructions or the Luanti Flatpak.
2. Connect to the same home network as the laptop.
3. Open Luanti and choose **Join Game**. A game-install prompt is for local play;
   it is not necessary to install a game to join this server.
4. Enter the laptop's LAN address and port `30001`.
5. Register a different player name for each child. Passwords may be left empty.
   On subsequent connections use that same name/password. First connection
   may take a little longer while assets download.

They do **not** need to install VoxeLibre, LWScratch, xcompat, or this world.
The server runs the mods and sends the required content automatically, as
explained in the [Luanti connection guide](https://docs.luanti.org/for-players/getting-started/).
This laptop currently has Luanti 5.16.1; use that version or a current stable
5.x client. Exact version matching is not forced by this server.

The server command detects the laptop's current addresses every time it starts,
so there is no fixed laptop IP to edit in a configuration file. It prints an
**Address** and **Port** for each Ethernet/Wi-Fi interface; use the one on the
kids' network. Join the home
network rather than a guest Wi-Fi network that isolates devices. Hosting over
the home network does not require router port forwarding. `server_announce`
is disabled, so this world is not advertised in the public server list.

The laptop's UFW configuration currently says `ENABLED=no`. If you later enable
UFW and connections time out, allow this port from the home subnet:

```sh
sudo ufw allow from 192.168.1.0/24 to any port 30001 proto udp
```

This command is provided for troubleshooting; the setup has not changed your
firewall. Luanti's [server hosting guide](https://docs.luanti.org/for-server-hosts/setup/linux/)
confirms that the server port uses UDP.

On a different Linux laptop, copy the project (including `saved-worlds` if you
want your named saves),
run `./luanti-worlds/setup-host.sh`, then use the same
`./luanti-worlds/server.sh` command. All launcher paths are
resolved relative to their location. Copy saves after stopping the old host,
so the SQLite files contain a consistent save.

Each new player receives their own robot kit. The two robots already in the
village are shared, so coordinate who edits them. When a child places a new
robot, they can choose **Private** to keep its programming sheet for themselves,
or **Public** to share it. Cassette programs and player inventories are saved
on the laptop and remain available on later connections.

## First experiment

1. Walk east along the village path to the river. The bridge robot is already
   placed and faces the far bank. Right-click it to open LWScratch's sheet.
2. Its Storage contains 64 oak planks. Your starter inventory also contains
   planks, a spare robot and a cassette.
3. Drag **Place forward, down** from the command palette into the first cell.
   Drag an oak plank from your inventory into the next cell as an item marker.
4. Put **Move forward** on the second line. Repeat these two lines six times.
5. Press the power button. Run `/edu_check` to check the bridge.

Each placement fills a gap at ground level in front of the robot; the next move
advances onto that block. The six gap blocks are `x=-3..2, y=0, z=0`. The robot
starts at `(-4,1,0)` facing +X. Inventory items in the program are markers;
the actual building material must be in the robot's **Storage**.

For the loop version, clear the sheet and use:

```text
Loop | Counter is less than | Number 6
    Place forward, down | oak plank marker
    Move forward
```

Indent both action lines by one cell. To set Number, move its marker to the top
Value slot, type `6`, click Set, and then put it in the program. Block boundaries
are controlled by indentation. The practice robot on the southern stone
platform is available for movement, turns, digging, and other experiments.

While running, **sneak + punch** opens the robot's stop dialog. Cassettes store
and copy programs. A robot must have empty Storage before you can dig it up.

Right-click the wooden lesson board near spawn for the same instructions.

## Commands

| Command | Purpose |
| --- | --- |
| `/edu_home` | Return to the village spawn |
| `/edu_kit` | Get another robot, cassette and 64 oak planks |
| `/edu_check` | Count the six oak bridge blocks |
| `/edu_reset_bridge` | Clear the bridge and replace its robot with a fresh one |
| `/edu_rebuild_village` | Reset the entire scene, including player builds and robots |

Reset commands require `server` privilege, which the singleplayer host has.
This is an exploration world: manual building is allowed, and the completion
check counts blocks rather than proving they were placed by a robot.

## Installed sources

The unmodified third-party source and its licenses are included in `worldmods`:

| Mod | Source | Pinned commit |
| --- | --- | --- |
| LWScratch | https://github.com/mt-historical/lwscratch | `6815a37bf56b2914a231212588b01d07d9ef7ba3` |
| xcompat | https://github.com/mt-mods/xcompat | `758684dac8875d06d8c1565e323ee52c9d4daf7f` |

LWScratch code is LGPL 2.1 and media CC-BY-SA 3.0. xcompat has its own bundled
license. The scenario code is in `worldmods/edu_village_river/init.lua`.
The LWScratch manual is bundled at `worldmods/lwscratch/docs/lwscratch.pdf`
and `worldmods/lwscratch/readme.txt`.

The installed runtime checked for this setup was Luanti **5.16.1** and
VoxeLibre **0.92.1**. These are the actual installed versions, superseding the
version recorded in the earlier planning note.

## Integration check

From the project root, run one check at a time:

```sh
./luanti-worlds/test-world.sh sequence
./luanti-worlds/test-world.sh loop
```

Each takes about 40 seconds and uses a fresh copy under `.tests`, bound to
localhost on port 30099. The playable world is not modified.

`worldmods/edu_village_river/selftest.lua` is an opt-in check for disposable world
copies, activated by `edu_selftest = true` in their configuration. It compiles
and executes a real LWScratch program, checks placement and storage consumption,
then shuts down the server. Do not enable it in the world you play: it programs
the bridge robot and builds the bridge.

VoxeLibre emits biome warnings with singlenode mapgen; these do not by themselves
indicate that the teaching scene or LWScratch failed. See the world-local
`debug.txt` for runtime errors.

Validation on September 14, 2026: the sequence and six-iteration loop both
completed under the installed Flatpak, placed all six bridge planks, moved the
robot six steps east, and consumed exactly six planks. Luanti discovered the
symlinked world and its graphical client joined the generated village without
Lua errors. The graphical drag-and-drop editing experience still needs a human
tryout.

The multiplayer launcher was also checked in a disposable world: it detected
current LAN addresses, listened on `0.0.0.0:30001`, loaded the village and robot
mods, applied the administrator/account settings, and shut down cleanly. The
launcher also rejects concurrent hosts for the same world. Connecting from the
kids' actual computers remains to be tried on the home network.

Host installer validation: shell checks passed; existing requirements were
detected on this laptop; the real VoxeLibre download matched its pinned commit;
a repeat install reused the downloaded game; and an incomplete existing game
directory was refused without changing its contents. System-package and Flatpak
installation on a fresh laptop have not been exercised here because this laptop
already has those requirements.

The fresh/save/resume lifecycle was checked with real Luanti servers in an
isolated fixture: a loop built the bridge, the finished world was saved, the next
default start had an empty bridge and unprogrammed robot, and loading the named
save restored the completed bridge and robot storage. All servers shut down
cleanly. Persistence/controller checks run with:

```sh
python3 luanti-worlds/test_worlds.py
```
