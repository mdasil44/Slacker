extends Control

export (NodePath) var TargetPath

onready var TargetNode = get_node(TargetPath)
onready var StartOffset = self.rect_global_position - TargetNode.get_global_position()

var claimed = false


func _process(delta):
	self.rect_global_position = TargetNode.get_global_position() + StartOffset


func set_value(value) -> void:
	get_node("ProgressBar").value = value


func get_value():
	return get_node("ProgressBar").value


func claim() -> bool:
	if claimed == false:
		claimed = true
		return true
	else:
		return false

func return_claim():
	print("returned")
	claimed = false
