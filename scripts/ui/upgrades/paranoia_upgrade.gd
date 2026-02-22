extends Upgrade

@export var upgrade_amount := 0.01

func _ready() -> void:
	super()

func buy_upgrade():
	super()
	
func apply_upgrade():
	super()
	var lowered_blood_paranoia = GameManager.blood_paranoia_rate - upgrade_amount
	GameManager.set_blood_paranoia_rate(lowered_blood_paranoia)
