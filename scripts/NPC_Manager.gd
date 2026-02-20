extends Node3D

@export var npc_scene: PackedScene
@export var npc_count: int = 20
@export var spawn_delay: float = 0.1
@export var max_spawn_height: float = 1.0
@export var panic_radius: float = 10.0

func _ready():
	await get_tree().physics_frame
	await get_tree().physics_frame
	_spawn_all()

func _spawn_all():
	for i in range(npc_count):
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_one()

func _spawn_one():
	var map = get_world_3d().navigation_map
	# try several times to find a point under the height limit
	for i in range(20):
		var pt = NavigationServer3D.map_get_random_point(map, 1, false)
		if pt != Vector3.ZERO and pt.y <= max_spawn_height:
			var npc = npc_scene.instantiate()
			add_child(npc)
			npc.global_position = pt
			return

func trigger_panic(source_position: Vector3, radius: float = 10.0):
	for child in get_children():
		if child.has_method("panic"):
			if child.global_position.distance_to(source_position) <= radius:
				child.panic(source_position)
