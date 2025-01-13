extends RigidBody2D

@export var speed: float = 200  # Speed at which the football moves downward
@export var throw_force: float = 500  # Force applied when the football is thrown
var is_attached: bool = false  # Indicates if the football is attached to the QB
@onready var quarterback = get_node("/root/GameScene/Players/Quarterback")
@export var offset: Vector2 = Vector2(7, 0)  # Offset for the football (to the right of the QB)

func _ready() -> void:
	# Set the initial velocity to move straight down
	linear_velocity = Vector2(0, speed)

func _input(event) -> void:
	# Listen for the throw action
	if is_attached and event.is_action_pressed("throw_ball"):
		throw_football()

func _process(delta: float) -> void:
	# If attached to the QB, update the position of the football to match the QB with the offset
	if is_attached and quarterback:
		# Set the football's position relative to the QB's global position
		# Apply QB's rotation to the offset
		var rotated_offset = offset.rotated(quarterback.rotation)
		
		# Set the football's position based on QB's position and the rotated offset
		position = quarterback.global_position + rotated_offset

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("QB"):
		print("Football attached to QB")
		is_attached = true  # Set the attachment flag
		quarterback = body  # Reference the QB node
		linear_velocity = Vector2.ZERO  # Stop the ball's movement

# This function handles the throwing action
func throw_football():
	# Ensure quarterback is not null before accessing its position
	if quarterback != null:
		# Get the mouse position in global coordinates
		var mouse_position = get_global_mouse_position()

		# Calculate the direction from the QB to the mouse position
		var direction = (mouse_position - quarterback.global_position).normalized()

		# Detach the football from the QB
		is_attached = false
		quarterback = null  # Unset QB reference

		# Apply an initial velocity in the direction of the mouse position
		linear_velocity = direction * throw_force  # Apply the throw force

		# Rotate the football to face the direction of travel with a 90-degree offset
		rotation = linear_velocity.angle() + PI / 2  # Apply a 90-degree rotation

		# Print the resulting velocity for debugging
		print("Throw direction:", direction)
		print("Linear velocity:", linear_velocity)

		print("Football thrown!")
	else:
		print("Quarterback not found!")
