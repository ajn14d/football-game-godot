extends CharacterBody2D

@export var speed = 120  # Normal movement speed
@export var sprint_speed = 150  # Sprint speed
@export var max_stamina = 0  # Maximum stamina
@export var stamina_depletion_rate = 40  # Stamina drained per second
@export var ball_speed_min = 40  # Minimum speed when holding the ball
@export var speed_reduction_rate = 10  # Speed reduction per second

@onready var game_scene = get_node("/root/GameScene")

@onready var quarterback = get_node("/root/GameScene/Quarterback")
@onready var runningback = get_node("/root/GameScene/Runningback")
@onready var wide_receiver_2 = get_node("/root/GameScene/WideReceiver2")
@onready var wide_receiver_3 = get_node("/root/GameScene/WideReceiver3")
@onready var wide_receiver_4 = get_node("/root/GameScene/WideReceiver4")

var has_ball = false
var current_stamina = max_stamina  # Current stamina
var current_speed = speed  # Current speed, adjusted dynamically

func _process(delta):
	# Gradually reduce speed if the player has the ball
	if has_ball and current_speed > ball_speed_min:
		current_speed -= speed_reduction_rate * delta
		if current_speed < ball_speed_min:
			current_speed = ball_speed_min  # Clamp to minimum speed
	elif not has_ball and current_speed < speed:
		current_speed += speed_reduction_rate * delta  # Gradually restore speed
		if current_speed > speed:
			current_speed = speed  # Clamp to normal speed

	# Only allow control if the RB has the ball
	if has_ball:
		# Handle movement input
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)

		# Normalize input vector for consistent speed in diagonal movement
		if input_vector != Vector2.ZERO:
			input_vector = input_vector.normalized()
		
		# Determine if sprinting is allowed based on stamina
		var is_sprinting = Input.is_action_pressed("sprint") and current_stamina > 0
		var final_speed = sprint_speed if is_sprinting else current_speed  # Use adjusted current speed

		# Deplete stamina when sprinting
		if is_sprinting:
			current_stamina -= stamina_depletion_rate * delta
			if current_stamina < 0:
				current_stamina = 0  # Prevent stamina from going below zero
		
		# Set velocity and move
		velocity = input_vector * final_speed
		move_and_slide()

	# Debug stamina and speed (optional)
	# print("Stamina:", current_stamina, "Speed:", current_speed)

# Reset stamina and speed for a new play
func reset_stamina():
	current_stamina = max_stamina
	current_speed = speed

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("football") and not quarterback.has_ball and not runningback.has_ball and not wide_receiver_2.has_ball and not wide_receiver_3.has_ball and not wide_receiver_4.has_ball:
		has_ball = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("football"):
		has_ball = false
