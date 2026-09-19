# Základy programování s micro:bitem v Pythonu

## 1. První program

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

## 2. Obrázek a čekání

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
## 3. Je tlačítko právě zmáčknuté?

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

## 4. Dlouhé zmáčknutí

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

## 5. Čidla micro:bitu

Micro:bit nemá jen tlačítka a displej. Umí také něco měřit.

### Teplota

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

### Mikrofon

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

### Diody

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

## Dvě důležité věci v Pythonu

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
