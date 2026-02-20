extends Node3D

var monsters: Array = []
var monster_sprites: Array = []
@export var monster_quota := 0
@export var monster_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monsters = get_children()
	if monsters.size() > 0:
		for monster in monsters:
			monster_sprites.append(monster.get_node("AnimatedSprite3D"))
	else:
		print("NO MONSTERS: ADD MONSTERS TO SCENE")
	
func _enable_blood():
	for sprite in monster_sprites:
		sprite.modulate = Color(255, 0, 0)

func _disable_blood():
	for sprite in monster_sprites:
		sprite.modulate = Color(255, 255, 255)
		
func _capture_monster():
	monster_count += 1
	print("Captured a Monster")
	
	if monster_count >= monster_quota:
		print("You Win")
		#GameManager._completed_level()
