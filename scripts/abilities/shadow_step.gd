extends Ability

var speed_boost := 1.0

@export var shadow_particles: PackedScene
var particles

func _ready() -> void:
	ab_name = "Shadow Step"
	ab_is_unlocked = false
	ab_is_active = false
	ab_level = 0
	
	duration = 2.5

func _activate():
	print("Active: Shadowstep")
	ab_is_active = true
	player._boost_speed(speed_boost)
	
	# Particles
	particles = shadow_particles.instantiate()
	add_child(particles)
	particles.global_transform.origin = player.global_transform.origin
	player.sprite.visible = false
	
	_start_timer(duration)

func _deactivate():
	print("Deactive: Shadowstep")
	ab_is_active = false
	player._boost_speed(-speed_boost)
	particles.queue_free()
	player.sprite.visible = true
