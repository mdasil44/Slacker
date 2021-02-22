extends StaticBody2D

export (bool) var locked = false # door can only be unlocked once for now (once unlocked, unlocked forever)
export (bool) var openable = true
export (float) var open_time = 5.0
var open_timer = Timer.new()

var original_rotation = 0
var open = false

const EPSILON = 0.01 # margin for error in door orientation

var player: Node = null


func _ready() -> void:
	# if door not openable or it is unlocked, get rid of interaction area (no more need to unlock/interact)
	if not openable or not locked:
		$InteractionArea.queue_free()
	$Lock.scale.x = $Lock.scale.x / scale.x
	$Lock.scale.y = $Lock.scale.y / scale.y
	
	original_rotation = rotation
	
	open_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	open_timer.set_wait_time(open_time)
	open_timer.set_one_shot(true)
	open_timer.connect("timeout", self, "close_door")
	add_child(open_timer)


func _physics_process(delta: float) -> void:
	if not locked:
		$Lock.visible = false
	else:
		$Lock.visible = true
	$Lock.rotation = -rotation


func _on_InteractionArea_action_complete(target_node) -> void:
	locked = false
	if openable and not open:
		open_door(target_node)


func _on_ActorDetector_body_entered(body: Node) -> void:
	if not locked and openable and not open:
		open_door(body)


func _on_ActorDetector_body_exited(body: Node) -> void:
	if open and open_timer.get_time_left() <= 0:
		close_door()


func open_door(body):
	open_timer.start()
	if (rotation <= EPSILON) and (rotation >= -EPSILON):
		print(position,body.position)
		print(rotation)
		if body.position.y > position.y:
			rotation -= PI/2
			print(rotation)
		else:
			rotation += PI/2
	elif (rotation <= PI/2 + EPSILON) and (rotation >= PI/2 - EPSILON):
		if body.position.x > position.x:
			rotation += PI/2
		else:
			rotation -= PI/2
	elif (abs(rotation) <= PI) and (abs(rotation) >= PI - EPSILON):
		if body.position.y > position.y:
			rotation += PI/2
		else:
			rotation -= PI/2
	elif (rotation <= -PI/2 + EPSILON) and (rotation >= -PI/2 - EPSILON):
		if body.position.x > position.x:
			rotation -= PI/2
		else:
			rotation += PI/2
	
	open = true


func close_door():
	rotation = original_rotation
	
	open = false


# functions to provide a smooth rotation from one position to the next
func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight


func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
