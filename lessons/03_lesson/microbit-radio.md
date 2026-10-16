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
| in         | v, unvitř          |
| not        | (zápor), ne        |

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

"Program se vším všudy"

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

nebo pokročilejší


```python
from microbit import *
import radio

STORAGE={}

radio.config(group=7)
radio.on()

def set_and_get_score(message: str):
    if message not in STORAGE:
        STORAGE[message] = 1
    else:
        STORAGE[message] = STORAGE[message] + 1

    return STORAGE[message]


while True:
    message = radio.receive()
    if message:
        display.show(set_and_get_score(message))
```

* `WHAT="BLINK"` do proměnné `WHAT` ukládáme slovo (řetězec) `"BLINK"`
  * když pracujeme s řetězcem, vždy používáme výraz v uvozovkách `""`
  * název proměnné ("kyblíčku", kde je uložena nějaká hodnota) může být jakýko-li - zde je použit výraz `WHAT`, ale může to být `MOJE_NEJAKA_PROMENNA`, nebo třeba `kdojetunejlepsi`, pro název proměnné používáme: velká a malá písmena, podtržítko, čisla a možná ještě něco
* `STORAGE={}` do proměnné `STORAGE` ukládáme objekt - obálku na další strukturované informace
  * "objekt" je možná divný termín, můžeme si představit, že je to obálka pro kyblíky do které nacpeme různé věci - další objekty, řetězce, čísla a tak podobně
  * `{}` označuje prázny objekt - jen prázdnou obálku
* `def set_and_get_score()` je vytvoření metody nebo funkce, která něco udělá a můžeme ji použít (zavolat) na různých místech
  * pracujeme zde zase s odsazením - je třeba aby `def` bylo uvedeno hned u kraje programu, vše co je odsazeno dále (`if`, `else`, `return`) je vykonáno v rámci metody, co začíná zase u kraje je už jiná část programu (nepatří do definice metody)
  * metoda může být pojmenována jak chceme (stejně jako proměnná), ale Python potřebuje vědět, že je to metoda a tak je tu povinné napsat `def` a `()` a `:`, tedy třeba `def cokoli():`
* `if/else` říká když je něco pravda tak udělej něco, když to není pravda, tak udělej něco jiného; `return` říká vrať nějaký výsledek z metody - výsledek se pak použije třeba pro uložení do proměnné nebo se zobrazí na displeji (`display.show(nazev_metody())`)
  * `if WHAT not in STORAGE:` lze přečíst jako anglickou větu - když obsah proměnné `WHAT` není uložen v objektu (obálce) `STORAGE` (v tomto případě když není v `STORAGE` hodnota řetězce `BLINK`) potom něco udělej
    * "potom" je zapsáno dvojtečkou `:`
  * `STORAGE[WHAT] = 1` znamená uložení hodnoty jedna (`1`) do krabičky hodnoty `WHAT` - tedy `"BLINK"` "krabička" v "obálce" `STORAGE` bude obsahovat hodnotu 1
  * `STORAGE[WHAT] = STORAGE[WHAT] + 1` - vezmi hodnotu z `STORAGE` v krabičce `WHAT` a ulož ji na stejné místo, jen k její hodnotě přidej jedničku (k tomu co tam je přičti jedna a ulož zpět)
  * `return STORAGE[WHAT]` - tomu kdo tě zavolal vrať hodnotu uloženou v "krabičce" `WHAT`. Protože tu pracujeme od začátku s čísly, bude vrácená hodnota nějaké číslo.
* jméno metody, například `set_and_get_score`, se musí zapsat se závorkami `()`, jinak se metoda nezavolá, správně tedy `set_and_get_score()` pro spuštění metody a získání výsledku (návratové hodnoty)


## 5. A co odesílání

```python
from microbit import *
import radio

radio.config(group=7)
radio.on()

score = {}
players = ["matej", "jakub"]

for player in players:
    score[player] = 0


def send_player(index):
    player = players[index]
    score[player] += 1
    display.show(player[0])
    sleep(750)
    display.show(score[player])
    radio.send(player)


while True:
    if button_a.was_pressed():
        send_player(0)

    if button_b.was_pressed():
        send_player(1)
```


