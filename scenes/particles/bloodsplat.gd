extends Node3D 

@export var jitter_amount := 0.4
@export var min_splat_size := 1.0
@export var max_splat_size := 2.0

func _ready():
	# random size
	var drop_size = randf_range(min_splat_size, max_splat_size) 
	scale = Vector3(drop_size, 1.0, drop_size)
	
	# random xz offset
	var offset_x = randf_range(-jitter_amount, jitter_amount)
	var offset_z = randf_range(-jitter_amount, jitter_amount)
	
	position.x += offset_x
	position.z += offset_z
