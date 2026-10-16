# Gateway micro:bit on the server laptop: sends the player name of each gold message over radio.
from microbit import *
import radio

uart.init(115200)
radio.config(group=7)
radio.on()
buffer = b""

while True:
    data = uart.read()
    if not data:
        continue
    buffer += data
    while b"\n" in buffer:
        line, buffer = buffer.split(b"\n", 1)
        # A bad line (noise when plugging in, a wrong group) is skipped, never fatal.
        try:
            text = str(line, "utf-8").strip()
            if text.startswith("GROUP|"):
                group = text.split("|")[1]
                radio.config(group=int(group))
                display.scroll(group, wait=False)
            elif text == "PING":
                display.show(Image.YES)
            elif text.startswith("GOLD|"):
                # Example: "GOLD|zeleny|3" from the server goes out as "zeleny".
                radio.send(text.split("|")[1])
                display.set_pixel(2, 2, 0 if display.get_pixel(2, 2) else 9)
        except ValueError:
            display.show(Image.NO)
