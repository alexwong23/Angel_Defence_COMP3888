# A. SET UNIT BEHAVIOURS HERE
# warriors attack the nearest enemy
def archerSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy:
            distance = me.distanceTo(enemy)
            if distance <10 :
                me.move(ownAngel.pos)
            else:
                me.attack(enemy)

# B. SET UNIT ACTIONS HERE
# all warrior units will behave as instructed in the function 'warriorSpawnFunction'
# add the behaviour into the game.setActionFor user method
game.setActionFor("archer", "spawn", archerSpawnFunction)

# C. SOME HELPFUL VARIABLES
# use these methods to locate units in the game, both friends and enemies
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
enemyAngel = hero.findByType("angel-fountain", hero.findEnemies())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]

# D. GAME LOGIC HERE
while True:
    # spawn warrior units, one of the eight unique unit types
    if hero.gold > hero.costOf("archer"):
        game.spawn("archer")

    # E. HERO LOGIC HERE
    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    # E.1 get potion
    if item and hero.health < 200:
        hero.move(item.pos)
    # E.2 retreat to base
    elif not item and hero.health < 200:
        hero.move(ownAngel.pos)
    # E.3 hero attacks nearby enemies
    elif enemy:
        hero.attack(enemy)
    # E.4 hero attacks enemy angel
    elif enemyAngel:
        hero.attack(enemyAngel)
