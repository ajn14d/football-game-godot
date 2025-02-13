extends Node2D

@onready var away_has_ball_label = $AwayHasBall
@onready var touchdown_label = $Touchdown
@onready var stop_label = $Stop

func _ready() -> void:
	# Initialize visibility
	away_has_ball_label.visible = true
	touchdown_label.visible = false
	stop_label.visible = false
	
	# Wait for 2 seconds, then handle the away team's possession
	await get_tree().create_timer(2.0).timeout
	handle_away_team_possession()

func handle_away_team_possession():
	randomize()
	var random_chance = randf()

	# 40% chance to score a touchdown
	if random_chance <= 0.40:
		away_team_scores()
	else:
		away_team_stopped()

func away_team_scores():
	away_has_ball_label.visible = false
	touchdown_label.visible = true
	stop_label.visible = false
	print("Away team scores a touchdown!")
	GameStats.away_score += 7
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://game_scene.tscn")

func away_team_stopped():
	away_has_ball_label.visible = false
	touchdown_label.visible = false
	stop_label.visible = true
	print("Away team stopped!")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://game_scene.tscn")
	
