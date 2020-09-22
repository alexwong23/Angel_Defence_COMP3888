{
  UNIT_PARAMETERS: {
    warrior: {
      health: 40,
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      speed: 10
    },
    knight: {
      health: 70,
      damage: 4,
      attackCooldown: 1,
      attackRange: 5,
      speed: 10
    },
    thief: {
      health: 20,
      damage: 10,
      attackCooldown: 0.5,
      attackRange: 4,
      speed: 20
    },
    wizard: {
      health: 10,
      damage: 20,
      attackCooldown: 4,
      attackRange: 10,
      speed: 10
    },
    archer: {
      health: 20,
      damage: 3,
      attackCooldown: 0.5,
      attackRange: 10,
      speed: 10
    },
    thrower: {
      health: 25,
      damage: 7,
      attackCooldown: 0.7,
      attackRange: 5,
      speed: 10
    },
    buffer: {
      health: 10,
      damage: 2,
      attackCooldown: 0.5,
      attackRange: 20,
      speed: 20
    },
    warlock: {
      health: 10,
      damage: 2,
      attackCooldown: 0.5,
      attackRange: 20,
      speed: 10
    },
    peasant: {
      health: 10,
      damage: 1,
      attackCooldown: 0.5,
      attackRange: 5,
      speed: 10
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
    brawler: {
      health: 100,
      damage: 20,
      attackCooldown: 1.5,
      attackRange: 5,
      speed: 30
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

  setupGlobal: (hero, color) ->
    game = {
      randInt: @world.rand.rand2,
      setActionFor: @setActionFor.bind(@, hero, color),
      log: console.log
      spawn: @spawnControllables.bind(@, hero, color)
      }
    Object.defineProperty(game, 'roundTime', {
      get: () => @gameTime(),
      set: (x) => return 0
    })
    aether = @world.userCodeMap[hero.id]?.plan
    esperEngine = aether?.esperEngine
    if esperEngine
      esperEngine.options.foreignObjectMode = 'smart'
      esperEngine.options.bookmarkInvocationMode = "loop"
      esperEngine.addGlobal?('game', game)
    # set hero attributes
    hero.health = 200
    hero.maxHealth = 200
    hero.damage = 25
    hero.attackCooldown = 1
    hero.attackRange = 5
    hero.maxSpeed = 0

  setSpawnPositions: ->
    @spawnPositions = []
    @redSpawnPositions = []
    @blueSpawnPositions = []
    @greenSpawnPositions = []
    for i in [0..1]
      th = @world.getThangByID("pos-red-" + i)
      th.index = i
      @redSpawnPositions.push(th)
    for i in [0..1]
      th = @world.getThangByID("pos-blue-" + i)
      th.index = i
      @blueSpawnPositions.push(th)
    for i in [0..1]
      th = @world.getThangByID("pos-green-" + i)
      th.index = i
      @greenSpawnPositions.push(th)
    @redBluePositions = @redSpawnPositions.concat(@blueSpawnPositions)
    @spawnPositions = @redBluePositions.concat(@greenSpawnPositions)

  setUpLevel: ->
    @actionHelpers = {
      "red": {}
      "blue": {}
      }
    @setupGlobal(@hero, "red")
    @setupGlobal(@hero2, "blue")
    @setSpawnPositions()
    @unitCounter = {}
    @ref = @world.getThangByID("ref")
    @ref.say("Angel Defence 2.0")
    @inventory = @world.getSystem 'Inventory'

  onFirstFrame: ->
    for th in @world.thangs when th.health? and not th.isProgrammable
      th.setExists(false)
    @prepareRound()

  chooseAction: ->
    if @roundStarted
      if not @neutralSpawned
        @spawnNeutrals()
      if not @potionSpawned
        @spawnPotions()
      @spawnCreeps()
      @clearField()
      @checkWinner()

  getPosXY: (color, n) ->
    rectID = "pos-#{color}-#{n}"
    rect = @world.getThangByID(rectID)
    return rect.pos.copy()

  setupUnit: (unit, unitType, color) ->
    params = @UNIT_PARAMETERS[unitType]
    unit.maxHealth = params.health
    unit.health = params.health
    unit.attackDamage = params.damage
    unit.attackRange = params.attackRange
    unit.maxSpeed = params.speed
    unit.keepTrackedProperty("maxHealth")
    unit.keepTrackedProperty("health")
    unit.keepTrackedProperty("attackDamage")
    unit.keepTrackedProperty("attackRange")
    unit.keepTrackedProperty("maxSpeed")
    if unit.actions.attack?.cooldown
      unit.actions.attack.cooldown = params.attackCooldown
    if color != "green"
      unit.commander = @
    unit.type = unitType
    unit.color = color
    # if @actionHelpers?[color]?[unitType]
    #   for event in @ALLOWED_UNIT_EVENT_NAMES
    #     handler = @actionHelpers?[color][unitType][event]
    #     if handler and _.isFunction(handler)
    #       unit.off(event)
    #       unit.on(event, handler)

    return unit

  createHumans: (unitType, color, posNumber) ->
    if not @UNIT_PARAMETERS[unitType]
      unitType = "peasant"
    pos = @getPosXY(color, posNumber)
    fullType = "#{unitType}-#{color}"
    @unitCounter[fullType] ?= 0
    @buildables[fullType].ids = ["#{fullType}-#{@unitCounter[fullType]}"]
    @unitCounter[fullType]++
    unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y, "#{unitType}-#{color}")
    @setupUnit(unit, unitType, color)
    return unit

  prepareRound: ->
    @rangel = @world.getThangByID("Red Angel")
    @rruin = @world.getThangByID("Red Ruin")
    @rruin.keepTrackedProperty("alpha")
    @bangel = @world.getThangByID("Blue Angel")
    @bruin = @world.getThangByID("Blue Ruin")
    @bruin.keepTrackedProperty("alpha")

    @hero.keepTrackedProperty("health")
    @hero.keepTrackedProperty("maxHealth")
    @hero2.keepTrackedProperty("health")
    @hero2.keepTrackedProperty("maxHealth")

    for th in @spawnPositions
      th.setExists(true)
      th.say?(th.index)
      th.alpha = 0.5
      th.keepTrackedProperty("alpha")
    @creepsInGame = []
    @unitsInGame = []
    @ref.setExists(true)
    @ref.say("RED vs BLUE")
    @setTimeout((() => @ref.say(3)), 1)
    @setTimeout((() => @ref.say(2)), 2)
    @setTimeout((() => @ref.say(1)), 3)
    @setTimeout((() => @ref.say("Fight!")), 4)
    @setTimeout(@clearRects.bind(@), 1)
    @setTimeout(@startRound.bind(@), 4)

  clearField: ->
    if @creepsInGame.length % 10 == 0
      # console.log 'number of creeps in game is ', @creepsInGame.length
      for u in @creepsInGame when u.health <= 0
        u.setExists(false)

  clearRects: ->
    for s in @spawnPositions
      s.alpha = 0
      s.clearSpeech()
      s.keepTrackedProperty("alpha")

  gameTime: ->
    if not @roundStarted
      return 0
    return @world.age - @roundStartTime

  startRound: () ->
    @neutralSpawned = false
    @potionSpawned = false
    @roundStarted = true
    @roundStartTime = @world.age
    @hero.maxSpeed = 20
    @hero2.maxSpeed = 20
    @ref.setExists(false)
    for unit in @unitsInGame when unit
      unit.startsPeaceful = false
      unit.commander = null
      # unit.isAttackable = false
      # unit.trigger?("spawn")
      fn = @actionHelpers[unit.color]?[unit.type]?["spawn"]
      if fn and _.isFunction(fn)
        if unit.color is "red"
          unit.commander = @hero
        if unit.color is "blue"
          unit.commander = @hero2
        unit.didTriggerSpawnEvent = true
        unit.on("spawn", fn)

  checkWinner: () ->
    return if not @roundStarted
    if @rangel.health <= 0
      @rangel.setExists(false)
      @rruin.alpha = 1
    else if @bangel.health <= 0
      @bangel.setExists(false)
      @bruin.alpha = 1

  createNeutral: (unitType, color, posNumber) ->
      if not @UNIT_PARAMETERS[unitType]
        unitType = "munchkin"
      pos = @getPosXY(color, posNumber)
      fullType = "#{unitType}-#{color}"
      @unitCounter[fullType] ?= 0
      @buildables[fullType].ids = ["#{fullType}-#{@unitCounter[fullType]}"]
      @unitCounter[fullType]++
      unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y, "#{unitType}-#{color}")
      neutralUnit = @setupUnit(unit, unitType, color)
      return neutralUnit

  spawnNeutrals: () ->
    spawnRate = 0.1 + @world.age / 1000000  # Range from 0.333 to 1.333 enemies per second on each side
    shouldHaveSpawned = 3 + spawnRate * @world.age
    # console.log 'shouldHaveSpawned is ', shouldHaveSpawned, '@built.length is ', @built.length
    if shouldHaveSpawned > @built.length / 5
      spawnChances = [
        [0, 'fmunchkin']
        [50, 'mmunchkin']
        [80, 'bthrower']
        [85, 'brawler']
        [99, 'headhunter']
      ]
      r = @world.rand.randf()
      n = 100 * r
      for [spawnChance, type] in spawnChances
        if n >= spawnChance
          buildType = type
        else
          break

      neutralUnit0 = @createNeutral(buildType, "green", 0)
      neutralUnit0.patrolChaseRange = 10
      neutralUnit0.patrolPoints = ([{"x": 5, "y": 60},
                            {"x": 10, "y": 60}])
      neutralUnit1 = @createNeutral(buildType, "green", 1)
      neutralUnit1.patrolChaseRange = 10
      neutralUnit1.patrolPoints = ([{"x": 75, "y": 10},
                            {"x": 70, "y": 10}])

      # spawn only one neutral
      @neutralSpawned = true

  spawnCreeps: () ->
      spawnRate = 0.05 + @world.age / 1000000  # Range from 0.333 to 1.333 enemies per second on each side
      shouldHaveSpawned = 3 + spawnRate * @world.age
      # console.log 'shouldHaveSpawned is ', shouldHaveSpawned, '@built.length is ', @built.length
      if shouldHaveSpawned > @built.length / 5

        redCreep = @createHumans("warrior", "red", 0)
        redCreep.patrolChaseRange = 20
        redCreep.patrolPoints = ([{"x": 70, "y": 55}])
        @creepsInGame.push(redCreep)

        blueCreep = @createHumans("warrior", "blue", 0)
        blueCreep.patrolChaseRange = 20
        blueCreep.patrolPoints = ([{"x": 12, "y": 12}])
        @creepsInGame.push(blueCreep)

    spawnPotions: () ->
        spawnRate = 0.05 + @world.age / 1000000  # Range from 0.333 to 1.333 enemies per second on each side
        shouldHaveSpawned = 3 + spawnRate * @world.age
        # console.log 'shouldHaveSpawned is ', shouldHaveSpawned, '@built.length is ', @built.length
        if shouldHaveSpawned > @built.length / 5

          # TO DO: use rand to spawn at either point
          @build "health-potion-medium"
          built = @performBuild()
          built.team = 'neutral'
          built.pos.x = 51
          built.pos.y = 25
          if built.move
            built.hasMoved = true
          else
            built.addTrackedProperties ['pos', 'Vector']
            built.keepTrackedProperty 'pos'

          @build "health-potion-medium"
          built2 = @performBuild()
          built2.team = 'neutral'
          built2.pos.x = 33
          built2.pos.y = 42
          built2.hasMoved = true
          if built2.move
            built2.hasMoved = true
          else
            built2.addTrackedProperties ['pos', 'Vector']
            built2.keepTrackedProperty 'pos'

          # spawn only one potion at a time
          @potionSpawned = true

    # USER
    setActionFor: (hero, color, type, event, fn) ->
      # TODO event type checking
      @actionHelpers[color][type] ?= {}
      # @actionHelpers[color][type][event] ?= []
      @actionHelpers[color][type][event] = fn
      for unit in @world.thangs when unit.type is type and unit.exists
        if not unit.on
          console.warn("#{type} need hasEvent")
          continue
        unit.off(event)
        unit.on(event, fn)

    spawnControllables: (hero, color, unitType) ->
        return if not @roundStarted
        team: ""
        if color is "red"
          team = "humans"
        else
          team = "ogres"
        if not unitType or not @UNIT_PARAMETERS[unitType]
          unitType = "warrior"

        fullType = "#{unitType}-#{color}"
        #console.log unitType, ' requires gold cost ', @buildables[fullType].goldCost
        if @inventory.goldForTeam(team) >= @buildables[fullType].goldCost
          @inventory.subtractGoldForTeam team,@buildables[fullType].goldCost
          unit = @createHumans(unitType, color, 1)
          unit.startsPeaceful = false
          unit.commander = null
          fn = @actionHelpers[unit.color]?[unit.type]?["spawn"]
          if fn and _.isFunction(fn)
             if unit.color is "red"
               unit.commander = @hero
             if unit.color is "blue"
               unit.commander = @hero2
             unit.didTriggerSpawnEvent = true
             #unit.off("spawn")
             unit.on("spawn", fn)

          @unitsInGame.push(unit)
}
