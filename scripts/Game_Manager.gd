extends Node

@export var reward_money := 500 # Changes depending on level
@export var total_time := 360
@export var max_paranoia := 100
@export var paranoia_reset_time := 3

@export var base_drain_rate := 1.0

var time_remaining := 0
var current_paranoia : float = 0.0
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
@export var blood_paranoia_rate := 0.05

## UI
var player_ui_obj = preload("res://scenes/ui/player_ui.tscn")
var lose_screen_obj = preload("res://scenes/ui/you_lose_screen.tscn")
var completed_level_obj = preload("res://scenes/game_scenes/completed_level_menu.tscn")
var player_ui
var lose_screen
var completed_level
var player
var screen_shader
var monster_manager

# Audio
var audio_btn_obj = preload("res://scenes/audio_click.tscn")
var audio_btn

func _ready() -> void:
	print("Game Manager Ready")
	player_ui = player_ui_obj.instantiate()
	lose_screen = lose_screen_obj.instantiate()
	completed_level = completed_level_obj.instantiate()
	player = get_tree().get_first_node_in_group("player")
	screen_shader = get_tree().get_first_node_in_group("screen_shader")
	monster_manager = get_tree().get_first_node_in_group("monster_manager")
	
	add_child(player_ui)
	add_child(lose_screen)
	add_child(completed_level)
	player_ui.visible = false
	lose_screen.visible = false
	completed_level.visible = false
	
	# Audio
	audio_btn = audio_btn_obj.instantiate()
	add_child(audio_btn)
	
func _process(delta: float) -> void:
	# Game Timer & Paranoia
	time_remaining = Time.get_ticks_msec() / 1000
	time_remaining = total_time - time_remaining
	if time_remaining <= 0:
		lose_game()
	
	current_paranoia -= base_drain_rate * delta
	
	# paranoia contributors
	var bodies = get_tree().get_nodes_in_group("evidence_body").size()
	var bloods = get_tree().get_nodes_in_group("evidence_blood").size()
	
	var penalty = (bodies * body_paranoia_rate) + (bloods * blood_paranoia_rate)
	current_paranoia += penalty * delta
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)
	if current_paranoia >= max_paranoia and not is_paranoia_full:
		print("MAX PARANOIA")
		lose_game()
		
	_check_paranoia()
	if is_paranoia_full:
		lose_game()
	
	if player_ui:
		player_ui.get_node("timer").text = "Time: " + str(int(time_remaining))
		
		var p_bar = player_ui.get_node_or_null("MarginContainer/ParanoiaBar")
		if p_bar:
			p_bar.value = current_paranoia
			
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
		
	# Lose Debug
	if Input.is_action_just_pressed("escape"):
		lose_game()
	elif Input.is_action_just_pressed("ui_focus_next"): #Tab
		win_level()

func add_money(amount: int):
	money += amount
	print("Money: " + str(money))
	
func win_level():
	current_level += 1
	print("Completed Level: Now on " + str(current_level))
	add_money(reward_money)
	player_ui.visible = false
	completed_level.visible = true
	#completed_level.get_node("gold").text = str(reward_money) + " Gold"
	
	#get_tree().change_scene_to_file("res://scenes/game_scenes/completed_level_menu.tscn")

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
	if is_paranoia_full: lose_game()
	
	current_paranoia += amount
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)
	_check_paranoia()

func remove_paranoia(amount: float):
	if is_paranoia_full: lose_game()
	
	current_paranoia -= amount
	current_paranoia = clamp(current_paranoia, 0.0, max_paranoia)

func _reset_paranoia():
	current_paranoia = 0
	is_paranoia_full = false
	
func _reset_timer():
	time_remaining = total_time
	
func lose_game():
	_reset_paranoia()
	money = 0
	current_level = 0
	lose_screen.visible = true
	get_tree().paused = true
	
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
	print("Entered day")
	change_scene(true, false, true)
func enter_night():
	get_tree().change_scene_to_file("res://scenes/game_scenes/mainmap.tscn") # CHANGE TO NIGHT
	await get_tree().process_frame
	print("Entered night")
	change_scene(false, true, true)
func enter_start():
	get_tree().change_scene_to_file("res://scenes/game_scenes/start.tscn")
	await get_tree().process_frame
	print("Enter start")
	change_scene(true, true, false)
	
func change_scene(is_it_day: bool, rain_on: bool, is_ui_visible: bool):
	is_day = is_it_day
	if rain_on: enable_rain()
	else: disable_rain()
	
	_reset_timer()
	if is_ui_visible: player_ui.visible = true
	else: player_ui.visible = false
	lose_screen.visible = false
	completed_level.visible = false
	get_tree().paused = false
	
# Debugging method
func reattach_nodes():
	player = get_tree().get_first_node_in_group("player")
	screen_shader = get_tree().get_first_node_in_group("screen_shader")
	monster_manager = get_tree().get_first_node_in_group("monster_manager")
	
# Upgradeable Stats
func set_player_speed(amount: float):
	player_speed = amount
	player.set_speed(player_speed)
func set_body_paranoia_rate(amount: float):
	body_paranoia_rate = amount
func set_blood_paranoia_rate(amount: float):
	blood_paranoia_rate = amount
	
func click_sfx():
	audio_btn.play()
