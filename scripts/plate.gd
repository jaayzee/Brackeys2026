extends Area3D

var player_nearby: bool = false

func _on_body_entered(body: Node3D) -> void:
	# print("Entered plate area")
	player_nearby = true
	# if you hit a certain button (E) to interact -> and it fills a certain requirement then give money
	pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	player_nearby = false
	pass # Replace with function body.

func _process(delta: float) -> void:
	if player_nearby:
		print("PLAYER CAN INTERACT")
		if Input.is_action_just_pressed("Interact"):
			# Check if a parameter is fulfilled (Correct item?)
			print()
	pass
