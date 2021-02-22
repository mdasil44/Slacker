extends Area2D

export (float) var lifetime: = 30.0 # how long will the tool live by default
export (int) var max_usage: = 3 # how many times can an enemy walk over the tool before it disappears

onready var timer = $LifetimeTimer
var usage_counter = 0


func _ready() -> void:
	timer.set_wait_time(lifetime)
	timer.connect("timeout", self, "timeout")
	
	timer.start()
	
	connect("body_entered", self, "body_entered")
	
	set_position(get_parent().get_parent().global_position) # offset to place gum under player body
	set_as_toplevel(true) # make the scene independent from parent movement


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
