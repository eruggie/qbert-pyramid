class_name PyramidWorld
extends RefCounted
## Tick-based actors and spawns. All coordinates are logical pyramid cells.

const Progression = preload("res://scripts/core/progression.gd")
const HOP: int = 24
const WARNING: int = 36
const STASIS_DELAY: int = 720
const STASIS_DURATION: int = 300
const STASIS_PERIOD: int = 42
const FALL_TICKS: int = 24
const PERIODS: Array[float] = [1.2, 1.35, 1.1, 1.5]
# Gottlieb PDF 7 (printed 5), levels I-IV. Bits: red, chaser, lateral,
# saboteur, green collectible. Level V onward admits all five roles.
const ROUND_ROSTERS: Array[int] = [
	3, 3, 30, 27,
	30, 30, 27, 31,
	27, 30, 31, 31,
	27, 31, 31, 31,
]
const STASIS_KIND: int = 4
const CHASER_ROUND_FACTORS: Array[float] = [1.0, 0.94, 0.88, 0.82]
const LIMITS: Array[int] = [8, 1, 2, 1]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var progression: Progression
var round_index: int = 0
var tick: int = 0
var next_spawn: int = 0
var warning_kind: int = -1
var warning_cell: Vector2i = Vector2i.ZERO
var warning_until: int = 0
var actors: Array[Dictionary] = []
var next_actor_id: int = 1
var stasis_cell: Vector2i = Vector2i.ZERO
var stasis_motion: Dictionary = {}
var falling_actors: Array[Dictionary] = []
var stasis_available: bool = false
var stasis_spawned: bool = false
var stasis_remaining: int = 0
var lure_cell: Vector2i = Vector2i(-1, -1)
var spawning_enabled: bool = true
var stasis_enabled: bool = true
var first_chaser_spawned: bool = false


func reset_round(index: int, policy: Progression) -> void:
	round_index = index
	progression = policy
	tick = 0
	next_spawn = policy.spawn_interval(index)
	warning_kind = -1
	first_chaser_spawned = false
	actors.clear()
	falling_actors.clear()
	stasis_motion.clear()
	stasis_available = false
	stasis_available = false
	stasis_spawned = false
	stasis_remaining = 0
	lure_cell = Vector2i(-1, -1)


func after_death() -> void:
	actors.clear()
	falling_actors.clear()
	stasis_motion.clear()
	stasis_available = false
	warning_kind = -1
	stasis_remaining = 0
	lure_cell = Vector2i(-1, -1)
	# The death wait lasts 90 ticks: another 90 active ticks make 3 seconds.
	next_spawn = tick + 90


func seed(value: int) -> void:
	rng.seed = value


func advance(player_before: Dictionary, player_after: Dictionary, protected: bool) -> Dictionary:
	## Move existing hops and resolve contact before cell effects or new departures.
	tick += 1
	if stasis_remaining > 0:
		stasis_remaining -= 1
	if stasis_enabled and is_character_available(STASIS_KIND) and not stasis_spawned and tick >= STASIS_DELAY:
		stasis_spawned = true
		stasis_available = true
		stasis_cell = Vector2i.ZERO
		stasis_motion = {"from": stasis_cell, "to": stasis_cell, "moving": false, "start": tick, "end": tick, "next": tick + STASIS_PERIOD}
	for falling: Dictionary in falling_actors.duplicate():
		if tick >= int(falling["fall_end"]):
			falling_actors.erase(falling)
	var stasis_fallen: bool = false
	var green_before: Dictionary = stasis_motion.duplicate()
	var green_cell_before: Vector2i = stasis_cell
	if stasis_available and stasis_motion.get("moving", false) and tick >= int(stasis_motion["end"]):
		stasis_cell = stasis_motion["to"]
		stasis_motion["moving"] = false
		if not PyramidBoard.is_valid_cell(stasis_cell):
			stasis_available = false
			stasis_fallen = true
			falling_actors.append({"kind": STASIS_KIND, "cell": stasis_cell, "from": stasis_motion["from"], "to": stasis_cell, "fall_start": tick, "fall_end": tick + FALL_TICKS})
	var landed: Array[Dictionary] = []
	var contacts: Array[Dictionary] = []
	var escaped: Array[Dictionary] = []
	for actor: Dictionary in actors:
		var was_moving: bool = actor["moving"]
		var old_cell: Vector2i = actor["cell"]
		var old_progress: float = clampf(float(tick - 1 - int(actor["start"])) / HOP, 0.0, 1.0) if was_moving else 0.0
		var was_grounded: bool = not was_moving
		if was_moving and tick >= int(actor["end"]):
			actor["moving"] = false
			actor["cell"] = actor["to"]
			if not PyramidBoard.is_valid_cell(actor["cell"]):
				escaped.append(actor)
				continue
			landed.append(actor)
		var shared_before: bool = not bool(player_before["is_airborne"]) and was_grounded and player_before["cell"] == old_cell
		var shared_after: bool = not bool(player_after["is_airborne"]) and not bool(actor["moving"]) and player_after["cell"] == actor["cell"]
		var crossed: bool = false
		if was_moving and bool(player_before["is_airborne"]) and player_before["jump_from"] == actor["to"] and player_before["jump_to"] == actor["from"]:
			var p0: float = float(int(player_before["tick"]) - int(player_before["jump_start_tick"])) / 18.0
			var p1: float = minf(1.0, p0 + 1.0 / 18.0)
			var e1: float = minf(1.0, old_progress + 1.0 / HOP)
			crossed = p0 + old_progress <= 1.0 and p1 + e1 >= 1.0
		var arrives_at_departure: bool = not bool(player_before["is_airborne"]) and was_moving and not bool(actor["moving"]) and player_before["cell"] == actor["cell"]
		if shared_before or shared_after or crossed or arrives_at_departure:
			contacts.append(actor)
	var lethal: bool = false
	if not protected and stasis_remaining == 0:
		for actor: Dictionary in contacts:
			if int(actor["kind"]) != 3:
				lethal = true
				break
	var collected: Array[int] = []
	if not lethal:
		for actor: Dictionary in contacts:
			if int(actor["kind"]) == 3:
				collected.append(int(actor["id"]))
				actors.erase(actor)
	for actor: Dictionary in escaped:
		actors.erase(actor)
		var falling: Dictionary = actor.duplicate(true)
		falling["fall_start"] = tick
		falling["fall_end"] = tick + FALL_TICKS
		falling_actors.append(falling)
	var green_contact: bool = not bool(player_after["is_airborne"]) and not stasis_motion.get("moving", false) and player_after["cell"] == stasis_cell
	green_contact = green_contact or (not bool(player_before["is_airborne"]) and not green_before.get("moving", false) and player_before["cell"] == green_cell_before)
	if green_before.get("moving", false) and bool(player_before["is_airborne"]) and player_before["jump_from"] == green_before["to"] and player_before["jump_to"] == green_before["from"]:
		var p0: float = float(int(player_before["tick"]) - int(player_before["jump_start_tick"])) / 18.0
		var g0: float = float(tick - 1 - int(green_before["start"])) / HOP
		green_contact = green_contact or (p0 + g0 <= 1.0 and minf(1.0, p0 + 1.0 / 18.0) + minf(1.0, g0 + 1.0 / HOP) >= 1.0)
	var stasis_collected: bool = not lethal and stasis_available and green_contact
	if stasis_collected:
		stasis_available = false
		stasis_remaining = STASIS_DURATION
	return {"lethal": lethal, "collected": collected, "landed": landed,
		"escaped": escaped, "stasis_collected": stasis_collected, "stasis_fallen": stasis_fallen}


func depart_and_spawn(player_cell: Vector2i, player_airborne: bool, player_target: Vector2i = Vector2i(-1, -1)) -> void:
	if stasis_remaining > 0:
		return
	if stasis_available and not stasis_motion.is_empty() and not stasis_motion["moving"] and tick >= int(stasis_motion["next"]):
		stasis_motion["from"] = stasis_cell
		stasis_motion["to"] = PyramidBoard.neighbor(stasis_cell, 2 + rng.randi_range(0, 1))
		stasis_motion["start"] = tick
		stasis_motion["end"] = tick + HOP
		stasis_motion["next"] = tick + STASIS_PERIOD
		stasis_motion["moving"] = true
	for actor: Dictionary in actors:
		if int(actor["kind"]) == 1 and PyramidBoard.is_valid_cell(lure_cell) and (actor["cell"] == lure_cell or (actor["moving"] and actor["to"] == lure_cell)):
			actor["lure_target"] = lure_cell
		if not actor["moving"] and tick >= int(actor["next"]):
			var destination: Vector2i = _destination(actor, player_cell)
			if int(actor["kind"]) == 1 and not PyramidBoard.is_valid_cell(destination) and PyramidBoard.is_valid_cell(actor.get("lure_target", lure_cell)):
				actor["lured"] = true
			actor["from"] = actor["cell"]
			actor["to"] = destination
			actor["start"] = tick
			actor["end"] = tick + HOP
			actor["moving"] = true
			actor["next"] = tick + move_period(int(actor["kind"]))
	if spawning_enabled and warning_kind < 0 and tick >= next_spawn - WARNING and actors.size() < progression.enemy_cap(round_index):
		var candidates: Array[int] = []
		for kind: int in range(4):
			if is_character_available(kind) and _count_kind(kind) < LIMITS[kind]:
				candidates.append(kind)
		if not candidates.is_empty():
			warning_kind = 1 if not first_chaser_spawned and candidates.has(1) else candidates[rng.randi_range(0, candidates.size() - 1)]
			if warning_kind == 2:
				warning_cell = Vector2i(6, 0 if rng.randi_range(0, 1) == 0 else 6)
			elif warning_kind == 1:
				warning_cell = Vector2i(6, 3)
			else:
				warning_cell = Vector2i.ZERO
			warning_until = maxi(next_spawn, tick + WARNING)
	if warning_kind >= 0 and tick >= warning_until:
		var unsafe: bool = (not player_airborne and player_cell == warning_cell) or (player_airborne and player_target == warning_cell)
		for actor: Dictionary in actors:
			unsafe = unsafe or actor["cell"] == warning_cell or (actor["moving"] and actor["to"] == warning_cell)
		if not unsafe and actors.size() < progression.enemy_cap(round_index) and _count_kind(warning_kind) < LIMITS[warning_kind]:
			actors.append({"id": next_actor_id, "kind": warning_kind, "cell": warning_cell,
				"from": warning_cell, "to": warning_cell, "moving": false, "start": tick,
				"end": tick, "next": tick + move_period(warning_kind)})
			if warning_kind == 1:
				first_chaser_spawned = true
			next_actor_id += 1
			warning_kind = -1
			next_spawn = tick + progression.spawn_interval(round_index)


func set_lure_target(cell: Vector2i) -> void:
	lure_cell = cell
	for actor: Dictionary in actors:
		if int(actor["kind"]) == 1 and (actor["cell"] == cell or (actor["moving"] and actor["to"] == cell)):
			actor["lure_target"] = cell


func is_character_available(kind: int) -> bool:
	if kind < 0 or kind > STASIS_KIND or round_index < 0:
		return false
	var roster: int = 31 if round_index >= ROUND_ROSTERS.size() else ROUND_ROSTERS[round_index]
	return (roster & (1 << kind)) != 0


func move_period(kind: int) -> int:
	var factor: float = progression.speed_factor(round_index)
	if kind == 1:
		factor *= CHASER_ROUND_FACTORS[round_index % 4]
	return maxi(HOP, roundi(PERIODS[kind] * 60.0 * factor))


func _count_kind(kind: int) -> int:
	var result: int = 0
	for actor: Dictionary in actors:
		if actor["kind"] == kind:
			result += 1
	return result


func _destination(actor: Dictionary, player_cell: Vector2i) -> Vector2i:
	var cell: Vector2i = actor["cell"]
	var kind: int = actor["kind"]
	if kind == 0 or kind == 3:
		return PyramidBoard.neighbor(cell, 2 + rng.randi_range(0, 1))
	if kind == 2:
		return PyramidBoard.neighbor(cell, 1 if cell.y == 0 else 0)
	var target: Vector2i = actor.get("lure_target", lure_cell)
	var goal: Vector2i = target if PyramidBoard.is_valid_cell(target) else player_cell
	if cell == target and cell.x in [3, 5]:
		return PyramidBoard.neighbor(cell, 0 if cell.y == 0 else 1)
	var best: Array[Vector2i] = []
	var distance: int = 999
	for direction: int in range(4):
		var candidate: Vector2i = PyramidBoard.neighbor(cell, direction)
		if not PyramidBoard.is_valid_cell(candidate):
			continue
		var delta: Vector2i = candidate - goal
		var current: int = maxi(absi(delta.x), maxi(absi(delta.y), absi(delta.x - delta.y)))
		if current < distance:
			distance = current
			best = [candidate]
		elif current == distance:
			best.append(candidate)
	return best[rng.randi_range(0, best.size() - 1)] if not best.is_empty() else cell


func snapshot() -> Dictionary:
	return {"tick": tick, "round_index": round_index, "rng_state": rng.state,
		"next_spawn": next_spawn, "warning_kind": warning_kind,
		"warning_cell": warning_cell, "warning_until": warning_until,
		"actors": actors.duplicate(true), "next_actor_id": next_actor_id,
		"stasis_cell": stasis_cell, "stasis_motion": stasis_motion.duplicate(true), "falling_actors": falling_actors.duplicate(true), "stasis_available": stasis_available,
		"stasis_spawned": stasis_spawned, "stasis_remaining": stasis_remaining,
		"lure_cell": lure_cell, "spawning_enabled": spawning_enabled,
		"stasis_enabled": stasis_enabled, "first_chaser_spawned": first_chaser_spawned}
