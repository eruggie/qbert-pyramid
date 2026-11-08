class_name PyramidGame
extends RefCounted
## Session rules. Movement and actors remain separate deterministic models.

const Simulation = preload("res://scripts/core/pyramid_simulation.gd")
const Score = preload("res://scripts/core/pyramid_score.gd")
const Progression = preload("res://scripts/core/progression.gd")
const World = preload("res://scripts/core/pyramid_world.gd")
const DEATH_TICKS: int = 90
const ROUND_END_TICKS: int = 180 # VID-01: approximately three seconds, see ARCADE_REVIEW.md.
const PROTECTION_TICKS: int = 120
const ROUND_COUNT: int = 12
const DEFAULT_MODES: Array[int] = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2]

enum State { PLAYING, DYING, ROUND_END, GAME_OVER, COMPLETED }

var simulation: Simulation = Simulation.new()
var score: Score = Score.new()
var progression: Progression = Progression.new(DEFAULT_MODES)
var world: World = World.new()
var platforms: Array[bool] = [true, true]
var rescue_remaining: int = 0
var last_platform_bonus: int = 0
var state: State = State.PLAYING
var paused: bool = false
var round_index: int = 0
var active_ticks: int = 0
var remaining_ticks: int = 0
var protection_ticks: int = 0
var last_bonus: int = 0
var _modes: Array[int] = DEFAULT_MODES.duplicate()

var level_number: int:
	get:
		return round_index / 4 + 1
var round_number: int:
	get:
		return round_index % 4 + 1
var accepts_movement: bool:
	get:
		return state == State.PLAYING and not paused and rescue_remaining == 0


func _init() -> void:
	simulation.defer_cell_effects = true
	world.seed(1)
	start_new_game()


func start_new_game(modes: Array[int] = DEFAULT_MODES, settings: Dictionary = {}) -> bool:
	if modes.size() != ROUND_COUNT:
		return false
	for mode: int in modes:
		if not PyramidBoard.is_valid_color_mode(mode):
			return false
	var candidate: Progression = Progression.new(modes)
	if not candidate.configure(settings):
		return false
	_modes = modes.duplicate()
	progression = candidate
	score.reset()
	round_index = 0
	active_ticks = 0
	paused = false
	_begin_round()
	return true


func set_paused(value: bool) -> void:
	if state == State.GAME_OVER or state == State.COMPLETED:
		return
	paused = value
	simulation.set_paused(value or state != State.PLAYING)


func step(input_events: Array[Dictionary] = []) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if paused or state == State.GAME_OVER or state == State.COMPLETED:
		return events
	if state == State.DYING or state == State.ROUND_END:
		remaining_ticks -= 1
		if remaining_ticks == 0:
			if state == State.DYING:
				if score.lives == 0:
					state = State.GAME_OVER
					events.append({"type": "game_over"})
				else:
					simulation.respawn()
					state = State.PLAYING
					protection_ticks = PROTECTION_TICKS
					events.append({"type": "respawn"})
			else:
				round_index += 1
				_begin_round()
				events.append({"type": "round_started", "round_index": round_index})
		return events
	active_ticks += 1
	if protection_ticks > 0:
		protection_ticks -= 1
	var before: Dictionary = simulation.get_snapshot()
	var was_rescuing: bool = rescue_remaining > 0
	if was_rescuing:
		rescue_remaining -= 1
		if rescue_remaining == 0:
			simulation.respawn()
			world.lure_cell = Vector2i(-1, -1)
			events.append({"type": "rescue_completed"})
	else:
		events = simulation.step(input_events)
	for event: Dictionary in events:
		if event["type"] == "jump_fallen":
			request_death(&"fall")
			return events
	var after: Dictionary = simulation.get_snapshot()
	# During a disc trip the old cell is not occupied. At its conclusion the
	# arrival at the apex happens before collision and collection checks.
	if was_rescuing:
		before["is_airborne"] = true
		before["jump_from"] = Vector2i(-1, -1)
		before["jump_to"] = Vector2i(-1, -1)
		if rescue_remaining > 0:
			after["is_airborne"] = true
			after["jump_from"] = Vector2i(-1, -1)
			after["jump_to"] = Vector2i(-1, -1)
	var resolved: Dictionary = world.advance(before, after, rescue_remaining > 0 or protection_ticks > 0)
	if resolved["lethal"]:
		# Arrivals/collisions precede departures at the same instant. A start
		# computed by the movement model is provisional until this check.
		for event: Dictionary in events.duplicate():
			if event["type"] == "jump_started":
				simulation.is_airborne = false
				simulation.jump_id = before["jump_id"]
				simulation.jump_from = before["jump_from"]
				simulation.jump_to = before["jump_to"]
				simulation.jump_start_tick = before["jump_start_tick"]
				simulation.jump_end_tick = before["jump_end_tick"]
				events.erase(event)
		request_death(&"contact")
		return events
	for actor_id: int in resolved["collected"]:
		score.credit("round:%d:actor:%d" % [round_index, actor_id], 300)
	if resolved["stasis_collected"]:
		score.credit("round:%d:stasis" % round_index, 100)
		events.append({"type": "stasis_collected"})
	if resolved["stasis_fallen"]:
		events.append({"type": "stasis_fallen"})
	for actor: Dictionary in resolved["escaped"]:
		events.append({"type": "actor_fallen", "kind": actor["kind"], "id": actor["id"], "lured": actor.get("lured", false)})
		if actor["kind"] == 1 and actor.get("lured", false):
			score.credit("round:%d:chaser:%d" % [round_index, actor["id"]], 500)
			world.actors.clear()
	for event: Dictionary in events:
		if event["type"] == "jump_fallen":
			request_death(&"fall")
			return events
		elif event["type"] == "jump_started":
			var platform: int = _platform_for(event["from"], event["to"])
			if platform >= 0 and platforms[platform]:
				platforms[platform] = false
				rescue_remaining = 72
				world.set_lure_target(event["from"])
				simulation.is_airborne = false
				simulation.set_paused(true)
				event["type"] = "rescue_started"
		elif event["type"] == "jump_landed":
			var color: Dictionary = simulation.board.apply_landing(event["to"])
			event["color_before"] = color["before"]
			event["color_after"] = color["after"]
			_credit_landing(event)
	for actor: Dictionary in resolved["landed"]:
		if actor["kind"] == 3 and world.actors.has(actor):
			simulation.board.apply_sabotage(actor["cell"])
	if simulation.board.all_complete:
		last_bonus = mini(1000 + 250 * round_index, 5000)
		last_platform_bonus = 50 * (int(platforms[0]) + int(platforms[1]))
		score.credit("round:%d:bonus" % round_index, last_bonus)
		if last_platform_bonus > 0:
			score.credit("round:%d:platforms" % round_index, last_platform_bonus)
		state = State.ROUND_END
		remaining_ticks = ROUND_END_TICKS
		simulation.set_paused(true)
		return events
	world.depart_and_spawn(simulation.cell, simulation.is_airborne or rescue_remaining > 0,
		simulation.jump_to if simulation.is_airborne else (Vector2i.ZERO if rescue_remaining > 0 else Vector2i(-1, -1)))
	return events


func request_death(cause: StringName) -> bool:
	# Stasis protects contacts only; falls remain lethal.
	if not accepts_movement or cause not in [&"fall", &"contact"]:
		return false
	if cause == &"contact" and (protection_ticks > 0 or world.stasis_remaining > 0):
		return false
	score.lives -= 1
	protection_ticks = 0
	remaining_ticks = DEATH_TICKS
	rescue_remaining = 0
	world.after_death()
	state = State.DYING
	simulation.set_paused(true)
	return true


func snapshot() -> Dictionary:
	return {"state": state, "paused": paused, "round_index": round_index,
		"active_ticks": active_ticks, "remaining_ticks": remaining_ticks,
		"protection_ticks": protection_ticks, "last_bonus": last_bonus,
		"score": score.snapshot(), "simulation": simulation.get_snapshot(),
		"modes": _modes.duplicate(), "platforms": platforms.duplicate(),
		"rescue_remaining": rescue_remaining, "world_tick": world.tick,
		"actors": world.actors.duplicate(true), "stasis_remaining": world.stasis_remaining,
		"world": world.snapshot(), "progression": progression.snapshot()}


func _begin_round() -> void:
	state = State.PLAYING
	remaining_ticks = 0
	protection_ticks = 0
	last_bonus = 0
	last_platform_bonus = 0
	platforms = [true, true]
	rescue_remaining = 0
	world.reset_round(round_index, progression)
	simulation.reset(progression.color_mode(round_index))


func _credit_landing(event: Dictionary) -> void:
	var after: int = int(event["color_after"])
	if after <= int(event["color_before"]):
		return
	var cell: Vector2i = event["to"]
	var id: String = "round:%d:cell:%d,%d:state:%d" % [round_index, cell.x, cell.y, after]
	var amount: int = 25 if after == simulation.board.target_state() else 15
	score.credit(id, amount)


func _platform_for(from_cell: Vector2i, to_cell: Vector2i) -> int:
	if PyramidBoard.is_valid_cell(to_cell):
		return -1
	if from_cell == Vector2i(3, 0) and to_cell == Vector2i(2, -1):
		return 0
	if from_cell == Vector2i(5, 5) and to_cell == Vector2i(4, 5):
		return 1
	return -1
