extends CharacterBody3D

@export var speed = 1
@export var jump_velocity = 3.0
@export var acceleration = 10.0
@export var friction = 10.0
@export var rotation_speed = 90.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_angle = 0.0
@onready var sprite = $AnimatedSprite3D
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

@onready var col_detector = $CollisionDetector

func _process(_delta):
	RenderingServer.global_shader_parameter_set("player_position", global_position)
	
func _ready() -> void:
	speed = GameManager.get_player_speed()
	
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
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Flip sprite based on movement
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Animation logic
	if is_on_floor():
		if direction:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")
		
# Ability 
func _boost_speed(increment: float):
	speed += increment
	print("Speed: " + str(increment))
	
func _get_near_npcs() -> Array:
	return col_detector.get_overlapping_bodies()
