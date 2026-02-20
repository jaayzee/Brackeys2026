extends Ability

@export var shadow_particles: PackedScene
var particles

@export var speed_boost := 1.0

func _ready() -> void:
	pass

func _activate():
	super()
	ab_is_active = true
	player._boost_speed(speed_boost)
	
	# Particles
	particles = shadow_particles.instantiate()
	add_child(particles)
	particles.global_transform.origin = player.global_transform.origin
	player.sprite.visible = false
	#_start_timer()

func _deactivate():
	super()
	ab_is_active = false
	player._boost_speed(-speed_boost)
	if particles:
		particles.queue_free()
	player.sprite.visible = true
