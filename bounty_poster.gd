extends Area3D

var can_interact := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_interact && Input.is_action_just_pressed("interact"):
		GameManager.enter_night()

func _on_body_entered(body: Node3D) -> void:
	can_interact = true
func _on_body_exited(body: Node3D) -> void:
	can_interact = false
