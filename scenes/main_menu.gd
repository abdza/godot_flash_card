# main_menu.gd
extends Control

@onready var start_button = $MenuContainer/StartButton
@onready var high_scores_button = $MenuContainer/HighScoresButton
@onready var quit_button = $MenuContainer/QuitButton
@onready var title_label = $TitleContainer/TitleLabel
@onready var version_label = $VersionLabel

func _ready():
	setup_button_styles()
	
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	high_scores_button.pressed.connect(_on_high_scores_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Add simple animation to title
	var tween = create_tween().set_loops()
	tween.tween_property(title_label, "theme_override_colors/font_color", 
		Color(1, 0.85, 0, 1), 1.0).from(Color(1, 1, 1, 1))
	tween.tween_property(title_label, "theme_override_colors/font_color", 
		Color(1, 1, 1, 1), 1.0)

func setup_button_styles():
	for button in [start_button, high_scores_button, quit_button]:
		var normal_style = StyleBoxFlat.new()
		var hover_style = StyleBoxFlat.new()
		
		# Base style properties
		for style in [normal_style, hover_style]:
			style.corner_radius_top_left = 10
			style.corner_radius_top_right = 10
			style.corner_radius_bottom_right = 10
			style.corner_radius_bottom_left = 10
			style.content_margin_left = 15
			style.content_margin_right = 15
			style.content_margin_top = 10
			style.content_margin_bottom = 10
		
		# Normal style
		normal_style.bg_color = Color(0.2, 0.4, 0.8, 1)  # Blue
		
		# Hover style
		hover_style.bg_color = Color(0.3, 0.5, 0.9, 1)  # Lighter blue
		
		# Apply styles
		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		
		# Add hover sound
		button.mouse_entered.connect(_on_button_hover.bind(button))

func _on_button_hover(button: Button) -> void:
	# You can add a hover sound effect here
	pass

func _on_start_pressed() -> void:
	# Change to category selection scene
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_high_scores_pressed() -> void:
	# Change to high scores scene
	var high_scores_scene = load("res://scenes/game_over_scene.tscn").instantiate()
	high_scores_scene.initialize(0, true)  # Pass 0 to just show scores without adding new one
	get_tree().root.add_child(high_scores_scene)
	queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()
