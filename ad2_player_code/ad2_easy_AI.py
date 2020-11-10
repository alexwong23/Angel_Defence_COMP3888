# Objective: Defeat the enemy Angel
# TOP 6 Tips
# 1. Use your hero and the potions wisely using method `hero.health`
# 2. Creeps (peasants) cannot be controlled and drop gold
# 3. Use gold to spawn additional units using methods `game.spawn()` or `game.spawnArray()`
# 4. Command these units using method `game.setActionFor`
# 5. Change their behaviours in-game using method `game.changeActionFor`
# 6. You need your hero to spawn additional units so keep him safe!
# TAKE NOTE: Detailed examples of these methods can be found in the documentation. GLHF! :)

# A. SET UNIT BEHAVIOURS HERE
# warriors attack the nearest enemy
def warriorSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy:
            me.attack(enemy)

# B. SET UNIT ACTIONS HERE
# all warrior units will behave as instructed in the function 'warriorSpawnFunction'
# add the behaviour into the game.setActionFor user method
game.setActionFor("warrior", "spawn", warriorSpawnFunction)

# C. SOME HELPFUL VARIABLES
# use these methods to locate units in the game, both friends and enemies
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
enemyAngel = hero.findByType("angel-fountain", hero.findEnemies())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]

# D. GAME LOGIC HERE
while True:
    # spawn warrior units, one of the eight unique unit types
    warriors  = hero.findByType("warrior", hero.findFriends())
    if len(warriors) < 2:
        game.spawn("warrior")
    # E. HERO LOGIC HERE
    enemy = hero.findNearestEnemy()
    if enemy:
        hero.attack(enemy)
