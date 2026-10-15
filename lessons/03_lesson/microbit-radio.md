# Použití radia s micro:bitem

<a href="https://python.microbit.org/v/3/" target="_blank">https://python.microbit.org/v/3/</a>

----

## Slovníček

První část na [Základy programování s micro:bitem v Pythonu](../02_lesson/microbit-zaklady.md#slovnek)

| Anglicky   | Česky              |
| ---------- | ------------------ |
| config     | konfiguruj, nastav |
| on         | zapnuto, v chodu   |
| off        | vypnuto            |
| group      | skupina            |
| send       | poslat             |
| receive    | přijmout           |
| message    | zpráva             |
| pitch      | výška tónu         |
| range      | rozsah, rozpětí    |
| for        | **cyklus**, pro každé X něco udělej  |
| set        | nastav             |
| get        | získej             |
| counter    | počítadlo          |
| storage    | skladiště          |
| return     | vrať               |

----



## 1. Komunikace přes rádio dvou microbitů

### Odesílající (microbit číslo 1)

```python
from microbit import *
import radio

radio.config(group=7)
radio.on()

while True:
    if button_a.was_pressed():
        radio.send("AHOJ")
```

### Přijímající (microbit číslo 2)

```python
from microbit import *
import radio
import music

radio.config(group=7)
radio.on()

while True:
    message = radio.receive()

    if message:
        display.scroll(message)
        music.pitch(440, 200)
```

* `from microbit import *` – to už známe, říkáme Pythonu, aby uměl pracovat s funkcemi připravenými pro microbit
* `import radio` a `import music` – je podobné, kdy říkáme Pythonu, aby uměl pracovat s funkcemi ovládající rádio a muziku pro microbit
* následně konfigurujeme radio - říkáme nastav `config` skupinu `group` vysílače rádia na určitou hodnotu. Vysílač a přijímač, které jsou ve stejné skupině spolu umí mluvit.
* `while` je [smyčka](https://github.com/ochaloup/kids-electronics-lab/blob/main/lessons/02_lesson/microbit.md#1-prvn%C3%AD-program---skroluj-text), znamená opakuj **dokud** je něco pravda (pravda je pravdou vždy, takže zde se jedná o nekonečnou smyčku)
* `radio.send` pošle zprávu
* `radio.receive` zkontroluje, zda byla přijata nějaká zpráva, pokud ano, uloží ji do proměnné `message`
* `music.pitch` zahraje tón určité výšky určitou dobu, je to `music.pitch(<<výška tónu, frekvence tónu v Hz>>, <<délka přehrávání, délka tónu v milisekundách>>)`


## 2. Vysílač i přijímač v jednom

```python
from microbit import *
import radio
import music

radio.config(group=7)
radio.on()

while True:
    if button_a.was_pressed():
        radio.send("AHOJ")

    message = radio.receive()

    if message:
        display.scroll(message)
        music.pitch(440, 200)
```

## 3. Přijímač vysílání bliká

```python
from microbit import *
import radio

WHAT="BLINK"

radio.config(group=7)
radio.on()

while True:
    message = radio.receive()

    if message == WHAT:
        for _ in range(5):
          pin0.write_digital(1)
          sleep(200)
          pin0.write_digital(0)
          sleep(200)
```

* novinkou je tu takzvaný `for` cyklus, který znamená "pro každé číslo v rozsahu něco udělej
  * zápis `for _ in range(5)` znamená napočítej do 5
  * stejnou věc můžeme trochu rozepsat jako `for i in range(5)` a pak proměnná `i` obsahuje čísla v rozsahu (slovo "range" znamená "rozsah") od 0 do 4
    * setkáváme se zde se dvěma zajímavostmi - proměnná `i` je v cylu `for` naplněna nějakou hodnotou, kterou můžeme využít, a potom rozsah se v programování počítá ("indexuje") od `0`. Požítáme tedy `0,1,2,3,4` (5 hodnot, kdy první je `0`) a nepočítáme(**!**) od jedné

## 4. Ukládání do objektu a metody

```python
from microbit import *
import radio

WHAT="BLINK"
STORAGE={}

radio.config(group=7)
radio.on()

def set_and_get_score():
    if WHAT not in STORAGE:
        STORAGE[WHAT] = 1
    else:
        STORAGE[WHAT] = STORAGE[WHAT] + 1

    return STORAGE[WHAT]


while True:
    message = radio.receive()

    if message == WHAT:
        display.show(set_and_get_score())
```

* TODO...