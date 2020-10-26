# Objective: Defeat the enemy Angel
# How to play: Overwhelm the enemy using different techniques
# 1. Use your hero and the potions wisely TIP: hero.health
# 2. Spawn units and command them to aid you in battle
# 3. Make good use of the creeps spawned at the Angel
# TAKE NOTE: You cannot command the creeps. GLHF! :)

AVAILABLE = [
    "warrior", "knight", "thief",
    "archer", "wizard", "thrower",
    "buffer", "warlock"]

def bufferSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if me.health < 35:
            if enemy and enemy.distanceTo(ownTower.pos) < 20:
                me.attack(enemy)
            else:
                me.move(ownAngel.pos)
        elif enemy:
            me.attack(enemy)

def knightSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if me.health < 75:
            if enemy and enemy.distanceTo(ownTower.pos) < 20:
                me.attack(enemy)
            else:
                me.move(ownAngel.pos)
        elif enemy:
            me.attack(enemy)

def unitDefendFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownTower.pos) < 20:
            me.attack(enemy)
        else:
            me.move(ownTower.pos)

def bufferUpdateFunction(e):
    me = e.target
    while True:
        me.move(ownTower.pos)
        console.log(me.id)


game.setActionFor("buffer", "spawn", bufferSpawnFunction)
game.setActionFor("buffer", "defend", unitDefendFunction)
game.setActionFor("knight", "spawn", knightSpawnFunction)
game.setActionFor("knight", "defend", unitDefendFunction)

game.setActionFor("buffer", "update", bufferUpdateFunction)

game.buildAction("dirtyKnight", unitDefendFunction)

# find important thangs by type
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
enemyAngel = hero.findByType("angel-fountain", hero.findEnemies())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]

while True:
    buffers = hero.findByType("buffer", hero.findFriends())
    knights = hero.findByType("knight", hero.findFriends())
    if hero.gold > hero.costOf("knight") and len(buffers) >= 2 and len(knights) <= 2:
        game.spawn("knight")
    elif hero.gold > hero.costOf("buffer") and len(buffers) <= 3:
        game.spawn("buffer")

    if len(knights) >= 1:
        hero.say("first knight defend")
        # game.changeActionForUnit(knights[0], "dirtyKnight")
        game.changeUnitWithoutSaving(knights[0], unitDefendFunction)

    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    enemies = hero.findEnemies()
    if item and hero.health < 150:
        hero.move(item.pos)
    elif not item and hero.health < 150 and hero.canCast("invisibility", hero): # turn invisible to escape
        hero.cast("invisibility", hero)
        hero.move(ownAngel.pos)
    elif not item and hero.health < 150:
        game.changeActionFor("buffer", "defend")
        game.changeActionFor("knight", "defend")
        hero.move(ownAngel.pos)
    elif enemy and hero.health < 200 and hero.canCast("flame-armor", hero): # cast flame armor
        hero.cast("flame-armor", hero)
    elif enemy:
        game.changeActionFor("buffer", "spawn")
        game.changeActionFor("knight", "spawn")
        hero.attack(enemy)
    elif enemyAngel:
        hero.attack(enemyAngel)
