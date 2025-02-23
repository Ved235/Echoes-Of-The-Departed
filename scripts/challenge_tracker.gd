# challenge_tracker.gd
extends Control

@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var progress_label = $MarginContainer/VBoxContainer/Label

var total_challenges: int = 0
var completed_challenges: int = 0

signal all_tasks_completed

func _ready():
	# Defer the initialization to happen after all nodes are ready
	call_deferred("initialize_tracker")

func initialize_tracker():
	print("Initializing tracker")
	# Get all maintenance spots


	var spots = get_tree().get_nodes_in_group("maintenance_spots")
	print("Found maintenance spots: ", spots.size())
	total_challenges = spots.size()
	
	# Initialize progress bar
	progress_bar.min_value = 0
	progress_bar.max_value = total_challenges
	progress_bar.value = completed_challenges
	
	# Connect to cleaning completion signals of all spots
	for spot in spots:
		print("Connecting to spot: ", spot.name)
		spot.cleaning_completed.connect(_on_challenge_completed)
		
	_update_progress_text()
	print("Progress initialized: ", completed_challenges, "/", total_challenges)

func _on_challenge_completed():
	print("Challenge completed called")
	completed_challenges += 1
	progress_bar.value = completed_challenges
	_update_progress_text()
	
	if completed_challenges >= total_challenges:
		print("All challenges completed!")
		emit_signal("all_tasks_completed")
		

func _update_progress_text():
	progress_label.text = "%d / %d Tasks Completed" % [completed_challenges, total_challenges]
