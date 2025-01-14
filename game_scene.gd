extends Node2D

var play_ended: bool = false  # Tracks whether the play has ended
var football: RigidBody2D  # Reference to the football node

var snap_speed = 200

# Define the position for the line of scrimmage
var line_of_scrimmage: Vector2 = Vector2(0, 544)
var last_football_position_y: float = 0.0  # Store the last position of the football's Y

# Store the pre-play positions of the players
var pre_play_positions: Dictionary = {}

@onready var players = $Players
@onready var quarterback = $Quarterback
@onready var runningback = $Runningback
@onready var right_defensive_tackle = $RightDefensiveTackle
@onready var left_defensive_tackle = $LeftDefensiveTackle
@onready var right_defensive_end = $RightDefensiveEnd
@onready var left_defensive_end = $LeftDefensiveEnd
@onready var right_offensive_guard = $RightOffensiveGuard
@onready var left_offensive_guard = $LeftOffensiveGuard
@onready var right_offensive_tackle = $RightOffensiveTackle
@onready var left_offensive_tackle = $LeftOffensiveTackle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get a reference to the football node
	football = $Football  # Adjust the path to your football node

	# Get the Area2D child of the football
	var football_area = football.get_node("DetectionArea")  # Adjust the path if needed

	# Connect the signal for the football's Area2D using Callable
	football_area.connect("area_entered", Callable(self, "_on_football_area_entered"))
	
	# Set the football position to the line of scrimmage and snap it
	football.position = line_of_scrimmage
	football.linear_velocity = Vector2(0, snap_speed)
	
	# Set the position of the sprite to the line of scrimmage position
	$LineOfScrimmage.position = line_of_scrimmage
	
# Position the players relative to the line of scrimmage
	quarterback.position = line_of_scrimmage + Vector2(0, 75)  # QB position
	runningback.position = line_of_scrimmage + Vector2(-50, 75)  # RB position
	right_defensive_tackle.position = line_of_scrimmage + Vector2(-30, -15)  # Right Defensive Tackle
	left_defensive_tackle.position = line_of_scrimmage + Vector2(30, -15)  # Left Defensive Tackle
	right_defensive_end.position = line_of_scrimmage + Vector2(-60, -15)  # Right Defensive End
	left_defensive_end.position = line_of_scrimmage + Vector2(60, -15)  # Left Defensive End
	right_offensive_guard.position = line_of_scrimmage + Vector2(25, 15)  # Right Offensive Guard
	left_offensive_guard.position = line_of_scrimmage + Vector2(-25, 15)  # Left Offensive Guard
	right_offensive_tackle.position = line_of_scrimmage + Vector2(50, 15)  # Right Offensive Tackle
	left_offensive_tackle.position = line_of_scrimmage + Vector2(-50, 15)  # Left Offensive Tackle
	
	# Save the pre-play position of the players
	pre_play_positions["quarterback"] = quarterback.position
	pre_play_positions["runningback"] = runningback.position
	pre_play_positions["right_defensive_tackle"] = right_defensive_tackle.position
	pre_play_positions["left_defensive_tackle"] = left_defensive_tackle.position
	pre_play_positions["right_defensive_end"] = right_defensive_end.position
	pre_play_positions["left_defensive_end"] = left_defensive_end.position
	pre_play_positions["right_offensive_guard"] = right_offensive_guard.position
	pre_play_positions["left_offensive_guard"] = left_offensive_guard.position
	pre_play_positions["right_offensive_tackle"] = right_offensive_tackle.position
	pre_play_positions["left_offensive_tackle"] = left_offensive_tackle.position

# Handle input to trigger the end_of_play function
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_play"):  # Default action for the space bar is "ui_accept"
		end_of_play()

# Function to handle the end of play
func end_of_play() -> void:
	if not play_ended:
		play_ended = true
		get_tree().paused = true  # Pause the entire game
		print("Play Ended")

		# Update the line of scrimmage to the last position of the football
		line_of_scrimmage.y = last_football_position_y
		$LineOfScrimmage.position = line_of_scrimmage
		print("New Line of Scrimmage Y Position: ", line_of_scrimmage.y)
		
		football.linear_velocity = Vector2(0, 0)
		
		# Reset players to pre-play positions
		pre_play()

# Function to reset players' positions to pre-play positions
func pre_play() -> void:
	
	football.past_los = false
	
	# remove ball from player
	quarterback.has_ball = false 
	runningback.has_ball = false
	
	play_ended = false
	# Calculate the offset from the original line of scrimmage
	var line_of_scrimmage_offset = line_of_scrimmage.y - pre_play_positions["quarterback"].y + 75
	
	# Set the football position to the line of scrimmage
	football.position = line_of_scrimmage
	
	# Snap football to QB
	football.linear_velocity = Vector2(0, snap_speed)

	# Reset the players to their pre-play positions adjusted for the new line of scrimmage
	quarterback.position = pre_play_positions["quarterback"] + Vector2(0, line_of_scrimmage_offset)
	runningback.position = pre_play_positions["runningback"] + Vector2(0, line_of_scrimmage_offset)
	right_defensive_end.position = pre_play_positions["right_defensive_end"] + Vector2(0, line_of_scrimmage_offset)
	right_defensive_tackle.position = pre_play_positions["right_defensive_tackle"] + Vector2(0, line_of_scrimmage_offset)
	left_defensive_end.position = pre_play_positions["left_defensive_end"] + Vector2(0, line_of_scrimmage_offset)
	left_defensive_tackle.position = pre_play_positions["left_defensive_tackle"] + Vector2(0, line_of_scrimmage_offset)
	right_offensive_guard.position = pre_play_positions["right_offensive_guard"] + Vector2(0, line_of_scrimmage_offset)
	right_offensive_tackle.position = pre_play_positions["right_offensive_tackle"] + Vector2(0, line_of_scrimmage_offset)
	left_offensive_guard.position = pre_play_positions["left_offensive_guard"] + Vector2(0, line_of_scrimmage_offset)
	left_offensive_tackle.position = pre_play_positions["left_offensive_tackle"] + Vector2(0, line_of_scrimmage_offset)

	# Print the new positions to check
	#print("Quarterback's position after reset: ", quarterback.position)
	#print("Runningback's position after reset: ", runningback.position)
	#print("Right Defensive Tackle's position after reset: ", right_defensive_tackle.position)
	#print("Left Defensive Tackle's position after reset: ", left_defensive_tackle.position)
	#print("Right Offensive Guard's position after reset: ", right_offensive_guard.position)
	#print("Left Offensive Guard's position after reset: ", left_offensive_guard.position)
	#print("Football's position after reset: ", football.position)

# Callback when the football's Area2D enters another Area2D
func _on_football_area_entered(area: Area2D) -> void:
	# Check if the area is in the "yard" group
	if area.is_in_group("yard"):
		# Check if the player has the ball (either QB or RB)
		if quarterback.has_ball or runningback.has_ball:
			# Only update position if the QB or RB has the ball
			#print("Football at yard marker:", area.name)
			#print("Football global position: ", football.global_position.y)
			
			# Update the last recorded position of the football only if QB or RB has the ball
			last_football_position_y = football.global_position.y
	if area.is_in_group("LOS"):
		football.past_los = true
		print("past the lOS")
