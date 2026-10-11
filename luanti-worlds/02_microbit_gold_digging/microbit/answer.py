# Jedno možné řešení. Barvy, hráče i pravidla si každý vymyslí po svém.
from microbit import *
import radio

MODRY = "modry"
ZELENY = "zeleny"

radio.on()
radio.config(group=7)
skore = {}


def ukaz_kdo_vede():
    modry = skore.get(MODRY, 0)
    zeleny = skore.get(ZELENY, 0)
    # P0 = zelená LED, P1 = modrá LED; při remíze nesvítí žádná.
    pin0.write_digital(1 if zeleny > modry else 0)
    pin1.write_digital(1 if modry > zeleny else 0)


while True:
    zprava = radio.receive()
    if zprava == "RESET":
        skore = {}
        display.clear()
        ukaz_kdo_vede()
    elif zprava and zprava.startswith("GOLD|"):
        casti = zprava.split("|")
        hrac = casti[1]
        skore[hrac] = int(casti[2])
        # wait=False: během posouvání textu nám neutečou další zprávy.
        display.scroll(hrac[0].upper() + " " + casti[2], wait=False)
        ukaz_kdo_vede()
