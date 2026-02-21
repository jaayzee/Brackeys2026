extends Node2D

var target_node: Node3D
var camera: Camera3D

func _ready():
	print("arrow at: ", target_node)
	if not camera:
		print("arrow no camera")

	var outline = Line2D.new()
	var poly = $Polygon2D
	
	outline.points = poly.polygon
	outline.closed = true
	outline.width = 1.0
	outline.default_color = Color.WHITE
	
	outline.show_behind_parent = true 
	
	poly.add_child(outline)

func _process(_delta):
	if not camera: return
	
	if not is_instance_valid(target_node):
		queue_free()
		return
		
	var target_position = target_node.global_position
	
	var screen_size = get_viewport().get_visible_rect().size 
	var screen_pos = camera.unproject_position(target_position)
	
	if camera.is_position_behind(target_position):
		screen_pos = Vector2(screen_size.x / 2, screen_size.y)
	
	var margin = 100.0
	var bounds = Rect2(margin, margin, screen_size.x - margin*2, screen_size.y - margin*2)
	
	var base_pos = Vector2.ZERO
	
	if bounds.has_point(screen_pos) and not camera.is_position_behind(target_position):
		# on screen
		base_pos = screen_pos + Vector2(0, -75) 
		rotation = deg_to_rad(90)
	else:
		# off screen
		base_pos.x = clamp(screen_pos.x, margin, screen_size.x - margin)
		base_pos.y = clamp(screen_pos.y, margin, screen_size.y - margin)
		
		var center = screen_size / 2.0
		var dir = (base_pos - center).normalized()
		rotation = dir.angle()

	# bounce
	var bounce_amount = sin(Time.get_ticks_msec() * 0.008) * 10.0
	
	# Vector2.RIGHT is arrow forward, use for bounce
	var bounce_vector = Vector2.RIGHT.rotated(rotation) * bounce_amount
	
	position = base_pos + bounce_vector
