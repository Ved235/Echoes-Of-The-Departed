# grave_spot.gd
extends Node3D

signal interaction_started
signal interaction_completed

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt_sprite: Sprite3D = $InteractionPrompt
var player_in_range: bool = false
var tasks_completed: bool = false

func _ready():
	# Setup interaction prompt
	prompt_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt_sprite.no_depth_test = true
	prompt_sprite.hide()
	
	# Connect signals
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Get challenge tracker to know when tasks are done
	var tracker = get_node("/root/Main/UI/ChallengeTracker")
	if tracker:
		tracker.all_tasks_completed.connect(_on_tasks_completed)

func _on_tasks_completed():
	tasks_completed = true
	if player_in_range:
		prompt_sprite.show()

func _on_player_entered(_body):
	player_in_range = true
	if tasks_completed:
		prompt_sprite.show()

func _on_player_exited(_body):
	player_in_range = false
	prompt_sprite.hide()

func _input(event):
	if event.is_action_pressed("interact") and player_in_range and tasks_completed:
		emit_signal("interaction_started")
		# Here you can trigger the memory/story sequence
		# For now we'll just emit the completed signal
		emit_signal("interaction_completed")

# memory_manager.gd
extends Node

var current_memory: Dictionary = {}
var memories = [
	{
		"name": "Sarah Thompson",
		"birth": "1945-03-15",
		"death": "2020-11-22",
		"story": "A beloved teacher who inspired generations...",
		"key_moments": ["First day teaching", "Meeting her future husband", "Retirement party"]
	},
	# Add more memories as needed
]

func get_random_memory() -> Dictionary:
	if memories.size() > 0:
		var index = randi() % memories.size()
		return memories[index]
	return {}

# Update challenge_tracker.gd to add:
signal all_tasks_completed

func _on_challenge_completed():
	print("Challenge completed called")
	completed_challenges += 1
	progress_bar.value = completed_challenges
	_update_progress_text()
	
	if completed_challenges >= total_challenges:
		print("All challenges completed!")
		emit_signal("all_tasks_completed")
