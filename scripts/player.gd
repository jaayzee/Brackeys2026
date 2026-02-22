extends CharacterBody3D

# @onready var kill_pointer = $PointerPivot

@export var speed = 1
@export var jump_velocity = 3.0
@export var acceleration = 10.0
@export var friction = 5.0
@export var rotation_speed = 90.0
@export var sprint_multiplier = 1.6
@export var indicator_scene: PackedScene

@export_group("Sprint Effect")
@export var ghost_interval := 0.08
@export var ghost_duration := 0.4

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_angle = 0.0
var _ghost_timer := 0.0

@onready var ui_layer = $Indicator
@onready var sprite = $AnimatedSprite3D
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

@onready var col_detector = $CollisionDetector

func _ready():
	#if kill_pointer:
		#kill_pointer.hide()
		
	sprite.play("idle")
	
	# manager for listeners
	var manager = get_tree().get_root().find_child("NPC_Manager", true, false)
	if manager:
		manager.kill_occurred.connect(point_to_corpse)
		
	speed = GameManager.get_player_speed()

func _process(_delta):
	RenderingServer.global_shader_parameter_set("player_position", global_position)
	
func _input(event):
	if event.is_action_pressed("v"):
		get_tree().get_root().find_child("NPC_Manager", true, false).trigger_panic(global_position, 15.0)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sprite.frame = 0 
		sprite.play("jump")
		
	# Camera rotation
	if Input.is_action_pressed("rotate_left"):
		camera_pivot.rotate_y(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_right"):
		camera_pivot.rotate_y(deg_to_rad(-rotation_speed * delta))
		
	# Movement input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var cam_basis = camera_pivot.global_transform.basis
	var cam_forward = -cam_basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()
	var cam_right = camera.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	
	# Move relative to camera direction
	var direction = (cam_forward * -input_dir.y + cam_right * input_dir.x).normalized()
	
	# sprint
	var is_sprinting = Input.is_action_pressed("sprint") 
	var current_speed = speed * sprint_multiplier if is_sprinting else speed
	
	if direction:
		var active_accel = acceleration * 0.4 if is_sprinting else acceleration
		velocity.x = move_toward(velocity.x, direction.x * current_speed, active_accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, active_accel * delta)
		
		# Flip sprite based on movement
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
	
	move_and_slide()
	
	#finish jump
	var jump_total_frames = sprite.sprite_frames.get_frame_count("jump")
	var jump_is_finishing = (sprite.animation == "jump" and sprite.frame < jump_total_frames - 1)
	
	# Animation logic
	if not is_on_floor():
		sprite.play("jump")
	elif jump_is_finishing:
		pass 
	else:
		if is_sprinting and velocity.length() > 0:
			sprite.play("walk")
			_ghost_timer -= delta
			if _ghost_timer <= 0:
				_spawn_ghost()
				_ghost_timer = ghost_interval
				
		elif velocity.length() > 0:
			sprite.play("walk")
			_ghost_timer = 0.0 # Reset timer when not sprinting
			
		else:
			sprite.play("idle")
			_ghost_timer = 0.0
		
# Ability 
func _boost_speed(increment: float):
	speed += increment
	print("Speed: " + str(increment))
	
func _get_near_npcs() -> Array:
	return col_detector.get_overlapping_bodies()

func point_to_corpse(corpse_node: Node3D):
	if not indicator_scene or not camera: return
	
	var arrow = indicator_scene.instantiate()
	
	arrow.target_node = corpse_node
	arrow.camera = camera
	
	ui_layer.add_child(arrow)
	
func _spawn_ghost():
	var ghost = Sprite3D.new()
	
	# take frame
	var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.texture = tex
	
	# match player orientation
	ghost.flip_h = sprite.flip_h
	ghost.pixel_size = sprite.pixel_size
	ghost.offset = sprite.offset
	ghost.modulate = Color(1.0, 0.0, 0.0)
	
	# get through postprocessing quad
	ghost.alpha_cut = Sprite3D.ALPHA_CUT_HASH 
	ghost.texture_filter = sprite.texture_filter
	ghost.render_priority = sprite.render_priority
	
	# stamp where player was
	get_tree().current_scene.add_child(ghost)
	ghost.global_transform = sprite.global_transform
	
	# fade out
	var tween = get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, ghost_duration)
	tween.tween_callback(ghost.queue_free)
	
	
