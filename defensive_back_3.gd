extends RigidBody2D

@export var speed = 90  # Speed at which the tackle chases the QB
var blocked_speed = 3

# Reference to the Football node
var wr3: Node2D

# Flag to stop pursuing the QB
var is_blocked = false

# Timer node to handle the break block attempts
var block_timer: Timer

func _ready():
	# Find the football node in the scene
	wr3 = get_node("/root/GameScene/WideReceiver3")
	
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
	if not is_blocked:
		pursue()

# Function to move the RDT towards the WR
func pursue():
	# Desired distance to maintain from the WR
	var desired_distance = 25  # Adjust this value as needed
	
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
		print("Block broken!")
		is_blocked = false  # Allow movement again
		block_timer.stop()  # Stop the timer
	else:
		print("Block held, retrying...")
