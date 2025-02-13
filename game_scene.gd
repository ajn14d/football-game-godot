#WARNING mostly spaghetti code

extends Node2D

var play_ended: bool = false  # Tracks whether the play has ended
var football: RigidBody2D  # Reference to the football node

var home_score = 0
var away_score = 0

var snap_speed = 300

var tackled = false
var incomplete = false

var down_counter = 0

var ball_in_endzone = false

# Bools to tell if run play or pass play
var run_play = false
var pass_play = false

enum WRState { INITIAL, MOVING_NORTH, MOVING_SOUTH, MOVING_EAST, MOVING_WEST, MOVING_NORTHEAST, MOVING_NORTHWEST, MOVING_SOUTHEAST, MOVING_SOUTHWEST, NOT_MOVING }

var wr1_state = WRState.INITIAL  # Initial state
var wr2_state = WRState.INITIAL  # Initial state
var wr3_state = WRState.INITIAL  # Initial state
var wr4_state = WRState.INITIAL  # Initial state
var rb_state = WRState.INITIAL

# Define the position for the line of scrimmage
var line_of_scrimmage: Vector2 = Vector2(0, 544)
var last_football_position_y: float = 0.0  # Store the last position of the football's Y

# Store the pre-play positions of the players
var pre_play_positions: Dictionary = {}

# load menu node
@onready var pause_node = $PauseNode

#Loading Player Node's
@onready var players = $Players
	#Offense
@onready var quarterback = $Quarterback
@onready var runningback = $Runningback
@onready var wide_receiver_1 = $WideReceiver1
@onready var wide_receiver_2 = $WideReceiver2
@onready var wide_receiver_3 = $WideReceiver3
@onready var wide_receiver_4 = $WideReceiver4
@onready var right_offensive_guard = $RightOffensiveGuard
@onready var left_offensive_guard = $LeftOffensiveGuard
@onready var right_offensive_tackle = $RightOffensiveTackle
@onready var left_offensive_tackle = $LeftOffensiveTackle
@onready var center = $Center
	#Defesnde
@onready var middle_linebacker = $MiddleLineBacker
@onready var outside_linebacker_1 = $OutsideLineBacker1
@onready var outside_linebacker_2 = $OutsideLineBacker2
@onready var defensive_back_1 = $DefensiveBack1
@onready var defensive_back_2 = $DefensiveBack2
@onready var defensive_back_3 = $DefensiveBack3
@onready var defensive_back_4 = $DefensiveBack4
@onready var right_defensive_tackle = $RightDefensiveTackle
@onready var left_defensive_tackle = $LeftDefensiveTackle
@onready var right_defensive_end = $RightDefensiveEnd
@onready var left_defensive_end = $LeftDefensiveEnd

# Random float values to determine length of pre-coverage for DB's
var db_1_pre_cover_duration = 0.0
var db_2_pre_cover_duration = 0.0
var db_3_pre_cover_duration = 0.0
var db_4_pre_cover_duration = 0.0

# Random float to detmine distance of DB coverage.
var db_1_cover_distance = 0.0
var db_2_cover_distance = 0.0
var db_3_cover_distance = 0.0
var db_4_cover_distance = 0.0

# Random Int to determine Linebacker plays
var middle_linebacker_play = 0
var middle_linebacker_coverage_angle = 0

var outside_linebacker_1_play = 0
var outside_linebacker_1_coverage_angle = 0

var outside_linebacker_2_play = 0
var outside_linebacker_2_coverage_angle = 0

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
	
	$FirstDown.position = Vector2($FirstDown.position.x, line_of_scrimmage.y - 182)
	
	# Position the players relative to the line of scrimmage
		#Offense
	quarterback.position = line_of_scrimmage + Vector2(0, 75)  # QB position
	runningback.position = line_of_scrimmage + Vector2(-50, 75)  # RB position
	wide_receiver_1.position = line_of_scrimmage + Vector2(200, 15)  # Wide Receiver 1 position
	wide_receiver_2.position = line_of_scrimmage + Vector2(-200, 15)  # Wide Receiver 2 position
	wide_receiver_3.position = line_of_scrimmage + Vector2(400, 15)  # Wide Receiver 3 position
	wide_receiver_4.position = line_of_scrimmage + Vector2(-400, 15)  # Wide Receiver 4 position
	right_offensive_guard.position = line_of_scrimmage + Vector2(25, 15)  # Right Offensive Guard
	left_offensive_guard.position = line_of_scrimmage + Vector2(-25, 15)  # Left Offensive Guard
	right_offensive_tackle.position = line_of_scrimmage + Vector2(50, 15)  # Right Offensive Tackle
	left_offensive_tackle.position = line_of_scrimmage + Vector2(-50, 15)  # Left Offensive Tacklee
	center.position = line_of_scrimmage + Vector2(0, 15)  # Wide Receiver 1 position
		#Defense
	middle_linebacker.position = line_of_scrimmage + Vector2(0, -75)  # MiddleLineBackers position
	outside_linebacker_1.position = line_of_scrimmage + Vector2(100, -75)  # OLB1 position
	outside_linebacker_2.position = line_of_scrimmage + Vector2(-100, -75)  # OLB2 position
	defensive_back_1.position = line_of_scrimmage + Vector2(200, -55)  # DB1 position
	defensive_back_2.position = line_of_scrimmage + Vector2(-200, -55)  # DB2 position
	defensive_back_3.position = line_of_scrimmage + Vector2(400, -55)  # DB3 position
	defensive_back_4.position = line_of_scrimmage + Vector2(-400, -55)  # DB4 position
	right_defensive_tackle.position = line_of_scrimmage + Vector2(-30, -15)  # Right Defensive Tackle
	left_defensive_tackle.position = line_of_scrimmage + Vector2(30, -15)  # Left Defensive Tackle
	right_defensive_end.position = line_of_scrimmage + Vector2(-60, -15)  # Right Defensive End
	left_defensive_end.position = line_of_scrimmage + Vector2(60, -15)  # Left Defensive End

	# Save the pre-play position of the players
		#Offense
	pre_play_positions["quarterback"] = quarterback.position
	pre_play_positions["runningback"] = runningback.position
	pre_play_positions["wide_receiver_1"] = wide_receiver_1.position
	pre_play_positions["wide_receiver_2"] = wide_receiver_2.position
	pre_play_positions["wide_receiver_3"] = wide_receiver_3.position
	pre_play_positions["wide_receiver_4"] = wide_receiver_4.position
	pre_play_positions["right_offensive_guard"] = right_offensive_guard.position
	pre_play_positions["left_offensive_guard"] = left_offensive_guard.position
	pre_play_positions["right_offensive_tackle"] = right_offensive_tackle.position
	pre_play_positions["left_offensive_tackle"] = left_offensive_tackle.position
	pre_play_positions["center"] = center.position
		#Defense
	pre_play_positions["middle_linebacker"] = middle_linebacker.position
	pre_play_positions["outside_linebacker_1"] = outside_linebacker_1.position
	pre_play_positions["outside_linebacker_2"] = outside_linebacker_2.position
	pre_play_positions["defensive_back_1"] = defensive_back_1.position
	pre_play_positions["defensive_back_2"] = defensive_back_2.position
	pre_play_positions["defensive_back_3"] = defensive_back_3.position
	pre_play_positions["defensive_back_4"] = defensive_back_4.position
	pre_play_positions["right_defensive_tackle"] = right_defensive_tackle.position
	pre_play_positions["left_defensive_tackle"] = left_defensive_tackle.position
	pre_play_positions["right_defensive_end"] = right_defensive_end.position
	pre_play_positions["left_defensive_end"] = left_defensive_end.position
	
	start_of_play()

func start_of_play() -> void:
	if not play_ended:
		play_ended = true
		get_tree().paused = true  # Pause the entire game
		#print("Start")
		
		# Reset players to pre-play positions
		pre_play()

func _process(delta: float) -> void:
	if pause_node.play_start:
		center.is_blocked = false
		center.after_block_engage = false
		if pause_node.play_select == 1:
			pass_play_1()
		elif pause_node.play_select == 2:
			pass_play_2()
		elif pause_node.play_select == 3:
			pass_play_3()
		elif pause_node.play_select == 4:
			run_play_1()
	if tackled:
		# Remove the ball from all potential ball carriers
		quarterback.has_ball = false 
		runningback.has_ball = false
		wide_receiver_1.has_ball = false
		wide_receiver_2.has_ball = false
		wide_receiver_3.has_ball = false
		wide_receiver_4.has_ball = false
		end_of_play()
		tackled = false
	
	if incomplete:
		# Remove the ball from all potential ball carriers
		quarterback.has_ball = false 
		runningback.has_ball = false
		wide_receiver_1.has_ball = false
		wide_receiver_2.has_ball = false
		wide_receiver_3.has_ball = false
		wide_receiver_4.has_ball = false
		incomplete_pass()
		incomplete = false
		
	if ball_in_endzone:
		if quarterback.has_ball or runningback.has_ball or wide_receiver_1.has_ball or wide_receiver_2.has_ball or wide_receiver_3.has_ball or wide_receiver_4.has_ball:
			print("Touchdown!!!")
			ball_in_endzone = false
			GameStats.home_score += 7
			get_tree().change_scene_to_file("res://opponent_possession.tscn")

# Handle input to trigger the end_of_play function
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_play"):  # Default action for the space bar is "ui_accept"
		end_of_play()

# Function to handle the end of play
func end_of_play() -> void:
	if not play_ended:
		play_ended = true
		get_tree().paused = true  # Pause the entire game
		#print("Play Ended")

		# Update the line of scrimmage to the last position of the football
		line_of_scrimmage.y = last_football_position_y
		$LineOfScrimmage.position = line_of_scrimmage
		#print("New Line of Scrimmage Y Position: ", line_of_scrimmage.y)
		
		# Check if the line of scrimmage is at or past -725 (10-yard line)
		if line_of_scrimmage.y <= -725 and $FirstDown.position.y >= $LineOfScrimmage.position.y:
			$FirstDown.position = Vector2($FirstDown.position.x, -900)
			down_counter = 0
			#print("First Down set to -900 because Line of Scrimmage is <= -725")
		# Only reset and place first down marker if a first down is achieved
		elif $FirstDown.position.y >= $LineOfScrimmage.position.y:
			$FirstDown.position = Vector2($FirstDown.position.x, line_of_scrimmage.y - 182)
			print("First Down!")
			down_counter = 0  # Reset down counter only if first down is made
		else:
			pass
			# If no first down, don't move the first down marker
			#print("No first down. First down marker not moved.")
		
		football.linear_velocity = Vector2(0, 0)
		
		if down_counter >= 4:
			print("opponent posession")
			get_tree().change_scene_to_file("res://opponent_possession.tscn")
		
		# Reset players to pre-play positions
		pre_play()

# Function to handle the end of play if player goes out of bounds
func incomplete_pass() -> void:
	if not play_ended:
		play_ended = true
		get_tree().paused = true  # Pause the entire game
		#print("Play Ended")
		
		# Reset players to pre-play positions
		pre_play()

# Function to reset players' positions to pre-play positions
func pre_play() -> void:
	
	ball_in_endzone = false
	
	down_counter += 1
	print("CUDDRENT DOWN: ", down_counter)
	
	football.football_thrown = false
	football.past_los = false
	
	# Remove the ball from all potential ball carriers
	quarterback.has_ball = false 
	runningback.has_ball = false
	wide_receiver_1.has_ball = false
	wide_receiver_2.has_ball = false
	wide_receiver_3.has_ball = false
	wide_receiver_4.has_ball = false
	
	reset_all_stamina()
	
	wr1_state = WRState.INITIAL  # Initial state
	wr2_state = WRState.INITIAL  # Initial state
	wr3_state = WRState.INITIAL  # Initial state
	wr4_state = WRState.INITIAL  # Initial state
	rb_state = WRState.INITIAL
	
	center.after_block_engage = false
	center.is_blocked = false
	
	# Below are factors for Defensive backs. Include Bools, variables and randomized floats to mimic game feel and player desicion making.
	defensive_back_1.pre_cover_ = true
	defensive_back_2.pre_cover_ = true
	defensive_back_3.pre_cover_ = true
	defensive_back_4.pre_cover_ = true
	
	# randomize db pre cover time
	db_1_pre_cover_duration = 0.0 + randf() * 2.0
	db_2_pre_cover_duration = 0.0 + randf() * 2.0
	db_3_pre_cover_duration = 0.0 + randf() * 2.0
	db_4_pre_cover_duration = 0.0 + randf() * 2.0
	
	if db_1_pre_cover_duration < 0.8:
		defensive_back_1.pre_cover_ = false
	if db_2_pre_cover_duration < 0.8:
		defensive_back_2.pre_cover_ = false
	if db_3_pre_cover_duration < 0.8:
		defensive_back_3.pre_cover_ = false
	if db_4_pre_cover_duration < 0.8:
		defensive_back_4.pre_cover_ = false
	
	# Randomize db cover distance
	db_1_cover_distance = 5 + randf() * 60
	db_2_cover_distance = 5 + randf() * 60
	db_3_cover_distance = 5 + randf() * 60
	db_4_cover_distance = 5 + randf() * 60
	
	# set bools for linebacker play select to false
	middle_linebacker.blitz_bool = false
	middle_linebacker.drop_coverage_bool = false
	middle_linebacker.in_coverage_bool = false
	
	outside_linebacker_1.blitz_bool = false
	outside_linebacker_1.drop_coverage_bool = false
	outside_linebacker_1.in_coverage_bool = false
	
	outside_linebacker_2.blitz_bool = false
	outside_linebacker_2.drop_coverage_bool = false
	outside_linebacker_2.in_coverage_bool = false
	
	# Random Int to determine MLB play selection
	middle_linebacker_play = (randi() % 2)
	#print("MLB play ", middle_linebacker_play)
	
	if middle_linebacker_play == 1:
		middle_linebacker.drop_coverage_bool = true
	
	#Randomize coverage angle for LB's
	middle_linebacker_coverage_angle = (randi() % 5)
	if middle_linebacker_coverage_angle == 0:
		middle_linebacker_coverage_angle = -40
	elif middle_linebacker_coverage_angle == 1:
		middle_linebacker_coverage_angle = -20
	elif middle_linebacker_coverage_angle == 2:
		middle_linebacker_coverage_angle = 0
	elif middle_linebacker_coverage_angle == 3:
		middle_linebacker_coverage_angle = 20
	elif middle_linebacker_coverage_angle == 4:
		middle_linebacker_coverage_angle = 40
	
	# Random Int to determine OLB1 play selection
	outside_linebacker_1_play = (randi() % 2)
	#print("OLB1 play ", outside_linebacker_1_play)
	
	if outside_linebacker_1_play == 1:
		outside_linebacker_1.drop_coverage_bool = true
	
	#Randomize LB1 coverage angle
	outside_linebacker_1_coverage_angle = (randi() % 3)
	if outside_linebacker_1_coverage_angle == 0:
		outside_linebacker_1_coverage_angle = 40
	elif outside_linebacker_1_coverage_angle == 1:
		outside_linebacker_1_coverage_angle = 20
	elif outside_linebacker_1_coverage_angle == 2:
		outside_linebacker_1_coverage_angle = 0

	# Random Int to determine OLB1 play selection
	outside_linebacker_2_play = (randi() % 3)
	#print("OLB2 play ", outside_linebacker_2_play)
	
	if outside_linebacker_2_play == 1:
		outside_linebacker_2.drop_coverage_bool = true
	
	#Randomize LB2 coverage angle
	outside_linebacker_2_coverage_angle = (randi() % 3)
	if outside_linebacker_2_coverage_angle == 0:
		outside_linebacker_2_coverage_angle = -40
	elif outside_linebacker_2_coverage_angle == 1:
		outside_linebacker_2_coverage_angle = -20
	elif outside_linebacker_2_coverage_angle == 2:
		outside_linebacker_2_coverage_angle = 0
	
	play_ended = false
	# Calculate the offset from the original line of scrimmage
	var line_of_scrimmage_offset = line_of_scrimmage.y - pre_play_positions["quarterback"].y + 75
	
	# Set the football position to the line of scrimmage
	football.position = line_of_scrimmage
	
	# Snap football to QB
	football.linear_velocity = Vector2(0, snap_speed)

	# Reset the players to their pre-play positions adjusted for the new line of scrimmage
		#Offense
	quarterback.position = pre_play_positions["quarterback"] + Vector2(0, line_of_scrimmage_offset)
	runningback.position = pre_play_positions["runningback"] + Vector2(0, line_of_scrimmage_offset)
	wide_receiver_1.position = pre_play_positions["wide_receiver_1"] + Vector2(0, line_of_scrimmage_offset)
	wide_receiver_2.position = pre_play_positions["wide_receiver_2"] + Vector2(0, line_of_scrimmage_offset)
	wide_receiver_3.position = pre_play_positions["wide_receiver_3"] + Vector2(0, line_of_scrimmage_offset)
	wide_receiver_4.position = pre_play_positions["wide_receiver_4"] + Vector2(0, line_of_scrimmage_offset)
	right_offensive_guard.position = pre_play_positions["right_offensive_guard"] + Vector2(0, line_of_scrimmage_offset)
	right_offensive_tackle.position = pre_play_positions["right_offensive_tackle"] + Vector2(0, line_of_scrimmage_offset)
	left_offensive_guard.position = pre_play_positions["left_offensive_guard"] + Vector2(0, line_of_scrimmage_offset)
	left_offensive_tackle.position = pre_play_positions["left_offensive_tackle"] + Vector2(0, line_of_scrimmage_offset)
	center.position = pre_play_positions["center"] + Vector2(0, line_of_scrimmage_offset)
		#Defense
	middle_linebacker.position = pre_play_positions["middle_linebacker"] + Vector2(0, line_of_scrimmage_offset)
	outside_linebacker_1.position = pre_play_positions["outside_linebacker_1"] + Vector2(0, line_of_scrimmage_offset)
	outside_linebacker_2.position = pre_play_positions["outside_linebacker_2"] + Vector2(0, line_of_scrimmage_offset)
	defensive_back_1.position = pre_play_positions["defensive_back_1"] + Vector2(0, line_of_scrimmage_offset)
	defensive_back_2.position = pre_play_positions["defensive_back_2"] + Vector2(0, line_of_scrimmage_offset)
	defensive_back_3.position = pre_play_positions["defensive_back_3"] + Vector2(0, line_of_scrimmage_offset)
	defensive_back_4.position = pre_play_positions["defensive_back_4"] + Vector2(0, line_of_scrimmage_offset)
	right_defensive_end.position = pre_play_positions["right_defensive_end"] + Vector2(0, line_of_scrimmage_offset)
	right_defensive_tackle.position = pre_play_positions["right_defensive_tackle"] + Vector2(0, line_of_scrimmage_offset)
	left_defensive_end.position = pre_play_positions["left_defensive_end"] + Vector2(0, line_of_scrimmage_offset)
	left_defensive_tackle.position = pre_play_positions["left_defensive_tackle"] + Vector2(0, line_of_scrimmage_offset)

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
		if quarterback.has_ball or runningback.has_ball or wide_receiver_1.has_ball or wide_receiver_2.has_ball or wide_receiver_3.has_ball or wide_receiver_4.has_ball:
			# Only update position if the QB or RB has the ball
			#print("Football at yard marker:", area.name)
			#print("Football global position: ", football.global_position.y)
			
			# Update the last recorded position of the football only if QB or RB has the ball
			last_football_position_y = football.global_position.y
	if area.is_in_group("LOS"):
		football.past_los = true
		#print("past the lOS")
	
	if area.is_in_group("defense"):
		if quarterback.has_ball or runningback.has_ball or wide_receiver_1.has_ball or wide_receiver_2.has_ball or wide_receiver_3.has_ball or wide_receiver_4.has_ball:
			#last_football_position_y = football.global_position.y
			tackled = true
		else:
			pass
	if area.is_in_group("OutOfBounds"):
		if quarterback.has_ball or runningback.has_ball or wide_receiver_1.has_ball or wide_receiver_2.has_ball or wide_receiver_3.has_ball or wide_receiver_4.has_ball:
			#last_football_position_y = football.global_position.y
			tackled = true
		else:
			print("football is out of bounds")
			incomplete = true
	
	if area.is_in_group("Touchdown"):
		ball_in_endzone = true

func reset_all_stamina():
	#resets stamina for offensive players
	quarterback.reset_stamina()
	runningback.reset_stamina()
	wide_receiver_1.reset_stamina()
	wide_receiver_2.reset_stamina()
	wide_receiver_3.reset_stamina()
	wide_receiver_4.reset_stamina()


#PlayBook
func pass_play_1() -> void:
	# Bools to tell if run play or pass play
	run_play = false
	pass_play = true
	
	if not wide_receiver_1.has_ball:
		match wr1_state:
			WRState.INITIAL:
				wr1_state = WRState.MOVING_NORTH  # Start moving north
			WRState.MOVING_NORTH:
				if wide_receiver_1.position.y > line_of_scrimmage.y - 25:
					wide_receiver_1.velocity = Vector2(0, -wide_receiver_1.speed)  # Move straight north
				else:
					wr1_state = WRState.MOVING_NORTHWEST  # Change direction to northwest
			WRState.MOVING_NORTHWEST:
				wide_receiver_1.velocity = Vector2(-wide_receiver_1.speed / 2, -wide_receiver_1.speed / 2)  # Move northwest
		
		# Move the wide receiver
		wide_receiver_1.move_and_slide()
	
	if not wide_receiver_2.has_ball:
		match wr2_state:
			WRState.INITIAL:
				wr2_state = WRState.MOVING_NORTH  # Start moving north
			WRState.MOVING_NORTH:
				if wide_receiver_2.position.y > line_of_scrimmage.y - 5:
					wide_receiver_2.velocity = Vector2(0, -wide_receiver_2.speed)  # Move straight north
				else:
					wr2_state = WRState.MOVING_NORTHWEST  # Change direction to northwest
			WRState.MOVING_NORTHWEST:
				wide_receiver_2.velocity = Vector2(wide_receiver_2.speed / 2, -wide_receiver_2.speed / 2)  # Move northwest
		
		# Move the wide receiver
		wide_receiver_2.move_and_slide()
	
	if not wide_receiver_3.has_ball:
		match wr3_state:
			WRState.INITIAL:
				wr3_state = WRState.MOVING_NORTH  # Start moving north
			WRState.MOVING_NORTH:
				if wide_receiver_3.position.y > line_of_scrimmage.y - 55:
					wide_receiver_3.velocity = Vector2(0, -wide_receiver_3.speed)  # Move straight north
				else:
					wr3_state = WRState.MOVING_NORTHWEST  # Change direction to northwest
			WRState.MOVING_NORTHWEST:
				wide_receiver_3.velocity = Vector2(-wide_receiver_3.speed / 2, -wide_receiver_3.speed / 2)  # Move northwest
		
		# Move the wide receiver
		wide_receiver_3.move_and_slide()
	
	if not wide_receiver_4.has_ball:
		match wr4_state:
			WRState.INITIAL:
				wr4_state = WRState.MOVING_NORTH  # Start moving north
			WRState.MOVING_NORTH:
				if wide_receiver_4.position.y > line_of_scrimmage.y - 55:
					wide_receiver_4.velocity = Vector2(0, -wide_receiver_4.speed)  # Move straight north
				else:
					wr4_state = WRState.MOVING_NORTHWEST  # Change direction to northwest
			WRState.MOVING_NORTHWEST:
				wide_receiver_4.velocity = Vector2(wide_receiver_4.speed / 2, -wide_receiver_4.speed / 2)  # Move northwest
		
		# Move the wide receiver
		wide_receiver_4.move_and_slide()
	
	if not runningback.has_ball:
		match rb_state:
			WRState.INITIAL:
				rb_state = WRState.MOVING_NORTHWEST  # Start moving northwest
			WRState.MOVING_NORTHWEST:
				runningback.velocity = Vector2(-runningback.speed, 0)  # Move northwest
		
		# Move the running back
		runningback.move_and_slide()

func pass_play_2() -> void:
	# Bools to tell if run play or pass play
	run_play = false
	pass_play = true
	
	if not wide_receiver_1.has_ball:
		match wr1_state:
			WRState.INITIAL:
				wr1_state = WRState.MOVING_NORTH  # Transition to moving north
			
			WRState.MOVING_NORTH:
				wide_receiver_1.velocity = Vector2(0, -wide_receiver_1.speed)  # Move straight north

		# Move the wide receiver
		wide_receiver_1.move_and_slide()
	
	if not wide_receiver_2.has_ball:
		match wr2_state:
			WRState.INITIAL:
				wr2_state = WRState.MOVING_NORTH  # Transition to moving north
			
			WRState.MOVING_NORTH:
				wide_receiver_2.velocity = Vector2(0, -wide_receiver_2.speed)  # Move straight north

		# Move the wide receiver
		wide_receiver_2.move_and_slide()
		
	if not wide_receiver_3.has_ball:
		match wr3_state:
			WRState.INITIAL:
				wr3_state = WRState.MOVING_NORTH  # Transition to moving north
			
			WRState.MOVING_NORTH:
				wide_receiver_3.velocity = Vector2(0, -wide_receiver_3.speed)  # Move straight north

		# Move the wide receiver
		wide_receiver_3.move_and_slide()
		
	if not wide_receiver_4.has_ball:
		match wr4_state:
			WRState.INITIAL:
				wr4_state = WRState.MOVING_NORTH  # Transition to moving north
			
			WRState.MOVING_NORTH:
				wide_receiver_4.velocity = Vector2(0, -wide_receiver_4.speed)  # Move straight north

		# Move the wide receiver
		wide_receiver_4.move_and_slide()
		
	if not runningback.has_ball:
		match rb_state:
			WRState.INITIAL:
				rb_state = WRState.MOVING_WEST  # Transition to moving west
			
			WRState.MOVING_WEST:
				runningback.velocity = Vector2(-runningback.speed, 0)  # Move West

		# Move the running back
		runningback.move_and_slide()

func pass_play_3() -> void:
	# Bools to tell if run play or pass play
	run_play = false
	pass_play = true
	
	if not wide_receiver_1.has_ball:
		# Check the current state of WR1
		match wr1_state:
			# If the state is NOT_MOVING, switch it to MOVING_NORTH
			WRState.INITIAL:
				wr1_state = WRState.MOVING_NORTH

			# Move straight north until reaching the target position
			WRState.MOVING_NORTH:
				if wide_receiver_1.position.y > line_of_scrimmage.y - 140:
					wide_receiver_1.velocity = Vector2(0, -wide_receiver_1.speed)  # Move straight north
				else:
					# Switch to southwest movement once target is reached
					wr1_state = WRState.MOVING_SOUTHWEST

			# Move southwest after moving north
			WRState.MOVING_SOUTHWEST:
				if wide_receiver_1.position.y < line_of_scrimmage.y - 100:
					wide_receiver_1.velocity = Vector2(-wide_receiver_1.speed / 2, wide_receiver_1.speed / 2)  # Move southwest
				else:
					wr1_state = WRState.NOT_MOVING
			
			WRState.NOT_MOVING:
				wide_receiver_1.velocity = Vector2(0, 0)

		# Move the receiver
		wide_receiver_1.move_and_slide()

	if not wide_receiver_2.has_ball:
		# Check the current state of WR1
		match wr2_state:
			# If the state is NOT_MOVING, switch it to MOVING_NORTH
			WRState.INITIAL:
				wr2_state = WRState.MOVING_NORTH

			# Move straight north until reaching the target position
			WRState.MOVING_NORTH:
				if wide_receiver_2.position.y > line_of_scrimmage.y - 140:
					wide_receiver_2.velocity = Vector2(0, -wide_receiver_2.speed)  # Move straight north
				else:
					# Switch to southwest movement once target is reached
					wr2_state = WRState.MOVING_SOUTHEAST

			# Move southwest after moving north
			WRState.MOVING_SOUTHEAST:
				if wide_receiver_2.position.y < line_of_scrimmage.y - 100:
					wide_receiver_2.velocity = Vector2(wide_receiver_2.speed / 2, wide_receiver_2.speed / 2)  # Move southwest
				else:
					wr2_state = WRState.NOT_MOVING
			
			WRState.NOT_MOVING:
				wide_receiver_2.velocity = Vector2(0, 0)

		# Move the receiver
		wide_receiver_2.move_and_slide()
		
	if not wide_receiver_3.has_ball:
		# Check the current state of WR1
		match wr3_state:
			# If the state is NOT_MOVING, switch it to MOVING_NORTH
			WRState.INITIAL:
				wr3_state = WRState.MOVING_NORTH

			# Move straight north until reaching the target position
			WRState.MOVING_NORTH:
				if wide_receiver_3.position.y > line_of_scrimmage.y - 100:
					wide_receiver_3.velocity = Vector2(0, -wide_receiver_3.speed)  # Move straight north
				else:
					# Switch to southwest movement once target is reached
					wr3_state = WRState.MOVING_SOUTHWEST

			# Move southwest after moving north
			WRState.MOVING_SOUTHWEST:
				if wide_receiver_3.position.y < line_of_scrimmage.y - 80:
					wide_receiver_3.velocity = Vector2(-wide_receiver_3.speed / 2, wide_receiver_3.speed / 2)  # Move southwest
				else:
					wr3_state = WRState.NOT_MOVING
			
			WRState.NOT_MOVING:
				wide_receiver_3.velocity = Vector2(0, 0)

		# Move the receiver
		wide_receiver_3.move_and_slide()
		
	if not wide_receiver_4.has_ball:
		# Check the current state of WR1
		match wr4_state:
			# If the state is NOT_MOVING, switch it to MOVING_NORTH
			WRState.INITIAL:
				wr4_state = WRState.MOVING_NORTH

			# Move straight north until reaching the target position
			WRState.MOVING_NORTH:
				if wide_receiver_4.position.y > line_of_scrimmage.y - 100:
					wide_receiver_4.velocity = Vector2(0, -wide_receiver_4.speed)  # Move straight north
				else:
					# Switch to southwest movement once target is reached
					wr4_state = WRState.MOVING_SOUTHEAST

			# Move southwest after moving north
			WRState.MOVING_SOUTHEAST:
				if wide_receiver_4.position.y < line_of_scrimmage.y - 80:
					wide_receiver_4.velocity = Vector2(wide_receiver_4.speed / 2, wide_receiver_4.speed / 2)  # Move southwest
				else:
					wr4_state = WRState.NOT_MOVING
			
			WRState.NOT_MOVING:
				wide_receiver_4.velocity = Vector2(0, 0)

		# Move the receiver
		wide_receiver_4.move_and_slide()
		
	if not runningback.has_ball:
		match rb_state:
			WRState.INITIAL:
				rb_state = WRState.MOVING_WEST  # Transition to moving west
			
			WRState.MOVING_WEST:
				runningback.velocity = Vector2(-runningback.speed, 0)  # Move West

		# Move the running back
		runningback.move_and_slide()

func run_play_1() -> void:
	
	# Bools to tell if run play or pass play
	run_play = true
	pass_play = false
	
	if quarterback.has_ball:
		football.pitch_football()
	
	if not runningback.has_ball:
		match rb_state:
			WRState.INITIAL:
				rb_state = WRState.MOVING_EAST  # Transition to moving west
			
			WRState.MOVING_EAST:
				runningback.velocity = Vector2(runningback.speed, -10)  # Move West

		# Move the running back 
		runningback.move_and_slide()
	wide_receiver_1.engage()
	wide_receiver_2.engage()
	wide_receiver_3.engage()
	wide_receiver_4.engage()
	quarterback.velocity = Vector2(0, quarterback.speed)
	quarterback.move_and_slide()
