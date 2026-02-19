extends Control

func _on_continue_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scenes/main_day.tscn")
