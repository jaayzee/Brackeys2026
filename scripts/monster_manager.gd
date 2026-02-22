extends Node3D

@export var monster_obj : PackedScene
var monsters: Array = []
var monster_sprites: Array = []
var monster_spawnpoints: Array = []
@export var monster_quota := 0
@export var monsters_captured := 0
@export var easiness_factor := 5 # 10 is easy, 1 is hard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_monsters()
	
	#if monsters.size() > 0:
		#for monster in monsters:
			#monster_sprites.append(monster.get_node("AnimatedSprite3D"))
	#else:
		#print("NO MONSTERS: ADD MONSTERS TO SCENE")

func _spawn_monsters():
	if !monster_spawnpoints:
		return
		
	monster_quota = GameManager.current_level / 3 + 1
	monster_quota = ((1/easiness_factor) * (GameManager.current_level * GameManager.current_level)) + 1
	monster_spawnpoints = $monster_spawnpoints.get_children()
	
	for i in range(monster_quota):
		var rand_int = randi() % monster_spawnpoints.size()
		var monster = monster_obj.instantiate()
		monsters.append(monster)
		add_child(monster)
		monster.global_transform.origin = monster_spawnpoints[rand_int].global_transform.origin
		print("SPAWNED MONSTER")
	
# ARCHIVED
func _enable_blood():
	return
	for sprite in monster_sprites:
		sprite.modulate = Color(255, 0, 0)

# ARCHIVED
func _disable_blood():
	return
	for sprite in monster_sprites:
		sprite.modulate = Color(255, 255, 255)
		
func _capture_monster():
	monsters_captured += 1
	print("Captured a Monster")
	
	if monsters_captured >= monster_quota:
		GameManager.win_level()
