class_name RoundConfiguration
extends Resource
## Editable phase 3 progression; the initial twelve rounds remain explicit.

@export var color_modes: Array[int] = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2]
@export var continuous_modes: Array[int] = [0, 1, 2]
@export var spawn_start_seconds: float = 2.0
@export var minimum_spawn_seconds: float = 1.2
@export var spawn_reduction_per_level: float = 0.1
@export var spawn_reduction_per_round: float = 0.1
@export var initial_enemy_cap: int = 6
@export var maximum_enemies: int = 8
@export var cap_growth_levels: int = 2
@export var minimum_speed_factor: float = 0.6
@export var speed_reduction_per_level: float = 0.02


func progression_settings() -> Dictionary:
	return {"continuous_modes": continuous_modes.duplicate(),
		"spawn_start_seconds": spawn_start_seconds, "minimum_spawn_seconds": minimum_spawn_seconds,
		"spawn_reduction_per_level": spawn_reduction_per_level, "spawn_reduction_per_round": spawn_reduction_per_round,
		"initial_enemy_cap": initial_enemy_cap, "maximum_enemies": maximum_enemies,
		"cap_growth_levels": cap_growth_levels, "minimum_speed_factor": minimum_speed_factor,
		"speed_reduction_per_level": speed_reduction_per_level}
