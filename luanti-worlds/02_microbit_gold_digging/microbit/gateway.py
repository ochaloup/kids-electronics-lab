# Gateway micro:bit on the server laptop: forwards each line from USB serial over radio.
from microbit import *
import radio

uart.init(115200)
radio.on()
radio.config(group=7)
buffer = b""

while True:
    if uart.any():
        buffer += uart.read()
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
                elif text:
                    radio.send(text)
                    display.set_pixel(2, 2, 0 if display.get_pixel(2, 2) else 9)
            except ValueError:
                display.show(Image.NO)
