extends Node2D


export (PackedScene) var Enemy


func _process(delta: float) -> void:
	# allow enemies to be spawned (for testing purposes)
	if Input.is_action_just_pressed("ui_end"):
		var enemy_instance = Enemy.instance()
		enemy_instance.position = Vector2(992, -290)
		add_child(enemy_instance)
