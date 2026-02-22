extends Area3D

var can_shop := false
var shop

func _ready() -> void:
	shop = get_node_or_null("shop_menu")
	
func _process(delta: float) -> void:
	# Would like to change to GameManager or Player one time, avoid splitting inputs in scripts
	if shop:
		# Enable shop
		if can_shop && Input.is_action_just_pressed("interact"):
			if !shop.visible:
				shop.visible = true
			else:
				shop.visible = false
		elif !can_shop:
			shop.visible = false
			
		# Disable shop with escape
		if shop.visible && Input.is_action_just_pressed("escape"):
			shop.visible = false

func _on_body_entered(body: Node3D) -> void:
	print("Entered shop")
	can_shop = true

func _on_body_exited(body: Node3D) -> void:
	print("Exited shop")
	can_shop = false
