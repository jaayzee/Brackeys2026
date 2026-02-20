@tool
extends EditorPlugin

var _toolbar : HBoxContainer
var _erase_button : Button
var _cut_button : Button
var _undo_button : Button
var _status_label : Label

var _is_drawing := false
var _rect_start := Vector2.ZERO
var _rect_end := Vector2.ZERO
var _erase_mode := false
var _cut_mode := false
var _selected_nav_region : NavigationRegion3D = null
var _undo_redo : EditorUndoRedoManager = null
var _draw_overlay : Control = null

func _enter_tree():
	_undo_redo = get_undo_redo()
	_build_toolbar()
	get_editor_interface().get_selection().connect("selection_changed", _on_selection_changed)

func _exit_tree():
	if _toolbar:
		_toolbar.queue_free()
	_remove_overlay()
	if get_editor_interface().get_selection().is_connected("selection_changed", _on_selection_changed):
		get_editor_interface().get_selection().disconnect("selection_changed", _on_selection_changed)

func _handles(object) -> bool:
	return object is NavigationRegion3D

func _edit(object):
	if object is NavigationRegion3D:
		_selected_nav_region = object
		if _status_label:
			_status_label.text = "Ready | %s" % object.name

func _make_visible(visible: bool):
	if _toolbar:
		_toolbar.visible = visible

func _build_toolbar():
	_toolbar = HBoxContainer.new()
	var sep = VSeparator.new()
	_toolbar.add_child(sep)
	var label = Label.new()
	label.text = "NavMesh Eraser:"
	_toolbar.add_child(label)

	_erase_button = Button.new()
	_erase_button.text = "✏ Erase"
	_erase_button.toggle_mode = true
	_erase_button.connect("toggled", _on_erase_toggled)
	_toolbar.add_child(_erase_button)

	_cut_button = Button.new()
	_cut_button.text = "✂ Cut"
	_cut_button.toggle_mode = true
	_cut_button.connect("toggled", _on_cut_toggled)
	_toolbar.add_child(_cut_button)

	_undo_button = Button.new()
	_undo_button.text = "↩ Undo"
	_undo_button.connect("pressed", _on_undo_pressed)
	_toolbar.add_child(_undo_button)

	_status_label = Label.new()
	_status_label.text = "Select a NavigationRegion3D"
	_status_label.custom_minimum_size = Vector2(280, 0)
	_toolbar.add_child(_status_label)

	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _toolbar)

func _add_overlay(color: Color):
	_remove_overlay()
	var vp = _find_3d_viewport()
	var parent = vp if vp else get_editor_interface().get_base_control()
	_draw_overlay = _OverlayControl.new()
	_draw_overlay.rect_color = color
	_draw_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draw_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(_draw_overlay)

func _find_3d_viewport() -> Control:
	return _search_for_viewport(get_editor_interface().get_base_control())

func _search_for_viewport(node: Node) -> Control:
	if node.get_class() == "Node3DEditorViewport":
		return node as Control
	for child in node.get_children():
		var result = _search_for_viewport(child)
		if result:
			return result
	return null

func _remove_overlay():
	if _draw_overlay:
		_draw_overlay.queue_free()
		_draw_overlay = null

func _on_erase_toggled(pressed: bool):
	if pressed:
		_cut_mode = false
		_cut_button.button_pressed = false
		if _selected_nav_region:
			_erase_mode = true
			_erase_button.text = "✅ Drag to erase..."
			_status_label.text = "Erase: removes polygons touching rectangle"
			_add_overlay(Color(1, 0.2, 0.2))
		else:
			_erase_button.button_pressed = false
			_status_label.text = "⚠ Select a NavigationRegion3D first!"
	else:
		_erase_mode = false
		_erase_button.text = "✏ Erase"
		_remove_overlay()

func _on_cut_toggled(pressed: bool):
	if pressed:
		_erase_mode = false
		_erase_button.button_pressed = false
		if _selected_nav_region:
			_cut_mode = true
			_cut_button.text = "✅ Drag to cut..."
			_status_label.text = "Cut: clips polygons cleanly at rectangle boundary"
			_add_overlay(Color(0.2, 0.6, 1.0))
		else:
			_cut_button.button_pressed = false
			_status_label.text = "⚠ Select a NavigationRegion3D first!"
	else:
		_cut_mode = false
		_cut_button.text = "✂ Cut"
		_remove_overlay()

func _on_undo_pressed():
	_undo_redo.undo()

func _on_selection_changed():
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	for node in selected:
		if node is NavigationRegion3D:
			_selected_nav_region = node
			if _status_label:
				_status_label.text = "Ready | %s" % node.name
			return

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if (not _erase_mode and not _cut_mode) or not _selected_nav_region:
		return EditorPlugin.AFTER_GUI_INPUT_PASS

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_drawing = true
			_rect_start = event.position
			_rect_end = event.position
			if _draw_overlay:
				_draw_overlay.update_rect(_rect_start, _rect_end, true)
			return EditorPlugin.AFTER_GUI_INPUT_STOP
		else:
			if _is_drawing:
				_is_drawing = false
				_rect_end = event.position
				if _draw_overlay:
					_draw_overlay.update_rect(Vector2.ZERO, Vector2.ZERO, false)
				_process_rect(viewport_camera, _rect_start, _rect_end, _cut_mode)
				return EditorPlugin.AFTER_GUI_INPUT_STOP

	if event is InputEventMouseMotion and _is_drawing:
		_rect_end = event.position
		if _draw_overlay:
			_draw_overlay.update_rect(_rect_start, _rect_end, true)
		return EditorPlugin.AFTER_GUI_INPUT_STOP

	return EditorPlugin.AFTER_GUI_INPUT_PASS

# ─── POLYGON TOUCHES RECT CHECK ──────────────────────────────────────────────
func _polygon_touches_rect(poly_2d: Array, rect: Rect2) -> bool:
	var n = poly_2d.size()
	# Case 1: any vertex inside rect
	for p in poly_2d:
		if rect.has_point(p):
			return true
	# Case 2: any rect corner inside polygon
	for c in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		if _point_in_polygon(c, poly_2d):
			return true
	# Case 3: any edge of polygon crosses any edge of rect
	var rect_edges = [
		[rect.position, Vector2(rect.end.x, rect.position.y)],
		[Vector2(rect.end.x, rect.position.y), rect.end],
		[rect.end, Vector2(rect.position.x, rect.end.y)],
		[Vector2(rect.position.x, rect.end.y), rect.position]
	]
	for i in n:
		var a = poly_2d[i]
		var b = poly_2d[(i + 1) % n]
		for edge in rect_edges:
			if _segments_intersect(a, b, edge[0], edge[1]):
				return true
	return false

func _point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var n = polygon.size()
	var inside = false
	var j = n - 1
	for i in n:
		var pi = polygon[i]
		var pj = polygon[j]
		if ((pi.y > point.y) != (pj.y > point.y)) and \
			(point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = not inside
		j = i
	return inside

func _segments_intersect(a1: Vector2, a2: Vector2, b1: Vector2, b2: Vector2) -> bool:
	var d1 = a2 - a1
	var d2 = b2 - b1
	var cross = d1.x * d2.y - d1.y * d2.x
	if abs(cross) < 0.0001:
		return false
	var t = ((b1.x - a1.x) * d2.y - (b1.y - a1.y) * d2.x) / cross
	var u = ((b1.x - a1.x) * d1.y - (b1.y - a1.y) * d1.x) / cross
	return t >= 0.0 and t <= 1.0 and u >= 0.0 and u <= 1.0

# ─── MAIN PROCESS ─────────────────────────────────────────────────────────────
func _process_rect(camera: Camera3D, screen_start: Vector2, screen_end: Vector2, do_cut: bool):
	if not _selected_nav_region or not _selected_nav_region.navigation_mesh:
		_status_label.text = "No NavMesh! Bake first."
		return

	var rect = Rect2(
		Vector2(min(screen_start.x, screen_end.x), min(screen_start.y, screen_end.y)),
		Vector2(abs(screen_end.x - screen_start.x), abs(screen_end.y - screen_start.y))
	)
	if rect.size.length() < 5:
		_status_label.text = "Too small - draw a bigger rectangle"
		return

	var nav_mesh = _selected_nav_region.navigation_mesh
	var old_mesh = nav_mesh.duplicate()

	var verts_3d : Array = []
	for v in nav_mesh.get_vertices():
		verts_3d.append(v)

	var verts_2d : Array = []
	for v in verts_3d:
		verts_2d.append(camera.unproject_position(v))

	var new_polys : Array = []
	var removed := 0
	var clipped := 0

	for i in nav_mesh.get_polygon_count():
		var poly : Array = []
		for idx in nav_mesh.get_polygon(i):
			poly.append(idx)

		var poly_2d : Array = []
		for idx in poly:
			poly_2d.append(verts_2d[idx])

		# Does this polygon touch the rect at all?
		if not _polygon_touches_rect(poly_2d, rect):
			new_polys.append(poly)
			continue

		# Is it entirely inside the rect?
		var all_inside = true
		for p in poly_2d:
			if not rect.has_point(p):
				all_inside = false
				break

		if all_inside or not do_cut:
			removed += 1
			continue

		# Cut mode: clip to parts OUTSIDE the rect
		# Clip against each of the 4 outside half-planes separately
		# Each gives a valid polygon for one "side" of the rect
		var parts = _clip_outside_rect(poly, rect, verts_3d, verts_2d)

		if parts.is_empty():
			removed += 1
		else:
			for part in parts:
				if part.size() >= 3:
					# Fan triangulate
					for t in range(1, part.size() - 1):
						new_polys.append([part[0], part[t], part[t + 1]])
			clipped += 1

	var new_mesh = _rebuild_mesh(verts_3d, new_polys)
	_commit_action("Cut NavMesh Polygons" if do_cut else "Erase NavMesh Polygons", old_mesh, new_mesh)

	if do_cut:
		_status_label.text = "Cut: removed %d, clipped %d | Ctrl+Z to undo" % [removed, clipped]
	else:
		_status_label.text = "Erased %d polygons | Ctrl+Z to undo" % removed

# ─── CLIP OUTSIDE RECT ────────────────────────────────────────────────────────
# Key insight: to get the parts of a polygon OUTSIDE a rectangle,
# clip the polygon against each of the 4 outward-facing half-planes separately.
# Each clip gives the portion of the polygon on that side of the rect edge.
# Union of all 4 = everything outside the rect.
# Each part is a valid convex polygon that can be triangulated independently.
func _clip_outside_rect(poly: Array, rect: Rect2, verts_3d: Array, verts_2d: Array) -> Array:
	var parts : Array = []
	var rx0 = rect.position.x
	var ry0 = rect.position.y
	var rx1 = rect.end.x
	var ry1 = rect.end.y

	# Top: keep y <= rect.top
	var top = _clip_to_halfplane(poly, verts_3d, verts_2d,
		func(p: Vector2) -> bool: return p.y <= ry0,
		func(a: Vector2, b: Vector2) -> float:
			if abs(b.y - a.y) < 0.0001: return -1.0
			return (ry0 - a.y) / (b.y - a.y))
	if top.size() >= 3:
		parts.append(top)

	# Bottom: keep y >= rect.bottom
	var bottom = _clip_to_halfplane(poly, verts_3d, verts_2d,
		func(p: Vector2) -> bool: return p.y >= ry1,
		func(a: Vector2, b: Vector2) -> float:
			if abs(b.y - a.y) < 0.0001: return -1.0
			return (ry1 - a.y) / (b.y - a.y))
	if bottom.size() >= 3:
		parts.append(bottom)

	# Left: keep x <= rect.left
	var left = _clip_to_halfplane(poly, verts_3d, verts_2d,
		func(p: Vector2) -> bool: return p.x <= rx0,
		func(a: Vector2, b: Vector2) -> float:
			if abs(b.x - a.x) < 0.0001: return -1.0
			return (rx0 - a.x) / (b.x - a.x))
	if left.size() >= 3:
		parts.append(left)

	# Right: keep x >= rect.right
	var right = _clip_to_halfplane(poly, verts_3d, verts_2d,
		func(p: Vector2) -> bool: return p.x >= rx1,
		func(a: Vector2, b: Vector2) -> float:
			if abs(b.x - a.x) < 0.0001: return -1.0
			return (rx1 - a.x) / (b.x - a.x))
	if right.size() >= 3:
		parts.append(right)

	return parts

# Standard Sutherland-Hodgman clip to a single half-plane
# Returns vertex indices (adding new verts to verts_3d/verts_2d as needed)
func _clip_to_halfplane(poly: Array, verts_3d: Array, verts_2d: Array,
		is_inside: Callable, get_t: Callable) -> Array:
	if poly.is_empty():
		return []
	var result : Array = []
	var n = poly.size()
	for i in n:
		var ci = poly[i]
		var ni = poly[(i + 1) % n]
		var cp : Vector2 = verts_2d[ci]
		var np : Vector2 = verts_2d[ni]
		var c_in = is_inside.call(cp)
		var n_in = is_inside.call(np)
		if c_in:
			result.append(ci)
		if c_in != n_in:
			var t : float = get_t.call(cp, np)
			if t >= 0.0 and t <= 1.0:
				var new_3d : Vector3 = verts_3d[ci].lerp(verts_3d[ni], t)
				var new_2d : Vector2 = cp.lerp(np, t)
				var idx = verts_3d.size()
				verts_3d.append(new_3d)
				verts_2d.append(new_2d)
				result.append(idx)
	return result

# ─── HELPERS ─────────────────────────────────────────────────────────────────
func _rebuild_mesh(vertices: Array, polygons: Array) -> NavigationMesh:
	var mesh = NavigationMesh.new()
	var packed := PackedVector3Array()
	for v in vertices:
		packed.append(v)
	mesh.set_vertices(packed)
	for poly in polygons:
		var p := PackedInt32Array()
		for idx in poly:
			p.append(idx)
		mesh.add_polygon(p)
	return mesh

func _commit_action(action_name: String, old_mesh: NavigationMesh, new_mesh: NavigationMesh):
	var nav_region = _selected_nav_region
	_undo_redo.create_action(action_name)
	_undo_redo.add_do_property(nav_region, "navigation_mesh", new_mesh)
	_undo_redo.add_undo_property(nav_region, "navigation_mesh", old_mesh)
	_undo_redo.commit_action()
	get_editor_interface().mark_scene_as_unsaved()

# ─── OVERLAY ─────────────────────────────────────────────────────────────────
class _OverlayControl extends Control:
	var _drawing := false
	var _start := Vector2.ZERO
	var _end := Vector2.ZERO
	var rect_color := Color(1, 0.2, 0.2)

	func _ready():
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func update_rect(start: Vector2, end: Vector2, drawing: bool):
		_start = start
		_end = end
		_drawing = drawing
		queue_redraw()

	func _draw():
		if not _drawing:
			return
		var rect = Rect2(
			Vector2(min(_start.x, _end.x), min(_start.y, _end.y)),
			Vector2(abs(_end.x - _start.x), abs(_end.y - _start.y))
		)
		draw_rect(rect, Color(rect_color.r, rect_color.g, rect_color.b, 0.15))
		draw_rect(rect, Color(rect_color.r, rect_color.g, rect_color.b, 0.9), false, 2.0)
		draw_circle(_start, 4, Color(rect_color.r, rect_color.g, rect_color.b, 0.9))
		draw_circle(_end, 4, Color(rect_color.r, rect_color.g, rect_color.b, 0.9))
		draw_line(_start + Vector2(-8, 0), _start + Vector2(8, 0), Color(rect_color.r, rect_color.g, rect_color.b, 0.9), 1.0)
		draw_line(_start + Vector2(0, -8), _start + Vector2(0, 8), Color(rect_color.r, rect_color.g, rect_color.b, 0.9), 1.0)
