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

# units attack the nearest enemy!
def attackSpawnFunction(e):
    me = e.target
    while True:
        enemy = me.findNearestEnemy()
        if enemy:
            me.attack(enemy)

# all archer units will behave as instructed in the function 'attackSpawnFunction'
game.setActionFor("archer", "spawn", attackSpawnFunction)

# find important thangs by type
enemyHero = hero.findByType("duelist", hero.findEnemies())[0]
enemyAngel = hero.findByType("angel-fountain", hero.findEnemies())[0]
ownAngel = hero.findByType("angel-fountain", hero.findFriends())[0]
ownTower = hero.findByType("arrow-tower", hero.findFriends())[0]

while True:
    if hero.gold > hero.costOf("archer"):
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
    else:
        hero.attack(enemyAngel)
