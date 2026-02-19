extends Node3D

var monsters: Array = []
var monster_sprites: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#monster_sprites = get_children()
	monsters = get_children()
	for monster in monsters:
		monster_sprites.append(monster.get_node("AnimatedSprite3D"))

func _enable_blood():
	for sprite in monster_sprites:
		sprite.modulate = Color(255, 0, 0)

func _disable_blood():
	for sprite in monster_sprites:
		sprite.modulate = Color(255, 255, 255)
