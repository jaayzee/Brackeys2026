extends Control

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	player.rotate_cam(delta)
	
func _on_play_btn_pressed() -> void:
	GameManager.click_sfx()
	GameManager.enter_day()

func _on_quit_btn_pressed() -> void:
	GameManager.click_sfx()
	get_tree().quit()
