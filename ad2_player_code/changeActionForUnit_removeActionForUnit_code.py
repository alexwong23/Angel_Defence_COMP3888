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

def knightSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if me.health < 75:
            if enemy and enemy.distanceTo(ownTower.pos) < 20:
                me.attack(enemy)
            else:
                me.move(ownTower.pos)
        elif enemy:
            me.attack(enemy)

def knightDefendFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownTower.pos) < 20:
            me.attack(enemy)
        else:
            me.move(ownTower.pos)

def knightAttackFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy:
            me.attack(enemy)

def oneKnightDefendFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownTower.pos) < 20:
            me.attack(enemy)
        else:
            me.move(ownAngel.pos)

game.setActionFor("knight", "spawn", knightSpawnFunction)
game.setActionFor("knight", "defend", knightDefendFunction)
game.setActionFor("knight", "attack", knightAttackFunction)

# use these methods to locate units in the game, both friends and enemies within 60
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]

while True:
    knights = hero.findByType("knight", hero.findFriends())
    if hero.gold > hero.costOf("knight"):
        game.spawn("knight")
    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    if item and hero.health < 150:
        hero.move(item.pos)
    elif not item and hero.health < 150 and hero.canCast("invisibility", hero): # turn invisible to escape
        hero.cast("invisibility", hero)
        hero.move(ownAngel.pos)
    elif not item and hero.health < 150:
        game.changeActionFor("knight", "defend")
        if len(knights) >= 1:
            game.removeActionForUnit(knights[0])
        hero.move(ownAngel.pos)
    elif enemy and hero.health < 200 and hero.canCast("flame-armor", hero): # cast flame armor
        hero.cast("flame-armor", hero)
    elif enemy:
        game.changeActionFor("knight", "spawn")
        if len(knights) >= 1:
            game.changeActionForUnit(knights[0], oneKnightDefendFunction)
        hero.attack(enemy)
