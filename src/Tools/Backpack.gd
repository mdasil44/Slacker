extends StaticBody2D

signal change_tool_gui(tool_type)

var image_set: = {
	gum		= preload("res://assets/Gum_Backpack.png"),
	slingshot	= preload("res://assets/Slingshot_Backpack.png")
}

var tool_set: = {
	gum			= preload("res://src/Tools/Gum.tscn"),
	slingshot	= preload("res://src/Tools/Slingshot.tscn")
}

export (String, "gum", "slingshot") var tool_type = "gum"

var player: Node = null


func _ready() -> void:
	$backpack.texture = image_set[tool_type]


func _on_InteractionArea_action_complete(target_node) -> void:
	player = target_node
	player.equip_tool(tool_type)
	emit_signal("change_tool_gui", tool_type)
