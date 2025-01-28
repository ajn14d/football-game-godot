extends RigidBody2D

@onready var game_scene = get_node("/root/GameScene")

@export var speed = 120  # Speed at which the tackle chases the QB
var blocked_speed = 3

var random_duration = 0.0

# Reference to the Football node
var wr1: Node2D
var wr2: Node2D
var wr3: Node2D
var wr4: Node2D
var rb = Node2D
var qb = Node2D
var football = Node2D

# Flag to stop pursuing the QB
var is_blocked = false

var pre_cover_ = true

# Timer node to handle the break block attempts
var block_timer: Timer

func _ready():
	#print(game_scene.pass_play)
	# Find the football node in the scene
	wr1 = get_node("/root/GameScene/WideReceiver1")
	wr2 = get_node("/root/GameScene/WideReceiver2")
	wr3 = get_node("/root/GameScene/WideReceiver3")
	wr4 = get_node("/root/GameScene/WideReceiver4")
	rb = get_node("/root/GameScene/Runningback")
	qb = get_node("/root/GameScene/Quarterback")
	football = get_node("/root/GameScene/Football")
	
	
	# Create and configure the Timer node
	block_timer = Timer.new()
	block_timer.wait_time = 2.0  # 1 second interval
	block_timer.one_shot = false  # Keep repeating until manually stopped
	add_child(block_timer)
	block_timer.connect("timeout", Callable(self, "_on_try_break_block"))

func _physics_process(delta):
	if not wr3:
		return  # No football found; do nothing
	# Only call pursue if RDT is not blocked
	if not is_blocked and not wr3.has_ball and pre_cover_:
		pre_cover()
	elif not is_blocked and not wr3.has_ball and not rb.has_ball and not pre_cover_ and not game_scene.run_play and not football.past_los:
		cover()
	elif football.football_thrown and wr3.has_ball:
		pursue_wr()
	elif game_scene.run_play:
		pursue_rb()
	elif rb.has_ball:
		pursue_rb()
	elif qb.has_ball and football.past_los:
		pursue_qb()
	elif wr1.has_ball or wr2.has_ball or wr3.has_ball or wr4.has_ball:
		pursue()

# Function to for the RDT to cover the WR
func cover():
	# Desired distance to maintain from the WR
	var desired_distance = game_scene.db_3_cover_distance  # Adjust this value as needed
	
	# Calculate direction to the WR
	var direction_to_wr3 = (wr3.global_position - global_position).normalized()
	
	# Calculate the current distance to the WR
	var distance_to_wr3 = global_position.distance_to(wr3.global_position)
	
	# Move only if the current distance is greater than the desired distance
	if distance_to_wr3 > desired_distance:
		linear_velocity = direction_to_wr3 * speed
	else:
		# Stop moving if within the desired distance
		linear_velocity = Vector2.ZERO

func pre_cover() -> void:
	
	# Drop back into pre coverage
	linear_velocity = Vector2(wr3.position.x - position.x, -speed)
	
	# Wait for timer
	await get_tree().create_timer(game_scene.db_3_pre_cover_duration).timeout
	
	pre_cover_ = false
	
	# Stop movement and call the next function
	linear_velocity = Vector2.ZERO

func pursue():
	# Desired distance to maintain from the WR
	var desired_distance = 0  # Adjust this value as needed
	
	# Calculate direction to the WR
	var direction_to_football = (football.global_position - global_position).normalized()
	
	# Calculate the current distance to the WR
	var distance_to_football = global_position.distance_to(football.global_position)
	
	# Move only if the current distance is greater than the desired distance
	if distance_to_football > desired_distance:
		linear_velocity = direction_to_football * speed
	else:
		# Stop moving if within the desired distance
		linear_velocity = Vector2.ZERO

# Function to move the RDT towards the WR
func pursue_wr():
	# Desired distance to maintain from the WR
	var desired_distance = 15  # Adjust this value as needed
	
	# Calculate direction to the WR
	var direction_to_wr3 = (wr3.global_position - global_position).normalized()
	
	# Calculate the current distance to the WR
	var distance_to_wr3 = global_position.distance_to(wr3.global_position)
	
	# Move only if the current distance is greater than the desired distance
	if distance_to_wr3 > desired_distance:
		linear_velocity = direction_to_wr3 * speed
	else:
		# Stop moving if within the desired distance
		linear_velocity = Vector2.ZERO

func tackle_wr():
	# Desired distance to maintain from the WR
	var desired_distance = 0  # Adjust this value as needed
	
	# Calculate direction to the WR
	var direction_to_wr3 = (wr3.global_position - global_position).normalized()
	
	# Calculate the current distance to the WR
	var distance_to_wr3 = global_position.distance_to(wr3.global_position)
	
	# Move only if the current distance is greater than the desired distance
	if distance_to_wr3 > desired_distance:
		linear_velocity = direction_to_wr3 * speed
	else:
		# Stop moving if within the desired distance
		linear_velocity = Vector2.ZERO

func pursue_rb():
	# Desired distance to maintain from the WR
	var desired_distance = 15  # Adjust this value as needed
	
	# Calculate direction to the WR
	var direction_to_rb = (rb.global_position - global_position).normalized()
	
	# Calculate the current distance to the WR
	var distance_to_rb = global_position.distance_to(rb.global_position)
	
	# Move only if the current distance is greater than the desired distance
	if distance_to_rb > desired_distance:
		linear_velocity = direction_to_rb * speed
	else:
		# Stop moving if within the desired distance
		linear_velocity = Vector2.ZERO

# Function to move the RDT towards the WR
func pursue_qb():
	# Desired distance to maintain from the WR
	var desired_distance = 15  # Adjust this value as needed
	
	# Calculate direction to the WR
	var direction_to_qb = (qb.global_position - global_position).normalized()
	
	# Calculate the current distance to the WR
	var distance_to_qb = global_position.distance_to(rb.global_position)
	
	# Move only if the current distance is greater than the desired distance
	if distance_to_qb > desired_distance:
		linear_velocity = direction_to_qb * speed
	else:
		# Stop moving if within the desired distance
		linear_velocity = Vector2.ZERO

# Function to reduce movement (called during a block)
func blocked():
	# Calculate direction to the QB
	var direction_to_wr3 = (wr3.global_position - global_position).normalized()
	
	# reduce movement
	linear_velocity = direction_to_wr3 * blocked_speed
	is_blocked = true  # Set the flag to indicate the block
	block_timer.start()  # Start the timer to attempt breaking the block

# Function to handle detection event when C enters the area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("C"):
		#print("OG detected")
		blocked()  # Stop movement when OG is detected

# Function to handle detection event when C exits the area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("C"):
		#print("OG exited, resuming pursuit")
		is_blocked = false  # Reset the flag to allow pursuit again
		block_timer.stop()  # Stop the timer when no longer blocked

# Function to attempt breaking the block
func _on_try_break_block():
	var chance = randi() % 100  # Random number between 0 and 99
	if chance < 50:  # 50% chance to break the block
		#print("Block broken!")
		is_blocked = false  # Allow movement again
		block_timer.stop()  # Stop the timer
	else:
		pass
		#print("Block held, retrying...")
