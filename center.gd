extends RigidBody2D

@export var speed = 30  # Speed at which the tackle chases the QB

# Reference to the RDT node
var mlb: Node2D

# Flag to stop pursuing the RDT
var is_blocked = false

var after_block_engage = false

func _ready():
	# Find the RDT node in the scene
	mlb = get_parent().get_node("MiddleLineBacker")

func _physics_process(delta):
	if not mlb:
		return  # No MLB found; do nothing
	
	if not is_blocked:
		pre_engage()
	
	if after_block_engage:
		engage()

# Function to move the Center along line to block the MLB
func pre_engage():
	# Calculate the direction to the MLB
	var direction_to_mlb = (mlb.global_position - global_position).normalized()
	
	# Set the horizontal velocity (x-axis) based on the direction
	linear_velocity.x = direction_to_mlb.x * speed
	
	# Ensure no vertical movement
	linear_velocity.y = 0

# Function to move the Center towards the MLB
func engage():
	# Calculate direction to the QB
	var direction_to_mlb = (mlb.global_position - global_position).normalized()

	# Set the RDT's velocity directly
	linear_velocity = direction_to_mlb * speed
	#print("enagage")

# Function to stop movement (called during a block)
func block():
	# Stop all movement
	linear_velocity = Vector2.ZERO
	is_blocked = true  # Set the flag to indicate the block

# Function to handle detection event when OT enters the area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("LB"):
		#print("DT detected")
		block()  # Stop movement when ROT is detected

# Function to handle detection event when OT exits the area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("LB"):
		#print("DT exited, resuming engage")
		is_blocked = false  # Reset the flag to allow pursuit again
		after_block_engage = true
