extends Control

@export var upgrades : Array[PackedScene] = [] # Fill with Upgrades
var shop_upgrades : Array = []
var shop_size := 3

@onready var upgrade_container = $upgrade_container
@onready var money = $money

func _ready() -> void:
	_setup_shop()
	
func _setup_shop():
	# Randomly select upgrades
	var last_rand_int = -1
	for i in range(shop_size):
		var rand_int = randi() % upgrades.size() # Random index in upgrades array
		if rand_int != last_rand_int: 
			shop_upgrades.append(upgrades[rand_int])
	
	# Display upgrades
	for upgrade in shop_upgrades:
		var upgrade_card = upgrade.instantiate()
		upgrade_container.add_child(upgrade_card)
		upgrade_card.shop = get_node(".")
		
	money.text = str(GameManager.money)
	
func remove_upgrade():
	# queue_free() upgrade and clear that array slot
	pass
	
func _clear_shop():
	shop_upgrades.clear()
	
func _exit_shop():
	# hit escape or click the button 
	pass
	
func _on_next_mission_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/game_scenes/objective_menu.tscn")
	#visible = false
	visible = false
	GameManager.enter_night()
