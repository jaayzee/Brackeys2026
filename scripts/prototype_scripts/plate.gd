extends Area3D

var plate_manager
var player_nearby: bool = false
var price := 10
var plate_seat

func _ready() -> void:
	plate_manager = get_parent()
	
func _on_body_entered(body: Node3D) -> void:
	player_nearby = true

func _on_body_exited(body: Node3D) -> void:
	player_nearby = false

func _process(delta: float) -> void:
	if player_nearby:
		if Input.is_action_just_pressed("Interact"):
			# Check if a parameter is fulfilled (Correct item?)
			GameManager.add_money(price)
			plate_manager._free_plate(plate_seat) # Tells the plate manager this seat is free to start a timer
			
			queue_free()
			
func _set_seat(seat: int):
	plate_seat = seat
