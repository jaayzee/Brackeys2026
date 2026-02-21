extends Camera3D

@export var player_path: NodePath
@onready var player = get_node(player_path)

var current_fade: float = 0.0
var fade_speed: float = 4.0 

func _physics_process(delta):
	if not player: return

	var space_state = get_world_3d().direct_space_state
	var target = player.global_position + Vector3(0, 0.15, 0)
	var query = PhysicsRayQueryParameters3D.create(global_position, target)
	query.collision_mask = 2 # building raycast collisions will be on layer 2 must ignore player
	
	var result = space_state.intersect_ray(query)
	
	var target_fade = 1.0 if result else 0.0
	
	current_fade = move_toward(current_fade, target_fade, fade_speed * delta)
	
	RenderingServer.global_shader_parameter_set("occlusion_amount", current_fade)
