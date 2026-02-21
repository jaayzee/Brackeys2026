extends Control

@export var upgrades : Array[PackedScene] = [] # Fill with Upgrades
var shop_upgrades : Array = []
var shop_size := 3

func _ready() -> void:
	_setup_shop()
	
func _setup_shop():
	# var random_vector3 = new Vector3(random,random,random)
	# shop_upgrades.append(upgrades[x]
	# shop_upgrades.append(upgrades[y]
	# shop_upgrades.append(upgrades[z]
	# rare upgrades? Idk
	# for 0->shop_size append stuff
	
	# determine this randomly ^
	for upgrade in upgrades:
		shop_upgrades.append(upgrade)
		
	for upgrade in shop_upgrades:
		var upgrade_card = upgrade.instantiate()
		add_child(upgrade_card)
	
	
func remove_upgrade():
	# queue_free() upgrade and clear that array slot
	pass
	
func _clear_shop():
	pass
	
func _exit_shop():
	# hit escape or click the button 
	pass
	
func _on_next_mission_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scenes/objective_menu.tscn")
