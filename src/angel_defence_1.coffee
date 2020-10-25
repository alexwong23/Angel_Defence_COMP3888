{
  # available units for users
  FRIEND_UNIT: {
    warrior: {
      health: 40,
      damage: 15,
      attackCooldown: 1.5,
      attackRange: 13,
      speed: 0
<<<<<<< HEAD
    },c
=======
    },
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
    wizard: {
      health: 10,
      damage: 5,
      attackCooldown: 0.75,
      attackRange: 25,
      speed: 0
    },
    archer: {
      health: 20,
      damage: 10,
      attackCooldown: 1,
      attackRange: 20,
      speed: 0
    }
  }

  # neutral enemy units
  ENEMY_UNIT: {
    thrower: {
      health: 25,
      damage: 7,
      attackCooldown: 0.7,
      attackRange: 5,
      speed: 50
    },
    mmunchkin: {
      health: 40,
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      speed: 65
    },
    fmunchkin: {
      health: 40,
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      speed: 65
    },
    bthrower: {
      health: 25,
      damage: 7,
      attackCooldown: 0.7,
      attackRange: 10,
      speed: 50
    },
    headhunter: {
      health: 80,
      damage: 12,
      attackCooldown: 1,
      attackRange: 5,
      speed: 50
    }
  }
  
  # bounty for killing an enemy
  ENEMY_BOUNTY: 10
  # max number of units allowed
  MAX_UNITS: 18
  # max number of units per cell position
  MAX_UNITS_PER_CELL: 3
  # game timeout seconds to clear the spawn positions and spawn neutrals
  TIME_OUT_SEC: 3
  # health increase rate for every second
<<<<<<< HEAD
  HEALTH_INCREASE_RATE: 2.5
  # speed increase rate for every second
  SPEED_INCREASE_RATE: 2.5
=======
  HEALTH_INCREASE_RATE: 4
  # speed increase rate for every second
  SPEED_INCREASE_RATE: 3
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
  # neutral (enemy) spawn speed rate
  NEUTRAL_SPAWN_RATE: 2
  # netural patrol chase range
  NEUTRAL_CHASE_RANGE: 5
<<<<<<< HEAD
  # flag to record if user have powered up waves: 0 for no, 1 for yes
  RED_POWERED_WAVES_FLAG: 0
  BLUE_POWERED_WAVES_FLAG: 0
  # amount of gold consumed to power up waves, also contributes to the rate of powering
  POWER_COST: 1
  # power rate of powering up waves
  POWER_RATE: 0.2
  
=======
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812

  # initialize and set up the postion for spawning on both sides
  # get spawn positions by id and append of them to a list
  setSpawnPositions: ->
    @spawnPositions = []
    @spawnPositionCounters = {}
    @redSpawnPositions = []
    @blueSpawnPositions = []
    @greenSpawnPositions = []

    # 6 positions on red side
    for i in [0..5]
      th = @world.getThangByID("pos-red-" + i)
      th.index = i
      @redSpawnPositions.push(th)

    # 6 positions on blue side
    for i in [0..5]
      th = @world.getThangByID("pos-blue-" + i)
      th.index = i
      @blueSpawnPositions.push(th)

    # 2 positions for spawning enemies
    for i in [0..1]
      th = @world.getThangByID("pos-green-" + i)
      th.index = i
      @greenSpawnPositions.push(th)
    @redBluePositions = @redSpawnPositions.concat(@blueSpawnPositions)
    @spawnPositions = @redBluePositions.concat(@greenSpawnPositions)
    for th in @spawnPositions
      th.setExists(true)
      th.say?(th.index)
      th.alpha = 0.5
      th.keepTrackedProperty("alpha")
      @spawnPositionCounters[th.id] = 0

  # Set up the netural including its type, status, color, patrol points
  # Position: 0 for red team, 1 for blue team
  setUpNeutral: (unit, unitType, color, posNumber) ->
      params = @ENEMY_UNIT[unitType]
      unit.maxHealth = params.health
      unit.health = params.health
      unit.keepTrackedProperty("maxHealth")
      unit.keepTrackedProperty("health")
      unit.attackDamage = params.damage
      unit.keepTrackedProperty("attackDamage")
      unit.attackRange = params.attackRange
      unit.keepTrackedProperty("attackRange")
      unit.maxSpeed = params.speed
      unit.keepTrackedProperty("maxSpeed")
      unit.patrolChaseRange = @NEUTRAL_CHASE_RANGE
      
      # The health and speed of newly spawned units increase by time
      unit.maxHealth += @world.age * @HEALTH_INCREASE_RATE
      unit.health += @world.age * @HEALTH_INCREASE_RATE
      unit.maxSpeed += @world.age * @SPEED_INCREASE_RATE
      
      if posNumber is 0
        # Patrol path for neutral enemies on the left side
        unit.patrolPoints = ([{"x": 32, "y": 55},
                              {"x": 32, "y": 40},
                              {"x": 12, "y": 40},
                              {"x": 12, "y": 25},
                              {"x": 30, "y": 25},
                              {"x": 30, "y": 10},
                              {"x": 15, "y": 10}])
      else
        # Patrol path for neutral enemies on the right side
        unit.patrolPoints = ([{"x": 48, "y": 55},
                              {"x": 48, "y": 40},
                              {"x": 68, "y": 40},
                              {"x": 68, "y": 25},
                              {"x": 50, "y": 25},
                              {"x": 50, "y": 10},
                              {"x": 65, "y": 10}])
      if unit.actions.attack?.cooldown
        unit.actions.attack.cooldown = params.attackCooldown
      unit.type = unitType
      unit.color = color

  # create a neutral at certain spawn position
  # neutral has to be listed in the referee existence builds component
  createNeutral: (unitType, color, posNumber) ->

      # if invalid unit type, set to default fmunchkin
      if not @ENEMY_UNIT[unitType]
        unitType = "fmunchkin"

      # get the full type information
      fullType = "#{unitType}-#{color}"
      
      # get the position of spawn position
      pos = @getPosXY(color, posNumber)
      unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y)
      
      @setUpNeutral(unit, unitType, color, posNumber)

      return unit

  # spawn netural types randomly
  spawnNeutrals: () ->
    if (@world.age % @NEUTRAL_SPAWN_RATE)==0
      spawnChances = [
        [0, 'fmunchkin']
        [50, 'mmunchkin']
        [85, 'brawler']
        [99, 'headhunter']
      ]
      r = @world.rand.randf() * 100
      for [spawnChance, type] in spawnChances
        if r >= spawnChance
          buildType = type
        else
          break

      # create neutral on left side (attacking red team)
      unit = @createNeutral(buildType, "green", 0)
      @redNeutral.push unit

      # create neutral on left side (attacking blue team)
      unit = @createNeutral(buildType, "green", 1)
      @blueNeutral.push unit


  # allows users to spawn a unit on the command game.spawn(unitType, posNumber) when the game starts
  # deducts gold from the team
  # assigns unit a team and commander and push it to the units array
  spawnControllables: (hero, color, unitType, posNumber) ->

    team: ""
    if color is "red"
      team = "humans"
    else
      team = "ogres"

    # if the input unitType is invalid, set to default "warrior"
    if not unitType or not @FRIEND_UNIT[unitType]
      unitType = "warrior"
    
    # get the full type of the unit
    fullType = "#{unitType}-#{color}"
    rectID = "pos-#{color}-#{posNumber}"

    # Check if user has enough money to spawn units
    if @inventory.goldForTeam(team) >= @buildables[fullType].goldCost and @spawnPositionCounters[rectID] < @MAX_UNITS_PER_CELL
      
      unit = @createUnit(unitType, color, posNumber)
      @spawnPositionCounters[rectID] += 1
      # subtract cost from user's team
      @inventory.subtractGoldForTeam team,@buildables[fullType].goldCost
      unit.startsPeaceful = false
      unit.commander = null

      @gameStates[color].myUnitType.push(unitType)
      @gameStates[color].myPositions.push(posNumber)
<<<<<<< HEAD
=======
      
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
  # Allow user to get how much gold he has when calling the method
  getGold: (hero,color)->
    if color is 'red'
      return @inventory.goldForTeam('humans')
    else
      return @inventory.goldForTeam('ogres') 
  
  # Allow user to get the cost of spawning certain type of unit
  getCostOf:(hero,color,unitType)->
    fullType = "#{unitType}-#{color}"
    return @buildables[fullType].goldCost
<<<<<<< HEAD
  
  # Allow user to power up waves using gold, units will be powered according to the amount of gold consumed
  powerWaves:(hero,color,cost)->
    if color is 'red'
      team = 'humans'
      if @inventory.goldForTeam(team) >= cost
        @RED_POWERED_WAVES_FLAG = 1
        @POWER_COST = cost
        @inventory.subtractGoldForTeam team,cost
    else
      team = 'ogres'
      if @inventory.goldForTeam(team) >= cost
        @BLUE_POWERED_WAVES_FLAG = 1
        @POWER_COST = cost
        @inventory.subtractGoldForTeam team,cost
=======
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812

  # set up functions player can use in the game
  setupGlobal: (hero, color) ->

    # available methods for users
    game = {
      randInt: @world.rand.rand2,
      log: console.log,
      spawn: @spawnControllables.bind(@, hero, color),
      gold: @getGold.bind(@, hero, color),
      costOf: @getCostOf.bind(@, hero, color)
<<<<<<< HEAD
      levelUpAllies: @powerWaves.bind(@, hero, color)
=======
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
      }

    aether = @world.userCodeMap[hero.id]?.plan
    esperEngine = aether?.esperEngine
    if esperEngine
      esperEngine.options.foreignObjectMode = 'smart'
      esperEngine.options.bookmarkInvocationMode = "loop"
      esperEngine.addGlobal?('game', game)

  # make spawn positions(rectangles) invisible to users
  invisibleSpawnPos:()->
    for s in @spawnPositions
      s.alpha = 0
      s.clearSpeech()
      s.keepTrackedProperty("alpha")

  # start the game
  setGameStart:()->
    @gameStart = true

  # Check the death of enemies
  checkDeath: () ->
    # Check if red team has killed an enemy (neutral)
    for unit in @redNeutral
      # if the unit is dead
      if unit.health <= 0
        # add gold for humans (red) team if this neutral enemy has been killed
        @inventory.addGoldForTeam "humans", @ENEMY_BOUNTY, false
        @redNeutral = (x for x in @redNeutral when x != unit)

    # Check if blue team has killed an enemy (neutral)
    for unit in @blueNeutral
      # if the unit is dead
      if unit.health <= 0
        # add gold for ogres (blue) team if this neutral enemy has been killed
        @inventory.addGoldForTeam "ogres", @ENEMY_BOUNTY, false
        @blueNeutral = (x for x in @blueNeutral when x != unit)
<<<<<<< HEAD
  
  # Update waves damage if user has called powerUpWaves()
  updateWaves: () ->
    # Check if user has called powerUpWaves()
    if @RED_POWERED_WAVES_FLAG == 1
      # power up spawned units in red team
      for unit in @redUnits
        unit.attackDamage += @POWER_COST * @POWER_RATE
      @RED_POWERED_WAVES_FLAG = 0
    if @BLUE_POWERED_WAVES_FLAG == 1 
      # power up spwaned units in blue team
      for unit in @blueUnits
        unit.attackDamage += @POWER_COST * @POWER_RATE
      @BLUE_POWERED_WAVES_FLAG = 0
      
  
=======

>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
  # Set up the netural including its type, status, color, actions, commander
  setupUnit: (unit, unitType, color) ->
    params = @FRIEND_UNIT[unitType]
    unit.maxHealth = params.health
    unit.health = params.health
    unit.keepTrackedProperty("maxHealth")
    unit.keepTrackedProperty("health")
    unit.attackDamage = params.damage
    unit.keepTrackedProperty("attackDamage")
    unit.attackRange = params.attackRange
    unit.keepTrackedProperty("attackRange")
    unit.maxSpeed = params.speed
    unit.keepTrackedProperty("maxSpeed")
    unit.startsPeaceful = false
    unit.commander = null
    unit.isAttackable = false
    if unit.actions.attack?.cooldown
      unit.actions.attack.cooldown = params.attackCooldown
    unit.type = unitType
    unit.color = color

    # activate units' actions
    fn = @actionHelpers[unit.color]?[unit.type]?["spawn"]
    if fn and _.isFunction(fn)
      # red team controlled by hero placeholder
      if unit.color is "red"
        unit.commander = @hero
      # blue team controlled by hero placeholder 1
      if unit.color is "blue"
        unit.commander = @hero2
      unit.didTriggerSpawnEvent = true
      unit.on("spawn", fn)
  
  # get the xy coordinates of the spawn position
  getPosXY: (color, n) ->
    rectID = "pos-#{color}-#{n}"
    rect = @world.getThangByID(rectID)
    return rect.pos.copy()

  # called by spawnControllable to create units
  createUnit: (unitType, color, posNumber) ->
    # if invalid friend unit type, set to default "archer"
    if not @FRIEND_UNIT[unitType]
      unitType = "archer"

    # spawn position
    rectID = "pos-#{color}-#{posNumber}"
<<<<<<< HEAD
    
=======

>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
    pos = @getPosXY(color, posNumber)
    fullType = "#{unitType}-#{color}"
    @unitCounter[fullType] ?= 0
    @buildables[fullType].ids = ["#{fullType}-#{@unitCounter[fullType]}"]
    @unitCounter[fullType]++
<<<<<<< HEAD
    
    x=pos.x+@world.rand.rand2 -3, 3
    y=pos.y+@world.rand.rand2 -3, 3
    
    
    unit = @instabuild("#{unitType}-#{color}", x, y, "#{unitType}-#{color}")
=======
    unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y, "#{unitType}-#{color}")
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
    @setupUnit(unit, unitType, color)
    
    if color is 'red' and unit not in @redUnits
      @redUnits.push unit
    else if color is 'blue' and unit not in @blueUnits
      @blueUnits.push unit
      
    return unit

  # spawn units on first frame based on the information from user input stored in gameStates
  checkSpawn:(color) ->
    i = 0
    while i < @gameStates[color].myUnitType.length
      unitType = @gameStates[color].myUnitType[i]
      unitPos = @gameStates[color].myPositions[i]
<<<<<<< HEAD
      unit = @createUnit(unitType, color, unitPos)
      
=======
      @createUnit(unitType, color, unitPos)
>>>>>>> 7eaadc79c652e3f26f8c9406f8113554a250e812
      i++
        

  # Setting of the level
  # Setting up Thangs information
  setUpLevel: ->
    @rangel = @world.getThangByID("Red Angel")
    @bangel = @world.getThangByID("Blue Angel")
    @ref = @world.getThangByID("ref")
    @actionHelpers = {
      "red": {}
      "blue": {}
    }
    @gameHandlers = {
      "red": {}
      "blue": {}
    }
    try
    @setSpawnPositions()
    @unitCounter = {}
    @setupGlobal(@hero, "red")
    @setupGlobal(@hero2, "blue")
    @ref.say("Battle start!")
    @hero.isAttackable = false
    @hero2.isAttackable = false
    @inventory = @world.getSystem 'Inventory'
    @redNeutral = []
    @blueNeutral = []
    @redUnits = []
    @blueUnits = []
    @gameStart = false
    
    # store information from user input
    @gameStates = {
      red: {
        myUnitType:[],
        myPositions:[],
      },
      blue: {
        myUnitType:[],
        myPositions:[],
      }
    }


  # only happens in the first frame
  # Before the game renders, make thangs that do not have health and is not programmable not exist in the game
  onFirstFrame: ->
    for th in @world.thangs when th.health? and not th.isProgrammable
      th.setExists(false)

    @ref.setExists(true)

    #bind angel hp with hero hp
    @rangel.setExists(true)
    @bangel.setExists(true)
    @hero.health = @rangel.health
    @hero.maxHealth = @rangel.maxHealth
    @hero.keepTrackedProperty("health")
    @hero.keepTrackedProperty("maxHealth")
    @hero2.health = @bangel.health
    @hero2.maxHealth = @bangel.maxHealth
    @hero2.keepTrackedProperty("health")
    @hero2.keepTrackedProperty("maxHealth")
    
    @checkSpawn("red")
    @checkSpawn("blue")
    
    #clear spawn position
    @setTimeout(@invisibleSpawnPos.bind(@), @TIME_OUT_SEC)
    @setTimeout(@setGameStart.bind(@), @TIME_OUT_SEC)
  
  # check for a winner in the allocated game time
  # break ties by comparing: angel health > total team gold
  checkWinner: () ->
    return if not @gameStarted
    @existence = @world.getSystem 'Existence'

    if @rangel.health <= 0
      @world.setGoalState "defeat-red-angel", "success"
    else if @bangel.health <= 0
      @world.setGoalState "defeat-blue-angel", "success"
    else if Math.round(@world.age) == @existence.lifespan 
      # end of game and no angel defeated, compare angel health
      if @bangel.health > @rangel.health
        @world.setGoalState "defeat-red-angel", "success"
      else if @rangel.health > @bangel.health
        @world.setGoalState "defeat-blue-angel", "success"
      else if @rangel.health == @bangel.health
        # angel health same, compare team gold
        if @inventory.teamGold["humans"].earned < @inventory.teamGold["ogres"].earned
          @world.setGoalState "defeat-red-angel", "success"
        else if @inventory.teamGold["ogres"].earned < @inventory.teamGold["humans"].earned
          @world.setGoalState "defeat-blue-angel", "success"


  # happens for every frame
  chooseAction: ->
    if @gameStart
      @spawnNeutrals()
      @updateWaves()
      @checkDeath()
      @checkWinner()

      #Update health
      @hero.health = @rangel.health
      @hero.keepTrackedProperty("health")
      @hero2.health = @bangel.health
      @hero2.keepTrackedProperty("health")

}
