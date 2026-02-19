extends Control

func _on_next_mission_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scenes/objective_menu.tscn")
