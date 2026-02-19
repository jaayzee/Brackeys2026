extends Ability

@export var blood_lust_particles : PackedScene
var blood_particles: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _activate():
	print("Activating: Blood Lust")
	ab_is_active = true
	monster_manager._enable_blood()
	
	blood_particles = []
	for monster in monster_manager.monsters:
		# Particles
		var particles = blood_lust_particles.instantiate()
		blood_particles.append(particles)
		monster.add_child(particles)
		particles.global_transform.origin = monster.global_transform.origin

	_start_timer(duration)
	
func _deactivate():
	ab_is_active = false
	monster_manager._disable_blood()
	
	for particle in blood_particles:
		particle.queue_free()
