class_name ArcadePalette
extends RefCounted
## Presentation only. S2/S3/S4-S5/S6/S8 in docs/ARCADE_REVIEW.md.
const TABLE: Array = [
	["5945eb", "dc7eb0", "dce013", "58a79a", "2f4745"],
	["f0dd80", "cc4776", "0844d9", "794000", "ff7c22"],
	["c2d6d4", "a087cd", "47494d", "7b7e80", "272a2d"],
	["075be2", "b31394", "b0bb12", "819793", "1a138c"],
	["0844d9", "f0dd80", "27bd39", "794000", "ff7c22"]]

static func for_round(round_index: int) -> Array[Color]:
	var index: int = clampi(round_index, 0, 4) if round_index < 5 else 1 + posmod(round_index - 5, 4)
	var result: Array[Color] = []
	for value: String in TABLE[index]:
		result.append(Color(value))
	return result
