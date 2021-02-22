extends Actor


signal sneaking()


var JOYPAD_SENSITIVITY = 2
const JOYPAD_DEADZONE = 0.15


export (float) var cooldown: = 0.15 # how long between ability uses

export (float) var stun_time = 1.0
var stun_timer = Timer.new()

var FailScene = 'res://src/Popups/FailScreen.tscn'

const Arrow = preload('res://src/Interactions/Arrow.tscn')
var arrow = null

onready var ObjectivesContainer = get_parent().get_node("ObjectiveContainer")


func _ready() -> void:
	$ToolCooldownTimer.set_wait_time(cooldown)
	
	stun_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	stun_timer.set_wait_time(stun_time)
	stun_timer.set_one_shot(true)
	add_child(stun_timer)
	
	arrow = Arrow.instance()
	add_child(arrow)
	
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
	else:
		print("Keyboard")



func _on_EnemyDetector_body_entered(body: PhysicsBody2D) -> void:
	get_tree().change_scene(FailScene)


func _process(delta: float) -> void:	
	if Input.is_key_pressed(KEY_Q):
		get_tree().quit()


# Movement ----------------------------------------------------------

# involves everything the involves physics (objects that have to collide - detecting floor and walls)
# when class extends another (Actor), Godot will run this _physics_process as well as the parent process (Actor's _physics_process) first
func _physics_process(delta: float) -> void:
	var speed_multiplier = 1.0
	modulate = Color(1, 1, 1)
	if stun_timer.get_time_left() > 0:
		speed_multiplier = 0.0
		modulate = Color(1, 1, 0)
	
	var direction: = get_move_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed)
	# move_and_slide multiplies velocity by delta by default; it also returns a modified velocity based on if the object is hitting a wall or sliding (rotated or scaled)
	_velocity = move_and_slide(_velocity * speed_multiplier)
	
	# get player to face the direction they are moving and face that same direction when stopping
	if _velocity != Vector2.ZERO || direction != Vector2.ZERO:
		look_at((get_global_position() + direction))
	
	# look for next objective and rotate the arrow towards it
	var objective_angle = (ObjectivesContainer.get_child(ObjectivesContainer.objective_counter).position - global_position).angle()
	var objective_distance = global_position.distance_to(ObjectivesContainer.get_child(ObjectivesContainer.objective_counter).position)
	arrow.position = Vector2(40, 0).rotated(objective_angle - rotation)
	arrow.rotation = objective_angle - rotation
	if objective_distance < 40:
		arrow.hide()
	else:
		arrow.show()
	
	# use tool
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN and Input.is_action_just_pressed("use_tool")) or (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and Input.is_mouse_button_pressed(BUTTON_LEFT)):
		use_tool()
		if $ToolCooldownTimer.get_time_left() <= 0:
			$ToolCooldownTimer.start()
	
	# if controller look used, hide mouse (using MouseMode)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and (Input.get_action_strength("look_up") or Input.get_action_strength("look_down") or Input.get_action_strength("look_left") or Input.get_action_strength("look_right")):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN and Input.is_mouse_button_pressed(BUTTON_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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
		emit_signal("sneaking")
	
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
	
	#TEST
	#inputs for testing the different tools
	#if event.is_action_pressed("ui_cancel"):
	#	equip_tool("gum")
	#
	#if event.is_action_pressed("ui_home"):
	#	equip_tool("slingshot")


func equip_tool(tool_type: String):
	for existing_tools in ToolPos.get_children(): # if there is already tools there, remove them
		existing_tools.queue_free()
	
	_tool = tool_set[tool_type]


func use_tool():
	if _tool != null:
		if $ToolCooldownTimer.get_time_left() <= 0:
			var tool_instance = _tool.instance()
			ToolPos.add_child(tool_instance)
