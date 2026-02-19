extends Node3D

# var abilities: Array = []
# Inital list of abilities
@export var shadow_step : PackedScene
var shadow_step_ab
@export var blood_lust : PackedScene
var blood_lust_ab
@export var vampiric_bite : PackedScene
var vampiric_bite_ab
# 3 core abilities that you can upgrade and improve on 
# abilities have a name, effect, bool if its activated, and levels (scope)

# var passives
var player
var monster_manager

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	monster_manager = get_tree().get_first_node_in_group("monster_manager")
	
	# Shadow_step
	shadow_step_ab = shadow_step.instantiate()
	add_child(shadow_step_ab)
	shadow_step_ab.player = player
	shadow_step_ab.monster_manager = monster_manager
	
	# Blood_lust
	blood_lust_ab = blood_lust.instantiate()
	add_child(blood_lust_ab)
	blood_lust_ab.player = player
	blood_lust_ab.monster_manager = monster_manager
	
	# Vampiric_bite
	vampiric_bite_ab = vampiric_bite.instantiate()
	add_child(vampiric_bite_ab)
	vampiric_bite_ab.player = player
	vampiric_bite_ab.monster_manager = monster_manager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Manages input
	if Input.is_action_just_pressed("Ability1"):
		shadow_step_ab._activate()
	elif Input.is_action_just_pressed("Ability2"):
		blood_lust_ab._activate()
	elif Input.is_action_just_pressed("Ability3"):
		vampiric_bite_ab._activate()
	
