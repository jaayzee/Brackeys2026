extends Ability

@export var blood_lust_particles : PackedScene
var blood_particles: Array = []
@export var particle_offset: Vector3

@export var blood_stain_obj : PackedScene
var blood_stains : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blood_stains = get_tree().get_nodes_in_group("blood")
	for blood in blood_stains:
		blood.visible = false
		
	# to add blood_stains
	# spawn one when an npc dies, in npc.die() -> spawn a blood stain at feet?
	# add ones every 2 second interval at the monsters feet AFTER he kills an NPC

func _activate():
	super()
	monster_manager._enable_blood()
	
	blood_particles = []
	for monster in monster_manager.monsters:
		var particles = blood_lust_particles.instantiate()
		blood_particles.append(particles)
		monster.add_child(particles)
		particles.global_transform.origin = monster.global_transform.origin + particle_offset
	
	if !blood_stains.is_empty():
		for blood in blood_stains:
			blood.visible = true
	
func _deactivate():
	super()
	monster_manager._disable_blood()
	
	for particle in blood_particles:
		if particle:
			particle.queue_free()
			
	if !blood_stains.is_empty():
		for blood in blood_stains:
			blood.visible = false
