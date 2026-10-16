# One possible solution: counts the gold of every player. Everyone picks their own rules.
from microbit import *
import radio

radio.config(group=7)
radio.on()
score = {}
players = ["matej", "jakub"]
for player in players:
    score[player] = 0

while True:
    # Example message: "matej" (player matej dug one gold).
    player = radio.receive()
    if player:
        score[player] = score.get(player, 0) + 1
        # wait=False: no messages are missed while the text scrolls.
        display.scroll(player[0].upper() + " " + str(score[player]), wait=False)
