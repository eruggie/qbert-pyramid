class_name PyramidInputBuffer
extends RefCounted
## Semantic input only. A device adapter owns physical key/button state and echo.

const DIRECTION_COUNT: int = 4
const BUFFER_TICKS: int = 12
const NO_DIRECTION: int = -1

var _held: Array[bool] = [false, false, false, false]
var _press_ticks: PackedInt64Array = PackedInt64Array([-1, -1, -1, -1])
var _buffer_direction: int = NO_DIRECTION
var _buffer_tick: int = -1
var _last_tick: int = -1


func accepts(events: Array[Dictionary], current_tick: int) -> bool:
	if current_tick < 0 or current_tick < _last_tick:
		return false
	for event: Dictionary in events:
		if not event.has("type") or not event.has("direction"):
			return false
		if typeof(event["type"]) != TYPE_STRING and typeof(event["type"]) != TYPE_STRING_NAME:
			return false
		if event["type"] != "press" and event["type"] != "release":
			return false
		if typeof(event["direction"]) != TYPE_INT:
			return false
		var direction: int = event["direction"]
		if direction < 0 or direction >= DIRECTION_COUNT:
			return false
	return true


func accept_events(events: Array[Dictionary], current_tick: int) -> bool:
	if not accepts(events, current_tick):
		return false
	_last_tick = current_tick
	_expire(current_tick)
	# Preserve a direction's press/release order, including taps entirely between ticks.
	# Tie priority across different directions is resolved only after the whole batch.
	var fresh: Array[bool] = [false, false, false, false]
	for event: Dictionary in events:
		var direction: int = event["direction"]
		if event["type"] == "release":
			_held[direction] = false
		elif not _held[direction]:
			_held[direction] = true
			_press_ticks[direction] = current_tick
			fresh[direction] = true
	var winner: int = NO_DIRECTION
	for direction: int in range(DIRECTION_COUNT):
		if fresh[direction]:
			winner = direction
			break
	if winner != NO_DIRECTION:
		_buffer_direction = winner
		_buffer_tick = current_tick
	return true


func take_direction(current_tick: int) -> int:
	if current_tick < 0 or current_tick < _last_tick:
		return NO_DIRECTION
	_expire(current_tick)
	if _buffer_direction != NO_DIRECTION:
		var direction: int = _buffer_direction
		_buffer_direction = NO_DIRECTION
		_buffer_tick = -1
		return direction
	var selected: int = NO_DIRECTION
	var latest_tick: int = -1
	for direction: int in range(DIRECTION_COUNT):
		if _held[direction] and _press_ticks[direction] > latest_tick:
			selected = direction
			latest_tick = _press_ticks[direction]
	return selected


func flush() -> void:
	_held.fill(false)
	_press_ticks.fill(-1)
	_buffer_direction = NO_DIRECTION
	_buffer_tick = -1
	_last_tick = -1


func get_snapshot() -> Dictionary:
	return {
		"held": _held.duplicate(),
		"press_ticks": _press_ticks.duplicate(),
		"buffer_direction": _buffer_direction,
		"buffer_tick": _buffer_tick,
		"last_tick": _last_tick,
	}


func _expire(current_tick: int) -> void:
	if _buffer_direction != NO_DIRECTION and current_tick - _buffer_tick >= BUFFER_TICKS:
		_buffer_direction = NO_DIRECTION
		_buffer_tick = -1
