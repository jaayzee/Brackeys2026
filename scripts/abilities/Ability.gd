extends Node
class_name Ability

# abilities have a name, effect, bool if its activated, and levels (scope)
@export var ab_name := ""
@export var ab_is_unlocked := false # Unlocked
@export var ab_is_active := false # Is using
@export var ab_level := 0
@export var duration := 0.0
@export var paranoia_rate := 0.0

var player
var monster_manager

func _ready() -> void:
	pass

# Called by the ability_manager when the correct input is pressed
func _activate():
	print("Activated: " + ab_name)
	ab_is_active = true

func _deactivate():
	print("Deactivated: " + ab_name)
	ab_is_active = false
	get_parent()._reset_UI()
	
func _start_timer():
	# Start a timer 
	var t = Timer.new()
	t.wait_time = duration
	add_child(t)
	t.start()
	t.one_shot = true
	t.timeout.connect(Callable(self, "_deactivate"))
