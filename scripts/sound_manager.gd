# sound_manager.gd
extends Node

# Audio players for different sound categories
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer

# Preload sound resources
var sounds = {
	# Interaction sounds
	"grave_approach": preload("res://audio/grave_approach.mp3"),
	"bench_repair": preload("res://audio/bench_repair.ogg"),
	"lamp_fix": preload("res://audio/lamp_fix.mp3"),
	"grass_remove": preload("res://audio/grass_remove.mp3"),
	
	# Cleaning progress sounds
	"cleaning_loop": preload("res://audio/bench_repair.ogg"),
	
	# Completion sounds
	"task_complete": preload("res://audio/lamp_fix.mp3"),
	
	# Memory sounds
	"memory_enter": preload("res://audio/lamp_fix.mp3"),
	"memory_exit": preload("res://audio/lamp_fix.mp3")
}

# Ambient sounds dictionary
var ambient_sounds = {
	"cemetery_night": preload("res://audio/cemetery_ambient.mp3")
}

func _ready():
	# Set up default properties for players
	sfx_player.bus = "SFX"
	ambient_player.bus = "Ambient"
	
	# Start ambient cemetery sound
	play_ambient("cemetery_night", true)

# Play a sound effect once
func play_sound(sound_name: String, volume_db: float = 0.0):
	if sounds.has(sound_name):
		sfx_player.stream = sounds[sound_name]
		sfx_player.volume_db = volume_db
		sfx_player.play()
	else:
		push_warning("Sound not found: " + sound_name)

# Play an ambient sound, with option to loop
func play_ambient(sound_name: String, loop: bool = true, volume_db: float = -10.0):
	if ambient_sounds.has(sound_name):
		ambient_player.stream = ambient_sounds[sound_name]
		ambient_player.volume_db = volume_db
		ambient_player.stream.loop = loop
		ambient_player.play()
	else:
		push_warning("Ambient sound not found: " + sound_name)

# Create a new temporary player for a sound at a specific position (3D)
func play_positioned_sound(sound_name: String, position: Vector3, volume_db: float = 0.0):
	if sounds.has(sound_name):
		var player = AudioStreamPlayer3D.new()
		add_child(player)
		player.stream = sounds[sound_name]
		player.volume_db = volume_db
		player.position = position
		player.max_distance = 10.0
		player.unit_size = 2.0
		player.autoplay = true
		
		# Connect to finished signal to remove the player when done
		player.finished.connect(func(): player.queue_free())
		player.play()
	else:
		push_warning("Sound not found for positioned audio: " + sound_name)

# Stop all sound effects
func stop_all_sfx():
	sfx_player.stop()

# Stop ambient sounds
func stop_ambient():
	ambient_player.stop()