# game_scene.gd
extends Node2D

# Constants
const POINTS_PER_CORRECT = 10
const ROUNDS_PER_GAME = 10

# Variables for game state
var current_score: int = 0
var current_round: int = 0
var current_word: String = ""
var correct_option: int = 0

# Sample data structure (replace this with your actual categories and words)
var word_data = {
	"farm animals": {
		"chicken": "res://assets/images/farm_animals/chicken.webp",
		"cow": "res://assets/images/farm_animals/cow.webp",
		"donkey": "res://assets/images/farm_animals/donkey.webp",
		"duck": "res://assets/images/farm_animals/duck.webp",
		"goat": "res://assets/images/farm_animals/goat.webp",
		"goose": "res://assets/images/farm_animals/goose.webp",
		"horse": "res://assets/images/farm_animals/horse.webp",
		"llama": "res://assets/images/farm_animals/llama.webp",
		"pig": "res://assets/images/farm_animals/pig.webp",
		"rabbit": "res://assets/images/farm_animals/rabbit.webp",
		"rooster": "res://assets/images/farm_animals/rooster.webp",
		"sheep": "res://assets/images/farm_animals/sheep.webp",
		"turkey": "res://assets/images/farm_animals/turkey.webp",
	}
}

# UI Elements (assign these in the editor)
@onready var word_label = $WordLabel
@onready var image_buttons = [
	$OptionContainer/Option1,
	$OptionContainer/Option2,
	$OptionContainer/Option3,
	$OptionContainer/Option4
]
@onready var score_label = $ScoreLabel
@onready var round_label = $RoundLabel
@onready var feedback_label = $FeedbackLabel
@onready var feedback_timer = $FeedbackTimer

func _ready():
	setup_game()

func setup_game():
	current_score = 0
	current_round = 0
	update_score_display()
	setup_next_round()

func setup_next_round():
	if current_round >= ROUNDS_PER_GAME:
		game_over()
		return
		
	current_round += 1
	update_round_display()
	
	# Get random word and images
	var category = "farm animals"  # This will be passed from category selection later
	var words = word_data[category].keys()
	words.shuffle()
	
	# Select the correct word
	current_word = words[0]
	
	# Setup the images (1 correct, 3 wrong)
	var available_words = words.slice(1, words.size())
	available_words.shuffle()
	
	# Randomly place correct answer
	correct_option = randi() % 4
	
	# Assign images to buttons
	for i in range(4):
		var button = image_buttons[i]
		if i == correct_option:
			set_button_image(button, word_data[category][current_word])
		else:
			set_button_image(button, word_data[category][available_words[i]])
	
	# Update word display
	word_label.text = current_word.capitalize()
	feedback_label.hide()

func set_button_image(button: TextureButton, image_path: String):
	var texture = load(image_path)
	button.texture_normal = texture

func _on_option_pressed(option_index: int):
	if option_index == correct_option:
		current_score += POINTS_PER_CORRECT
		show_feedback("Correct!", Color.GREEN)
	else:
		show_feedback("Wrong! Try again!", Color.RED)
	
	update_score_display()
	
	# Wait a moment before next round
	await get_tree().create_timer(1.0).timeout
	setup_next_round()

func show_feedback(text: String, color: Color):
	feedback_label.text = text
	feedback_label.modulate = color
	feedback_label.show()
	feedback_timer.start()

func _on_feedback_timer_timeout():
	feedback_label.hide()

func update_score_display():
	score_label.text = "Score: %d" % current_score

func update_round_display():
	round_label.text = "Round: %d/%d" % [current_round, ROUNDS_PER_GAME]

func game_over():
	# Get the game over scene
	var game_over_scene = load("res://scenes/game_over_scene.tscn").instantiate()
	
	# Initialize it with the final score
	game_over_scene.final_score = current_score
	
	# Switch to the game over scene
	get_tree().root.add_child(game_over_scene)
	queue_free()
