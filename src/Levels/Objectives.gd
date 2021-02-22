extends Container


export (int) var total_objectives = 3


var objective_counter = 0
var WinScene = 'res://src/Popups/WinScreen.tscn'

func _ready() -> void:
	for task in get_children():
		task.connect("action_complete", self, "_on_action_complete")


func _on_action_complete(target_node) -> void:
	if objective_counter < total_objectives - 1:
		get_child(objective_counter).visible_indicator = false
		get_child(objective_counter).enabled = false
		objective_counter += 1
		get_child(objective_counter).visible_indicator = true
		get_child(objective_counter).enabled = true
	else:
		get_tree().change_scene(WinScene)



