extends Ability

@export var drink_range := 0.5

@export var suck_duration := 0.3

func _ready() -> void:
	ab_name = "Drink Blood"
	ab_is_unlocked = true 
	ab_is_active = false
	ab_level = 0
	duration = 1.0

func _activate():
	super()
	ab_is_active = true
	player.disable_ghosts = true

func _process(_delta: float) -> void:
	# If we aren't holding the button, do nothing
	if not ab_is_active: return
	
	var bloods = get_tree().get_nodes_in_group("evidence_blood")
	var drank_any = false
	
	for b in bloods:
		if is_instance_valid(b):
			if player.global_position.distance_to(b.global_position) <= drink_range:
				_suck_blood(b)
				GameManager.remove_paranoia(1.0)
				drank_any = true
				
	if drank_any:
		print("blood drank")

func _suck_blood(blood_node: Node3D):
	blood_node.remove_from_group("evidence_blood")
	
	var tween = get_tree().create_tween()
	
	# ease in
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	
	# player center parget
	var target_pos = player.global_position + Vector3(0, 0, 0)
	
	# animate
	tween.parallel().tween_property(blood_node, "global_position", target_pos, suck_duration)
	tween.parallel().tween_property(blood_node, "scale", Vector3.ZERO, suck_duration)	
	# delete on reaching player
	tween.tween_callback(blood_node.queue_free)
	
func _deactivate():
	super()
	ab_is_active = false
	player.disable_ghosts = false
