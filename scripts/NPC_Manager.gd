extends Node3D

@export var npc_scene: PackedScene
@export var player: Node3D
@export var max_active_npcs: int = 20
@export var max_spawn_height: float = 1.0

@export_group("Spawn Despawn")
@export var off_screen_radius: float = 3.0 
@export var despawn_radius: float = 4.5  
@export var spawn_interval: float = 0.1 

@export_group("Corpse Settings")
@export var corpse_scene: PackedScene
@export var corpse_spawn_min: float = 5.0
@export var corpse_spawn_max: float = 6.5

signal kill_occurred(corpse_node: Node3D)

var _active_npcs: Array[Node3D] = []
var _corpses: Array[Node3D] = []
var _spawn_timer: float = 0.0

var _map_ready: bool = false 

func _ready():
	# wait for navmesh to load
	await get_tree().process_frame 
	await get_tree().physics_frame
	await get_tree().physics_frame
	_map_ready = true

func _physics_process(delta):
	if not _map_ready or not player: 
		return
	
	# if too far, deltee
	for i in range(_active_npcs.size() - 1, -1, -1):
		var npc = _active_npcs[i]
		if is_instance_valid(npc):
			if npc.global_position.distance_to(player.global_position) > despawn_radius:
				npc.queue_free()
				_active_npcs.remove_at(i)
		else:
			_active_npcs.remove_at(i)
			
	# spawn if not maxed
	if _active_npcs.size() < max_active_npcs:
		_spawn_timer -= delta
		if _spawn_timer <= 0:
			_spawn_timer = spawn_interval
			# spawn off screen
			_try_spawn_npc(off_screen_radius, despawn_radius - 0.5)

func _try_spawn_npc(min_dist: float, max_dist: float):
	if not player: return
	
	var map = get_world_3d().navigation_map
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var dist = randf_range(min_dist, max_dist)
	var desired_pos = player.global_position + (random_dir * dist)
	
	var closest_point = NavigationServer3D.map_get_closest_point(map, desired_pos)
	
	if closest_point.y <= max_spawn_height:
		var npc = npc_scene.instantiate()
		add_child(npc)
		npc.global_position = closest_point
		_active_npcs.append(npc)
		
		# walk towards screen on spawn
		if npc.has_method("walk_toward_screen"):
			npc.walk_toward_screen(player.global_position)
			
func trigger_panic(source_position: Vector3, radius: float = 10.0):
	for npc in _active_npcs:
		if is_instance_valid(npc) and npc.has_method("panic"):
			if npc.global_position.distance_to(source_position) <= radius:
				npc.panic(source_position)

func spawn_dead_body(kill_location: Vector3):
	var body = corpse_scene.instantiate()
	add_child(body)

	# drop exactly where the monster committed the crime
	body.global_position = kill_location
	_corpses.append(body)
	
	kill_occurred.emit(body)
	trigger_panic(kill_location, 15.0)
