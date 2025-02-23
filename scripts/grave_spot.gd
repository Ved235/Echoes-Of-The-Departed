# grave_spot.gd
extends Node3D

signal interaction_started
signal interaction_completed

@export var grave_id: String = ""

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt_sprite: Sprite3D = $InteractionPrompt
var player_in_range: bool = false
var tasks_completed: bool = false

func _ready():
	# Setup interaction prompt
	prompt_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt_sprite.no_depth_test = true
	prompt_sprite.hide()
	
	# Connect Area3D signals - IMPORTANT FOR INTERACTION
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Get challenge tracker to know when tasks are done
	var tracker = get_node("/root/Main/ChallengeTracker")
	if tracker:
		tracker.all_tasks_completed.connect(_on_tasks_completed)

func _on_tasks_completed():
	tasks_completed = true
	print("yaya")
	if player_in_range:
		prompt_sprite.show()

func _on_player_entered(body: Node3D):
	# Check if it's actually the player (uses CharacterBody3D)
	print("player entered")
	if body is CharacterBody3D:
		player_in_range = true
		if tasks_completed:
			prompt_sprite.show()

func _on_player_exited(body: Node3D):
	if body is CharacterBody3D:
		player_in_range = false
		prompt_sprite.hide()

func _input(event):
	if event.is_action_pressed("interact") and player_in_range and tasks_completed:
		start_memory_sequence()

func start_memory_sequence():
	emit_signal("interaction_started")
	var memory_manager = get_node("/root/Main/MemoryManager")
	if memory_manager:
		memory_manager.load_memory_scene(grave_id)
	emit_signal("interaction_completed")
