extends CharacterBody3D

@export var move_speed := 0.45
@export var kill_interval_min := 5.0
@export var kill_interval_max := 12.0
@export var blood_trail_scene: PackedScene
@export var bleed_time:= 10.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var visible_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

var _kill_timer := 5.0
var _blood_timer := 0.0
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	_kill_timer = randf_range(kill_interval_min, kill_interval_max)
	_pick_new_point()

func _physics_process(delta):
	if not is_on_floor(): velocity.y -= _gravity * delta
	
	if agent.is_navigation_finished():
		velocity.x = 0; velocity.z = 0
		sprite.play("idle")
		if _kill_timer > 0:
			_kill_timer -= delta
			if _kill_timer <= 0: _pick_new_point()
	else:
		_move_along_path()

	_handle_kill_logic(delta)
	
	if _blood_timer > 0:
		_blood_timer -= delta
		_leave_blood()

func _leave_blood():
	# spawn bloodsplat every 0.2 seconds
	if Engine.get_frames_drawn() % 12 == 0:
		var b = blood_trail_scene.instantiate()
		get_parent().add_child(b)
		b.global_position = Vector3(global_position.x, 0.01, global_position.z)

func _move_along_path():
	var next = agent.get_next_path_position()
	var dir = (next - global_position).normalized()
	dir.y = 0
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	
	var cam = get_viewport().get_camera_3d()
	if cam:
		var local_dir = cam.global_transform.basis.inverse() * dir
		sprite.flip_h = local_dir.x < 0
	sprite.play("walk")
	move_and_slide()

func _pick_new_point():
	var map = get_world_3d().navigation_map
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var target_pos = global_position + (random_dir * randf_range(2.0, 5.0))
	agent.target_position = NavigationServer3D.map_get_closest_point(map, target_pos)

func _handle_kill_logic(delta):
	# killing must happen offscreen
	if _kill_timer <= 0 and not visible_notifier.is_on_screen():
		_perform_kill()

func _perform_kill():
	var spawner = get_tree().get_root().find_child("NPC_Manager", true, false)
	if spawner.has_method("spawn_dead_body"):
		spawner.spawn_dead_body(global_position)
		
	_kill_timer = randf_range(kill_interval_min, kill_interval_max)
	_blood_timer = bleed_time
