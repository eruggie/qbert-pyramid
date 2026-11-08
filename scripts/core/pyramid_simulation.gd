class_name PyramidSimulation
extends RefCounted
## Fixed-step, presentation-independent phase 1 laboratory simulation.

const TICK_RATE: int = 60
const JUMP_TICKS: int = 18
const RECOVERY_TICKS: int = 2

var board: PyramidBoard = PyramidBoard.new()
# The game resolves collisions before committing a landing; lab remains immediate.
var defer_cell_effects: bool = false
var cell: Vector2i = Vector2i.ZERO
var tick: int = 0
var jump_id: int = 0
var jump_from: Vector2i = Vector2i.ZERO
var jump_to: Vector2i = Vector2i.ZERO
var jump_start_tick: int = 0
var jump_end_tick: int = 0
var is_airborne: bool = false
var fallen: bool = false

var paused: bool:
	get:
		return _paused

var jump_progress: float:
	get:
		if jump_id == 0:
			return 0.0
		if not is_airborne:
			return 1.0
		return clampf(float(tick - jump_start_tick) / float(JUMP_TICKS), 0.0, 1.0)

var recovery_ticks_remaining: int:
	get:
		return maxi(_ready_tick - tick, 0) if not is_airborne and not fallen else 0

var is_recovering: bool:
	get:
		return recovery_ticks_remaining > 0

var state: StringName:
	get:
		if _paused:
			return &"paused"
		if fallen:
			return &"fallen"
		if is_airborne:
			return &"jumping"
		if is_recovering:
			return &"recovering"
		return &"ready"

var _input: PyramidInputBuffer = PyramidInputBuffer.new()
var _paused: bool = false
var _ready_tick: int = 0
var _last_jump_id: int = 0


func reset(mode: int = PyramidBoard.ColorMode.PERMANENT, start_cell: Vector2i = Vector2i.ZERO) -> bool:
	if not PyramidBoard.is_valid_color_mode(mode) or not PyramidBoard.is_valid_cell(start_cell):
		return false
	board.reset(mode)
	_reset_actor(start_cell)
	return true


func respawn() -> void:
	# Preserve the board and unique jump IDs while clearing movement/input.
	_reset_actor(Vector2i.ZERO)


func _reset_actor(start_cell: Vector2i) -> void:
	cell = start_cell
	tick = 0
	jump_id = 0
	jump_from = start_cell
	jump_to = start_cell
	jump_start_tick = 0
	jump_end_tick = 0
	is_airborne = false
	fallen = false
	_paused = false
	_ready_tick = 0
	_input.flush()
	# IDs are unique for the lifetime of this simulation, including resets/respawns.


func set_paused(value: bool) -> bool:
	if _paused == value:
		return true
	_paused = value
	_input.flush()
	return true


func step(events: Array[Dictionary] = []) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _paused or fallen:
		return result
	var next_tick: int = tick + 1
	if not _input.accept_events(events, next_tick):
		return result
	tick = next_tick
	if is_airborne and tick >= jump_end_tick:
		_finish_jump(result)
	if not fallen and not is_airborne and tick >= _ready_tick:
		var direction: int = _input.take_direction(tick)
		if direction != PyramidInputBuffer.NO_DIRECTION:
			_start_jump(direction, result)
	return result


func get_snapshot() -> Dictionary:
	return {
		"board": board.get_snapshot(),
		"cell": cell,
		"tick": tick,
		"jump_id": jump_id,
		"last_jump_id": _last_jump_id,
		"jump_from": jump_from,
		"jump_to": jump_to,
		"jump_start_tick": jump_start_tick,
		"jump_end_tick": jump_end_tick,
		"jump_progress": jump_progress,
		"is_airborne": is_airborne,
		"is_recovering": is_recovering,
		"recovery_ticks_remaining": recovery_ticks_remaining,
		"fallen": fallen,
		"paused": _paused,
		"state": state,
		"input": _input.get_snapshot(),
	}


func _start_jump(direction: int, events: Array[Dictionary]) -> void:
	_last_jump_id += 1
	jump_id = _last_jump_id
	jump_from = cell
	jump_to = PyramidBoard.neighbor(cell, direction)
	jump_start_tick = tick
	jump_end_tick = tick + JUMP_TICKS
	is_airborne = true
	events.append({
		"type": "jump_started",
		"jump_id": jump_id,
		"tick": tick,
		"from": jump_from,
		"to": jump_to,
		"direction": direction,
	})


func _finish_jump(events: Array[Dictionary]) -> void:
	is_airborne = false
	var terminal: Dictionary = {
		"type": "jump_landed",
		"jump_id": jump_id,
		"tick": tick,
		"from": jump_from,
		"to": jump_to,
	}
	if not PyramidBoard.is_valid_cell(jump_to):
		fallen = true
		_input.flush()
		terminal["type"] = "jump_fallen"
	else:
		cell = jump_to
		if not defer_cell_effects:
			var color_change: Dictionary = board.apply_landing(cell)
			terminal["color_before"] = color_change["before"]
			terminal["color_after"] = color_change["after"]
		_ready_tick = tick + RECOVERY_TICKS
	events.append(terminal)
