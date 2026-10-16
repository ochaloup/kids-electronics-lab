# 02 micro:bit gold digging

**Gold Digging - micro:bit**: players dig gold out of a hill in a closed arena
(36 `mcl_core:stone_with_gold` blocks). Each gold block raises the player's
score, and the server sends a message to the micro:bits. Every kid programs
their own micro:bit to react with the display or LEDs. Kids never touch the
server.

```
Luanti server (mod edu_gold)
    │ USB cable, serial line /dev/ttyACM0
    ▼
gateway: micro:bit at the server (microbit/gateway.py)
    │ radio, group 7
    ▼
kids' micro:bits (microbit/starter.py, microbit/answer.py)
```

## Messages the kids' micro:bits receive

| Message | Meaning |
| --- | --- |
| `zeleny` | player `zeleny` dug one gold |

The micro:bit counts the gold itself, e.g. `score[player] = score.get(player, 0) + 1`.
Each kid decides who to react to and with which colour.

## Start

1. Flash `microbit/gateway.py` to the gateway micro:bit via
   [python.microbit.org](https://python.microbit.org/v/3), then close the editor
   tab. The tab holds the USB port and the server could not reach the micro:bit.
2. Plug the gateway into the server laptop and run:

   ```sh
   ./luanti-worlds/server.sh 02_microbit_gold_digging
   ```

   `server.sh` first runs `prestart.sh`. It finds the micro:bit, sends it
   `PING` (the gateway shows a tick) and passes the device to the mod. With
   several micro:bits, pick the gateway with
   `MICROBIT=/dev/ttyACM0 ./luanti-worlds/server.sh ...`. Without a micro:bit,
   start with `MICROBIT=none` (messages go to `server.log` only, possibly `tail -f ~/.var/app/org.luanti.luanti/.minetest/worlds/02_microbit_gold_digging/server.log`).
3. Kids join the game (port **30002**) with an empty inventory. Gold can only be
   dug with an iron pickaxe, so each round is a race:

   tree → crafting table → wooden and stone pickaxe → iron ore from the rocks →
   furnace (fuelled by wood) → iron pickaxe → gold

   The arena has 10 trees and 40 iron ores, enough for 10 kids. Kids flash
   `microbit/starter.py` to their micro:bit and change it from there.
   `microbit/answer.py` is just one possible solution.

`/gold_score` prints the standings. **New round** = stop the server (Ctrl+C)
and start it again: the world is fresh. Kids press the reset button on their
micro:bit to start counting from zero.

The radio group is set in `server.conf` (`edu_gold_radio_group`). The server
sends it to the gateway at start. Kids must use the same number in
`radio.config(group=7)`.

## LEDs

```
P0 → 220–330 Ω resistor → green LED → GND
P1 → 220–330 Ω resistor → blue LED → GND
```

The longer LED leg (anode) goes to the pin. The resistor keeps the pin current
to a few mA.

## Limits

- Radio reaches about one room, and messages can get lost, so a micro:bit
  count can be lower than `/gold_score`. `display.scroll`
  without `wait=False` blocks, so messages may be missed while text scrolls.
- If the gateway is unplugged while running, the server keeps going and writes
  messages to the log only. Reconnecting needs a server restart.
- After a gateway reset (button, power loss) the gateway is back on group 7.
  With another group, restart the server so it sends the right number.
- The mod may write to the serial port because of
  `secure.trusted_mods = edu_gold` in `server.conf`. This applies only to this
  server, not to `play.sh`.
