extends Area2D

export (float) var lifetime: = 30.0 # how long will the tool live by default
export (int) var max_usage: = 3 # how many times can an enemy walk over the tool before it disappears

var timer = Timer.new()
var usage_counter = 0


func _ready() -> void:
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	timer.set_wait_time(lifetime)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "timeout")
	
	add_child(timer)
	timer.start()
	
	connect("body_entered", self, "body_entered")
	
	set_as_toplevel(true) # make the scene independent from parent movement
	set_position(global_position + Vector2(0, -16)) # offset to place gum under player body


func _physics_process(delta: float) -> void:
	pass


func body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		usage_counter += 1
		body.gummed_timer.start()
	
	if usage_counter >= max_usage:
		queue_free()


func timeout() -> void:
	queue_free()
