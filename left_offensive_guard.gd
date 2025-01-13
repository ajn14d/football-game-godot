extends RigidBody2D

@export var speed = 30  # Speed at which the tackle chases the QB

# Reference to the RDT node
var rdt: Node2D

# Flag to stop pursuing the RDT
var is_blocked = false

func _ready():
	# Find the RDT node in the scene
	rdt = get_parent().get_node("LeftDefensiveTackle")

func _physics_process(delta):
	if not rdt:
		return  # No QB found; do nothing

	# Only call pursue if RDT is not blocked
	if not is_blocked:
		engage()

# Function to move the RDT towards the QB
func engage():
	# Calculate direction to the QB
	var direction_to_rdt = (rdt.global_position - global_position).normalized()

	# Set the RDT's velocity directly
	linear_velocity = direction_to_rdt * speed
	#print("enagage")

# Function to stop movement (called during a block)
func block():
	# Stop all movement
	linear_velocity = Vector2.ZERO
	is_blocked = true  # Set the flag to indicate the block

# Function to handle detection event when OT enters the area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("DT"):
		#print("DT detected")
		block()  # Stop movement when ROT is detected

# Function to handle detection event when OT exits the area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("DT"):
		#print("DT exited, resuming engage")
		is_blocked = false  # Reset the flag to allow pursuit again
