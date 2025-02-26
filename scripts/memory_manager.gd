# memory_manager.gd
extends Node

var memory_scenes = {
	"sarah": preload("res://scenes/memories/sarah_memory.tscn")
}

func load_memory_scene(grave_id: String) -> void:
	if memory_scenes.has(grave_id):
		# Play memory transition sound
		var sound_manager = get_node("/root/SoundManager")
		if sound_manager:
			sound_manager.play_sound("memory_enter")
			
		# Fade out cemetery ambient sound
		if sound_manager:
			# Gradually lower volume of ambient sounds
			var tween = create_tween()
			tween.tween_method(
				func(vol: float): sound_manager.ambient_player.volume_db = vol,
				sound_manager.ambient_player.volume_db, 
				-40.0, 
				1.0
			)
			tween.tween_callback(func(): sound_manager.stop_ambient())
			
		# Instance the memory scene
		var memory_instance = memory_scenes[grave_id].instantiate()
		add_child(memory_instance)

func return_to_graveyard() -> void:
	# Play exit sound
	var sound_manager = get_node("/root/SoundManager")
	if sound_manager:
		sound_manager.play_sound("memory_exit")
		
	# Restart cemetery ambient sound
	if sound_manager:
		sound_manager.play_ambient("cemetery_night")
		var tween = create_tween()
		tween.tween_method(
			func(vol: float): sound_manager.ambient_player.volume_db = vol,
			-40.0, 
			-10.0, 
			1.0
		)
		
	# Free ALL active memory scenes 
	for child in get_children():
		child.queue_free()
