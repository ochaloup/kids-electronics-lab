# Začátek: micro:bit poslouchá rádio a ukazuje zprávy ze hry.
from microbit import *
import radio

radio.on()
# Stejné číslo skupiny, jaké používá brána u serveru.
radio.config(group=7)

while True:
    zprava = radio.receive()
    if zprava:
        display.scroll(zprava)
