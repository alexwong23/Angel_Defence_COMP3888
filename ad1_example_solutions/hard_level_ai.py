AVAILABLE = ["archer", "warrior", "wizard"]
# Goal: make your angel survive longer than the other team.
#       summon units to protect it!
# Use game.spawn(<unitType>, <position_number>) to summon your unit.
# They are "auto chess"! You don't need to control their action.

unitNum = 0

archerCost = game.costOf("archer")
warriorCost = game.costOf("warrior")
wizardCost = game.costOf("wizard")

archerSpawnPos = 0
warriorSpawnPos = 4
wizardSpawnPos = 0

while True:
    if unitNum >= 18:
        game.levelUpAllies(game.gold)
    else:
        game.log(game.gold() + " check "+game.costOf("archer"))
        if game.gold() > archerCost:
            if archerSpawnPos < 6:
                game.spawn("archer", archerSpawnPos % 6)
                archerSpawnPos += 1
                unitNum += 1
        elif game.gold() > warriorCost:
            if warriorSpawnPos < 6:
                game.spawn("warrior", warriorSpawnPos % 6)
                warriorSpawnPos += 1
                unitNum += 1
        elif game.gold() > wizardCost:
            if wizardSpawnPos < 4:
                game.spawn("wizard", wizardSpawnPos % 6)
                wizardSpawnPos += 1
                unitNum += 1