{
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
  
  #Constants
  ALLOWED_UNIT_EVENT_NAMES: ["spawn"]
  MAX_UNITS: 18
  MAX_UNITS_PER_CELL: 3
  
  ARCHER_USER_FLAG : 0
  ARCHER_USER_TYPE : "archer"
  ARCHER_USER_COLOR : "red"
  ARCHER_USER_POS : 0
  
  WARRIOR_USER_FLAG : 0
  WARRIOR_USER_TYPE : "archer"
  WARRIOR_USER_COLOR : "red"
  WARRIOR_USER_POS : 0
  
  WIZARD_USER_FLAG : 0
  WIZARD_USER_TYPE : "archer"
  WIZARD_USER_COLOR : "red"
  WIZARD_USER_POS : 0


  #################################
  setSpawnPositions: ->
    @spawnPositions = []
    @spawnPositionCounters = {}
    @redSpawnPositions = []
    @blueSpawnPositions = []
    @greenSpawnPositions = []
    for i in [0..5]
      th = @world.getThangByID("pos-red-" + i)
      th.index = i
      @redSpawnPositions.push(th)
    for i in [0..5]
      th = @world.getThangByID("pos-blue-" + i)
      th.index = i
      @blueSpawnPositions.push(th)
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
        unit.patrolPoints = ([{"x": 32, "y": 55},
                              {"x": 32, "y": 40},
                              {"x": 12, "y": 40},
                              {"x": 12, "y": 25},
                              {"x": 30, "y": 25},
                              {"x": 30, "y": 10},
                              {"x": 15, "y": 10}])
      else
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

  createNeutral: (unitType, color, posNumber) ->

      if not @ENEMY_UNIT[unitType]
        unitType = "fmunchkin"

      fullType = "#{unitType}-#{color}"

      if posNumber==0
        unit = @instabuild("#{unitType}-#{color}", 9, 60)
      else
        unit = @instabuild("#{unitType}-#{color}", 68, 60)

      @setUpNeutral(unit, unitType, color, posNumber)

      return unit

  spawnNeutrals: () ->
    if (@world.age % 2)==0
      spawnChances = [
        [0, 'fmunchkin']
        [50, 'mmunchkin']
        #[80, 'bthrower']
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
      
      # @redNeutral = []  
      # @blueNeutral = []
    
      unit = @createNeutral(buildType, "green", 0)
      @redNeutral.push unit
      
      unit = @createNeutral(buildType, "green", 1)
      @blueNeutral.push unit
      
    
  
  addArcher: (hero, color, pos) ->
    @ARCHER_USER_FLAG = 1
    @ARCHER_USER_TYPE = "archer"
    @ARCHER_USER_POS = pos
    @ARCHER_USER_COLOR = color
    
  addWarrior: (hero, color, pos) ->
    @WARRIOR_USER_FLAG = 1
    @WARRIOR_USER_TYPE = "warrior"
    @WARRIOR_USER_POS = pos
    @WARRIOR_USER_COLOR = color
    
  addWizard: (hero, color, pos) ->
    @WIZARD_USER_FLAG = 1
    @WIZARD_USER_TYPE = "wizard"
    @WIZARD_USER_POS = pos
    @WIZARD_USER_COLOR = color
  
  spawnControllables: (hero, color, unitType, posNumber) ->
    #return if not @gameStart
    # console.log("I AM USING SPAWN")
    team: ""
    if color is "red"
      team = "humans"
    else
      team = "ogres"
    if not unitType or not @FRIEND_UNIT[unitType]
      unitType = "warrior"

    fullType = "#{unitType}-#{color}"
    rectID = "pos-#{color}-#{posNumber}"
    # console.log("I AM USING SPAWN 1"+ @spawnPositionCounters[rectID]+@MAX_UNITS_PER_CELL)
    if @inventory.goldForTeam(team) >= @buildables[fullType].goldCost and @spawnPositionCounters[rectID]<@MAX_UNITS_PER_CELL
      unit = @createUnit(unitType, color, posNumber)
      console.log("CHECKING CREATE"+unit.type+unit.color)
      @inventory.subtractGoldForTeam team,@buildables[fullType].goldCost
      unit.startsPeaceful = false
      unit.commander = null
      if unit.color is "red"
        # unit.commander = @hero
        # unit.didTriggerSpawnEvent = true
        
        @redPlayerUnit.push(unit)
        @redPos.push(posNumber)
      if unit.color is "blue"
        # unit.commander = @hero2
        # unit.didTriggerSpawnEvent = true
        
        @bluePlayerUnit.push(unit)
        @bluePos.push(posNumber)
 
      
    
  setupGlobal: (hero, color) ->
   
    game = {
      randInt: @world.rand.rand2,
      log: console.log,
      addArcher: @addArcher.bind(@, hero, color)
      addWarrior: @addWarrior.bind(@, hero, color)
      addWizard: @addWizard.bind(@, hero, color)
      spawn: @spawnControllables.bind(@, hero, color)
      }

    aether = @world.userCodeMap[hero.id]?.plan
    esperEngine = aether?.esperEngine
    if esperEngine
      esperEngine.options.foreignObjectMode = 'smart'
      esperEngine.options.bookmarkInvocationMode = "loop"
      esperEngine.addGlobal?('game', game)
  
  invisibleSpawnPos:()->
    for s in @spawnPositions
      s.alpha = 0
      s.clearSpeech()
      s.keepTrackedProperty("alpha")
      console.log("clearing spwanPositions"+s.alpha)
  
  setGameStart:()->
    @gameStart = true
    
  checkDeath: () ->
    # Check if red team has killed an unit
    for unit in @redNeutral
      console.log unit.health
      if unit.health <= 0
        @inventory.addGoldForTeam "humans", 10, false  #replace 10 with the cost of unit
        @redNeutral = (x for x in @redNeutral when x != unit)
        
    # Check if blue team has killed an unit    
    for unit in @blueNeutral
    
      if unit.health <= 0
        @inventory.addGoldForTeam "ogres", 10, false  #replace 10 with the cost of unit
        @blueNeutral = (x for x in @blueNeutral when x != unit)

  
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
 
    # unit.trigger?("spawn")
    fn = @actionHelpers[unit.color]?[unit.type]?["spawn"]
    if fn and _.isFunction(fn)
      if unit.color is "red"
        unit.commander = @hero
      if unit.color is "blue"
        unit.commander = @hero2
      unit.didTriggerSpawnEvent = true
      unit.on("spawn", fn)
    
  getPosXY: (color, n) ->
    rectID = "pos-#{color}-#{n}"
    rect = @world.getThangByID(rectID)
    return rect.pos.copy()
  
  createUnit: (unitType, color, posNumber) ->
    if not @FRIEND_UNIT[unitType]
      unitType = "archer"
    
    rectID = "pos-#{color}-#{posNumber}"
    
    unit = NaN
    #if @spawnPositionCounters[rectID]<@MAX_UNITS_PER_CELL
    pos = @getPosXY(color, posNumber)
    fullType = "#{unitType}-#{color}"
    unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y, "#{unitType}-#{color}")
    @setupUnit(unit, unitType, color)
    @spawnPositionCounters[rectID] += 1
     
    return unit
  
  checkSpawn:()-> 
    i=0
    console.log("BUTTUERBUTTER "+@bluePos.length+@bluePlayerUnit.length)
    for unit in @bluePlayerUnit
      console.log(unit.type+"BUTTUERBUTTER"+unit.color+" "+@bluePos[i])
      @createUnit(unit.type, unit.color, @bluePos[i])
      i+=1
    i=0
    for unit in @redPlayerUnit      
      console.log(unit.type+"HEREHERHERHER"+unit.color+" "+@redPos[i])
      @createUnit(unit.type, unit.color, @redPos[i])
      i+=1
  
  #################################
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
   # @setSpawnPositions()
    @gameStart = false
   
    @redPlayerUnit=[]#only be used in checkSpawn
    @redPos=[] #only be used in checkSpawn
    @bluePlayerUnit=[] #only be used in checkSpawn
    @bluePos=[] #only be used in checkSpawn
    
  onFirstFrame: ->
    for th in @world.thangs when th.health? and not th.isProgrammable
      th.setExists(false)
    
    #show spawnPosition to player
    # for th in @spawnPositions
    #   th.setExists(true)
    #   th.say?(th.index)
    #   th.alpha = 0.5
    #   th.keepTrackedProperty("alpha")
    #   @spawnPositionCounters[th.id] = 0
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
    

  chooseAction: ->
    if @gameStart
      @spawnNeutrals()
      @checkDeath()

      #Update health
      @hero.health = @rangel.health
      @hero.keepTrackedProperty("health")
      @hero2.health = @bangel.health
      @hero2.keepTrackedProperty("health")


  checkVictory: ->

  
}
