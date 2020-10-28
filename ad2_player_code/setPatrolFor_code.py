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

# A. SET UNIT BEHAVIOURS HERE
# warriors attack the nearest enemy

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

def archerSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy:
            me.attack(enemy)

# B. SET UNIT ACTIONS HERE
# all warrior units will behave as instructed in the function 'warriorSpawnFunction'
# add the behaviour into the game.setActionFor user method
game.setActionFor("knight", "spawn", knightSpawnFunction)
game.setActionFor("knight", "defend", knightDefendFunction)
game.setActionFor("archer", "spawn", archerSpawnFunction)
game.setPatrolFor("archer", 5, [{"x":63,"y":45}, {"x":55,"y":55}]) # blue
# game.setPatrolFor("archer", 5, [{"x":17,"y":24}, {"x":29,"y":14}]) # red

# C. SOME HELPFUL VARIABLES
# use these methods to locate units in the game, both friends and enemies
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
enemyAngel = hero.findByType("angel-fountain", hero.findEnemies())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]

# D. GAME LOGIC HERE
while True:
    # spawn warrior units, one of the eight unique unit types
    knights = hero.findByType("knight", hero.findFriends())
    archers = hero.findByType("archer", hero.findFriends())
    if hero.gold > hero.costOf("archer") and len(archers) < 2:
        game.spawn("archer")
    else:
        game.spawn("knight")

    # E. HERO LOGIC HERE
    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    # E.1 get potion
    if item and hero.health < 200:
        hero.move(item.pos)
    # E.2 retreat to base
    elif not item and hero.health < 200:
        hero.move(ownAngel.pos)
        game.changeActionFor("knight", "defend")
        game.changePatrolFor("archer", 5, [{"x":77,"y":52}, {"x":77,"y":41}]) # blue
        # game.changePatrolFor("archer", 5, [{"x":4,"y":25}, {"x":4,"y":12}]) # red
    # E.3 hero attacks nearby enemies
    elif enemy:
        hero.attack(enemy)
        game.changeActionFor("knight", "spawn")
        game.changePatrolFor("archer", 5, [{"x":63,"y":45}, {"x":55,"y":55}]) # blue
        # game.changePatrolFor("archer", 5, [{"x":17,"y":24}, {"x":29,"y":14}]) # red
    # E.4 hero attacks enemy angel
    elif enemyAngel:
        hero.attack(enemyAngel)
