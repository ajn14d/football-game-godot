extends RigidBody2D

var has_ball = false
var past_los = false
var football_thrown = false
@export var throw_force: float = 500  # Force applied when the football is thrown
@onready var quarterback = get_node("/root/GameScene/Quarterback")
@onready var running_back = get_node("/root/GameScene/Runningback")  # Reference to the RB node
@onready var wide_receiver_1 = get_node("/root/GameScene/WideReceiver1")
@onready var wide_receiver_2 = get_node("/root/GameScene/WideReceiver2")
@onready var wide_receiver_3 = get_node("/root/GameScene/WideReceiver3")
@onready var wide_receiver_4 = get_node("/root/GameScene/WideReceiver4")
@export var offset: Vector2 = Vector2(0, 0)  # Offset for the football (to the right of the QB or RB)

func _ready() -> void:
	pass

func _input(event) -> void:
	# Listen for the throw action
	if quarterback != null and quarterback.has_ball and event.is_action_pressed("throw_ball"):
		# Only allow throwing if the football is attached to the QB
		if quarterback.has_ball:
			throw_football()

func _process(delta: float) -> void:
	# If attached to the QB or RB, update the position of the football to match with the offset
	if quarterback != null and quarterback.has_ball:
		var player = quarterback if quarterback.has_ball else running_back  # Determine if the football is with the QB or RB
		if player:
			# Set the football's position relative to the QB's or RB's global position
			# Apply player's rotation to the offset
			var rotated_offset = offset.rotated(player.rotation)
			
			# Set the football's position based on player's position and the rotated offset
			position = player.global_position + rotated_offset
			
	elif running_back != null and running_back.has_ball:
		# If the RB has the ball, update the football's position to be with the RB
		var rotated_offset = offset.rotated(running_back.rotation)
		position = running_back.global_position + rotated_offset
	
	elif wide_receiver_1 != null and wide_receiver_1.has_ball:
		# If the RB has the ball, update the football's position to be with the RB
		var rotated_offset = offset.rotated(wide_receiver_1.rotation)
		position = wide_receiver_1.global_position + rotated_offset
	
	elif wide_receiver_2 != null and wide_receiver_2.has_ball:
		# If the RB has the ball, update the football's position to be with the RB
		var rotated_offset = offset.rotated(wide_receiver_2.rotation)
		position = wide_receiver_2.global_position + rotated_offset
		
	elif wide_receiver_3 != null and wide_receiver_3.has_ball:
		# If the RB has the ball, update the football's position to be with the RB
		var rotated_offset = offset.rotated(wide_receiver_3.rotation)
		position = wide_receiver_3.global_position + rotated_offset
	
	elif wide_receiver_4 != null and wide_receiver_4.has_ball:
		# If the RB has the ball, update the football's position to be with the RB
		var rotated_offset = offset.rotated(wide_receiver_4.rotation)
		position = wide_receiver_4.global_position + rotated_offset

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("QB"):
		has_ball = true  # Set the attachment flag for QB
		quarterback = body  # Reference the QB node
		linear_velocity = Vector2.ZERO  # Stop the ball's movement
	elif body.is_in_group("RB"):
		has_ball = true  # Set the attachment flag for RB
		running_back = body  # Reference the RB node
		running_back.has_ball = true  # Mark the RB as having the ball
		linear_velocity = Vector2.ZERO  # Stop the ball's movement
	elif body.is_in_group("WR"):
		has_ball = true  # Set the attachment flag for RB
		wide_receiver_1 = body  # Reference the RB node
		wide_receiver_1.has_ball = true  # Mark the RB as having the ball
		linear_velocity = Vector2.ZERO  # Stop the ball's movement

# This function handles the throwing action
func throw_football():
	# Ensure quarterback is not null before accessing its position
	if quarterback != null and not past_los:
		# Get the mouse position in global coordinates
		var mouse_position = get_global_mouse_position()

		# Calculate the direction from the quarterback to the mouse position
		var direction = (mouse_position - quarterback.global_position).normalized()

		# Detach the football from the quarterback, but first, get the QB's rotation
		var qb_rotation = quarterback.rotation  # Capture QB's rotation before unsetting it
		has_ball = false
		quarterback = null  # Unset QB reference
		running_back = null  # Unset RB reference
		wide_receiver_1 = null # Unset WR reference
		wide_receiver_2 = null # Unset WR reference
		wide_receiver_3 = null # Unset WR reference
		wide_receiver_4 = null # Unset WR reference

		# Apply an initial velocity in the direction of the mouse position
		linear_velocity = direction * throw_force  # Apply the throw force

		# Rotate the football to face the direction of travel with a 90-degree offset
		rotation = linear_velocity.angle()

		# Now add the QB's rotation to the throw's rotation
		rotation += qb_rotation  # Adjust the rotation based on QB's current rotation
		
		football_thrown = true

		# Print the resulting velocity for debugging
		#print("Throw direction:", direction)
		#print("Linear velocity:", linear_velocity)

		#print("Football thrown!")
	else:
		print("Quarterback not found!")
