class_name PyramidView
extends Control
## Original pixel presentation. Geometry and animation never change game rules.
const Palette = preload("res://scripts/presentation/arcade_palette.gd")
var actor_sheet: Texture2D
var arcade_font: Font

const SimulationScript = preload("res://scripts/core/pyramid_simulation.gd")
const BoardScript = preload("res://scripts/core/pyramid_board.gd")

var simulation: SimulationScript
var game: PyramidGame


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor_sheet = load("res://assets/arcade/actors.png") as Texture2D
	arcade_font = load("res://assets/arcade/arcade_font.fnt") as Font
	resized.connect(queue_redraw)


func rendered_cell_count() -> int:
	return 0 if simulation == null else simulation.board.cells().size()


func cell_to_canvas(cell: Vector2i) -> Vector2:
	var width: float = _tile_width()
	var height: float = width * 0.50
	var depth: float = width * 0.55
	var top: float = maxf(width * 0.8, (size.y - width * 5.6) * 0.5)
	return Vector2(size.x * 0.5 + (float(cell.y) - float(cell.x) * 0.5) * width, top + float(cell.x) * (height * 0.5 + depth))


func cell_polygon(cell: Vector2i) -> PackedVector2Array:
	var center: Vector2 = cell_to_canvas(cell)
	var half_width: float = _tile_width() * 0.5
	var half_height: float = _tile_width() * 0.25
	return PackedVector2Array([
		center + Vector2(0.0, -half_height),
		center + Vector2(half_width, 0.0),
		center + Vector2(0.0, half_height),
		center + Vector2(-half_width, 0.0)
	])


func platform_canvas_position(index: int) -> Vector2:
	var anchor: Vector2i = Vector2i(3, 0) if index == 0 else Vector2i(5, 5)
	var width: float = _tile_width()
	return cell_to_canvas(anchor) + Vector2((-0.76 if index == 0 else 0.76) * width, -0.31 * width)


func rescue_platform_index() -> int:
	return 0 if simulation.jump_from == Vector2i(3, 0) else 1


func rescue_disk_position() -> Vector2:
	var elapsed: float = float(72 - game.rescue_remaining)
	var platform: Vector2 = platform_canvas_position(rescue_platform_index())
	if elapsed <= 18.0:
		return platform
	var progress: float = clampf((elapsed - 18.0) / 54.0, 0.0, 1.0)
	return platform.lerp(cell_to_canvas(Vector2i.ZERO), progress) + Vector2(0, -sin(progress * PI) * _tile_width() * 0.48)


func actor_canvas_position() -> Vector2:
	if simulation == null:
		return Vector2.ZERO
	if game != null and game.rescue_remaining > 0:
		var elapsed: float = float(72 - game.rescue_remaining)
		if elapsed <= 18.0:
			var progress: float = clampf(elapsed / 18.0, 0.0, 1.0)
			return cell_to_canvas(simulation.jump_from).lerp(platform_canvas_position(rescue_platform_index()), progress) + Vector2(0, -sin(progress * PI) * _tile_width() * 0.42)
		return rescue_disk_position()
	if simulation.is_airborne:
		var progress: float = simulation.jump_progress
		var from: Vector2 = cell_to_canvas(simulation.jump_from)
		var to: Vector2 = cell_to_canvas(simulation.jump_to)
		return from.lerp(to, progress) + Vector2(0.0, -sin(progress * PI) * _tile_width() * 0.55)
	return cell_to_canvas(simulation.cell)


func actor_shadow_position() -> Vector2:
	if game != null and game.rescue_remaining > 0:
		var elapsed: float = float(72 - game.rescue_remaining)
		if elapsed <= 18.0:
			return cell_to_canvas(simulation.jump_from).lerp(platform_canvas_position(rescue_platform_index()), clampf(elapsed / 18.0, 0.0, 1.0))
		return rescue_disk_position()
	if simulation.is_airborne:
		return cell_to_canvas(simulation.jump_from).lerp(cell_to_canvas(simulation.jump_to), simulation.jump_progress)
	return cell_to_canvas(simulation.cell)


func palette() -> Array[Color]:
	return Palette.for_round(game.round_index if game != null else 4 if simulation.board.color_mode == 1 else 0)


func _draw() -> void:
	if simulation == null or actor_sheet == null:
		return
	if game != null:
		_draw_platforms()
	for cell: Vector2i in simulation.board.cells():
		_draw_cell(cell)
	var objects: Array[Dictionary] = []
	if game != null:
		if game.world.stasis_available:
			var green_ground: Vector2 = cell_to_canvas(game.world.stasis_cell)
			var green_height: float = 0.0
			var motion: Dictionary = game.world.stasis_motion
			if motion.get("moving", false):
				var progress: float = clampf(float(game.world.tick - int(motion["start"])) / PyramidWorld.HOP, 0.0, 1.0)
				green_ground = cell_to_canvas(motion["from"]).lerp(cell_to_canvas(motion["to"]), progress)
				green_height = sin(progress * PI) * _tile_width() * .37
			objects.append({"feet": green_ground + Vector2(0, -green_height), "floor": green_ground, "kind": 6, "direction": 3, "pose": 1 if motion.get("moving", false) else 0})
		for actor: Dictionary in game.world.actors:
			var ground: Vector2 = cell_to_canvas(actor["cell"])
			var height: float = 0.0
			var pose: int = 0
			if actor["moving"]:
				var progress: float = clampf(float(game.world.tick - int(actor["start"])) / 24.0, 0.0, 1.0)
				ground = cell_to_canvas(actor["from"]).lerp(cell_to_canvas(actor["to"]), progress)
				height = sin(progress * PI) * _tile_width() * 0.37
				pose = 1 if progress < 0.8 else 2
			var kind: int = [1, 2, 3 if actor["cell"].y == 0 else 4, 5][int(actor["kind"])]
			objects.append({"feet": ground + Vector2(0, -height), "floor": ground, "kind": kind,
				"direction": facing_direction(actor["from"], actor["to"]), "pose": pose})
		for falling: Dictionary in game.world.falling_actors:
			var elapsed: float = float(game.world.tick - int(falling["fall_start"])) / PyramidWorld.FALL_TICKS
			var fall_position: Vector2 = cell_to_canvas(falling["cell"]) + Vector2(0, elapsed * elapsed * _tile_width() * 1.8)
			var sprite_kind: int = 6 if falling["kind"] == PyramidWorld.STASIS_KIND else [1, 2, 3 if falling["cell"].y <= 0 else 4, 5][int(falling["kind"])]
			_draw_sprite(sprite_kind, facing_direction(falling["from"], falling["to"]), 1, fall_position, _tile_width() / 40.0, Color(1, 1, 1, 1.0 - elapsed))
		if game.world.warning_kind >= 0:
			var point: Vector2 = cell_to_canvas(game.world.warning_cell)
			var width: float = _tile_width()
			draw_rect(Rect2(point + Vector2(-width * 0.10, -width * 0.10), Vector2(width * 0.20, width * 0.04)), Color("f4df53"))
		if game.rescue_remaining > 0 and game.rescue_remaining <= 54:
			_draw_platform(rescue_disk_position())
	if not simulation.fallen:
		objects.append({"feet": actor_canvas_position(), "floor": actor_shadow_position(), "kind": 0,
			"direction": facing_direction(simulation.jump_from, simulation.jump_to),
			"pose": 1 if simulation.is_airborne else 2 if simulation.state == &"recovering" else 0})
	elif game != null and game.state == PyramidGame.State.DYING and game.remaining_ticks > 60:
		var elapsed: float = float(90 - game.remaining_ticks)
		var falling: Vector2 = cell_to_canvas(simulation.jump_to) + Vector2(0, elapsed * _tile_width() * 0.045)
		_draw_sprite(0, facing_direction(simulation.jump_from, simulation.jump_to), 1, falling, _tile_width() / 40.0, Color(1, 1, 1, 1.0 - elapsed / 30.0))
	objects.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["floor"].y < b["floor"].y)
	for object: Dictionary in objects:
		var feet: Vector2 = object["feet"]
		var ground: Vector2 = object["floor"]
		draw_ellipse_shadow(ground, _tile_width() / 90.0)
		var tint: Color = Color.WHITE
		if object["kind"] == 0 and game != null:
			if game.state == PyramidGame.State.DYING and not simulation.fallen:
				tint = Color("ff7888") if (game.remaining_ticks / 6) % 2 == 0 else Color.WHITE
				_draw_impact(feet)
			elif game.world.stasis_remaining > 0 or game.protection_ticks > 0:
				var color: Color = Color("75f16a") if game.world.stasis_remaining > 0 else Color("ffe276")
				for dx: int in [-1, 1]:
					draw_rect(Rect2(feet + Vector2(dx * _tile_width() * 0.32, -_tile_width() * 0.32), Vector2(3, 3)), color)
		_draw_sprite(object["kind"], object["direction"], object["pose"], feet, _tile_width() / 40.0, tint)
	if game != null:
		_draw_arcade_hud()
		if game.state == PyramidGame.State.ROUND_END:
			_draw_round_card()


static func facing_direction(from: Vector2i, to: Vector2i) -> int:
	var delta: Vector2i = to - from
	if delta.x < 0:
		return 0 if delta.y < 0 else 1
	return 2 if delta.y <= 0 and delta != Vector2i.ZERO else 3


func _draw_sprite(kind: int, direction: int, pose: int, feet: Vector2, unit: float, tint: Color = Color.WHITE) -> void:
	var source: Rect2 = Rect2(Vector2((direction * 3 + pose) * 40, kind * 48), Vector2(40, 48))
	var destination: Rect2 = Rect2((feet - Vector2(20, 44) * unit).round(), Vector2(40, 48) * unit)
	draw_texture_rect_region(actor_sheet, destination, source, tint)


func _draw_cell(cell: Vector2i) -> void:
	var colors: Array[Color] = palette()
	var state: int = simulation.board.get_state(cell)
	var top_color: Color = colors[2] if simulation.board.is_target(cell) else colors[1] if state > 0 else colors[0]
	_draw_cube(cell_to_canvas(cell), _tile_width(), top_color, colors[3], colors[4])


func _draw_cube(center: Vector2, width: float, top: Color, left: Color, right: Color) -> void:
	var half: float = width * 0.25
	var depth: float = width * 0.55
	draw_colored_polygon(PackedVector2Array([center + Vector2(-width * 0.5, 0), center + Vector2(0, half), center + Vector2(0, half + depth), center + Vector2(-width * 0.5, depth)]), left)
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, half), center + Vector2(width * 0.5, 0), center + Vector2(width * 0.5, depth), center + Vector2(0, half + depth)]), right)
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -half), center + Vector2(width * 0.5, 0), center + Vector2(0, half), center + Vector2(-width * 0.5, 0)]), top)


func _draw_platforms() -> void:
	for index: int in range(2):
		var preparing: bool = game.rescue_remaining > 54 and rescue_platform_index() == index
		if game.platforms[index] or preparing:
			_draw_platform(platform_canvas_position(index))


func _draw_platform(center: Vector2) -> void:
	var radius: Vector2 = Vector2(_tile_width() * 0.25, _tile_width() * 0.11)
	var colors: Array[Color] = [Color("f2e552"), Color("ed3150"), Color("1dc241"), Color("1768e5")]
	var spin: int = int(game.active_ticks / 7) % 4
	for segment: int in range(4):
		var points: PackedVector2Array = PackedVector2Array([center])
		for step: int in range(5):
			var angle: float = (float(segment) + float(step) / 4.0) * PI * 0.5
			points.append((center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y)).round())
		draw_colored_polygon(points, colors[(segment + spin) % 4])
	draw_line(center + Vector2(-radius.x * 0.7, radius.y), center + Vector2(radius.x * 0.7, radius.y), Color("867e42"), maxf(2, _tile_width() * 0.035))


func draw_ellipse_shadow(center: Vector2, actor_scale: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(12):
		var angle: float = TAU * float(index) / 12.0
		points.append((center + Vector2(cos(angle) * 12, sin(angle) * 4) * actor_scale).round())
	draw_colored_polygon(points, Color(0, 0, 0, 0.24))


func _draw_impact(feet: Vector2) -> void:
	var unit: float = _tile_width() / 32.0
	for dx: int in [-1, 1]:
		draw_line(feet + Vector2(dx * 9, -18) * unit, feet + Vector2(dx * 14, -22) * unit, Color("fff49c"), 2 * unit)


func _draw_arcade_hud() -> void:
	var colors: Array[Color] = palette()
	var x: float = maxf(42.0, size.x * 0.5 - _tile_width() * 3.9)
	var sample: Vector2 = Vector2(x, _tile_width() * 0.75)
	draw_string(arcade_font, Vector2(maxf(2, x - 45), 18), "OBIETTIVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ed3a5b"))
	_draw_cube(sample, _tile_width() * 0.45, colors[2], colors[3], colors[4])
	for index: int in range(game.score.lives):
		_draw_sprite(0, 3, 0, Vector2(x, _tile_width() * 1.65 + index * _tile_width() * 0.45), _tile_width() / 64.0)
	if game.active_ticks < 60 and game.state == PyramidGame.State.PLAYING and not simulation.is_airborne:
		draw_string(arcade_font, Vector2(size.x * 0.5 - 85, 16), "LIVELLO %d  ROUND %d" % [game.level_number, game.round_number], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f3db5c"))


func shows_level_card() -> bool:
	return game != null and game.state == PyramidGame.State.ROUND_END and (game.round_index + 1) % 4 == 0


func _draw_round_card() -> void:
	# VID-01 00:40–00:43 and 01:20–01:22: keep the completed board visible.
	if not shows_level_card():
		# GameScreen already displays the credited bonus below the board.
		return
	var next_index: int = game.round_index + 1
	var colors: Array[Color] = Palette.for_round(next_index)
	var center: Vector2 = size * 0.5
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
	for offset: Vector2 in [Vector2(0, -65), Vector2(-24, -27), Vector2(24, -27), Vector2(0, 11)]:
		_draw_cube(center + offset, 48, colors[0], colors[3], colors[4])
	_draw_sprite(0, 3, 0, center + Vector2(0, -65), 1.5)
	draw_string(arcade_font, center + Vector2(-110, 83), "LIVELLO %d / ROUND %d" % [int(next_index / 4) + 1, next_index % 4 + 1], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("52df54"))


func _tile_width() -> float:
	return maxf(20.0, minf(160.0, minf(size.x / 9.0, size.y / 6.45)))
