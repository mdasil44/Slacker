extends "res://src/Actors/Actor.gd"

export (float) var gummed_speed = 0.5
export (float) var gummed_time = 5.0
var gummed_timer = Timer.new()

# _ready run iteratively through each child node from starting scene (e.g. Player - first execute _ready on CollisionShape2D aand player sprite, then go back up and execute _ready for Player)
func _ready() -> void:
	gummed_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	gummed_timer.set_wait_time(gummed_time)
	gummed_timer.set_one_shot(true)
	gummed_timer.connect("timeout", self, "gummed_timeout")
	
	add_child(gummed_timer)
	
	# deactivate enemy at start of game
	set_physics_process(false)
	_velocity.x = -speed.x

# only runs when enemy is on screen due to VisibilityEnabler2D
func _physics_process(delta: float) -> void:
	if gummed_timer.get_time_left() <= 0:
		_velocity *= gummed_speed # slow down enemy to gummed speed
		
	if is_on_wall(): # is_on_wall and is_on_floor only update after a movement
		_velocity.x *= -1.0
	_velocity.y = move_and_slide(_velocity).y
	
	# get player to face the direction they are moving and face that same direction when stopping
	if _velocity != Vector2.ZERO:
		look_at((get_global_position() + _velocity))


func gummed_timeout() -> void:
	_velocity /= gummed_speed # return enemy to normal speed
