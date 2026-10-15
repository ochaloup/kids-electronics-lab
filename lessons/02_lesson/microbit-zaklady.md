# Základy programování s micro:bitem v Pythonu

<a href="https://python.microbit.org/v/3/" target="_blank">https://python.microbit.org/v/3/</a>

* [Klávesové zkratky](#klávesové-zkratky)
* [Slovníček](#slovnek)
* [Programy](#programy)
* [Poznámky k programování](#poznmky-k-programovn-v-pythonu)

## Klávesové zkratky

* **CTRL+A** - označit vše
* **CTRL+C** - zkopírovat označený text do schránky
* **CTRL+V** - vložit text ze schránky (do místa, kde je kurzor)
* **CTRL+mezerník** - zobrazení nápovědy po tečce "." v programovacím prostředí 

## Slovníček

| Anglicky | Česky |
| -------- | ----- |
| **while**     | **dokud** (cyklus, opakování) |
| **if**        | **pokud** (podminka, když-tak) |
| true          | pravda |
| false         | nepravda  |
| is            | je  |
| was           | bylo  |
| get           | dát (vrať nějakou hodnotu)  |
| button        | tlačítko  |
| pres(ed)      | stisknout (stisknuto)  |
| display       | displej, zobrazit  |
| show          | ukaž, zobraz  |
| sleep         | spát  |
| image         | obrázek  |
| clear         | čistit  |
| write         | psát  |
| read          | číst  |


## Programy

### 1. První program - skroluj text

```python
from microbit import *

while True:
    if button_a.was_pressed():
        display.scroll("AHOJ")
```

- `from microbit import *` – tzv. **boilerplate**. Potřebujeme ho, aby program znal funkce micro:bitu.
- `while True:` – `while` znamená **dokud**. Je to cyklus, v programování se vždy čeká "pravda". Tedy opakuj, dokud je něco pravdivé.
  - tedy `while <podmínka>` = opakuj, dokud je podmínka pravdivá.
  - `True` = pravda.
  - `False` = nepravda.
  - co se stane, když napíšeme `while False:`?
- `if` znamená **pokud**, je to podmínka - udělej, jestli je něco pravda.
  - `if <podmínka>` = udělej něco, pokud je podmínka pravdivá.
- `button_a` - "button" znamená "tlačítko", zde tlačítko A.
- `was_pressed()` - "was" znamená "bylo" (minulý čas slova "be", česky "být"), "press" znamená "zmáčknout", tedy "bylo zmáčknuto?"
- `display` - displej micro:bitu.
- `scroll("AHOJ")` - "posouvej", říká posouvej text na displeji
- Text píšeme do uvozovek: `"AHOJ"`, to tak programátoři dělají

---

### 2. Obrázek a čekání

```python
from microbit import *

while True:
    if button_a.was_pressed():
        display.show(Image.SKULL)
        sleep(2000)
        display.clear()
```

- `display.show(...)` - ukaž ("show" znamená "ukaž") něco na displeji.
- `Image.SMILE` - obrázek úsměvu. Co je asi "SKULL"?
- `sleep(2000)` - "sleep" znamená "spát", zde je to myšleno jako "čekej nějakou chvíli", programátoři pracují s milisekundami - tisícina sekundy
  - 1000 ms = 1 sekunda.
  - 2000 ms = 2 sekundy.
- `display.clear()` - "clear" znamená "vyčisti", takže zhasni / vyčisti displej.

---
-
### 3. Je tlačítko právě zmáčknuté?

```python
from microbit import *

while True:
    if button_a.is_pressed():
        display.show(Image.SMILE)
```

- "is" je přítomný čas slova "být", tedy znamená to "je"
- `is_pressed()` = **je právě zmáčknuto?**
- Výsledek je `True` nebo `False`.

Tlačítko umí například:

- `button_a.was_pressed()` – bylo od minula zmáčknuto?
- `button_a.is_pressed()` – je právě teď zmáčknuto?
- `button_a.get_presses()` – kolikrát bylo od posledního dotazu zmáčknuto?

---

### 4. Dlouhé zmáčknutí

```python
from microbit import *

while True:
    if button_a.is_pressed():
        sleep(3000)

        if button_a.is_pressed():
            display.show(Image.SMILE)
            sleep(2000)
            display.clear()
```

Co program dělá?

1. Zjistí, jestli je tlačítko A zmáčknuté.
2. Počká 3 sekundy.
3. Znovu se podívá, jestli je stále zmáčknuté.
4. Pokud ano, ukáže úsměv.

---

### 5. Čidla micro:bitu

Micro:bit nemá jen tlačítka a displej. Umí také něco měřit.

### 5.1 Teplota

```python
from microbit import *

while True:
    if button_a.was_pressed():
        display.scroll(str(temperature()))
```

- `temperature()` = zjisti teplotu ("temperature" znamená "teplota")
- Výsledkem je číslo.
- `str(...)` převede číslo na text, aby ho mohl displej posouvat, zase nějaké programátorské techtle mechtle...

---

#### 5.2 Mikrofon

```python
from microbit import *

while True:
    if microphone.was_event(SoundEvent.LOUD):
        display.show(Image.HEART)
        sleep(1000)
        display.clear()
```

- "microphone" je "mikrofon", "was" už víme znamená "bylo", "event" znamená "událost" a SoundEvent pak je "zvuková událostů, "LOUD" znamená hlasitý - tedy, když byla hlasitá událost
  - "když" je podmínka, tak to můžeme vrazit do "if <podmínka>" a když to bude pravda, tak se něco stane
- `microphone` - mikrofon.
- `was_event(...)` - stala se nějaká událost?
- `SoundEvent.LOUD` - hlasitý zvuk.
- Když micro:bit zaznamená hlasitý zvuk, podmínka je `True`.

---

#### 5.3 Akcelerometr

```python
from microbit import *
import random

answers = [
    "Je to jiste",
    "Rozhodne ano",
    "Bez pochyby",
    "Ano, urcite",
    "Muzes s tim pocitat",
    "Podle me ano",
    "Velmi pravdepodobne",
    "Vypada to dobre",
    "Ano",
    "Vse nasvedcuje tomu, ze ano",
    "Odpoved je nejasna, zkus to znovu",
    "Zeptej se znovu pozdeji",
    "Ted ti to radsi nereknu",
    "Ted se to neda predpovedet",
    "Soustred se a zeptej se znovu",
    "Nespolehej na to",
    "Odpoved zni ne",
    "Podle vseho ne",
    "Nevypada to dobre",
    "Velmi nepravdepodobne",
]

while True:
    display.show("8")
    if accelerometer.was_gesture("shake"):
        display.clear()
        sleep(1000)
        display.scroll(random.choice(answers), delay = 120)
```

- protože program pracuje s náhodou, je tu použité přidání nové "znalosti" pro program - `import random`
  - "random" je anglicky náhoda
  - `import random` znamená "přidej/nauč se náhodu"
- "answers" znamená anglicky odpovědi
- použití `answers = <něco>` znamená "přiřazení do proměnné", můžeme si tak uložit různá data pro další použití v programu
  - `jmeno = "Petr"` uloží do proměnné pojmenované `jmeno` hodnotu textu `""` `Petr`. Proměnnou jméno od chvíle definice náš program zná a může ji použít.
  - `cislo = 3` uloží do proměnné pojmenované `cislo` hodnotu čísla `3`
  - `answers = [ ... ]`, je složitější přiřazení (uložení) do proměnné, kde se ukládá _seznam_ textů. V tomto případě každý řádek je oddělený čárkou `,`
    a ukládáme tak seznam různých hodnot. V programování se tomu říká "pole" (anglicky `array`).
  - chceme-li vyvolat jednu hodnotu pole a použít ji přímo, pak použijeme proměnnou a k ní přidáme hranaté závorky `[]` a do nich pak číslo pořadí.
    Začínáme počítat od nuly. `answers[0]` vrátí `"Je to jisté"`.
  - můžeme tak "pole" použít třeba v `display.scroll` přímo a příkaz `display.scroll(answers[10])` zobrazí vždý `"Odpověď je nejasná, zkus to znovu"`
  - používáme písmena bez háčků a čárek, protože microbit neumí diakritiku správně zobrazovat
- "accelerometer" je čidlo pohybu a `was_gesture` znamená jestli byl proveden nějaký "pohyb", `shake` znamená zatřást
  - máme i jiné typy pohybů, které microbit pozná - jsou dokumentované tady: https://python.microbit.org/v/3/reference/accelerometer
- `random.choice` vybere náhodný prvek z pole `answers` a vrať ho, scroll takto získaný prvek z pole vezme a zaskroluje na displeji
- co program tedy dělá? 
  1. `while True` opakuje stále dokola
  2. na displeji `display` se zobrazí `show` osmička 
  3. kontroluje, jestli `if` někdo zatřásl `was_gesture("shake") microbitem, když ano, pak
  4. `clear` vyčistí displej
  5. čeká `sleep` 1 sekundu
  6. displey `display` zobrazí `scroll` náhodný `random.choice` nápis ze seznamu `answers`, parameter "delay", zrychluje přehrátí zprávy

---


### 6. Diody

Nemusíme jen pracovat s mikrobitem, ale mikrobit může i ovládat, co k němu zapojíme.
K tomu slouží PINy.

```python
from microbit import *

while True:
    if microphone.was_event(SoundEvent.LOUD):
        pin0.write_digital(1)
        sleep(1000)
        pin0.write_digital(0)
```

## Poznámky k programování v Pythonu

### Dvojtečka

Za `while` a `if` píšeme `:`.

```python
if button_a.was_pressed():
```

### Odsazení

To, co patří pod `while` nebo `if`, musí být odsazené.

```python
while True:
    if button_a.was_pressed():
        display.show(Image.SMILE)
```

Odsazení říká Pythonu, **které příkazy patří dovnitř podmínky nebo cyklu**.


### Komentář

Když chci něco nechat na obrazovce, ale nechci aby se provádělo

```python
# toto je zakomentované a není to kód, který by se provedl
```

