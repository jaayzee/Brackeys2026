extends Control

func _on_begin_pressed() -> void:
	visible = false
	GameManager.first_time = false
	GameManager.player_ui.visible = true
