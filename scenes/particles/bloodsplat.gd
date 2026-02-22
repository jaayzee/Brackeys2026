extends Node3D

func _ready():
	# random size
	var base_scale = randf_range(0.5, 1.2)
	
	# stretch
	var stretch_x = base_scale * randf_range(0.8, 1.4)
	var stretch_z = base_scale * randf_range(0.8, 1.4) 
	
	scale = Vector3(stretch_x, 1.0, stretch_z)
	
	# random orientation
	rotation.y = randf_range(0, TAU)
