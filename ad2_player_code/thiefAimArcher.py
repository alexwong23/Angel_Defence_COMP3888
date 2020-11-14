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
# thiefs attack the nearest enemy
def attackSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy and enemy.distanceTo(ownAngel) < 15: # enemy close to angel, attack!
            me.attack(enemy)
        elif enemy and enemy.distanceTo(ownTower) < 10: # enemy close to tower, run to angel!
            me.move(ownAngel.pos)
        elif enemy and me.distanceTo(enemy) < 10: # enemy close to me, run to tower!
            me.move(ownTower.pos)
        elif enemy:
            me.attack(enemy)

def thiefAimArcherFunction(e):
    me = e.target
    while True:
        archers = me.findByType("archer", me.findEnemies())
        thieves = me.findByType("thief", me.findFriends())
        enemy = me.findNearestEnemy()
        if thieves >= 3:
            me.attack(enemy)
        elif me.health < 30 or (me.distanceTo(ownTower.pos) > 50 and thieves < 3):
            if enemy and enemy.distanceTo(ownTower.pos) < 20:
                me.attack(enemy)
            else:
                me.move(ownAngel.pos)
        elif len(archers) > 0:
            me.attack(archers[0])
        elif enemy:
            me.attack(enemy)

# all knight and archer units will behave as instructed in the function 'attackSpawnFunction'
game.setActionFor("knight", "spawn", attackSpawnFunction)
game.setActionFor("archer", "spawn", attackSpawnFunction)
game.setActionFor("thief", "spawn", thiefAimArcherFunction)

# find important thangs by type
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]

while True:
    # keep count of number of knights and archers
    knights = hero.findByType("knight", hero.findFriends())
    archers = hero.findByType("archer", hero.findFriends())
    enemyArchers = hero.findByType("archer", hero.findEnemies())

    # at least one knight when more than two archers
    if len(enemyArchers) > 0:
        game.spawn("thief")
    elif len(knights) < 1 and len(archers) >= 2 and hero.gold > hero.costOf("knight"):
        game.spawn("knight")
    elif hero.gold > hero.costOf("archer"):
        game.spawn("archer")

    # hero performs actions
    enemy = hero.findNearestEnemy()
    item = hero.findNearestItem()
    if item and hero.health < 150: # get potion
        hero.move(item.pos)
    elif not item and hero.health < 150 and hero.canCast("invisibility", hero): # turn invisible to escape
        hero.cast("invisibility", hero)
    elif not item and hero.health < 150: # retreat to base
        hero.move(ownAngel.pos)
    elif enemy and hero.health < 200 and hero.canCast("flame-armor", hero): # cast flame armor
        hero.cast("flame-armor", hero)
    elif enemy: # hero attacks nearby enemies
        hero.attack(enemy)
