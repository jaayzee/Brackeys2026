extends Node
class_name Upgrade

@export var up_name := "basic_upgrade"
@export var up_cost := 0

func _on_button_pressed() -> void:
	buy_upgrade()
	
func buy_upgrade():
	print("Purchased: " + up_name)
	GameManager.add_money(-up_cost)
	
func apply_upgrade():
	# Actually do the effect of the upgrade here
	
	pass
