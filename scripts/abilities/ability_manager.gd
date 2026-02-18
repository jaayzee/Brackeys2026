extends Node3D

# var abilities: Array = []
# Inital list of abilities
@export var shadow_step : PackedScene
var shadow_step_ab
# 3 core abilities that you can upgrade and improve on 
# abilities have a name, effect, bool if its activated, and levels (scope)

# var passives
var player

func _ready() -> void:
	player = get_parent()
	shadow_step_ab = shadow_step.instantiate()
	add_child(shadow_step_ab)
	shadow_step_ab.player = player
	print("Instantiated Player:")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Manages input
	if Input.is_action_just_pressed("Interact"):
		print("Trying to start ability")
		shadow_step_ab._activate()
