class_name PyramidScore
extends RefCounted
## Idempotent credits for one game. No device, scene or persistence dependencies.

const INITIAL_LIVES: int = 3
const MAX_LIVES: int = 5
const FIRST_EXTRA: int = 8000
const EXTRA_INTERVAL: int = 14000

var points: int = 0
var lives: int = INITIAL_LIVES
var next_extra: int = FIRST_EXTRA
var _credits: Dictionary = {}


func reset() -> void:
	points = 0
	lives = INITIAL_LIVES
	next_extra = FIRST_EXTRA
	_credits.clear()


func credit(id: String, amount: int) -> bool:
	if id.is_empty() or amount <= 0 or _credits.has(id):
		return false
	_credits[id] = true
	points += amount
	while points >= next_extra:
		lives = mini(lives + 1, MAX_LIVES)
		next_extra += EXTRA_INTERVAL
	return true


func snapshot() -> Dictionary:
	return {"points": points, "lives": lives, "next_extra": next_extra, "credits": _credits.duplicate(true)}
