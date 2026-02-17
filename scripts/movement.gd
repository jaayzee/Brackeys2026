extends CharacterBody3D

@export var speed = 2.0
@export var jump_velocity = 2.5
@export var acceleration = 10.0
@export var friction = 10.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var sprite = $AnimatedSprite3D

# Shooting
@export var bullet: PackedScene # Can be plates or actually bullets

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Movement input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Flip sprite based on horizontal movement
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# SHOOTING
	if Input.is_action_just_pressed("Interact"):
		shoot()
	
	# Animation logic
	if is_on_floor():
		if direction:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")
		
func shoot():
	
	pass
