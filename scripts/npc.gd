extends CharacterBody3D

@export var move_speed := 0.5
@export var panic_speed := 1.0
@export var wait_time_min := 2.0
@export var wait_time_max := 5.0
@export var panic_duration := 10.0
@export var min_flee_distance := 8.0

@export var navigation_layer: int = 1:
	set(value):
		navigation_layer = value
		if agent:
			agent.navigation_layers = value

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _panicking := false
var _dead := false
var _panic_timer := 0.0
var _panic_source := Vector3.ZERO

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	agent.navigation_layers = navigation_layer
	await get_tree().physics_frame
	await get_tree().physics_frame
	_pick()

func panic(source_position: Vector3):
	if _panicking:
		return
	_panicking = true
	_panic_timer = panic_duration
	_panic_source = source_position
	sprite.play("panic")
	agent.target_position = global_position
	_pick_panic(source_position)

func _pick_panic(source_position: Vector3):
	if not _panicking:
		return
	var map = get_world_3d().navigation_map
	var best_pt = Vector3.ZERO
	var best_dist = 0.0
	for i in range(40):
		var candidate = NavigationServer3D.map_get_random_point(map, navigation_layer, false)
		var dist = candidate.distance_to(source_position)
		if dist > best_dist and dist > min_flee_distance:
			best_dist = dist
			best_pt = candidate
	if best_pt == Vector3.ZERO:
		best_pt = NavigationServer3D.map_get_random_point(map, navigation_layer, false)
	if best_pt != Vector3.ZERO:
		agent.target_position = best_pt
		agent.target_position = best_pt

func _pick():
	if _panicking:
		return
	var map = get_world_3d().navigation_map
	var pt = Vector3.ZERO
	for i in range(10):
		var candidate = NavigationServer3D.map_get_random_point(map, navigation_layer, false)
		var path = NavigationServer3D.map_get_path(map, global_position, candidate, true, navigation_layer)
		if path.size() > 0:
			pt = candidate
			break
	if pt == Vector3.ZERO:
		await get_tree().create_timer(1.0).timeout
		_pick()
		return
	agent.target_position = pt
	await agent.navigation_finished
	await get_tree().create_timer(randf_range(wait_time_min, wait_time_max)).timeout
	_pick()

func die():
	_dead = true
	move_speed = 0
	set_collision_layer_value(2, false)
	print("DIED")
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= _gravity * delta

	if _panicking:
		_panic_timer -= delta
		if _panic_timer <= 0:
			_panicking = false
			_pick()
		# keep picking new flee targets as they reach each one
		if agent.is_navigation_finished():
			_pick_panic(_panic_source)

	var speed = panic_speed if _panicking else move_speed

	if not agent.is_navigation_finished():
		var next = agent.get_next_path_position()
		var dir = (next - global_position)
		dir.y = 0.0
		if dir.length() > 0.1:
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			sprite.flip_h = dir.x < 0
			if !_dead:
				sprite.play("panic" if _panicking else "walk")
	else:
		velocity.x = 0
		velocity.z = 0
		sprite.play("die" if _dead else "idle")

	move_and_slide()
