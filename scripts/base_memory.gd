extends Node3D

func _ready():
	setup_memory()

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		exit_memory()

func setup_memory():
	# Override this in specific memory scenes
	pass

func exit_memory():
	var memory_manager = get_node("/root/Main/MemoryManager")
	if memory_manager:
		memory_manager.return_to_graveyard()
