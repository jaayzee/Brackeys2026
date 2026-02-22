extends Node

@export var reward_money := 500 # Changes depending on level
@export var total_time := 360
@export var max_paranoia := 100
@export var paranoia_reset_time := 3

@export var base_drain_rate := 1.0
@export var body_paranoia_rate := 1.0
@export var blood_paranoia_rate := 0.1

var time_remaining := 0
var current_paranoia : float = 0.0
var is_paranoia_full = false

## Shop
var money := 0

# Upgradeable stats
@export var player_speed = 1

var player_ui

func _ready() -> void:
	print("Game Manager Ready")
	player_ui = get_tree().get_first_node_in_group("player_ui")
	
func _process(delta: float) -> void:
	# Game Timer & Paranoia
	time_remaining = Time.get_ticks_msec() / 1000
	time_remaining = total_time - time_remaining
	
	current_paranoia -= base_drain_rate * delta
	
	# paranoia contributors
	var bodies = get_tree().get_nodes_in_group("evidence_body").size()
	var bloods = get_tree().get_nodes_in_group("evidence_blood").size()
	
	var penalty = (bodies * body_paranoia_rate) + (bloods * blood_paranoia_rate)
	current_paranoia += penalty * delta
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)
	
	_check_paranoia()
	
	if player_ui:
		player_ui.get_node("timer").text = "Time: " + str(int(time_remaining))
		
		var p_bar = player_ui.get_node_or_null("ParanoiaBar")
		if p_bar:
			p_bar.value = current_paranoia
	
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

func _check_paranoia():
	if current_paranoia >= max_paranoia and not is_paranoia_full:
		print('MAX PARANOIA')
		is_paranoia_full = true
		
		var t = Timer.new()
		t.wait_time = paranoia_reset_time
		add_child(t)
		t.start()
		t.one_shot = true
		t.timeout.connect(Callable(self, "_reset_paranoia"))

func add_paranoia(amount: float):
	if is_paranoia_full: return 
	
	current_paranoia += amount
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)
	_check_paranoia()

func remove_paranoia(amount: float):
	if is_paranoia_full: return
	
	current_paranoia -= amount
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)

	
func _reset_paranoia():
	current_paranoia = 0
	is_paranoia_full = false
	
func get_player_speed():
	return player_speed
