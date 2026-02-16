extends CharacterBody3D

@export var speed = 2.0
@export var jump_velocity = 2.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var anim_player = $Rogue_Hooded/AnimationPlayer
@onready var model = $Rogue_Hooded

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
		
		# Rotate character to face movement direction
		model.rotation.y = atan2(direction.x, direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Animation logic
	if anim_player:
		if not is_on_floor():
			# In air
			if velocity.y > 0:
				anim_player.play("Jump_Start")
			else:
				anim_player.play("Jump_Land")
		elif direction:
			# Moving
			anim_player.play("Walking_A")  # or Running_A for faster
		else:
			# Idle
			anim_player.play("T-Pose")  # Change to an idle animation when you get one
