class_name PyramidBoard
extends RefCounted
## Pure logical board. Coordinates are Vector2i(row, column), never pixels.

enum Direction { NW = 0, NE = 1, SW = 2, SE = 3 }
enum ColorMode { PERMANENT = 0, TWO_STEP = 1, REVERSIBLE = 2 }

const ROW_COUNT: int = 7
const CELL_COUNT: int = 28
const INVALID_CELL: Vector2i = Vector2i(-1, -1)
const INVALID_STATE: int = -1

var color_mode: int:
	get:
		return _color_mode

var all_complete: bool:
	get:
		return completed_count() == CELL_COUNT

var _color_mode: int = ColorMode.PERMANENT
var _states: PackedInt32Array = PackedInt32Array()


func _init() -> void:
	_states.resize(CELL_COUNT)
	_states.fill(0)


static func is_valid_cell(coordinate: Vector2i) -> bool:
	return coordinate.x >= 0 and coordinate.x < ROW_COUNT and coordinate.y >= 0 and coordinate.y <= coordinate.x


static func is_valid_direction(direction: int) -> bool:
	return direction >= Direction.NW and direction <= Direction.SE


static func is_valid_color_mode(mode: int) -> bool:
	return mode >= ColorMode.PERMANENT and mode <= ColorMode.REVERSIBLE


static func neighbor(coordinate: Vector2i, direction: int) -> Vector2i:
	if not is_valid_cell(coordinate) or not is_valid_direction(direction):
		return INVALID_CELL
	match direction:
		Direction.NW:
			return coordinate + Vector2i(-1, -1)
		Direction.NE:
			return coordinate + Vector2i(-1, 0)
		Direction.SW:
			return coordinate + Vector2i(1, 0)
		Direction.SE:
			return coordinate + Vector2i(1, 1)
	return INVALID_CELL


func reset(mode: int = ColorMode.PERMANENT) -> bool:
	if not is_valid_color_mode(mode):
		return false
	_color_mode = mode
	_states.fill(0)
	return true


func cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for row: int in range(ROW_COUNT):
		for column: int in range(row + 1):
			result.append(Vector2i(row, column))
	return result


func get_state(coordinate: Vector2i) -> int:
	if not is_valid_cell(coordinate):
		return INVALID_STATE
	return _states[_index(coordinate)]


func target_state() -> int:
	return 2 if _color_mode == ColorMode.TWO_STEP else 1


func is_target(coordinate: Vector2i) -> bool:
	return is_valid_cell(coordinate) and get_state(coordinate) == target_state()


func completed_count() -> int:
	var result: int = 0
	var target: int = target_state()
	for value: int in _states:
		if value == target:
			result += 1
	return result


func apply_landing(coordinate: Vector2i) -> Dictionary:
	if not is_valid_cell(coordinate):
		return {}
	var index: int = _index(coordinate)
	var before: int = _states[index]
	var after: int = before
	match _color_mode:
		ColorMode.PERMANENT:
			after = 1
		ColorMode.TWO_STEP:
			after = mini(before + 1, 2)
		ColorMode.REVERSIBLE:
			after = 1 - before
	_states[index] = after
	return {
		"cell": coordinate,
		"before": before,
		"after": after,
		"changed": before != after,
		"all_complete": all_complete,
	}


func apply_sabotage(coordinate: Vector2i) -> bool:
	if not is_valid_cell(coordinate):
		return false
	var index: int = _index(coordinate)
	var previous: int = _states[index]
	_states[index] = maxi(0, previous - 1)
	return _states[index] != previous


func get_snapshot() -> Dictionary:
	return {
		"color_mode": _color_mode,
		"states": _states.duplicate(),
		"target_state": target_state(),
		"completed_count": completed_count(),
		"all_complete": all_complete,
	}


static func _index(coordinate: Vector2i) -> int:
	return ((coordinate.x * (coordinate.x + 1)) >> 1) + coordinate.y
