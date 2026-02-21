extends Node
class_name Upgrade

@export var up_name := "basic_upgrade"
@export var up_description := "basic description"
@export var up_cost := 0
@export var up_img := Texture

@onready var card_title = $card_title
@onready var card_text = $card_text
@onready var card_img = $card_img
@onready var card_cost = $card_cost
var shop
var is_bought = false

func _ready() -> void:
	card_title.text = up_name
	card_text.text = up_description
	card_cost.text = str(up_cost)
	card_img.texture = up_img
	
func _on_button_pressed() -> void:
	buy_upgrade()
	
func buy_upgrade():
	if GameManager.money < up_cost:
		print("Credit Card Declined: your broke & chopped")
		return
	elif is_bought:
		return
		
	print("Purchased: " + up_name)
	GameManager.add_money(-up_cost)
	get_node(".").modulate = Color(1,1,1, 0)
	is_bought = true
	
	apply_upgrade()
	
func apply_upgrade():
	# Actually do the effect of the upgrade here
	
	pass
