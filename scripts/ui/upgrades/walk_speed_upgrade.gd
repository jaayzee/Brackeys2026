extends Upgrade

@export var upgrade_amount := 0.1

func _ready() -> void:
	super()

func buy_upgrade():
	super()
	
func apply_upgrade():
	super()
	var upgraded_speed = GameManager.player_speed + upgrade_amount
	GameManager.set_player_speed(upgraded_speed)
