extends RigidBody2D

@export var speed: float = 400  # Speed at which the football moves downward
var is_attached: bool = false  # Indicates if the football is attached to the QB
@onready var quarterback = get_node("/root/GameScene/Players/Quarterback")
@export var offset: Vector2 = Vector2(7, 0)  # Offset for the football (to the right of the QB)

func _ready() -> void:
	# Set the initial velocity to move straight down
	linear_velocity = Vector2(0, speed)

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
