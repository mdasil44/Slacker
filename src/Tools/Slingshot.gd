extends Area2D

export (float) var lifetime: = 5.0 # how long will the tool live by default
export (float) var speed: = 600 # how fast does bullet travel
export (float) var shot_spread: = 0.01 # how much spread there is to each taser shot

onready var timer = $LifetimeTimer

var velocity:Vector2

func _ready() -> void:
	timer.set_wait_time(lifetime)
	timer.connect("timeout", self, "timeout")
	
	timer.start()
	
	connect("body_entered", self, "body_entered")
	
	set_as_toplevel(true) # make the scene independent from parent movement
	
	var direction = get_fire_direction()
	if direction == Vector2.ZERO:
		velocity = global_transform.x * speed
	else:
		velocity = direction * speed


func _physics_process(delta: float) -> void:
	global_translate(velocity * delta)


func get_fire_direction() -> Vector2:
	var direction: Vector2
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		direction = Vector2(
			# Input allows you to query an input on every frame of the game
			Input.get_action_strength("look_right") - Input.get_action_strength("look_left"),
			Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		).normalized() # ensures object doesn't move faster diagonally
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		direction = get_global_mouse_position() - get_parent().get_parent().global_position
	
	if direction == Vector2.ZERO:
		return direction
	else:
		var angle = direction.angle() + rand_range(-shot_spread, shot_spread)
		return Vector2(1, 0).rotated(angle)


func body_entered(body: Node) -> void:
	if !body.is_in_group("player"):
		if body.is_in_group("enemy"):
			body.slingshot_timer.start()
		queue_free()


func timeout() -> void:
	queue_free()
