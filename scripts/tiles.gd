@tool
extends Node3D

# ToolStaticBodyMaker.gd
# Takes a scene of imported MeshInstances and creates StaticBodys for them,
# now as children of each MeshInstance3D.
# The hierarchy for each tile becomes:
# MeshInstance3D ->
#   StaticBody3D ->
#     CollisionShape3D
#
# To use:
# First save scene as a .tscn file, and clear inheritance!
# Attach this script to a scene of imported meshes
# Set IS_CONVEX to false to build concave Shape if desired.
# Save scene; close/reload; it will run, and do its thing.
# Detach this script and save your scene; carry on!

const IS_CONVEX: bool = true  # Set to false for concave collisions
const CLEAN: bool = true      # Clean up the collision mesh
const SIMPLIFY: bool = false  # Simplify the collision mesh

func _ready() -> void:
	_work()

func _work() -> void:
	var root: Node3D = self
	
	# Get all MeshInstance3D nodes in the scene
	for child in root.get_children():
		if child is MeshInstance3D:
			print("Found MeshInstance3D: ", child.name)
			var mesh_inst: MeshInstance3D = child
			
			# Create a new StaticBody3D as a child of the MeshInstance3D
			var static_body: StaticBody3D = StaticBody3D.new()
			mesh_inst.add_child(static_body)
			static_body.owner = root  # Ensure the new node is part of the scene
			
			# Optionally, name the StaticBody3D node with a suffix
			static_body.name = mesh_inst.name + "_StaticBody"
			
			# Create and attach CollisionShape3D as child of the StaticBody3D
			var coll_shape: CollisionShape3D = CollisionShape3D.new()
			static_body.add_child(coll_shape)
			coll_shape.owner = root
			
			# Build the collision shape from the MeshInstance3D's mesh
			var mesh: Mesh = mesh_inst.mesh
			if IS_CONVEX:
				var shape = mesh.create_convex_shape(CLEAN, SIMPLIFY)
				coll_shape.shape = shape
			else:
				var shape = mesh.create_trimesh_shape()
				coll_shape.shape = shape
			
			print("Created collision for: ", mesh_inst.name)
