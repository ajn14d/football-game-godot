extends Node2D

var play_ended: bool = false  # Tracks whether the play has ended
var football: RigidBody2D  # Reference to the football node

# Define the position for the line of scrimmage
var line_of_scrimmage: Vector2 = Vector2(0, 544)

@onready var players = $Players
@onready var quarterback = $Players/Quarterback
@onready var runningback = $Players/Runningback

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get a reference to the football node
	football = $Football  # Adjust the path to your football node

	# Get the Area2D child of the football
	var football_area = football.get_node("DetectionArea")  # Adjust the path if needed

	# Connect the signal for the football's Area2D using Callable
	football_area.connect("area_entered", Callable(self, "_on_football_area_entered"))
	
	# Set the position of the sprite to the line of scrimmage position
	$LineOfScrimmage.position = line_of_scrimmage
	
	 # Position the quarterback relative to the line of scrimmage
	players.position = line_of_scrimmage + Vector2(0, 75)  # QB is 50 units above the line of scrimmage

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

# Callback when the football's Area2D enters another Area2D
# Callback when the football's Area2D enters another Area2D
func _on_football_area_entered(area: Area2D) -> void:
	# Check if the area is in the "yard" group
	if area.is_in_group("yard"):
		# Check if the player has the ball (either QB or RB)
		if (quarterback.has_ball or runningback.has_ball):
			print("Football at yard marker:", area.name)
			print("Football global position: ", football.global_position.y)
