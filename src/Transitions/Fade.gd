extends ColorRect


signal start_fade
signal fade_finished


func fade():
	$AnimationPlayer.play("Fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished")
