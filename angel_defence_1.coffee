{
  # available units for users
  FRIEND_UNIT: {
    warrior: {
      health: 40,
      damage: 15,
      attackCooldown: 1.5,
      attackRange: 13,
      speed: 0,
      cost: 20
    },
    wizard: {
      health: 10,
      damage: 5,
      attackCooldown: 4,
      attackRange: 25,
      speed: 0,
      cost:25
    },
    archer: {
      health: 20,
      damage: 10,
      attackCooldown: 0.5,
      attackRange: 20,
      speed: 0,
      cost: 23
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
      speed: 50
    },
    fmunchkin: {
      health: 40,
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      speed: 50
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
  
  
  ALLOWED_UNIT_EVENT_NAMES: ["spawn"]
  # max number of units allowed
  MAX_UNITS: 18
  # max number of units per cell position
  MAX_UNITS_PER_CELL: 3
  

  # Configuration for positions of spawning units
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
    
  # Neutral units setting up
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
      unit.patrolChaseRange = 5

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
      #unit.commander = @
      unit.type = unitType
      unit.color = color

  # Netural creation
  createNeutral: (unitType, color, posNumber) ->
      
      # if invalid unit type, set to default fmunchkin
      if not @ENEMY_UNIT[unitType]
        unitType = "fmunchkin"
      
      # get the full type information
      fullType = "#{unitType}-#{color}"
      
      # if it is neutral on left side
      if posNumber==0
        unit = @instabuild("#{unitType}-#{color}", 9, 60)
      # if it is neutral on right side
      else
        unit = @instabuild("#{unitType}-#{color}", 68, 60)

      @setUpNeutral(unit, unitType, color, posNumber)

      return unit
  
  # spawn netural randomly
  spawnNeutrals: () ->
    if (@world.age % 2)==0
      spawnChances = [
        [0, 'fmunchkin']
        [50, 'mmunchkin']
        [85, 'brawler']
        [99, 'headhunter']
      ]
      r = @world.rand.randf() * 100
      #n = 100 * Math.pow r, 85 / (@world.age + 1)
      for [spawnChance, type] in spawnChances
        # console.log n, " ",  spawnChance
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
      
    
  # receive information when user calls game.spawn
  spawnControllables: (hero, color, unitType, posNumber) ->

    team: ""
    if color is "red"
      team = "humans"
    else
      team = "ogres"
      
    # if the input unitType is invalid, set to default "warrior"
    if not unitType or not @FRIEND_UNIT[unitType]
      unitType = "warrior"

    fullType = "#{unitType}-#{color}"
    rectID = "pos-#{color}-#{posNumber}"

    # Check if user has enough money to spawn units
    if @inventory.goldForTeam(team) >= @buildables[fullType].goldCost and @spawnPositionCounters[rectID]<@MAX_UNITS_PER_CELL
      unit = @createUnit(unitType, color, posNumber)
      # subtract cost from user's team
      @inventory.subtractGoldForTeam team,@buildables[fullType].goldCost
      unit.startsPeaceful = false
      unit.commander = null
      
      # if user is on red team
      if unit.color is "red"
        @redPlayerUnit.push(unit)
        @redPos.push(posNumber)
        
      # if user is on blue team
      if unit.color is "blue"
        @bluePlayerUnit.push(unit)
        @bluePos.push(posNumber)
 
      
  # global setting for the game
  setupGlobal: (hero, color) ->
   
    # available methods for users
    game = {
      randInt: @world.rand.rand2,
      log: console.log,
      spawn: @spawnControllables.bind(@, hero, color)
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
    
  
  checkDeath: () ->
    # Check if red team has killed an unit
    for unit in @redNeutral
      # if the unit is dead
      if unit.health <= 0
        # add gold for humans (red) team if this neutral enemy has been killed
        @inventory.addGoldForTeam "humans", 10, false
        @redNeutral = (x for x in @redNeutral when x != unit)
        
    # Check if blue team has killed an unit    
    for unit in @blueNeutral
      # if the unit is dead
      if unit.health <= 0
        # add gold for ogres (blue) team if this neutral enemy has been killed
        @inventory.addGoldForTeam "ogres", 10, false
        @blueNeutral = (x for x in @blueNeutral when x != unit)

  # set up units configuration
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
  
  getPosXY: (color, n) ->
    rectID = "pos-#{color}-#{n}"
    rect = @world.getThangByID(rectID)
    return rect.pos.copy()
  
  # creation of units
  createUnit: (unitType, color, posNumber) ->
    # if invalid friend unit type, set to default "archer"
    if not @FRIEND_UNIT[unitType]
      unitType = "archer"
    
    # spawn position
    rectID = "pos-#{color}-#{posNumber}"
    
    unit = NaN
    #if @spawnPositionCounters[rectID]<@MAX_UNITS_PER_CELL
    pos = @getPosXY(color, posNumber)
    fullType = "#{unitType}-#{color}"
    unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y, "#{unitType}-#{color}")
    @setupUnit(unit, unitType, color)
    @spawnPositionCounters[rectID] += 1
     
    return unit
  
  # make sure spawned units have correct color and positions
  checkSpawn:()-> 
    i=0
    for unit in @bluePlayerUnit
      @createUnit(unit.type, unit.color, @bluePos[i])
      i+=1
    i=0
    for unit in @redPlayerUnit
      @createUnit(unit.type, unit.color, @redPos[i])
      i+=1

  # Setting of the level
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
    @setSpawnPositions()
    @setupGlobal(@hero, "red")
    @setupGlobal(@hero2, "blue")
    @hero.gold = 100
    @hero2.gold = 100
    @ref.say("Battle start!")
    @hero.isAttackable = false
    @hero.health = 2
    @hero.maxHealth = 2
    @hero2.isAttackable = false
    @hero2.health = 2
    @hero2.maxHealth = 2
    @inventory = @world.getSystem 'Inventory'
    @redNeutral = []
    @blueNeutral = []
    @gameStart = false
   
    @redPlayerUnit=[]   #only be used in checkSpawn
    @redPos=[]          #only be used in checkSpawn
    @bluePlayerUnit=[]  #only be used in checkSpawn
    @bluePos=[]         #only be used in checkSpawn
  
  # only happens in the first frame
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
    
    #clear spawn position
    @setTimeout(@invisibleSpawnPos.bind(@), 2)
    @checkSpawn()
    @setTimeout(@setGameStart.bind(@), 3)
    
  # happens every frame
  chooseAction: ->
    if @gameStart
      @spawnNeutrals()
      @checkDeath()

      #Update health
      @hero.health = @rangel.health
      @hero.keepTrackedProperty("health")
      @hero2.health = @bangel.health
      @hero2.keepTrackedProperty("health")
  
}
