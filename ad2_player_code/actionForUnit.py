# Objective: Defeat the enemy Angel
# Tips to build the best code
# 1. Click on the Hints Button at the top right to find out more
# 2. Use your hero and the potions wisely using method `hero.health`
# 3. Creeps (peasants) cannot be controlled and drop gold
# 4. Use gold to spawn additional units using methods `game.spawn()` or `game.spawnArray()`
# 5. Command these units using method `game.setActionFor`
# 6. Change their behaviours in-game using method `game.changeActionFor`
# 7. You need your hero to spawn additional units so keep him safe!
# 8. Finally, submit your code to the ladder by clicking 'Rank My Game'
# TAKE NOTE: Detailed examples of these methods can be found in the documentation. GLHF! :)

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

# find important thangs by type
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
