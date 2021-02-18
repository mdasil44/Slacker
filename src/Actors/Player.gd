extends Actor


var JOYPAD_SENSITIVITY = 2
const JOYPAD_DEADZONE = 0.15


func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
	else:
		print("Keyboard")



func _on_EnemyDetector_body_entered(body: PhysicsBody2D) -> void:
	print(body.name)
	print("Game Over!")
	pass # add functionality to bring up game over screen (make sure player can't move while that screen is up)


func _process(delta: float) -> void:	
	if Input.is_key_pressed(KEY_Q):
		get_tree().quit()
	#if Input.is_action_just_pressed(ui)


func get_look_direction() -> Vector2:
	return get_global_mouse_position()


# Movement ----------------------------------------------------------

# involves everything the involves physics (objects that have to collide - detecting floor and walls)
# when class extends another (Actor), Godot will run this _physics_process as well as the parent process (Actor's _physics_process) first
func _physics_process(delta: float) -> void:
	var direction: = get_move_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed)
	# move_and_slide multiplies velocity by delta by default; it also returns a modified velocity based on if the object is hitting a wall or sliding (rotated or scaled)
	_velocity = move_and_slide(_velocity)
	
	# get player to face the direction they are moving and face that same direction when stopping
	if _velocity != Vector2.ZERO || direction != Vector2.ZERO:
		look_at((get_global_position() + direction))



# separate out get_direction to allow both physics processes and direction calculations to be modified separately
func get_move_direction() -> Vector2:
	return Vector2(
		# Input allows you to query an input on every frame of the game
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() # ensures player doesn't move faster diagonally


# explicit variable passing to ensure no direct modification of character properties
func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2
	) -> Vector2:
	# can use : = to assign value and explicit type at the same time
	var new_velocity: = linear_velocity

	# delta is the time elapsed since last frame
	# used to make velocity frame rate independent (velocity of character should stay the same even if game slows down) vel*delta
	# new_velocity.y += gravity * get_physics_process_delta_time()
	new_velocity = speed * direction
	
	if Input.is_action_pressed("sneak"):
		new_velocity *= 0.5
	
	return new_velocity


# Tools ----------------------------------------------------------------

onready var ToolPos: = $ToolPosition
var tool_set: = {
	gum			= preload("res://src/Tools/Gum.tscn"),
	slingshot	= preload("res://src/Tools/Slingshot.tscn")
}
var _tool


func _unhandled_input(event: InputEvent) -> void:
	# Allow zooming the camera in and out for testing purposes (to be converted into a button for wide and close camera view toggle)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			if $Camera2D.zoom > Vector2(0.1, 0.1):
				$Camera2D.zoom = $Camera2D.zoom - Vector2(0.05, 0.05)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			#if $Camera2D.zoom < Vector2(0.75, 0.75):
			$Camera2D.zoom = $Camera2D.zoom + Vector2(0.05, 0.05)
	
	# use tool
	if event.is_action_pressed("use_tool"):
		use_tool()
	
	if event.is_action_pressed("ui_cancel"):
		equip_tool("gum")
	
	if event.is_action_pressed("ui_home"):
		equip_tool("slingshot")


func equip_tool(tool_type: String):
	for existing_tools in ToolPos.get_children(): # if there is already tools there, remove them
		existing_tools.queue_free()
	
	_tool = tool_set[tool_type]


func use_tool():
	if _tool != null:
		var tool_instance = _tool.instance()
		ToolPos.add_child(tool_instance)
