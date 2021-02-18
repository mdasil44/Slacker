extends "res://src/Actors/Actor.gd"

export (bool) var active_chase = false
onready var ai = $AI

export (float) var gummed_speed_multiplier = 0.5
export (float) var gummed_time = 5.0
var gummed_timer = Timer.new()

export (float) var slingshot_time = 2.0
var slingshot_timer = Timer.new()

# _ready run iteratively through each child node from starting scene (e.g. Player - first execute _ready on CollisionShape2D aand player sprite, then go back up and execute _ready for Player)
func _ready() -> void:
	gummed_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	gummed_timer.set_wait_time(gummed_time)
	gummed_timer.set_one_shot(true)
	add_child(gummed_timer)
	
	slingshot_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	slingshot_timer.set_wait_time(slingshot_time)
	slingshot_timer.set_one_shot(true)
	add_child(slingshot_timer)
	
	_velocity.x = -speed.x


func _physics_process(delta: float) -> void:
	var speed_multiplier = 1.0
	if gummed_timer.get_time_left() > 0:
		speed_multiplier = gummed_speed_multiplier # slow down enemy to gummed speed
	if slingshot_timer.get_time_left() > 0:
		speed_multiplier = 0.0
		
	if is_on_wall(): # is_on_wall and is_on_floor only update after a movement
		_velocity.x *= -1.0
	_velocity.y = move_and_slide(_velocity*speed_multiplier).y
	
	# get player to face the direction they are moving and face that same direction when stopping
	if _velocity != Vector2.ZERO:
		look_at((get_global_position() + _velocity))
