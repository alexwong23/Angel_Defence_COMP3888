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

# warriors attack the nearest enemy!
def archerSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy:
            me.attack(enemy)

def archerDefendFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownTower.pos) < 20:
            me.attack(enemy)
        else:
            me.move(ownAngel.pos)


def knightSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownTower.pos) < 20:
            me.attack(enemy)
        else:
            me.move(ownAngel.pos)

# all units will behave as instructed in the function 'warriorSpawnFunction'
game.setActionFor("archer", "spawn", archerSpawnFunction)
game.setActionFor("archer", "defend", archerDefendFunction)

game.setActionFor("knight", "spawn", knightSpawnFunction)
game.setActionForUnit("knight-blue-0", "defend", archerDefendFunction)

# find important thangs by type
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
enemyAngel = hero.findByType("angel-fountain", hero.findEnemies())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]

while True:
    archers = hero.findByType("archer", hero.findFriends())
    knights = hero.findByType("knight", hero.findFriends())
    if hero.gold > hero.costOf("knight") and len(archers) >= 3 and len(knights) <= 2:
        game.spawn("knight")
    elif hero.gold > hero.costOf("archer"):
        game.spawn("knight")

    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    enemies = hero.findEnemies()
    if item and hero.health < 150:
        hero.move(item.pos)
    elif not item and hero.health < 150 and hero.canCast("invisibility", hero): # turn invisible to escape
        hero.cast("invisibility", hero)
        hero.move(ownAngel.pos)
    elif not item and hero.health < 150: # retreat to base
        game.changeActionFor("archer", "defend")
        game.changeActionForUnit("knight-blue-0", "defend")
        hero.move(ownAngel.pos)
    elif enemy and hero.health < 200 and hero.canCast("flame-armor", hero): # cast flame armor
        hero.cast("flame-armor", hero)
    elif enemy:
        game.changeActionFor("archer", "spawn")
        game.changeActionForUnit("knight-blue-0", "spawn")
        hero.attack(enemy)
    else:
        hero.attack(enemyAngel)
