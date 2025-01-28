extends RigidBody2D

@onready var game_scene = get_node("/root/GameScene")
@onready var rb = get_node("/root/GameScene/Runningback")
@onready var qb = get_node("/root/GameScene/Quarterback")
@onready var wr1 = get_node("/root/GameScene/WideReceiver1")
@onready var wr2 = get_node("/root/GameScene/WideReceiver2")
@onready var wr3 = get_node("/root/GameScene/WideReceiver3")
@onready var wr4 = get_node("/root/GameScene/WideReceiver4")

@export var speed = 85  # Speed at which the tackle chases the QB
var blocked_speed = 3

# Reference to the Football node
var football: Node2D

# Flag to stop pursuing the QB
var is_blocked = false

var blitz_bool = false
var drop_coverage_bool = false

var in_coverage_bool = false

var drop_coverage_timer = null

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
	if not is_blocked and game_scene.middle_linebacker_play == 0:
		blitz()

	if not is_blocked and drop_coverage_bool and not in_coverage_bool and not football.football_thrown and not football.past_los and game_scene.middle_linebacker_play == 1:
		drop_coverage()
	
	elif in_coverage_bool and not football.football_thrown and not football.past_los:
		in_coverage()
	
	elif not is_blocked:
		pursue()

func blitz():
		
	# Calculate direction to the football
	var direction_to_football = (football.global_position - global_position).normalized()

	# Set the RDT's velocity directly
	linear_velocity = direction_to_football * speed

func drop_coverage() -> void:
	
	# Drop back into pre coverage
	linear_velocity = Vector2(game_scene.middle_linebacker_coverage_angle, -speed)
	
	if position.y + 200 < game_scene.line_of_scrimmage.y:
	
		if football.football_thrown:
			drop_coverage_bool = false
		
		in_coverage()
	
func in_coverage() -> void:
	
	in_coverage_bool = true
	
	# Drop back into pre coverage
	linear_velocity = Vector2(0, 0)
	
# Function to move the LB towards the football
func pursue():
	# Calculate direction to the QB
	var direction_to_football = (football.global_position - global_position).normalized()

	# Set the RDT's velocity directly
	linear_velocity = direction_to_football * speed

# Function to reduce movement (called during a block)
func blocked():
	# Calculate direction to the QB
	var direction_to_football = (football.global_position - global_position).normalized()
	
	# reduce movement
	linear_velocity = direction_to_football * blocked_speed
	is_blocked = true  # Set the flag to indicate the block
	block_timer.start()  # Start the timer to attempt breaking the block

# Function to handle detection event when C enters the area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("C"):
		#print("C detected")
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
