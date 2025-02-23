# memory_manager.gd
extends Node

var memory_scenes = {
	"sarah": preload("res://scenes/memories/sarah_memory.tscn")
}

func load_memory_scene(grave_id: String) -> void:
	if memory_scenes.has(grave_id):
		# Instance the memory scene
		var memory_instance = memory_scenes[grave_id].instantiate()
		add_child(memory_instance)

func return_to_graveyard() -> void:
	# Free ALL active memory scenes 
	for child in get_children():
		child.queue_free()
