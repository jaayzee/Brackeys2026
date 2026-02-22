extends Node3D

@onready var particles = $GPUParticles3D

func _ready():
	particles.emitting = true
	
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
