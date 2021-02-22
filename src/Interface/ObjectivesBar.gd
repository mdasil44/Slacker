extends Control


export (String) var ObjectivesFilePath = 'res://src/Objectives/LevelTemplate.txt'
export (String) var ThemeFilePath = 'res://assets/Themes/ObjectivesTheme.tres'


onready var ObjectivesBar = $InterfaceLayout/ObjectivesBar
onready var CounterContainer = $InterfaceLayout/CounterContainer

var tool_set_gui: = {
	gum = preload('res://src/Interface/GumCounter.tscn'),
	slingshot = preload('res://src/Interface/SlingshotCounter.tscn')
}


func _ready() -> void:
	load_file(ObjectivesFilePath)


func load_file(file):
	var f = File.new()
	var t = load(ThemeFilePath)
	var font = t.default_font
	font.size = 24
	t.default_font = font
	f.open(file, File.READ)
	
	while not f.eof_reached(): # iterate though all lines until the end of file is reached
		var line = f.get_line()
		var label = Label.new()
		label.text = line
		label.set_theme(t)
		ObjectivesBar.add_child(label)
	f.close()
	return


func _on_Task1Interaction_action_complete(target_node) -> void:
	pass # Replace with function body.


func _on_Task2Interaction_action_complete(target_node) -> void:
	pass # Replace with function body.


func _on_Task3Interaction_action_complete(target_node) -> void:
	pass # Replace with function body.


func _on_SlingshotBackpack_change_tool_gui(tool_type) -> void:
	for existing_counter in CounterContainer.get_children(): # free existing counters if any
		queue_free()
	CounterContainer.add_child(tool_set_gui["slingshot"].instance())


func _on_GumBackpack_change_tool_gui(tool_type) -> void:
	for existing_counter in CounterContainer.get_children(): # free existing counters if any
		queue_free()
	CounterContainer.add_child(tool_set_gui["gum"].instance())
