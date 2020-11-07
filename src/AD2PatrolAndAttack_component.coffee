class AD2PatrolAndAttack extends Component
  @className: 'AD2PatrolAndAttack'
  constructor: (config) ->
    super config
    @patrolChaseRange ?= 0

  chooseAction: ->
    enemy = @getNearestEnemy()
    distance = if enemy then @distance enemy, true else 9001
    return @action if (@target?.health > 0 and distance > @patrolChaseRange) or @patrolChaseRange < 1 # preserve out-of-range aggro while keeping useful target switching to nearest enemy
    if distance < @attackRange
      @attack enemy
    else if distance < @patrolChaseRange
      @currentSpeedRatio = 1
      @follow enemy
    else
      @patrol @patrolPoints
    
