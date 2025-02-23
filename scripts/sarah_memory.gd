extends Node2D

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		var memory_manager = get_node("/root/Main/MemoryManager")
		if memory_manager:
			memory_manager.return_to_graveyard()
