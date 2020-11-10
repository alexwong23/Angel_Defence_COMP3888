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
# archers attack the nearest enemy
def archerSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownAngel) < 20: # enemy close to angel, attack!
            me.attack(enemy)
        elif enemy and enemy.distanceTo(ownTower) < 15: # enemy close to tower, run to angel!
            me.move(ownAngel.pos)
        elif enemy and me.distanceTo(enemy) < 15: # enemy close to me, run to tower!
            me.move(ownTower.pos)
        elif enemy:
            me.attack(enemy)

# B. SET UNIT ACTIONS HERE
# all warrior units will behave as instructed in the function 'warriorSpawnFunction'
# add the behaviour into the game.setActionFor user method
game.setActionFor("wizard", "spawn", archerSpawnFunction)

# C. SOME HELPFUL VARIABLES
# use these methods to locate units in the game, both friends and enemies within 60
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]

# D. GAME LOGIC HERE
while True:
    # spawn archer units, one of the eight unique unit types
    if hero.gold > hero.costOf("wizard"):
        game.spawn("wizard")

    # E. HERO LOGIC HERE
    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    # E.1 get potion
    if item and hero.health < 150:
        hero.move(item.pos)
    # E.2 retreat to base
    elif not item and hero.health < 150:
        hero.move(ownAngel.pos)
    # E.3 hero attacks nearby enemies
    elif enemy:
        hero.attack(enemy)
