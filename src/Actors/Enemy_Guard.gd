extends Enemy


var taser = preload("res://src/Tools/Taser.tscn")
onready var TaserPos = $TaserPosition


export (float) var cooldown: = 1.0 # how long between ability uses


func _ready() -> void:
	$AbilityCooldownTimer.set_wait_time(cooldown)
	
	ai.set_action(funcref(self, "shoot_taser"))


func shoot_taser(target_position):
	if $AbilityCooldownTimer.get_time_left() <= 0:
		var taser_instance = taser.instance()
		var angle = (target_position - global_position).angle()
		
		taser_instance.start(global_position, angle)
		TaserPos.add_child(taser_instance)
		$AbilityCooldownTimer.start()
