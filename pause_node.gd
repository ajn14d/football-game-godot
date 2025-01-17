extends Node

@export var play_start = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("new_play"):
		if get_tree().paused:
			get_tree().paused = false
			play_start = true
