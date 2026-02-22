extends Ability

@export var bite_sprite_obj : PackedScene
@export var blood_explosion_scene : PackedScene
@export var bite_paranoia_penalty := 10.0
var bite_sprite
var sprite
var _highlighted_target : Node3D = null
var _is_aiming := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ab_name = "Vampiric Bite"
	ab_is_unlocked = false
	ab_is_active = false
	ab_level = 0
	paranoia_rate = 0.0
	duration = 2.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# not holding abilty, no highlight
	if not _is_aiming:
		if is_instance_valid(_highlighted_target):
			_remove_highlight(_highlighted_target)
		_highlighted_target = null
		return
	
	var target = _get_closest_target()
	
	# swap targets
	if target != _highlighted_target:
		if is_instance_valid(_highlighted_target):
			_remove_highlight(_highlighted_target)
			
		_apply_highlight(target)
		_highlighted_target = target

func _apply_highlight(body: Node3D):
	if not is_instance_valid(body):
		return
	var sprite = body.get_node_or_null("AnimatedSprite3D")
	if sprite:
		sprite.modulate = Color(1.0, 0.0, 0.0)

func _remove_highlight(body: Node3D):
	if not is_instance_valid(body): return
	var sprite = body.get_node_or_null("AnimatedSprite3D")
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0)

func _get_closest_target() -> Node3D:
	var bodies = player._get_near_npcs()
	if bodies.size() == 0:
		return null

	var closest = bodies[0]
	for body in bodies:
		if is_instance_valid(body):
			var dist = player.global_position.distance_to(body.global_position)
			if dist < player.global_position.distance_to(closest.global_position):
				closest = body
				
	return closest

func _activate():
	super()
	# highlight on hold
	_is_aiming = true
	if player.has_method("start_attack"):
		player.start_attack()
	var target = _get_closest_target()
	if target:
		_apply_highlight(target)
		_highlighted_target = target

func _deactivate():
	if _is_aiming and is_instance_valid(_highlighted_target):
		_perform_bite(_highlighted_target)
		
	if is_instance_valid(_highlighted_target):
		_remove_highlight(_highlighted_target)
	_highlighted_target = null
	
	_is_aiming = false
	if player.has_method("release_attack"):
		player.release_attack()
	super()
	
func _perform_bite(closest_body: Node3D):
	if not is_instance_valid(closest_body):
		return
	var target_pos = closest_body.global_position
	
	if closest_body.is_in_group("monster"):
		print("Biting monster")
		closest_body.die()
		await _bite(closest_body)
		monster_manager._capture_monster()
	elif closest_body.is_in_group("npc"):
		print("Biting npc")
		closest_body.die()
		await _bite(closest_body)
		GameManager.add_paranoia(bite_paranoia_penalty)
		_spawn_blood(target_pos)
		closest_body.queue_free()
	elif closest_body.is_in_group("evidence_body"):
		print("Biting corpse")
		await _bite(closest_body)
		GameManager.remove_paranoia(bite_paranoia_penalty)
		_spawn_blood(target_pos)
		if is_instance_valid(closest_body):
			closest_body.queue_free()

func _spawn_blood(spawn_pos: Vector3):
	if blood_explosion_scene:
		var blood = blood_explosion_scene.instantiate()
		get_tree().current_scene.add_child(blood)
		blood.global_position = spawn_pos + Vector3(0, 0.3, 0)
		
func _bite(body: Node3D):	
	# Bite Animation
	bite_sprite = bite_sprite_obj.instantiate()
	get_tree().current_scene.add_child(bite_sprite)
	bite_sprite.global_transform.origin = body.global_transform.origin + Vector3(0, 0.3, 0)
	
	if bite_sprite is AnimatedSprite3D:
		bite_sprite.play("default") # (Change "default" to your actual animation name)
		await bite_sprite.animation_finished
	else:
		print("bite is not animatedsprite3d")
		
func _stop_death_animation():
	sprite.stop()
	sprite.frame = sprite.sprite_frames.get_frame_count("die") - 1
	
