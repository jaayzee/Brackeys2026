extends Node3D

@export var ability_scenes: Array[PackedScene] = []
var abilities: Array = []

# var passives
var player
var monster_manager
var player_ui

# Audio
@onready var audio_stream_bite = $audio_bite
@onready var audio_shadow: AudioStreamPlayer = $audio_shadow

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	monster_manager = get_tree().get_first_node_in_group("monster_manager")
	player_ui = get_tree().get_first_node_in_group("player_ui")
	
	for ability in ability_scenes:
		var ability_obj = ability.instantiate()
		abilities.append(ability_obj)
		add_child(ability_obj)
		ability_obj.player = player
		ability_obj.monster_manager = monster_manager
	
	print(ability_scenes.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.is_paranoia_full:
		# Deactivate all abilities
		# is unlocked = false
		pass
		
	if Input.is_action_just_pressed("Ability1"):
		abilities[0]._activate()
		abilities[3]._activate()
		var ability1_label = player_ui.get_node("VBoxContainer/ability1")
		ability1_label.modulate = Color(1, 1, 1, 1)
		audio_shadow.play()
	elif Input.is_action_just_released("Ability1"):
		abilities[0]._deactivate()
		abilities[3]._deactivate()
		audio_shadow.stop()
		
	if Input.is_action_just_pressed("Ability2"):
		abilities[1]._activate()
		var ability2_label = player_ui.get_node("VBoxContainer/ability2")
		ability2_label.modulate = Color(1, 1, 1, 1)
	elif Input.is_action_just_released("Ability2"):
		abilities[1]._deactivate()
		
	if Input.is_action_just_pressed("Ability3"):
		abilities[2]._activate()
		var ability3_label = player_ui.get_node("VBoxContainer/ability3")
		ability3_label.modulate = Color(1, 1, 1, 1)
		#audio_stream_bite.play()
	elif Input.is_action_just_released("Ability3"):
		abilities[2]._deactivate()
	# Checks if NPC is near while using an ability
	for ability in abilities:
		if ability.ab_is_active:
			if (player._get_near_npcs().size() >= 1):
				GameManager.add_paranoia(ability.paranoia_rate)
		
func _reset_UI():
	var ability_container = player_ui.get_node("VBoxContainer")
	for ability in ability_container.get_children():
		ability.modulate = Color(1,1,1, .25)
		
func upgrade_ability(ability_index: int):
	abilities[ability_index].ab_level += 1
