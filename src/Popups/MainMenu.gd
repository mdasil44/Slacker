extends MarginContainer


var scene_path_to_load


func _ready():
	# for each child in the list of menu option buttons, connect to _on_Button_pressed function
	for button in $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuOptions.get_children():
		if button.name != "QuitButton":
			button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
	
	# on startup, disable the continue button and grab focus on the new game button
	get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuOptions/ContinueButton").disabled = true
	get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuOptions/ContinueButton").modulate = Color(1, 1, 1, 0.5)
	get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuOptions/ContinueButton").focus_mode = FOCUS_NONE
	get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuOptions/NewGameButton").grab_focus()


func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade()


#func _process(delta):
	


func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)
