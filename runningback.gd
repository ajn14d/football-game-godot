extends CharacterBody2D

@export var speed = 70  # Normal movement speed
@export var sprint_speed = 150  # Sprint speed
@export var max_stamina = 70  # Maximum stamina
@export var stamina_depletion_rate = 40  # Stamina drained per second

@onready var game_scene = get_node("/root/GameScene")

@onready var quarterback = get_node("/root/GameScene/Quarterback")
@onready var wide_receiver_1 = get_node("/root/GameScene/WideReceiver1")
@onready var wide_receiver_2 = get_node("/root/GameScene/WideReceiver2")
@onready var wide_receiver_3 = get_node("/root/GameScene/WideReceiver3")
@onready var wide_receiver_4 = get_node("/root/GameScene/WideReceiver4")

var has_ball = false

var current_stamina = max_stamina  # Current stamina

func _process(delta):
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
		var current_speed = sprint_speed if is_sprinting else speed  # Corrected ternary operator

		# Deplete stamina when sprinting
		if is_sprinting:
			current_stamina -= stamina_depletion_rate * delta
			if current_stamina < 0:
				current_stamina = 0  # Prevent stamina from going below zero
		
		# Set velocity and move
		velocity = input_vector * current_speed
		move_and_slide()

		# Debug stamina (optional)
		#print("Stamina:", current_stamina)

# Reset stamina for a new play
func reset_stamina():
	current_stamina = max_stamina


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("football") and not quarterback.has_ball and not wide_receiver_1.has_ball  and not wide_receiver_2.has_ball and not wide_receiver_3.has_ball and not wide_receiver_4.has_ball:
		has_ball = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("football"):
		has_ball = false
