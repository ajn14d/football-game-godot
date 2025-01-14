extends Node2D

var play_ended: bool = false  # Tracks whether the play is paused

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the input handling
	set_process_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# You can add other logic here if needed
	if play_ended:
		# Optional: Add any visual indication or logic during pause
		pass

# Handle input to trigger the end_of_play function
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_play"):  # Default action for the space bar is "ui_accept"
		end_of_play()

# Function to handle the end of a play
func end_of_play() -> void:
	if not play_ended:
		play_ended = true
		get_tree().paused = true  # Pause the entire game
		print("Play Ended")
