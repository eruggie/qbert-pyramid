class_name DirectionalInputAdapter
extends RefCounted
## Converts mapped device events into clock-independent semantic direction events.
## Multiple bindings of one action share a single held state in the simulation.

const ACTIONS: Array[StringName] = [&"move_nw", &"move_ne", &"move_sw", &"move_se"]

var is_suspended: bool = false
var _held_sources: Dictionary = {}
var _queued_events: Array[Dictionary] = []


func feed_event(event: InputEvent) -> bool:
	var source: String = _source_id(event)
	if source.is_empty():
		return false
	if event.is_echo():
		return _find_direction(event) >= 0
	if not event.is_pressed() and _held_sources.has(source):
		var previous: Dictionary = _held_sources[source]
		var released_direction: int = int(previous["direction"])
		_held_sources.erase(source)
		if not bool(previous["blocked"]) and not is_suspended and not _has_active_source(released_direction):
			_queued_events.append({"type": "release", "direction": released_direction})
		return true
	var direction: int = _find_direction(event)
	if direction < 0:
		return false
	if not event.is_pressed():
		return true
	if _held_sources.has(source):
		return true
	var already_active: bool = _has_active_source(direction)
	_held_sources[source] = {"direction": direction, "blocked": is_suspended, "event": event.duplicate()}
	if not is_suspended and not already_active:
		_queued_events.append({"type": "press", "direction": direction})
	return true


func drain_events() -> Array[Dictionary]:
	var events: Array[Dictionary] = _queued_events
	_queued_events = []
	return events


func set_suspended(suspended: bool) -> void:
	is_suspended = suspended
	if suspended:
		flush_require_fresh()


func flush_require_fresh() -> void:
	_queued_events.clear()
	for source: String in _held_sources:
		var held: Dictionary = _held_sources[source]
		held["blocked"] = true
		_held_sources[source] = held


func reconcile_focus() -> int:
	# Releases outside the application may update Input without reaching this node.
	# Only blocked sources can be reconciled: active input is never synthesized.
	var removed: int = 0
	for source: String in _held_sources.keys():
		var held: Dictionary = _held_sources[source]
		if bool(held["blocked"]) and not _source_is_pressed(held):
			_held_sources.erase(source)
			removed += 1
	return removed


func _source_is_pressed(held: Dictionary) -> bool:
	var event: InputEvent = held.get("event") as InputEvent
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		if key.physical_keycode != 0:
			return Input.is_physical_key_pressed(key.physical_keycode)
		return Input.is_key_pressed(key.keycode)
	if event is InputEventJoypadButton:
		var button: InputEventJoypadButton = event as InputEventJoypadButton
		if button.device >= 0:
			return Input.is_joy_button_pressed(button.device, button.button_index)
		for device: int in Input.get_connected_joypads():
			if Input.is_joy_button_pressed(device, button.button_index):
				return true
		return false
	if event is InputEventAction:
		var action: InputEventAction = event as InputEventAction
		return InputMap.has_action(action.action) and Input.is_action_pressed(action.action)
	return false


func held_source_count() -> int:
	return _held_sources.size()


func _has_active_source(direction: int) -> bool:
	for value: Dictionary in _held_sources.values():
		if int(value["direction"]) == direction and not bool(value["blocked"]):
			return true
	return false


func _find_direction(event: InputEvent) -> int:
	for direction: int in range(ACTIONS.size()):
		if event.is_action(ACTIONS[direction]):
			return direction
	return -1


func _source_id(event: InputEvent) -> String:
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		var code: int = key.physical_keycode if key.physical_keycode != 0 else key.keycode
		return "key:%d:%d" % [key.device, code]
	if event is InputEventJoypadButton:
		var button: InputEventJoypadButton = event as InputEventJoypadButton
		return "joy:%d:%d" % [button.device, button.button_index]
	if event is InputEventAction:
		var action: InputEventAction = event as InputEventAction
		return "action:%d:%s" % [action.device, action.action]
	return ""
