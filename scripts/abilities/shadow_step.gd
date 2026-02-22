extends Ability

@export var shadow_particles: PackedScene
var particles

@export var shadow_speed_boost := 1
var og_walk_speed

func _ready() -> void:
	pass

func _activate():
	super()
	ab_is_active = true
	og_walk_speed = player.speed
	player.set_speed(GameManager.player_speed + shadow_speed_boost)
	
	# Particles
	particles = shadow_particles.instantiate()
	add_child(particles)
	particles.global_transform.origin = player.global_transform.origin
	player.sprite.visible = false
	#_start_timer()

func _deactivate():
	super()
	ab_is_active = false
	player.set_speed(og_walk_speed)
	if particles:
		particles.queue_free()
	player.sprite.visible = true
