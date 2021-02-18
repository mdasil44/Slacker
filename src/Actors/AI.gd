extends Node2D

signal state_changed(new_state)

# potential states for state machine
enum State {
	PATROL,
	ENGAGE
}

onready var PlayerDetectionZone = $PlayerDetectionZone
export var detection_radius = 400

var current_state: int = State.PATROL setget set_state # whenver state changes, call set_state function
var player: Node = null


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	current_state = new_state
	emit_signal("state_changed", current_state)


func _ready() -> void:
	$PlayerDetectionZone/CollisionShape2D.shape.radius = detection_radius


func _on_PlayerDetectionZone_body_entered(body: Node) -> void:
	# check if body is a Player and if it is in front of the enemy body
	if body.is_in_group("player") and body.global_position.x >= global_position.x:
		set_state(State.ENGAGE)
		player = body
