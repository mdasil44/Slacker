extends Control

export (NodePath) var TargetPath

onready var TargetNode = get_node(TargetPath)
onready var StartOffset = self.rect_global_position - TargetNode.get_global_position()


func _process(delta):
	self.rect_global_position = TargetNode.get_global_position() + StartOffset


func set_value(value) -> void:
	get_node("ProgressBar").value = value
