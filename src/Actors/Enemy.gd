extends Actor
class_name Enemy

onready var ai = $AI

export (int) var detection_radius = 400
export (float) var detection_sneak_modifier = 0.5
export (int) var detection_angle = 180
export (bool) var active_chase = false # is the actor going to chase the player once they are seen
export (bool) var patrol = true
export (float) var chase_timeout = 2.0 # how long until actor stops chasing once they lost line-of-sight

export (float) var gum_speed_multiplier = 0.5 # speed at which the actor will move if they move over gum
export (float) var gum_time = 5.0 # how long the gum speed effect lasts
var gum_timer = Timer.new()

export (float) var slingshot_time = 2.0 # how long the slingshot stun effect lasts (actor can't move)
var slingshot_timer = Timer.new()

export (float) var stun_time = 1.0 # how long the taser stun effect lasts (actor can't move; friendly fire)
var stun_timer = Timer.new()

# _ready runs iteratively through each child node from starting scene (e.g. Player - first execute _ready on CollisionShape2D and player sprite, then go back up and execute _ready for Player)
func _ready() -> void:
	# set up timers and add them to the tree
	gum_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	gum_timer.set_wait_time(gum_time)
	gum_timer.set_one_shot(true)
	add_child(gum_timer)
	
	slingshot_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	slingshot_timer.set_wait_time(slingshot_time)
	slingshot_timer.set_one_shot(true)
	add_child(slingshot_timer)
	
	stun_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	stun_timer.set_wait_time(stun_time)
	stun_timer.set_one_shot(true)
	add_child(stun_timer)
	
	get_node("AI").detection_radius_default = detection_radius
	get_node("AI").detection_sneak_modifier = detection_sneak_modifier
	get_node("AI").detection_angle = detection_angle
	get_node("AI").active_chase = active_chase
	get_node("AI").patrol = patrol
	get_node("AI").chase_timeout = chase_timeout

# calculate speed for each actor
func _physics_process(delta: float) -> void:
	var speed_multiplier = 1.0
	modulate = Color(1, 1, 1)
	if gum_timer.get_time_left() > 0:
		speed_multiplier = gum_speed_multiplier # slow down enemy to gummed speed
	if slingshot_timer.get_time_left() > 0:
		speed_multiplier = 0.0
	if stun_timer.get_time_left() > 0:
		speed_multiplier = 0.0
		modulate = Color(1, 1, 0)
	
	#print(_velocity)
	_velocity = move_and_slide(_velocity * speed_multiplier)
	
	# get player to face the direction they are moving and face that same direction when stopping
	if _velocity != Vector2.ZERO:
		look_at((get_global_position() + _velocity))
