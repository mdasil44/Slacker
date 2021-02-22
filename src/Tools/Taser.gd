extends Area2D

export (float) var lifetime: = 5.0 # how long will the tool live by default
export (float) var speed: = 600 # how fast does bullet travel
export (float) var shot_spread: = 0.05 # how much spread there is to each taser shot

onready var timer = $LifetimeTimer

var velocity:Vector2

func _ready() -> void:
	timer.set_wait_time(lifetime)
	timer.connect("timeout", self, "timeout")
	
	timer.start()
	
	connect("body_entered", self, "body_entered")
	
	set_as_toplevel(true) # make the scene independent from parent movement


func start(starting_position, direction):
	direction = direction + rand_range(-shot_spread, shot_spread)
	rotation = direction + PI/2 # adding PI/2 to ensure sprite is in the right direction
	velocity = Vector2(speed, 0).rotated(direction)


func _physics_process(delta: float) -> void:
	global_translate(velocity * delta)


func body_entered(body: Node) -> void:
	# if the body being hit by the taser isn't self (parent of parent of taser is EnemyGuard)
	if body != get_parent().get_parent(): 
		if body.is_in_group("player") or body.is_in_group("enemy"):
			body.stun_timer.start()
		queue_free()


func timeout() -> void:
	queue_free()
