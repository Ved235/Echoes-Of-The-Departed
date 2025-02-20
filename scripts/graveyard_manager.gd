# graveyard_manager.gd
extends Node3D

@export var grass_scene: PackedScene
@export var lamp_scene: PackedScene

@onready var maintenance_spots = $MaintenanceSpots

func _ready():
	setup_maintenance_spots()

func setup_maintenance_spots():
	# Add initial maintenance spots
	spawn_grass_spot(Vector3(0, 0, 0))
	spawn_grass_spot(Vector3(10, 0, 5))
	mark_lamp_broken($"../Props/Lightpost-single")
	mark_lamp_broken($"../Props/Lightpost-single2")

func spawn_grass_spot(position: Vector3):
	var spot = grass_scene.instantiate()
	spot.spot_type = maintenance_spots.SpotType.GRASS
	maintenance_spots.add_child(spot)
	spot.add_to_group("maintenance_spots")
	spot.global_position = position
	print("Added grass spot to maintenance_spots group")
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
