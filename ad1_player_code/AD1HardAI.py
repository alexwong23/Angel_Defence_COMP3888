AVAILABLE = ["archer", "warrior", "wizard"]
# Goal: make your angel survive longer than the other team.
#       summon units to protect it!
# Use game.spawn(<unitType>, <position_number>) to summon your unit.
# They are "auto chess"! You don't need to control their action.

#Constants
TOTAL_SPAWN_NUMBER = 16

#warrior spawn position configuration
WARRIOR_SPAWN_NUMBER = 8

#warrior and archer spawn position configuration
WARRIOR_SPAWN_START_POS = 4
WARRIOR_SPAWN_POS_NUM = 2
ARCHER_SPAWN_POS_NUM = 4

#spend all initial 80 gold here
for i in range(0,4):
    game.spawn("wizard",i)
game.spawn("warrior",0)
game.spawn("warrior",1)

#unit number start with 6
unitNum = 6
archerCtr = 0
wizardCtr = 4
warriorCtr = 2

#initila the spawn position of units which will be spawned in while loop
archerSpawnPos = 0
warriorSpawnPos = 4

while True:
    if unitNum >= TOTAL_SPAWN_NUMBER:
        game.levelUpAllies(game.gold())
    else:
        if game.gold() >= game.costOf("warrior") and warriorCtr<WARRIOR_SPAWN_NUMBER:
            game.spawn("warrior", warriorSpawnPos%WARRIOR_SPAWN_POS_NUM+WARRIOR_SPAWN_START_POS)
            warriorSpawnPos+=1
            warriorCtr+=1
            unitNum+=1
        elif game.gold() >= game.costOf("archer") and warriorCtr>=WARRIOR_SPAWN_NUMBER:
            game.spawn("archer", archerSpawnPos%ARCHER_SPAWN_POS_NUM)
            archerSpawnPos += 1
            archerCtr+=1;
            unitNum += 1
