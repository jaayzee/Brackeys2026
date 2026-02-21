extends Ability

@export var bite_sprite_obj : PackedScene
var bite_sprite
var sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ab_name = "Vampiric Bite"
	ab_is_unlocked = false
	ab_is_active = false
	ab_level = 0
	
	duration = 2.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _activate():
	super()

	var bodies = player._get_near_npcs()
	var closest_body
	
	if bodies.size() > 0:
		closest_body = bodies[0]
	else:
		_deactivate()
		return

	for body in bodies:
		var dist = player.global_position.distance_to(body.global_position)
		if dist < player.global_position.distance_to(closest_body.global_position):
			closest_body = body

	if closest_body.is_in_group("monster"):
		print("Biting monster")
		_bite(closest_body)
		monster_manager._capture_monster()
	elif closest_body.is_in_group("npc"):
		print("Biting npc")
		_bite(closest_body)
		closest_body.die()
		GameManager._add_paranoia(paranoia_rate)
		
	_deactivate()
	
func _bite(body: Node3D):
	sprite = body.get_node_or_null("AnimatedSprite3D")
	if sprite:
		sprite.play("die")
		sprite.animation_finished.connect(_stop_death_animation, CONNECT_ONE_SHOT)
	else:
		print("no animatedsprite")
		_deactivate()

func _stop_death_animation():
	sprite.stop()
	#sprite.frame = sprite.frame_frames.get_frame_count("die") - 1
	sprite.frame = 6 # errors for some reason if I do ^
	_deactivate()
	
func _deactivate():
	super()
