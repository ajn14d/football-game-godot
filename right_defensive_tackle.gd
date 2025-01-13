extends RigidBody2D

@export var speed = 40  # Speed at which the tackle chases the QB

# Reference to the Football node
var football: Node2D

# Flag to stop pursuing the QB
var is_blocked = false

# Timer node to handle the break block attempts
var block_timer: Timer

func _ready():
	# Find the football node in the scene
	football = get_node("/root/GameScene/Football")
	
	# Create and configure the Timer node
	block_timer = Timer.new()
	block_timer.wait_time = 2.0  # 1 second interval
	block_timer.one_shot = false  # Keep repeating until manually stopped
	add_child(block_timer)
	block_timer.connect("timeout", Callable(self, "_on_try_break_block"))

func _physics_process(delta):
	if not football:
		return  # No football found; do nothing

	# Only call pursue if RDT is not blocked
	if not is_blocked:
		pursue()

# Function to move the RDT towards the QB
func pursue():
	# Calculate direction to the QB
	var direction_to_football = (football.global_position - global_position).normalized()

	# Set the RDT's velocity directly
	linear_velocity = direction_to_football * speed

# Function to stop movement (called during a block)
func blocked():
	# Stop all movement
	linear_velocity = Vector2.ZERO
	is_blocked = true  # Set the flag to indicate the block
	block_timer.start()  # Start the timer to attempt breaking the block

# Function to handle detection event when OG enters the area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("OG"):
		#print("OG detected")
		blocked()  # Stop movement when OG is detected

# Function to handle detection event when OG exits the area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("OG"):
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
