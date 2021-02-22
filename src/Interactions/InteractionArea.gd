extends Node2D

enum Orientation { ANY, UP, DOWN, LEFT, RIGHT }

signal action_complete(target_node)

export (NodePath) var ProgressBarPath
export (Orientation) var direction: = Orientation.ANY
export var wait_time = 5.0
export (bool) var visible_indicator = false
export (bool) var reusable = false
export (bool) var enabled = true

onready var ProgressBarNode: Node = get_node(ProgressBarPath)
var ProgressBarClaim = false

# defining state constants for when an object is in or out of the interaction area
const IN_AREA = 1
const OUT_OF_AREA = 0

# defining rotation constants for use in body orientation comparisons (is the body facing up, down, left, or right
const QUARTER_ROTATION = PI / 2
const RIGHT_ROTATION = 0
const UP_ROTATION = -QUARTER_ROTATION
const LEFT_ROTATION = 2 * QUARTER_ROTATION
const DOWN_ROTATION = QUARTER_ROTATION
const FLOAT_EPSILON = QUARTER_ROTATION / 2 # for use in comparing rotation angles (is the angle within +/- 45 degrees of the target angle)

var player: Node = null

var _state = OUT_OF_AREA
var timer = Timer.new()
var timing = false
var completed = false

var IndicatorColor = Color(0.0, 0.5, 1.0, 0.2)


func _on_InteractionDetection_body_entered(body: PhysicsBody2D) -> void:
	if body and body.is_in_group("player"):
		player = body
		_state = IN_AREA


func _on_InteractionDetection_body_exited(body: PhysicsBody2D) -> void:
	if body and player:
		if body == player:
			body == null
			_state = OUT_OF_AREA
			if reusable:
				completed = false


func _ready():
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	timer.set_wait_time(wait_time)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "action_complete")
	
	add_child(timer)


func _process(delta):
	update()
	# if in the interaction area and facing the right direction (based on export variable) and the action hasnt been completed
	#   then check if the interact button is being pressed or if the player is attempting to walk in the desired direction
	#   if so, start timing process
	if enabled and not completed and _state == IN_AREA and (direction == Orientation.ANY or \
	(direction == Orientation.UP and compare_rotations(player.get_rotation(), UP_ROTATION)) or \
	(direction == Orientation.DOWN and compare_rotations(player.get_rotation(), DOWN_ROTATION)) or \
	(direction == Orientation.LEFT and compare_rotations(player.get_rotation(), LEFT_ROTATION)) or \
	(direction == Orientation.RIGHT and compare_rotations(player.get_rotation(), RIGHT_ROTATION))):
		if Input.is_action_pressed("interact"):
			timing = true
		elif ((direction == Orientation.ANY and player.get_move_direction() != Vector2.ZERO) or
		(direction == Orientation.UP and compare_rotations(player.get_move_direction().angle(), UP_ROTATION)) or \
		(direction == Orientation.DOWN and compare_rotations(player.get_move_direction().angle(), DOWN_ROTATION)) or \
		(direction == Orientation.LEFT and compare_rotations(player.get_move_direction().angle(), LEFT_ROTATION)) or \
		(direction == Orientation.RIGHT and compare_rotations(player.get_move_direction().angle(), RIGHT_ROTATION))) and \
		player._velocity == Vector2.ZERO:
			timing = true
		else:
			timing = false
	else:
		timing = false
	
	if timing == true:
		var time_left = timer.get_time_left()
		if time_left <= 0:
			timer.start()
		
		if not ProgressBarClaim:
			ProgressBarClaim = ProgressBarNode.claim()
		if ProgressBarClaim:
			ProgressBarNode.visible = true
			ProgressBarNode.set_value(100.0 * (wait_time - timer.get_time_left()) / wait_time) # update progress bar to a level scaled with the total wait time
	else:
		timer.stop()
		
		if ProgressBarClaim:
			ProgressBarNode.visible = false
			ProgressBarNode.set_value(0.0)
			ProgressBarNode.return_claim()
			ProgressBarClaim = false


func _draw() -> void:
	if visible_indicator:
		draw_circle(Vector2.ZERO, 40, IndicatorColor)


func compare_rotations(current, target, epsilon = FLOAT_EPSILON):
	return abs(current - target) <= epsilon


func action_complete():
	emit_signal("action_complete", player)
	completed = true
