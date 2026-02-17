extends Ability

var speed_boost := 1.50

func _ready() -> void:
	ab_name = "Shadow Step"
	ab_is_unlocked = false
	ab_is_active = false
	ab_level = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _activate():
	player._boost_speed(speed_boost)
	print("activated ability in shadowstep")
	
