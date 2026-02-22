extends Upgrade

@export var upgrade_amount := 0.2

func _ready() -> void:
	super()

func buy_upgrade():
	super()
	
func apply_upgrade():
	super()
	var lowered_blood_paranoia = GameManager.body_paranoia_rate - upgrade_amount
	# Add cap?
	GameManager.set_body_paranoia_rate(lowered_blood_paranoia)
