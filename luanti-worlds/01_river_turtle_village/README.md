# 01 River turtle village

**Programming Village - LWScratch**: a calm VoxeLibre village by a river. Kids
program LWScratch robots to build a six-block bridge, first as a sequence, then
as a loop. Start, save and host it with the shared scripts described in
[../README.md](../README.md), for example:

```sh
./luanti-worlds/server.sh 01_river_turtle_village
```

A fresh world means the village, river and robots are newly generated, with no
builds or robot programs from earlier sessions; it is not a blank landscape.
The scenario enforces daylight, disabled damage/PvP/hunger and no natural mob
or weather cycles. The server listens on UDP port **30001**; the admin name
**ondra** (in `server.conf`) can use `/edu_reset_bridge`, `/edu_rebuild_village`
and `/shutdown`.

Each new player receives their own robot kit. The two robots already in the
village are shared, so coordinate who edits them. A child placing a new robot
can choose **Private** to keep its programming sheet, or **Public** to share it.

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

## Mods

`mods.txt` pins the unmodified third-party mods that setup installs into
Luanti's `mods` folder:

| Mod | Source | Pinned commit |
| --- | --- | --- |
| LWScratch | https://github.com/mt-historical/lwscratch | `6815a37bf56b2914a231212588b01d07d9ef7ba3` |
| xcompat | https://github.com/mt-mods/xcompat | `758684dac8875d06d8c1565e323ee52c9d4daf7f` |

LWScratch code is LGPL 2.1 and media CC-BY-SA 3.0. xcompat has its own bundled
license. The scenario code is in `worldmods/edu_village_river/init.lua`.
The LWScratch manual is at `mods/lwscratch/docs/lwscratch.pdf` and
`mods/lwscratch/readme.txt` in Luanti's user data folder.

## Self-test

```sh
./luanti-worlds/test-world.sh 01_river_turtle_village sequence
./luanti-worlds/test-world.sh 01_river_turtle_village loop
```

`worldmods/edu_village_river/selftest.lua` runs only with `edu_selftest = true`.
It compiles and executes a real LWScratch program, checks placement and storage
consumption, then shuts down the server. Never enable it in a world you play:
it programs the bridge robot and builds the bridge. VoxeLibre's biome warnings
with singlenode mapgen are expected; look for Lua errors in `debug.txt`.

## Validation history

September 14, 2026: the sequence and loop programs placed all six planks, moved
the robot six steps east and consumed exactly six planks. The graphical client
joined the village without Lua errors. The multiplayer launcher listened on
`0.0.0.0:30001` and shut down cleanly; a real fresh/save/resume cycle restored
the finished bridge from a save. October 10, 2026: the full setup, server,
save and uninstall cycle passed on Luanti 5.17.0 with VoxeLibre 0.92.3.
Connecting from the kids' own computers is still untested.
