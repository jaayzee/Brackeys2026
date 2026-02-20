extends Ability

@export var blood_lust_particles : PackedScene
var blood_particles: Array = []

@export var particle_offset: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _activate():
	super()
	monster_manager._enable_blood()
	
	blood_particles = []
	for monster in monster_manager.monsters:
		# Particles
		var particles = blood_lust_particles.instantiate()
		blood_particles.append(particles)
		monster.add_child(particles)
		particles.global_transform.origin = monster.global_transform.origin + particle_offset

	#_start_timer()
	
func _deactivate():
	super()
	monster_manager._disable_blood()
	
	for particle in blood_particles:
		if particle:
			particle.queue_free()
