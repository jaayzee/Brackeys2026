@tool
extends Node3D

@export var do_merge: bool:
	set(value):
		if Engine.is_editor_hint():
			run_merge()

func run_merge():
	var instances = []
	for child in get_children():
		if child is MeshInstance3D:
			instances.append(child)
	
	var merged = merge_meshes(instances)
	get_parent().add_child(merged)
	merged.owner = owner

func merge_meshes(mesh_instances: Array) -> MeshInstance3D:
	var merged_mesh = ArrayMesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for mi in mesh_instances:
		if mi.mesh == null:
			continue
		st.append_from(mi.mesh, 0, mi.global_transform)
	
	st.commit(merged_mesh)
	
	var result = MeshInstance3D.new()
	result.mesh = merged_mesh
	return result
