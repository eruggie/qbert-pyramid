class_name PyramidProgression
extends RefCounted
## Finite opening and configurable bounded progression, independent of devices.

const SPAWN_SECONDS: Array[float] = [5.0, 4.6, 4.2, 3.8, 3.6, 3.3, 3.0, 2.8, 2.6, 2.4, 2.2, 2.0]
const ENEMY_CAPS: Array[int] = [2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6]
var minimum_spawn_seconds: float = 1.2
var maximum_enemies: int = 8
var initial_modes: Array[int] = []
var continuous_modes: Array[int] = [0, 1, 2]
var spawn_start_seconds: float = 2.0
var spawn_reduction_per_level: float = 0.1
var spawn_reduction_per_round: float = 0.1
var initial_enemy_cap: int = 6
var cap_growth_levels: int = 2
var minimum_speed_factor: float = 0.6
var speed_reduction_per_level: float = 0.02


func _init(modes: Array[int] = []) -> void:
	initial_modes = modes.duplicate()


func color_mode(round_index: int) -> int:
	if round_index < initial_modes.size():
		return initial_modes[round_index]
	return continuous_modes[((round_index / 4) - 3) % continuous_modes.size()]


func spawn_interval(round_index: int) -> int:
	if round_index < SPAWN_SECONDS.size():
		return roundi(SPAWN_SECONDS[round_index] * 60.0)
	var level: int = round_index / 4 + 1
	var round_in_level: int = round_index % 4
	return roundi(maxf(minimum_spawn_seconds, spawn_start_seconds - spawn_reduction_per_level * float(level - 4) - spawn_reduction_per_round * float(round_in_level)) * 60.0)


func enemy_cap(round_index: int) -> int:
	if round_index < ENEMY_CAPS.size():
		return ENEMY_CAPS[round_index]
	var level: int = round_index / 4 + 1
	return mini(maximum_enemies, initial_enemy_cap + (level - 4) / cap_growth_levels)


func speed_factor(round_index: int) -> float:
	if round_index < 12:
		return 1.0 - 0.02 * float(round_index)
	var level: int = round_index / 4 + 1
	return maxf(minimum_speed_factor, 0.78 - speed_reduction_per_level * float(level - 3))


func configure(settings: Dictionary) -> bool:
	for key: String in ["spawn_start_seconds", "minimum_spawn_seconds", "spawn_reduction_per_level", "spawn_reduction_per_round", "minimum_speed_factor", "speed_reduction_per_level"]:
		if settings.has(key) and typeof(settings[key]) not in [TYPE_INT, TYPE_FLOAT]:
			return false
	for key: String in ["initial_enemy_cap", "maximum_enemies", "cap_growth_levels"]:
		if settings.has(key) and typeof(settings[key]) != TYPE_INT:
			return false
	var cycle_value: Variant = settings.get("continuous_modes", continuous_modes)
	if not cycle_value is Array or cycle_value.is_empty():
		return false
	var cycle: Array[int] = []
	for value: Variant in cycle_value:
		if typeof(value) != TYPE_INT or not PyramidBoard.is_valid_color_mode(value):
			return false
		cycle.append(value)
	var start: float = float(settings.get("spawn_start_seconds", spawn_start_seconds))
	var minimum: float = float(settings.get("minimum_spawn_seconds", minimum_spawn_seconds))
	var level_delta: float = float(settings.get("spawn_reduction_per_level", spawn_reduction_per_level))
	var round_delta: float = float(settings.get("spawn_reduction_per_round", spawn_reduction_per_round))
	var first_cap: int = int(settings.get("initial_enemy_cap", initial_enemy_cap))
	var max_cap: int = int(settings.get("maximum_enemies", maximum_enemies))
	var growth: int = int(settings.get("cap_growth_levels", cap_growth_levels))
	var floor_speed: float = float(settings.get("minimum_speed_factor", minimum_speed_factor))
	var speed_delta: float = float(settings.get("speed_reduction_per_level", speed_reduction_per_level))
	if not is_finite(start) or not is_finite(minimum) or not is_finite(level_delta) or not is_finite(round_delta) or not is_finite(floor_speed) or not is_finite(speed_delta):
		return false
	if minimum < 0.6 or start < minimum or level_delta < 0.0 or round_delta < 0.0:
		return false
	if first_cap < 1 or max_cap < first_cap or max_cap > 8 or growth < 1:
		return false
	if floor_speed < 0.6 or floor_speed > 0.78 or speed_delta < 0.0:
		return false
	continuous_modes = cycle
	spawn_start_seconds = start
	minimum_spawn_seconds = minimum
	spawn_reduction_per_level = level_delta
	spawn_reduction_per_round = round_delta
	initial_enemy_cap = first_cap
	maximum_enemies = max_cap
	cap_growth_levels = growth
	minimum_speed_factor = floor_speed
	speed_reduction_per_level = speed_delta
	return true


func snapshot() -> Dictionary:
	return {"initial_modes": initial_modes.duplicate(), "continuous_modes": continuous_modes.duplicate(),
		"spawn_start_seconds": spawn_start_seconds, "minimum_spawn_seconds": minimum_spawn_seconds,
		"spawn_reduction_per_level": spawn_reduction_per_level, "spawn_reduction_per_round": spawn_reduction_per_round,
		"initial_enemy_cap": initial_enemy_cap, "maximum_enemies": maximum_enemies,
		"cap_growth_levels": cap_growth_levels, "minimum_speed_factor": minimum_speed_factor,
		"speed_reduction_per_level": speed_reduction_per_level}
