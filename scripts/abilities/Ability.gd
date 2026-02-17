extends Node
class_name Ability

# abilities have a name, effect, bool if its activated, and levels (scope)
var ab_name := ""
var ab_is_unlocked := false # Unlocked
var ab_is_active := false # Is using
var ab_level := 0
var player

# Called by the ability_manager when the correct input is pressed
func _activate():
	pass
	
func _get_player():
	player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	pass
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
