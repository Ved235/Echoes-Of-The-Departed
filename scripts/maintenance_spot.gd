extends Node3D

signal cleaning_started
signal cleaning_progressed(progress: float)
signal cleaning_completed

enum SpotType { GRASS, LAMP, BENCH, GRAVE }

@export var spot_type: SpotType
@export var cleaning_time: float = 3.0

var is_being_cleaned: bool = false
var cleaning_progress: float = 0.0
var player_in_range: bool = false
var cleaning_sound_player: AudioStreamPlayer3D = null

@onready var interaction_area: Area3D = $InteractionArea
@onready var progress_sprite: Sprite3D = $ProgressBar3D
@onready var viewport: SubViewport = $ProgressBar3D/SubViewport
@onready var progress_bar: TextureProgressBar = $ProgressBar3D/SubViewport/ProgressBar

func _ready():
	# Setup viewport with larger size
	viewport.transparent_bg = true
	
	# Setup progress bar
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	
	# Adjust the Sprite3D scale if needed
	progress_sprite.pixel_size = 0.005  # Might need adjustment
	progress_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	progress_sprite.no_depth_test = true 
	progress_sprite.texture = viewport.get_texture()
	progress_sprite.hide()
	# Position the progress bar above the object
	progress_sprite.position.y = 1
	
	# Connect signals
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Create cleaning sound player
	cleaning_sound_player = AudioStreamPlayer3D.new()
	add_child(cleaning_sound_player)
	cleaning_sound_player.unit_size = 1.0
	cleaning_sound_player.max_distance = 8.0
	cleaning_sound_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	
	# Set the appropriate sound based on spot type
	var sound_manager = get_node("/root/SoundManager")
	if sound_manager:
		match spot_type:
			SpotType.GRASS:
				cleaning_sound_player.stream = sound_manager.sounds["grass_remove"]
			SpotType.LAMP:
				cleaning_sound_player.stream = sound_manager.sounds["lamp_fix"]
			SpotType.BENCH:
				cleaning_sound_player.stream = sound_manager.sounds["bench_repair"]
			SpotType.GRAVE:
				cleaning_sound_player.stream = sound_manager.sounds["cleaning_loop"]
	
	# Enable looping for the cleaning sound
	if cleaning_sound_player.stream:
		cleaning_sound_player.stream.loop = true

func _process(delta):
	if is_being_cleaned and player_in_range:
		cleaning_progress += (delta / cleaning_time) * 100
		cleaning_progress = min(cleaning_progress, 100)
		# Force update the progress bar value
		progress_bar.value = cleaning_progress
		emit_signal("cleaning_progressed", cleaning_progress)
		
		if cleaning_progress >= 100:
			_complete_cleaning()

func start_cleaning():
	if not is_being_cleaned and player_in_range:
		# Reset progress when starting
		cleaning_progress = 0.0
		progress_bar.value = cleaning_progress
		is_being_cleaned = true
		progress_sprite.show()
		
		# Play the cleaning sound
		if cleaning_sound_player:
			cleaning_sound_player.play()
			
		emit_signal("cleaning_started")

func stop_cleaning():
	if is_being_cleaned:
		is_being_cleaned = false
		# Reset progress when stopping
		cleaning_progress = 0.0
		progress_bar.value = cleaning_progress
		progress_sprite.hide()
		
		# Stop the cleaning sound
		if cleaning_sound_player:
			cleaning_sound_player.stop()

func _complete_cleaning():
	# Stop the cleaning sound
	if cleaning_sound_player:
		cleaning_sound_player.stop()
	
	# Apply the effects of cleaning first
	if spot_type == SpotType.LAMP:
		# Get the lamp node that this maintenance spot is positioned at
		var props = get_node("/root/Main/Props")  # Adjust path as needed
		for lamp in props.get_children():
			if lamp.name.begins_with("Lightpost"):
				# Check if this lamp's position matches our maintenance spot
				if lamp.global_position.distance_to(global_position) < 0.1:
					var light = lamp.get_node("Lightpost-single/OmniLight3D")
					if light:
						light.light_energy = 1.0
					break
					
	if spot_type == SpotType.BENCH:
		# Get the stored spawn position
		var spawn_pos = get_meta("spawn_position")
		# Get the fixed bench scene
		var fixed_bench_scene = load("res://scenes/bench.tscn")  # Adjust path as needed
		if fixed_bench_scene:
			# Instance and place the fixed bench
			var fixed_bench = fixed_bench_scene.instantiate()
			var props = get_node("/root/Main/Props")  # Adjust path as needed
			props.add_child(fixed_bench)
			fixed_bench.global_position = spawn_pos	
			fixed_bench.rotation_degrees = Vector3(0, -90, 0)
	
	if spot_type == SpotType.GRAVE:
		var spawn_pos = get_meta("spawn_position")
		# Get the fixed grave scene
		var fixed_grave_scene = load("res://scenes/gravestone-bevel.tscn")  # Adjust path as needed
		if fixed_grave_scene:
			var fixed_grave = fixed_grave_scene.instantiate()
			var props = get_node("/root/Main/Props")  # Adjust path as needed
			props.add_child(fixed_grave)
			fixed_grave.global_position = spawn_pos	

	emit_signal("cleaning_completed")
	
	# Play completion sound with proper handling via SoundManager
	var sound_manager = get_node("/root/SoundManager")
	if sound_manager:
		# Create a standalone player for the completion sound
		var temp_player = AudioStreamPlayer.new()
		# Connect the finished signal before playing
		temp_player.finished.connect(func() -> void:
			temp_player.queue_free()
		)
		temp_player.stream = sound_manager.sounds["task_complete"]
		temp_player.volume_db = 0.0
		temp_player.bus = "SFX"
		# Ensure the sound isn’t looping
		if temp_player.stream is AudioStream:
			temp_player.stream.loop = false
		get_tree().root.add_child(temp_player)
		temp_player.play()
	
	# Now we can safely queue_free this node
	queue_free()

func _on_player_entered(_body):
	player_in_range = true
	# Reset and show progress
	cleaning_progress = 0.0
	progress_bar.value = cleaning_progress
	progress_sprite.show()
	
	# Play approach sound if this is a grave
	if spot_type == SpotType.GRAVE:
		var sound_manager = get_node("/root/SoundManager")
		if sound_manager:
			sound_manager.play_positioned_sound("grave_approach", global_position, -5.0)

func _on_player_exited(_body):
	player_in_range = false
	progress_sprite.hide()
	stop_cleaning()
