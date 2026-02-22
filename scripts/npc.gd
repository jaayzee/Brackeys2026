extends CharacterBody3D

@export var default_move_speed := 0.5
@export var default_panic_speed := 1.0
@export var wait_min := 1.0
@export var wait_max := 3.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var rng = RandomNumberGenerator.new()

var move_speed := default_move_speed
var _wait_timer := 0.0
var _panicking := false
var _dead := false
var panic_speed := default_panic_speed
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _stuck_timer := 0.0
var _last_pos := Vector3.ZERO

func _ready():
	rng.randomize()
	agent.path_desired_distance = 0.5
	agent.target_desired_distance = 0.5
	agent.path_max_distance = 1.0 	
	_wait_timer = randf_range(0.5, 2.0)
	sprite.play("idle")

func _pick_new_point(is_panic: bool, source_pos: Vector3 = Vector3.ZERO):
	var map = get_world_3d().navigation_map
	var target_pos = Vector3.ZERO
	
	if is_panic:
		var flee_dist = rng.randf_range(4.0, 8.0)
		var jitter = Vector3(rng.randf_range(-0.6, 0.6), 0, rng.randf_range(-0.6, 0.6))
		var dir = (global_position - source_pos).normalized() + jitter
		target_pos = global_position + (dir.normalized() * flee_dist)
		panic_speed = default_panic_speed + rng.randf_range(-0.5, 0.5)
	else:
		move_speed = default_move_speed + rng.randf_range(-0.3, 0.3)
		var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		target_pos = global_position + (random_dir * randf_range(1.5, 3.0))
	agent.target_position = NavigationServer3D.map_get_closest_point(map, target_pos)

func panic(source_position: Vector3):
	if _panicking: return
	_panicking = true
	# if we want panic to not be spammable
	_wait_timer = 0.0 
	# start on different animation frame for variation
	sprite.play("panic")
	var f_count = sprite.sprite_frames.get_frame_count("panic")
	sprite.frame = rng.randi_range(0, f_count - 1)
	_pick_new_point(true, source_position)

func die():
	_dead = true
	sprite.play("die")
	move_speed = 0
	velocity = Vector3.ZERO
	collision_layer &= ~(1 << 2) # Turns off layer 2 to not get bitten again
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	print("DIED")
	
func _physics_process(delta):
	if _dead:
		return
	if not is_on_floor():
		velocity.y -= _gravity * delta
		
	if agent.is_navigation_finished():
		_handle_arrival(delta)
		_stuck_timer = 0.0
	else:
		var next_waypoint = agent.get_next_path_position()
		var dir = (next_waypoint - global_position).normalized()
		dir.y = 0 
		
		var current_speed = panic_speed if _panicking else move_speed
		velocity.x = dir.x * current_speed
		velocity.z = dir.z * current_speed
		
		# stuck handler
		if global_position.distance_to(_last_pos) < 0.005:
			_stuck_timer += delta
			if _stuck_timer > 2.0:
				_stuck_timer = 0.0
				_pick_new_point(false)
		else:
			_stuck_timer = 0.0
			
		_last_pos = global_position
		
		# flip sprite relative to camera
		var cam = get_viewport().get_camera_3d()
		if cam:
			# cam-local coords
			var local_dir = cam.global_transform.basis.inverse() * dir
			
			# local_dir.x = screen left/right
			if abs(local_dir.x) > 0.05:
				sprite.flip_h = local_dir.x < 0
			
		sprite.play("panic" if _panicking else "walk")
			
	move_and_slide()

func _handle_arrival(delta):
	velocity.x = 0
	velocity.z = 0
	sprite.play("idle")
	
	_wait_timer -= delta
	if _wait_timer <= 0:
		if _panicking: _panicking = false
		_wait_timer = randf_range(wait_min, wait_max)
		_pick_new_point(false)
