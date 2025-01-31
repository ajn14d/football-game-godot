extends Node

@export var play_start = false
@export var play_select = 0

@onready var game_scene = get_node("/root/GameScene")

@onready var play_menu = $PlaySelect

@onready var punt_play = $PlaySelect/PassPlays/Punt

var timer_accumulator: float = 0  # Accumulator for time tracking
var interval: float = 1.0  # Interval in seconds (once per second)

func _process(delta: float) -> void:
	timer_accumulator += delta
	if timer_accumulator >= interval:
		timer_accumulator = 0  # Reset the timer
			# Center the menu on the camera's view
		play_menu.position = Vector2(-80, game_scene.line_of_scrimmage.y + 125)
		play_menu.visible = true  # Enable the visibility of the menu
	if game_scene.down_counter == 4:
		punt_play.disabled = false
		punt_play.visible = true
	else:
		punt_play.disabled = true
		punt_play.visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("play_1"):
		print("Next Play: Quick Slants")
		play_select = 1
	elif Input.is_action_just_pressed("play_2"):
		print("Next Play: Hail Mary")
		play_select = 2
	if Input.is_action_just_pressed("new_play"):
		if get_tree().paused and play_select > 0:
			get_tree().paused = false
			play_start = true
			play_menu.visible = false  # Disable the visibility of the menu
		else:
			print("Select Play!")

func _on_slant_pressed() -> void:
	print("Next Play: Quick Slants")
	play_select = 1

func _on_go_pressed() -> void:
	print("Next Play: Hail Mary")
	play_select = 2

func _on_curls_pressed() -> void:
	print("Next Play: Curls")
	play_select = 3

func _on_punt_pressed() -> void:
	print("Punt")

func _on_hb_dive_pressed() -> void:
	print("Next Play: HB Dive")
	play_select = 4
