extends Ability

var speed_boost := 1.0
var duration := 2.50

@export var shadow_particles: PackedScene
var particles

func _ready() -> void:
	ab_name = "Shadow Step"
	ab_is_unlocked = false
	ab_is_active = false
	ab_level = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _activate():
	print("Active: Shadowstep")
	player._boost_speed(speed_boost)
	
	# Particles
	particles = shadow_particles.instantiate()
	add_child(particles)
	particles.global_transform.origin = player.global_transform.origin
	player.sprite.visible = false
	
	# Start a timer 
	var t = Timer.new()
	t.wait_time = duration
	add_child(t)
	t.start()
	t.one_shot = true
	t.timeout.connect(Callable(self, "_deactivate"))

func _deactivate():
	print("Deactive: Shadowstep")
	player._boost_speed(-speed_boost)
	particles.queue_free()
	player.sprite.visible = true
