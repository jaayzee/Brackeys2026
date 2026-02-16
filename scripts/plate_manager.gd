extends Node

@export var plate_obj: PackedScene
var plate_spawntime := 5.0
var plate_positions: Array[Vector3] = []
var plates: Array = []

# Creates plate arrays and sets positions
func _ready() -> void:
	# Get all possible plate positions
	var plate_slots = get_children()
	for slot in plate_slots:
		plate_positions.append(slot.transform.origin)
		plates.append(null)
		
	for i in range(plates.size()):
		_set_plate(i)
	
func _process(delta: float) -> void:
	pass

func _set_plate(seat: int):
	var plate = plate_obj.instantiate()
	plate._set_seat(seat)
	plates[seat] = plate
	# plate._set_cost(amount)
	
	add_child(plate)
	plate.global_transform.origin = plate_positions[seat]
	
func _free_plate(seat: int):
	plates[seat] = null
	
	# Start a timer to respawn the plate
	var t = Timer.new()
	t.wait_time = plate_spawntime
	add_child(t)
	t.start()
	t.timeout.connect(Callable(self, "_set_plate").bind(seat))

#timer
