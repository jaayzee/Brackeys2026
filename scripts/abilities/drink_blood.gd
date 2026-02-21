extends Ability

@export var drink_range := 0.5

func _ready() -> void:
	ab_name = "Drink Blood"
	ab_is_unlocked = true 
	ab_is_active = false
	ab_level = 0
	duration = 1.0

func _activate():
	super()
	ab_is_active = true

func _process(_delta: float) -> void:
	# If we aren't holding the button, do nothing
	if not ab_is_active: return
	
	var bloods = get_tree().get_nodes_in_group("evidence_blood")
	var drank_any = false
	
	for b in bloods:
		if is_instance_valid(b):
			if player.global_position.distance_to(b.global_position) <= drink_range:
				b.queue_free()
				drank_any = true
				
	if drank_any:
		print("blood drank")

func _deactivate():
	super()
	ab_is_active = false
