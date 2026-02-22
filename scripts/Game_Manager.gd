extends Node

@export var reward_money := 500 # Changes depending on level
@export var total_time := 360
@export var max_paranoia := 100
@export var paranoia_reset_time := 3

var time_remaining := 0
var current_paranoia := 0
var is_paranoia_full = false
var is_day = false

## Levels
var current_level := 0

## Shop
var money := 50
var can_shop := false
# Upgradeable stats
@export var player_speed = 1
@export var body_paranoia_rate := 1.0
@export var blood_paranoia_rate := 0.1

## UI
var player_ui
var player
var screen_shader

func _ready() -> void:
	print("Game Manager Ready")
	player_ui = get_tree().get_first_node_in_group("player_ui")
	player = get_tree().get_first_node_in_group("player")
	screen_shader = get_tree().get_first_node_in_group("screen_shader")
	
func _process(delta: float) -> void:
	# Game Timer & Paranoia
	time_remaining = Time.get_ticks_msec() / 1000
	time_remaining = total_time - time_remaining
	
	current_paranoia -= delta # Lowkey change from delta since it probably is FPS dependent
	
	# paranoia contributors
	var bodies = get_tree().get_nodes_in_group("evidence_body").size()
	var bloods = get_tree().get_nodes_in_group("evidence_blood").size()
	
	var penalty = (bodies * body_paranoia_rate) + (bloods * blood_paranoia_rate)
	current_paranoia += penalty * delta
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)
	if current_paranoia >= max_paranoia and not is_paranoia_full:
		print("MAX PARANOIA")
		
	# Set UI
	if player_ui:
		player_ui.get_node("timer").text = "Time: " + str(time_remaining)
		player_ui.get_node("money").text = "Money: " + str(money)
		player_ui.get_node("paranoia").text = "Paranoia: " + str(current_paranoia)
		
	# This is so fucked up if this adds to performance shoot me (GET RID OF  SOMETIME)
	reattach_nodes() 
	if is_day:
		disable_rain()
	else:
		enable_rain()
	
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

func _add_paranoia(amount: int):
	current_paranoia += amount
	if current_paranoia >= max_paranoia:
		is_paranoia_full = true
		
		var t = Timer.new()
		t.wait_time = paranoia_reset_time
		add_child(t)
		t.start()
		t.one_shot = true
		t.timeout.connect(Callable(self, "_reset_paranoia"))

func _reset_paranoia():
	current_paranoia = 0
	is_paranoia_full = false
	
func disable_rain():
	screen_shader = get_tree().get_first_node_in_group("screen_shader")
	if screen_shader:
		screen_shader.get_active_material(0).set("shader_parameter/rain_enabled", false)
		
func enable_rain():
	screen_shader = get_tree().get_first_node_in_group("screen_shader")
	if screen_shader:
		screen_shader.get_active_material(0).set("shader_parameter/rain_enabled", true)

# Scene Management
func enter_day():
	get_tree().change_scene_to_file("res://scenes/game_scenes/day.tscn")
	await get_tree().process_frame
	
	is_day = true
	disable_rain()
	print("Entered day")
func enter_night():
	get_tree().change_scene_to_file("res://scenes/game_scenes/mainmap.tscn") # CHANGE TO NIGHT
	await get_tree().process_frame
	
	is_day = false
	enable_rain()
	print("Entered night")
func enter_start():
	get_tree().change_scene_to_file("res://scenes/game_scenes/start.tscn")
	await get_tree().process_frame
	
	is_day = true
	enable_rain()
	
# Debugging method
func reattach_nodes():
	player_ui = get_tree().get_first_node_in_group("player_ui")
	player = get_tree().get_first_node_in_group("player")
	screen_shader = get_tree().get_first_node_in_group("screen_shader")
	
# Upgradeable Stats
func set_player_speed(amount: float):
	player_speed = amount
	player.set_speed(player_speed)
func set_body_paranoia_rate(amount: float):
	body_paranoia_rate = amount
func set_blood_paranoia_rate(amount: float):
	blood_paranoia_rate = amount
