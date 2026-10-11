# 02 micro:bit gold digging

**Gold Digging - micro:bit**: hráči v uzavřené aréně těží zlato z kopce
(36 bloků `mcl_core:stone_with_gold`). Každé vytěžené zlato zvýší skóre hráče
a server pošle zprávu do micro:bitů. Každé dítě si programuje vlastní micro:bit,
který na zprávy reaguje displejem nebo LEDkami. Se serverem děti nic nedělají.

```
Luanti server (mod edu_gold)
    │ USB kabel, sériová linka /dev/ttyACM0
    ▼
brána: micro:bit u serveru (microbit/gateway.py)
    │ rádio, skupina 7
    ▼
micro:bity dětí (microbit/starter.py, microbit/answer.py)
```

## Zprávy, které micro:bity dětí dostávají

| Zpráva | Význam |
| --- | --- |
| `GOLD\|zeleny\|3` | hráč `zeleny` vytěžil zlato a má skóre 3 |
| `RESET` | server začal nové kolo, všechna skóre jsou 0 |

Rozdělení: `casti = zprava.split("|")`, pak `casti[1]` je hráč a
`int(casti[2])` skóre. Skóre se počítá zvlášť pro každé jméno hráče; kdo
reaguje na koho a jakou barvou, si každé dítě rozhodne samo.

## Spuštění

1. Do micro:bitu brány nahrajte `microbit/gateway.py` přes
   [python.microbit.org](https://python.microbit.org/v/3) a zavřete záložku
   editoru (drží USB a server by se k micro:bitu nedostal).
2. Připojte bránu k notebooku se serverem a spusťte:

   ```sh
   ./luanti-worlds/server.sh 02_microbit_gold_digging
   ```

   Skript najde micro:bit sám a brána ukáže fajfku. Při více micro:bitech
   vyberte bránu `MICROBIT=/dev/ttyACM0 ./luanti-worlds/server.sh ...`, bez
   micro:bitu spusťte s `MICROBIT=none` (zprávy jsou jen v `server.log`).
3. Děti se připojí ke hře (port **30002**), každé dostane železný krumpáč.
   Do svého micro:bitu nahrají `microbit/starter.py` a dál si ho upravují;
   `microbit/answer.py` je jen jedno možné řešení.

`/gold_score` vypíše pořadí. **Nové kolo** = zastavit server (Ctrl+C) a spustit
znovu: svět je čerstvý a micro:bity dostanou `RESET`.

Číslo rádiové skupiny je v `server.conf` (`edu_gold_radio_group`), server ho
při startu pošle bráně. Děti musí mít stejné číslo v `radio.config(group=7)`.

## LEDky

```
P0 → odpor 220–330 Ω → zelená LED → GND
P1 → odpor 220–330 Ω → modrá LED → GND
```

Delší nožička LED (anoda) jde k pinu. Odpor drží proud pinu na pár mA.

## Omezení

- Rádio dosáhne zhruba na jednu místnost; zprávy se mohou ztratit.
  `display.scroll` bez `wait=False` blokuje a během posouvání mohou další
  zprávy propadnout.
- Odpojí-li se brána za běhu, server pokračuje a zprávy píše jen do logu;
  znovu ji připojíte jen restartem serveru.
- Po resetu brány (tlačítko, výpadek napájení) brána vysílá zase ve skupině 7.
  Při jiné skupině je potřeba restartovat server, aby jí poslal správné číslo.
- Mod smí zapisovat na sériový port díky `secure.trusted_mods = edu_gold`
  v `server.conf`; platí jen pro tento server, ne pro `play.sh`.
