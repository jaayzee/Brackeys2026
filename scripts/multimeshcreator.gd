extends Node3D

@export var parent: Node3D

func _ready():
	# Find all MeshInstance3D nodes
	var mesh_instances = []
	for child in parent.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)

	# Group by mesh type
	var groups = {}
	for node in mesh_instances:
		var mesh = node.mesh
		var key = mesh.get_class()  # "BoxMesh", "CylinderMesh", etc
		if not groups.has(key):
			groups[key] = []
		groups[key].append(node)

	# For each group, create a MultiMesh
	for mesh_type in groups.keys():
		var nodes_in_group = groups[mesh_type]

		var multimesh = MultiMesh.new()
		multimesh.mesh = nodes_in_group[0].mesh
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.instance_count = nodes_in_group.size()

		for i in range(nodes_in_group.size()):
			var transform = nodes_in_group[i].global_transform
			multimesh.set_instance_transform(i, transform)

		# Create the MultiMeshInstance3D node
		var multimesh_instance = MultiMeshInstance3D.new()
		multimesh_instance.multimesh = multimesh
		multimesh_instance.name = "MultiMesh_" + mesh_type
		add_child(multimesh_instance)

		# Save resource to disk
		var save_path = "res://multimesh_" + mesh_type + ".tres"
		ResourceSaver.save(multimesh, save_path)

		# Remove original individual mesh nodes
		for node in nodes_in_group:
			node.queue_free()
