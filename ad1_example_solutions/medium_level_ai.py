
AVAILABLE = ["archer", "warrior", "wizard"]
# Goal: make your angel survive longer than the other team
#       summon units to protect it!
# Use game.spawn(<unitType>, <position_number>) to summon your unit.
# They are "auto chess"! You don't need to control their action.

game.spawn("warrior", 0)
game.spawn("warrior", 3)
game.spawn("archer", 1)
while True:
     game.spawn("archer", 5)
