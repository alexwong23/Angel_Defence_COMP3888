{ArgumentError} = require 'lib/world/errors'

class AD2ThiefCatchArrows extends Component
  @className: 'AD2ThiefCatchArrows'

  constructor: (config) ->
    super config
    @catchRadiusSquared = @catchRadius * @catchRadius

  attach: (thang) ->
    catchAction = {name: "catch", cooldown: @cooldown, specificCooldown: @specificCooldown}
    delete @cooldown
    delete @specificCooldown
    super thang
    thang.addActions catchAction
    thang.contextCatchesArrows = @getCodeContext?() or {}

  catch: (missile) ->
    #console.log("TRY", missile)
    unless missile?
      throw new ArgumentError @contextCatchesArrows?.error, "bash", "target", "object", target
    @setTarget missile
    #console.log("SET")
    unless missile.isMissile and missile.diesOnHit?
      @say?(@contextCatchesArrows?.cant or "Can't catch it")
      return
    @intent = "catch"
    @block?()

  update: () ->
    return unless @intent is "catch"
    unless @target and @target.exists and not @target.collidedWith?
      @target = null
      @intent = null
      @setAction "idle"
      @unblock?()
      return
    if @distanceSquared(@target) > @catchRadiusSquared
      @setAction "move"
    else
      @setAction "catch"
    if @action is "catch" and @act()
      @performCatch()

  performCatch: (missile) ->
    @unblock?()
    if @target
      @target.diesOnHit = true
      @target.beginContact? @
      type = missile["type"]
      damage = missile["shooter"]["attackDamage"]
      @sayWithoutBlocking "Dodged " + type + "!"
      @.health += damage
    @intent = null
    @target = null

  chooseAction: ->
    return if @hasBeenCommanded or not @catchPassive
    return unless @isReady("catch")
    arrows = (a for a in @getEnemyMissiles() when a.diesOnHit? and not a.collidedWith? and  @distanceSquared(a) <= @catchRadiusSquared)
    nearestArrow = @findNearest arrows
    if nearestArrow
      @setAction "catch"
      @setTarget nearestArrow
      @act()
      @performCatch(nearestArrow)
