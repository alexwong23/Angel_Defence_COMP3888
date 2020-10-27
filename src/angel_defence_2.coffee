{ArgumentError} = require 'lib/world/errors'
{
  # ANGEL DEFENCE 2 REFEREE CODE

  # object contains attributes of hero and neutrals
  THANG_PARAMETERS: {
    hero: {
      damage: 25,
      attackCooldown: 1,
      attackRange: 5,
      health: 300,
      speed: 25,
    },
    peasant: {
      damage: 3,
      attackCooldown: 1.5,
      attackRange: 5,
      health: 50,
      speed: 15
    },
    mmunchkin: {
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      health: 50,
      speed: 15
    },
    fmunchkin: {
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      health: 50,
      speed: 15
    },
    bthrower: {
      damage: 10,
      attackCooldown: 1.0,
      attackRange: 10,
      health: 25,
      speed: 20
    },
    brawler: {
      damage: 40,
      attackCooldown: 4.0,
      attackRange: 5,
      health: 150,
      speed: 10
    }
  }

  # object contains the attributes of all 'spawnable' units
  UNIT_PARAMETERS: {
    warrior: {
      damage: 8,
      attackCooldown: 1.5,
      attackRange: 5,
      health: 100,
      speed: 15
    },
    knight: {
      damage: 3,
      attackCooldown: 1.5,
      attackRange: 5,
      health: 150,
      speed: 10
    },
    thief: {
      damage: 10,
      attackCooldown: 0.5,
      attackRange: 5,
      health: 50,
      speed: 30
    },
    archer: {
      damage: 10,
      attackCooldown: 1.5,
      attackRange: 15,
      health: 50,
      speed: 20
    },
    wizard: {
      damage: 20,
      attackCooldown: 4.0,
      attackRange: 20,
      health: 50,
      speed: 15
    },
    thrower: {
      damage: 8,
      attackCooldown: 1.0,
      attackRange: 10,
      health: 50,
      speed: 20
    },
    buffer: {
      damage: 5,
      attackCooldown: 4.0, # affects how fast spells are cast
      attackRange: 15,
      health: 50,
      speed: 15,
      healingAmount: 3
    },
    warlock: {
      damage: 8,
      attackCooldown: 4.0, # affects how fast spells are cast
      attackRange: 15,
      health: 50,
      speed: 15,
      slowAmount: 0.75
    }
  }

  # array of allowed unit events, this is used in game.setActionFor()
  ALLOWED_UNIT_EVENT_NAMES: ["spawn", "attack", "defend", "update"]

  # set up functions player can use in the game along with set up hero properties
  setupGlobal: (hero, color) ->
    # defined our user functions here, game.spawn()
    # user can call these methods from within the coding area
    game = {
      randInt: @world.rand.rand2,
      log: console.log
      # setPatrolPointsFor: @setPatrolPointsFor.bind(@, hero, color),
      setActionFor: @setActionFor.bind(@, hero, color),
      setActionForUnit: @setActionForUnit.bind(@, hero, color),
      changeActionFor: @changeActionFor.bind(@, hero, color),
      changeActionForUnit: @changeActionForUnit.bind(@, hero, color),
      spawn: @spawnUserMethod.bind(@, hero, color),
      spawnArray: @spawnArray.bind(@, hero, color),
      costOfSpawnArray: @costOfSpawnArray.bind(@, hero, color)
      }
    aether = @world.userCodeMap[hero.id]?.plan
    esperEngine = aether?.esperEngine
    if esperEngine
      esperEngine.options.foreignObjectMode = 'smart'
      esperEngine.options.bookmarkInvocationMode = "loop"
      esperEngine.addGlobal?('game', game)
    # set hero attributes
    heroStats = @THANG_PARAMETERS["hero"]
    hero.health = heroStats.health
    hero.maxHealth = heroStats.health
    hero.damage = heroStats.damage
    hero.attackCooldown = heroStats.attackCooldown
    hero.attackRange = heroStats.attackRange
    hero.speed = heroStats.speed
    hero.maxSpeed = 0 # prevent movement until start of game

  # initialize and set up the postion for spawning on both sides
  # get spawn positions by id and append of them to a list
  # for red and blue positions, creeps spawn at 0 and controllable units at 1
  setSpawnPositions: ->
    @spawnPositions = []
    @redSpawnPositions = []
    @blueSpawnPositions = []
    @greenSpawnPositions = []
    for i in [0..1]
      th = @world.getThangByID("pos-red-" + i) # red positions for red team
      th.index = i
      @redSpawnPositions.push(th)
    for i in [0..1]
      th = @world.getThangByID("pos-blue-" + i) # blue positions for blue team
      th.index = i
      @blueSpawnPositions.push(th)
    for i in [0..1]
      th = @world.getThangByID("pos-green-" + i) # green positions for neutrals
      th.index = i
      @greenSpawnPositions.push(th)
    @redBluePositions = @redSpawnPositions.concat(@blueSpawnPositions)
    @spawnPositions = @redBluePositions.concat(@greenSpawnPositions)

  # one of the four main functions provided by CodeCombat interface
  # setup hero and user functions before the game starts
  setUpLevel: ->
    # object of units, their colors, types and event function
    @actionHelpers = {
      "red": {}
      "blue": {}
      }
    @setupGlobal(@hero, "red")
    @setupGlobal(@hero2, "blue")
    @setSpawnPositions() # put all spawn positions in the game into a list
    @unitCounter = {} # objects is populated with total number of unit types built, includes creeps, units and neutrals
    @ref = @world.getThangByID("ref")
    @ref.say("Angel Defence 2.0")
    @inventory = @world.getSystem 'Inventory' # used to get manipulate teams' gold


  # one of the four main functions provided by CodeCombat interface
  # Before the game renders, make thangs that do not have health and is not programmable not exist in the game
  # call prepareGame() to start the game process
  onFirstFrame: ->
    for th in @world.thangs when th.health? and not th.isProgrammable
      th.setExists(false)

    # prevent the thangs outside the map from attacking one another
    predefinedThangs = []
    for k, v of @UNIT_PARAMETERS
      predefinedThangs.push(k + '-red')
      predefinedThangs.push(k + '-blue')
    predefinedThangs.push('peasant-red')
    predefinedThangs.push('peasant-blue')
    for k, v of @THANG_PARAMETERS when k != "peasant" and k != "hero"
      predefinedThangs.push(k + '-green')

    for thang in predefinedThangs
      th = @world.getThangByID(thang)
      th.setExists(false)
    @prepareGame()


  # one of the four main functions provided by CodeCombat interface
  # this function performs like a while loop, running throughout the game
  # function run only when game starts
  chooseAction: ->
    if @gameStarted
      @spawnNeutrals() # spawn if neutral defeated
      @spawnPotions() # spawn if potion taken
      @spawnCreeps() # spawn every 5 seconds
      @clearField() # clear the dead creeps
      @checkWinner() # check for the winner

  # get the xy coordinates of the spawn position
  getPosXY: (color, n) ->
    rectID = "pos-#{color}-#{n}"
    rect = @world.getThangByID(rectID)
    return rect.pos.copy()

  # after first frame, start preparing the game
  prepareGame: ->
    @thangsInGame = [] # stores creeps from both teams and all neutrals
    @spawnablesInGame = [] # stores all spawned units

    # make angel and tower exist in the game
    rtower = @world.getThangByID("Red Tower")
    @rangel = @world.getThangByID("Red Angel")
    rtower.setExists(true)
    @rangel.setExists(true)
    btower = @world.getThangByID("Blue Tower")
    @bangel = @world.getThangByID("Blue Angel")
    btower.setExists(true)
    @bangel.setExists(true)

    # make ruins not exist until the angel is destroyed
    @rruin = @world.getThangByID("Red Ruin")
    @rruin.keepTrackedProperty("alpha")
    @rruin.setExists(false)
    @bruin = @world.getThangByID("Blue Ruin")
    @bruin.keepTrackedProperty("alpha")
    @bruin.setExists(false)

    # track both hero's health
    @hero.keepTrackedProperty("health")
    @hero.keepTrackedProperty("maxHealth")
    @hero2.keepTrackedProperty("health")
    @hero2.keepTrackedProperty("maxHealth")

    # make spawn positions visible before the game starts
    for th in @spawnPositions
      th.setExists(true)
      th.say?(th.index)
      th.alpha = 0.5
      th.keepTrackedProperty("alpha")

    # format referee messages here
    @ref.setExists(true)
    @ref.say("RED vs BLUE")
    @setTimeout((() => @ref.say(3)), 1)
    @setTimeout((() => @ref.say(2)), 2)
    @setTimeout((() => @ref.say(1)), 3)
    @setTimeout((() => @ref.say("Fight!")), 4)
    @setTimeout(@clearRects.bind(@), 1) # spawn positions disappear after the first second
    @setTimeout(@startGame.bind(@), 4) # start the game after four seconds

  # clear the battlefield of dead creeps/neutrals when the total is a multiple of 10
  clearField: ->
    if @thangsInGame.length % 10 == 0
      # when creep/neutral has no health, it is considered dead and its body disappears
      for u in @thangsInGame when u.health <= 0
        u.setExists(false)

  # clear spawn positions and referee messages when round starts
  clearRects: ->
    for s in @spawnPositions
      s.alpha = 0
      s.clearSpeech()
      s.keepTrackedProperty("alpha")

  # start the game
  # spawn the first neutrals and potions, allow hero to move, remove referee
  startGame: () ->
    buildType = @spawnNeutralChance()
    @neutralTop = @createThang(buildType, "green", 0)
    @setUpNeutral(@neutralTop, [{"x": 10, "y": 60}, {"x": 25, "y": 50}])
    @neutralBtm = @createThang(buildType, "green", 1)
    @setUpNeutral(@neutralBtm, [{"x": 75, "y": 10}, {"x": 60, "y": 20}])
    @potionRight = @createPotion({"x": 49, "y": 30})
    @potionLeft = @createPotion({"x": 34, "y": 40})
    @hero.maxSpeed = 20
    @hero2.maxSpeed = 20
    @gameStarted = true
    @ref.setExists(false)

  # check for a winner in the allocated game time
  # timeout: break ties by comparing: angel health > total team gold > hero health
  checkWinner: () ->
    return if not @gameStarted
    @existence = @world.getSystem 'Existence'

    # if angel is destroyed, show the ruins
    if @bangel.health <= 0 and @rangel.health <= 0
      # angels defeated at same time, break ties
      @redAngelCollapse()
      @blueAngelCollapse()
      @breakTiesGoal(true)
    else if @rangel.health <= 0
      @redAngelCollapse()
    else if @bangel.health <= 0
      @blueAngelCollapse()
    else if Math.round(@world.age) == @existence.lifespan
      # end of game and no angel defeated, compare angel health
      if @bangel.health > @rangel.health
        # ogres win and humans lose
        @world.setGoalState "defeat-red-angel", "success"
        @world.setGoalState "defeat-blue-angel", "failure"
      else if @rangel.health > @bangel.health
        # humans win and ogres lose
        @world.setGoalState "defeat-blue-angel", "success"
        @world.setGoalState "defeat-red-angel", "failure"
      else if @rangel.health == @bangel.health
        # angel health same, break ties
       @breakTiesGoal(false)

  # break ties by comparing team gold earned and then hero health
  breakTiesGoal: (isBothDefeated) ->
    # compare team gold
    if @inventory.teamGold["humans"].earned < @inventory.teamGold["ogres"].earned
      # ogres win and humans lose
      if isBothDefeated
        @world.setGoalState "defeat-blue-angel", "failure"
      @world.setGoalState "defeat-red-angel", "success"
    else if @inventory.teamGold["ogres"].earned < @inventory.teamGold["humans"].earned
      # humans win and ogres lose
      if isBothDefeated
        @world.setGoalState "defeat-red-angel", "failure"
      @world.setGoalState "defeat-blue-angel", "success"
    else if @inventory.teamGold["ogres"].earned == @inventory.teamGold["humans"].earned
      # team gold same, compare hero health
      if @hero.health < @hero2.health
        # ogres win and humans lose
        if isBothDefeated
          @world.setGoalState "defeat-blue-angel", "failure"
        @world.setGoalState "defeat-red-angel", "success"
      else if @hero2.health < @hero.health
        # humans win and ogres lose
        if isBothDefeated
          @world.setGoalState "defeat-red-angel", "failure"
        @world.setGoalState "defeat-blue-angel", "success"

  # if red angel defeated then red ruins appear
  redAngelCollapse: () ->
    @rangel.setExists(false)
    @rruin.setExists(true)
    @rruin.alpha = 1

  # if blue angel defeated then blue ruins appear
  blueAngelCollapse: () ->
    @bangel.setExists(false)
    @bruin.setExists(true)
    @bruin.alpha = 1

  # build a medium health potion at the x y coordinate
  createPotion:(pos) ->
    @build "health-potion-medium"
    builtPotion = @performBuild()
    builtPotion.team = 'neutral'
    builtPotion.pos.x = pos.x
    builtPotion.pos.y = pos.y
    builtPotion.collectableProperties[0][0][1] = 200
    return builtPotion

  # every 30 second interval, spawn a potion if the previous potion was taken
  spawnPotions: () ->
    spawnTime = Math.round(@world.age * 10) / 10
    if spawnTime % 30.0 == 0 # spawn potion every 30 sec interval
      if @potionRight.exists == false
        @potionRight = @createPotion({"x": 49, "y": 30})
      if @potionLeft.exists == false
        @potionLeft = @createPotion({"x": 34, "y": 40})

  # changes warlock attack property, includes a slow on target unit
  setUpWarlockSlow: (warlock, slowAmount) ->
    warlock.oldperformAttack = warlock.performAttack
    warlock.performAttack = (target, damageRatio=1, momentum=null) =>
      return unless target.hasEffects
      warlock.oldperformAttack(target, damageRatio, momentum)
      target.effects = (e for e in target.effects when e.name isnt 'slow')
      target.addEffect {name: 'slow', duration: 2, reverts: true, factor: slowAmount, targetProperty: 'maxSpeed'}

  # changes buffer attack property, heals weak allies
  setUpBufferHeal: (buffer, healingAmount) ->
    buffer.oldperformAttack = buffer.performAttack
    buffer.performAttack = (target, damageRatio=1, momentum=null) =>
      buffer.oldperformAttack(target, damageRatio, momentum)

      # find the weakest ally
      friends=buffer.findFriends()
      leastHealth=10000
      weakestAlly=null
      for friend in friends
        if (@UNIT_PARAMETERS[friend.type] || friend.type == "peasant" || friend.type == "duelist") &&
            friend.health < leastHealth && friend.health > 0 and friend.hasEffects
          leastHealth = friend.health
          weakestAlly = friend

      # heal the weakest ally every time buffer attacks
      if weakestAlly && weakestAlly.effects
        weakestAlly.health = Math.min(weakestAlly.health + healingAmount, weakestAlly.maxHealth)
        weakestAlly.keepTrackedProperty('health')
        weakestAlly.effects = (e for e in weakestAlly.effects when e.name isnt 'heal')
        weakestAlly.addEffect {name: 'heal', duration: 0.5, reverts: true, setTo: true, targetProperty: 'beingHealed'}

  # set up the unit, its stats, color and unit type
  setupThang: (unit, unitType, color, params) ->
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
    unit.startsPeaceful = true

    if unit.type is "warlock" # warlock slows enemies
      @setUpWarlockSlow(unit, params.slowAmount)
    else if unit.type is "buffer" # buffer heals lowest health allies
      @setUpBufferHeal(unit, params.healingAmount)

    return unit

  # create a thang at the position
  # thang has to be listed in the referee existence builds component
  createThang: (unitType, color, posNumber) ->
    params = {}
    if @THANG_PARAMETERS[unitType]
      params = @THANG_PARAMETERS[unitType]
    else if @UNIT_PARAMETERS[unitType]
      params = @UNIT_PARAMETERS[unitType]
    else
      throw new ArgumentError "Thang of type " + unitType + " cannot be created in this level."

    pos = @getPosXY(color, posNumber)
    fullType = "#{unitType}-#{color}"
    @unitCounter[fullType] ?= 0
    @buildables[fullType].ids = ["#{fullType}-#{@unitCounter[fullType]}"]
    @unitCounter[fullType]++
    unit = @instabuild("#{unitType}-#{color}", pos.x, pos.y, "#{unitType}-#{color}")
    thang = @setupThang(unit, unitType, color, params)
    return thang

  # assign creeps (not controllable) to their commander by color
  # give creep a patrol point to the enemy angel so they can attack it
  # push creep to the thangs array
  setUpCreep: (unit, patrolPoints) ->
    unit.commander = null
    if unit.color is "red"
      unit.commander = @hero
    if unit.color is "blue"
      unit.commander = @hero2
    unit.patrolChaseRange = 10
    unit.patrolPoints = patrolPoints
    @thangsInGame.push(unit)

  # every 5 second, spawn a creep on either team
  spawnCreeps: () ->
    spawnTime = Math.round(@world.age * 10) / 10 # round world.age to one decimal place
    if spawnTime % 5.0 == 0 # spawn potion every 5 sec
      redCreep = @createThang("peasant", "red", 0)
      @setUpCreep(redCreep, [{"x": 70, "y": 55}])
      # @setUpCreep(redCreep, [{"x": 35, "y": 30}, {"x": 45, "y": 35}, {"x": 70, "y": 55}])
      blueCreep = @createThang("peasant", "blue", 0)
      @setUpCreep(blueCreep, [{"x": 12, "y": 12}])
      # @setUpCreep(blueCreep, [{"x": 46, "y": 34}, {"x": 34, "y": 31}, {"x": 12, "y": 12}])

  # choose a neutral type to spawn at random
  spawnNeutralChance: () ->
    spawnChances = [
      [0, 'fmunchkin']
      [35, 'mmunchkin']
      [70, 'bthrower']
      [99, 'brawler']
    ]
    n = 100 * @world.rand.randf()
    returnType: ""
    for [spawnChance, type] in spawnChances
      if n >= spawnChance
        returnType = type
    return returnType

  # assign neutral unit to a patrol and add it to the list of thangs so it's dead body can disappear too
  setUpNeutral: (neutralUnit, patrolPoints) ->
    neutralUnit.patrolChaseRange = 10
    neutralUnit.patrolPoints = patrolPoints
    @thangsInGame.push(neutralUnit)

  # every 15 second interval, spawn a neutral on the green positions if the previous neutral was defeated
  spawnNeutrals: () ->
    spawnTime = Math.round(@world.age * 10) / 10
    if spawnTime % 15.0 == 0 # spawn potion every 15 sec interval
      buildType = @spawnNeutralChance()
      if @neutralTop.health < 1
        @neutralTop = @createThang(buildType, "green", 0)
        @setUpNeutral(@neutralTop, [{"x": 10, "y": 60}, {"x": 25, "y": 50}])
      if @neutralBtm.health < 1
        @neutralBtm = @createThang(buildType, "green", 1)
        @setUpNeutral(@neutralBtm, [{"x": 75, "y": 10}, {"x": 60, "y": 20}])

  # create a creep or unit at the position
  # unit has to be listed in the referee existence builds component
  setUpSpawnable: (unitType, color, posNumber) ->
    # return just to be safe, this check is already done by the functions that call it
    return if not @UNIT_PARAMETERS[unitType]

    spawnableUnit = @createThang(unitType, color, 1)

    return spawnableUnit

  # sets up a controllable unit
  # assigns unit a team and commander and push it to the units array
  createSpawnable: (team, color, fullType, unitType) ->
    # return just to be safe, this check is already done by the functions that call it
    return if not @UNIT_PARAMETERS[unitType]

    unit = @setUpSpawnable(unitType, color, 1)
    unit.commander = null
    if unit.color is "red"
      unit.commander = @hero
    if unit.color is "blue"
      unit.commander = @hero2
    @spawnablesInGame.push(unit)

    # assigns the controllable unit the spawn behaviour
    fn = @actionHelpers[unit.color]?[unit.type]?["spawn"]
    # replace spawn fn if unit has been given an individual spawn behaviour
    if @actionHelpers[unit.color]?[unit.id]?["spawn"]
      fn = @actionHelpers[unit.color]?[unit.id]?["spawn"]
    if fn and _.isFunction(fn)
      @onUnitEvent(unit, unitType, fn)

  # function to calculate the discounted price of using the user method game.spawnArray
  calculateSpawnArray: (color, unitTypesArray) ->
    # check if all units in array is in @UNIT_PARAMETERS[unitType]
    for unitType in unitTypesArray
      if not @UNIT_PARAMETERS[unitType]
        throw new ArgumentError "Please specify one of the eight spawnable units.", "spawnArray", "unitType", "spawnable", unitType
    # calculate the total cost of units in the array after applying discounts
    # 2 units: 10% off
    # 3 units: 20% off
    # 4 units: 30% off
    # 5 and above units: 40% off
    all_cost = 0
    for unitType in unitTypesArray
      fullType = "#{unitType}-#{color}"
      all_cost += @buildables[fullType].goldCost
    all_cost *= Math.max (1 - (unitTypesArray.length - 1)*0.1),0.6
    return all_cost

  # function to assign a behaviour to the unit
  onUnitEvent: (unit, type, fn) ->
    if not unit.on
      console.warn("#{type} need hasEvent")
    unit.didTriggerSpawnEvent = true
    unit.off("spawn")
    unit.on("spawn", fn)

  ## USER FUNCTIONS

  # allows users to assign units of unitType, a function on an allowed event
  # the unit has to exist and can be controlled, before it behaves as instructed in the function
  # setPatrolPointsFor: (hero, color, type, patrolPoints, patrolChaseRange) ->
  #   if not @UNIT_PARAMETERS[type]
  #     throw new ArgumentError "Please specify one of the eight spawnable units.", "spawn", "unitType", "spawnable", type
  #   for th in @world.thangs when th.health > 0 and th.type == type
  #     console.log(th.id)
  #     th.patrolPoints = patrolPoints
  #     th.patrolChaseRange = patrolChaseRange

  # allows users to assign units of unitType, a function on an allowed event
  # the unit has to exist and can be controlled, before it behaves as instructed in the function
  setActionFor: (hero, color, type, event, fn) ->
    if event not in @ALLOWED_UNIT_EVENT_NAMES
      throw new ArgumentError "Please specify an allowed event type: [\"spawn\", \"attack\", \"defend\", \"update\"]", "setActionFor", "eventType"
    if not @UNIT_PARAMETERS[type]
      throw new ArgumentError "Please specify a valid spawnable unit", "setActionFor", "unitType", "spawnable", type
    @actionHelpers[color][type] ?= {}
    @actionHelpers[color][type][event] = fn

  # allows users to assign a specific unit a function on an allowed event
  # the unit has to exist and can be controlled, before it behaves as instructed in the function
  setActionForUnit: (hero, color, unitID, event, fn) ->
    if event not in @ALLOWED_UNIT_EVENT_NAMES
      throw new ArgumentError "Please specify one of the following: [\"spawn\", \"attack\", \"defend\", \"update\"]", "setActionFor", "eventType"
    @actionHelpers[color][unitID] ?= {}
    @actionHelpers[color][unitID][event] = fn

  # allows users to change the behaviour of all units of type
  changeActionFor: (hero, color, type, event) ->
    if event not in @ALLOWED_UNIT_EVENT_NAMES
      throw new ArgumentError "Please specify one of the following: [\"spawn\", \"attack\", \"defend\", \"update\"]", "setActionFor", "eventType"
    if not @UNIT_PARAMETERS[type]
      throw new ArgumentError "Please specify a valid spawnable unit", "setActionFor", "unitType", "spawnable", type
    fn = @actionHelpers[color]?[type]?[event]
    if fn and _.isFunction(fn)
      for unit in @world.thangs when unit.type is type and unit.exists and unit.color is color
        @onUnitEvent(unit, type, fn)

  # allows users to change the behaviour of a unit using thangID
  changeActionForUnit: (hero, color, unitID, event) ->
    if event not in @ALLOWED_UNIT_EVENT_NAMES
      throw new ArgumentError "Please specify one of the following: [\"spawn\", \"attack\", \"defend\", \"update\"]", "setActionFor", "eventType"
    unit = @world.getThangByID(unitID)
    fn = @actionHelpers[color]?[unitID]?[event]
    if fn and _.isFunction(fn) and unit and unit.exists and unit.color is color
        @onUnitEvent(unit, unitID, fn)

  # allows users to spawn a unit on the command game.spawn('unitType') when the game starts
  # throws argument error if unit type is not spawnable
  spawnUserMethod: (hero, color, unitType) ->
    return if not @gameStarted
    if not @UNIT_PARAMETERS[unitType]
      throw new ArgumentError "Please specify one of the eight spawnable units.", "spawn", "unitType", "spawnable", unitType
    team: ""
    if color is "red"
      team = "humans"
    else
      team = "ogres"

    fullType = "#{unitType}-#{color}"
    #console.log unitType, ' requires gold cost ', @buildables[fullType].goldCost
    if @inventory.goldForTeam(team) >= @buildables[fullType].goldCost
      @inventory.subtractGoldForTeam team,@buildables[fullType].goldCost
      @createSpawnable(team, color, fullType, unitType)


  # allows users to check if they have enough gold to spawn units in the array
  # throws argument error if any unit type is not spawnable
  costOfSpawnArray: (hero, color, unitTypesArray) ->
    return if not @gameStarted
    return @calculateSpawnArray(color, unitTypesArray)

  # allows users to spawn units on the command game.spawnArray(['unitType', 'unitType', ...]) when the game starts
  # throws argument error if any unit type is not spawnable
  # if the player has enough gold, deduct gold and spawn the units
  spawnArray: (hero, color, unitTypesArray) ->
    return if not @gameStarted

    # get the player's team so we can deduct their gold
    team: ""
    if color is "red"
      team = "humans"
    else
      team = "ogres"

    # calculate discounted cost
    all_cost = @calculateSpawnArray(color, unitTypesArray)

    # if player has enough gold, spawn all units
    if @inventory.goldForTeam(team) >= all_cost
      @inventory.subtractGoldForTeam team, all_cost
      for unitType in unitTypesArray
        fullType = "#{unitType}-#{color}"
        @createSpawnable(team, color, fullType, unitType)
}
