# Objective: Defeat the enemy Angel
# How to play: Overwhelm the enemy using different techniques
# 1. Use your hero and the potions wisely TIP: hero.health
# 2. Spawn units and command them to aid you in battle
# 3. Make good use of the creeps spawned at the Angel
# TAKE NOTE: You cannot command the creeps. GLHF! :)

AVAILABLE = [
    "warrior", "knight", "thief",
    "archer", "wizard", "thrower",
    "buffer", "warlock", "peasant"]

# warriors attack the nearest non-neutral enemy!
def archerSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.team != "neutral":
            me.attack(enemy)

def archerDefendFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if me.pos.y < 48:
            me.moveXY(49, 49)
        else:
            if enemy and enemy.team != "neutral":
                me.attack(enemy)

def archerUpdateFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if me.pos.x < 54:
            me.moveXY(56, 45)
        else:
            if enemy and enemy.team != "neutral":
                me.attack(enemy)

def knightSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if me.pos.x < 69:
            me.moveXY(70, 54)
        else:
            if enemy and enemy.team != "neutral":
                me.attack(enemy)

# all warrior units will behave as instructed in the function 'warriorSpawnFunction'
game.setActionFor("archer", "spawn", archerSpawnFunction)
game.setActionFor("archer", "defend", archerDefendFunction)
game.setActionFor("archer", "update", archerUpdateFunction)

game.setActionFor("knight", "spawn", knightSpawnFunction)
game.setActionForUnit("knight-red-0", "update", archerUpdateFunction)
game.setActionForUnit("knight-red-0", "defend", archerDefendFunction)

while True:
    # spawn warrior units
    # use game.spawn()
    # e.g. game.spawn("warrior")
    archers = hero.findByType("archer", hero.findFriends())
    if hero.gold > hero.costOf("knight") and len(archers) >= 3:
        game.spawn("knight")
    elif hero.gold > hero.costOf("archer"):
        game.spawn("archer")

    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    enemies = hero.findEnemies()
    if item and hero.health < 60:
        hero.move(item.pos)
    elif not item and hero.health < 100:
        hero.say("defend!")
        hero.moveXY(63, 44)
        game.changeActionFor("archer", "defend")
        game.changeActionForUnit("knight-red-0", "defend")
    elif not item and hero.health < 200:
        hero.say("regroup!")
        game.changeActionFor("archer", "update")
        game.changeActionForUnit("knight-red-0", "update")
    else:
        hero.say("fight!")
        game.changeActionFor("archer", "spawn")
        game.changeActionForUnit("knight-red-0", "spawn")
        if enemy:
            hero.attack(enemy)
