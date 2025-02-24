# graveyard_manager.gd
extends Node3D

@export var grass_scene: PackedScene
@export var lamp_scene: PackedScene
@export var broken_bench_scene: PackedScene # Scene for broken bench maintenance spot
@export var fixed_bench_scene: PackedScene # Scene for the fixed bench
@export var damaged_grave_scene: PackedScene # Scene for the damaged grave
@onready var maintenance_spots = $MaintenanceSpots

func _ready():
	setup_maintenance_spots()

func setup_maintenance_spots():
	# Add initial maintenance spots
	spawn_grass_spot(Vector3(0, 0, 0))
	#spawn_grass_spot(Vector3(10, 0, 5))
	#mark_lamp_broken($"../Props/Lightpost-single")
	#mark_lamp_broken($"../Props/Lightpost-single2")
	spawn_broken_bench(Vector3(6, 0, -7)) # Add broken benches at desired positions
	spawn_damaged_grave(Vector3(-32, 0, -40)) # Add damaged grave at desired position

func spawn_grass_spot(position: Vector3):
	var spot = grass_scene.instantiate()
	spot.spot_type = maintenance_spots.SpotType.GRASS
	maintenance_spots.add_child(spot)
	spot.add_to_group("maintenance_spots")
	spot.global_position = position

func mark_lamp_broken(lamp_node: Node3D):
	var spot = lamp_scene.instantiate()
	spot.spot_type = maintenance_spots.SpotType.LAMP
	maintenance_spots.add_child(spot)
	spot.add_to_group("maintenance_spots")
	spot.global_position = lamp_node.global_position
	
	# Get the light node using the correct path
	var light = lamp_node.get_node("Lightpost-single/OmniLight3D")
	if light:
		light.light_energy = 0.1
	else:
		push_error("Could not find light node in lamp: " + lamp_node.name)

func spawn_broken_bench(position: Vector3):
	# Spawn the broken bench
	var broken_bench = broken_bench_scene.instantiate()
	broken_bench.spot_type = maintenance_spots.SpotType.BENCH
	maintenance_spots.add_child(broken_bench)
	broken_bench.add_to_group("maintenance_spots")
	broken_bench.global_position = position
	
	broken_bench.rotation_degrees = Vector3(0, -90, 0)

	# Store the position for later replacement
	broken_bench.set_meta("spawn_position", position)

func spawn_damaged_grave(position: Vector3):
	# Spawn the damaged grave
	var grave = damaged_grave_scene.instantiate()
	grave.spot_type = maintenance_spots.SpotType.GRAVE
	maintenance_spots.add_child(grave)
	grave.add_to_group("maintenance_spots")
	grave.global_position = position


	# Store the position for later replacement
	grave.set_meta("spawn_position", position)
