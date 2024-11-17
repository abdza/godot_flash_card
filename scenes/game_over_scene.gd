# game_over_scene.gd
extends Control

@onready var game_over_container = $GameOverContainer
@onready var score_label = $GameOverContainer/FinalScoreLabel
@onready var game_over_label = $GameOverContainer/GameOverLabel
@onready var score_list = $HighScoresContainer/ScoresList
@onready var high_score_container = $HighScoreContainer
@onready var name_input_container = $NameInputContainer
@onready var name_input = $NameInputContainer/NameInput
@onready var submit_button = $NameInputContainer/SubmitButton
@onready var message_label = $MessageLabel
@onready var play_again_button = $ButtonsContainer/PlayAgainButton
@onready var main_menu_button = $ButtonsContainer/MainMenuButton

var final_score: int = 0
var high_scores: HighScores
var is_high_score_only: bool = false

func _ready():
	high_scores = HighScores.new()
	high_scores.load_scores()
	
	# Hide name input by default
	name_input_container.hide()
	
	# Setup button styles
	setup_button_styles()
	
	# Connect button signals
	submit_button.pressed.connect(_on_submit_button_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	if is_high_score_only:
		# If we're just showing high scores
		game_over_container.hide()
		message_label.hide()
		play_again_button.text = "Play Game"
		name_input_container.hide()
		update_high_scores_display()
	else:
		# If we're showing game over screen
		game_over_container.show()
		score_label.text = "Final Score: %d" % final_score
		game_over_label.text = "Game Over!"
		message_label.show()
		
		# Check if it's a high score
		if high_scores.is_high_score(final_score):
			message_label.text = "Congratulations! You got a high score!"
			name_input_container.show()
		else:
			message_label.text = "Game Over! Try again to get a high score!"
			name_input_container.hide()

func setup_button_styles():
	# Create StyleBoxFlat for submit button
	var submit_style = StyleBoxFlat.new()
	submit_style.bg_color = Color(0.2, 0.4, 0.8, 1)  # Blue
	submit_style.corner_radius_top_left = 5
	submit_style.corner_radius_top_right = 5
	submit_style.corner_radius_bottom_right = 5
	submit_style.corner_radius_bottom_left = 5
	submit_button.add_theme_stylebox_override("normal", submit_style)
	
	# Create StyleBoxFlat for play again button
	var play_again_style = StyleBoxFlat.new()
	play_again_style.bg_color = Color(0.2, 0.6, 0.3, 1)  # Green
	play_again_style.corner_radius_top_left = 5
	play_again_style.corner_radius_top_right = 5
	play_again_style.corner_radius_bottom_right = 5
	play_again_style.corner_radius_bottom_left = 5
	play_again_button.add_theme_stylebox_override("normal", play_again_style)
	
	# Create StyleBoxFlat for main menu button
	var main_menu_style = StyleBoxFlat.new()
	main_menu_style.bg_color = Color(0.6, 0.3, 0.2, 1)  # Red-brown
	main_menu_style.corner_radius_top_left = 5
	main_menu_style.corner_radius_top_right = 5
	main_menu_style.corner_radius_bottom_right = 5
	main_menu_style.corner_radius_bottom_left = 5
	main_menu_button.add_theme_stylebox_override("normal", main_menu_style)

func initialize(score: int, high_score_only: bool = false) -> void:
	is_high_score_only = high_score_only
	final_score = score

func update_high_scores_display() -> void:
	$HighScoresContainer.visible = true
	$MessageLabel.visible = false
	$GameOverContainer/FinalScoreLabel.visible = false
	
	# Clear existing items
	for child in score_list.get_children():
		child.queue_free()
	
	# Add header
	var header = create_score_label("Rank", "Player", "Score", true)
	score_list.add_child(header)
	
	# Add scores
	var scores = high_scores.get_scores()
	for i in range(scores.size()):
		var score = scores[i]
		var score_label = create_score_label(
			str(i + 1),
			score["name"],
			str(score["score"])
		)
		score_list.add_child(score_label)

func create_score_label(rank: String, name: String, score: String, is_header: bool = false) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.custom_minimum_size.x = 400
	
	var rank_label = Label.new()
	var name_label = Label.new()
	var score_label = Label.new()
	
	rank_label.custom_minimum_size.x = 50
	name_label.custom_minimum_size.x = 250
	score_label.custom_minimum_size.x = 100
	
	rank_label.text = rank
	name_label.text = name
	score_label.text = score
	
	if is_header:
		rank_label.add_theme_color_override("font_color", Color(1, 0.85, 0, 1))
		name_label.add_theme_color_override("font_color", Color(1, 0.85, 0, 1))
		score_label.add_theme_color_override("font_color", Color(1, 0.85, 0, 1))
	else:
		rank_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		score_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	container.add_child(rank_label)
	container.add_child(name_label)
	container.add_child(score_label)
	
	return container

func _on_submit_button_pressed() -> void:
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		message_label.text = "Please enter your name!"
		return
	
	if high_scores.add_score(player_name, final_score):
		message_label.text = "Score saved successfully!"
		name_input_container.hide()
		update_high_scores_display()
	else:
		message_label.text = "Error saving score. Please try again."

func _on_play_again_pressed() -> void:
	# If we're in high score view, go to category selection
	if is_high_score_only:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
	else:
		# Otherwise, restart the game
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
