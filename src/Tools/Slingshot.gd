extends Area2D

export (float) var lifetime: = 5.0 # how long will the tool live by default
export (float) var speed: = 600 # how fast does bullet travel

var timer = Timer.new()

var velocity:Vector2

func _ready() -> void:
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	timer.set_wait_time(lifetime)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "timeout")
	
	add_child(timer)
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
	return Vector2(
		# Input allows you to query an input on every frame of the game
		Input.get_action_strength("look_right") - Input.get_action_strength("look_left"),
		Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	).normalized() # ensures object doesn't move faster diagonally


func body_entered(body: Node) -> void:
	print(body.name)
	if body.name != "Player":
		if body.is_in_group("enemy"):
			body.slingshot_timer.start()
		queue_free()


func timeout() -> void:
	queue_free()
