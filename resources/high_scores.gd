# high_scores.gd
extends Resource
class_name HighScores

const SAVE_PATH = "user://high_scores.json"
const MAX_SCORES = 10

var scores: Array = []

func load_scores() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.parse_string(json_string)
		if json:
			scores = json
	else:
		# Initialize with empty scores if file doesn't exist
		scores = []
		save_scores()

func save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(scores)
	file.store_string(json_string)

func add_score(player_name: String, score: int) -> bool:
	var new_entry = {
		"name": player_name,
		"score": score,
		"date": Time.get_datetime_string_from_system()
	}
	
	# If we have less than MAX_SCORES, just add it
	if scores.size() < MAX_SCORES:
		scores.append(new_entry)
		scores.sort_custom(func(a, b): return a["score"] > b["score"])
		save_scores()
		return true
	
	# Check if the new score is higher than the lowest score
	if scores[-1]["score"] < score:
		scores.pop_back() # Remove lowest score
		scores.append(new_entry)
		scores.sort_custom(func(a, b): return a["score"] > b["score"])
		save_scores()
		return true
	
	return false

func is_high_score(score: int) -> bool:
	if scores.size() < MAX_SCORES:
		return true
	return score > scores[-1]["score"]

func get_scores() -> Array:
	return scores
