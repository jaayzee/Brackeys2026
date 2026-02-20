extends Node

@export var money := 500
@export var reward_money := 500 # Changes depending on level
@export var total_time := 0
@export var time_remaining := 0
var player_ui

func _ready() -> void:
	player_ui = get_node_or_null("player_ui")
	
func _process(delta: float) -> void:
	time_remaining = Time.get_ticks_msec() / 1000
	if player_ui:
		player_ui.get_node("timer").text = "Time: " + str(time_remaining)
	
func add_money(amount: int):
	money += amount
	print("Money: " + str(money))
	
func clear_money():
	money = 0
	
func _completed_level():
	print("Completed Level!")
	add_money(reward_money)
	if player_ui:
		player_ui.get_node("money").text = "Money: " + str(money)
		
	get_tree().change_scene_to_file("res://scenes/game_scenes/completed_level_menu.tscn")
