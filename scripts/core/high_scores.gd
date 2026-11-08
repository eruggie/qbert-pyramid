class_name HighScores
extends RefCounted
## Original local ten-entry ranking, stable ties and no fabricated scores.
const CAPACITY: int = 10
const NAME_LENGTH: int = 3

static func clean_name(value: String) -> String:
	var result: String = ""
	for character: String in value.to_upper():
		if character in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
			result += character
	return result.left(NAME_LENGTH)

static func qualifies(entries: Array, points: int) -> bool:
	return points > 0 and (entries.size() < CAPACITY or points > int(entries[-1]["points"]))

static func insert(entries: Array, points: int, level: int, round_number: int, player_name: String) -> Array:
	var result: Array = entries.duplicate(true)
	if not qualifies(result, points):
		return result
	var cleaned: String = clean_name(player_name)
	if cleaned.length() != NAME_LENGTH:
		return result
	var entry: Dictionary = {"name": cleaned if not cleaned.is_empty() else "AAA", "points": points, "level": level, "round": round_number}
	var index: int = 0
	while index < result.size() and int(result[index]["points"]) >= points:
		index += 1
	result.insert(index, entry)
	if result.size() > CAPACITY:
		result.resize(CAPACITY)
	return result

static func validate(value: Variant) -> Array:
	# Caller checks container, length and exact validation equality.
	var result: Array = []
	if not value is Array or value.size() > CAPACITY:
		return result
	var last_points: int = 2147483647
	for item: Variant in value:
		if not item is Dictionary or item.size() not in [4, 5] or (item.size() == 5 and not item.has("legacy_name")) or not item.has_all(["name", "points", "level", "round"]):
			return []
		if not item["name"] is String or item["name"].length() != NAME_LENGTH or clean_name(item["name"]) != item["name"]:
			return []
		for key: String in ["points", "level", "round"]:
			if typeof(item[key]) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(item[key])) or float(item[key]) != floorf(float(item[key])):
				return []
		if item["points"] <= 0 or item["points"] > last_points or item["level"] < 1 or item["level"] > 1000000 or item["round"] < 1 or item["round"] > 4:
			return []
		if item.has("legacy_name") and (not item["legacy_name"] is String or item["legacy_name"].is_empty() or item["legacy_name"].length() > 8):
			return []
		last_points = int(item["points"])
		result.append({"name": item["name"], "points": int(item["points"]), "level": int(item["level"]), "round": int(item["round"])})
		if item.has("legacy_name"):
			result[-1]["legacy_name"] = item["legacy_name"]
	return result


static func migrate_legacy(entries: Array) -> Array:
	# Schema 3 allowed eight characters. Preserve their full original spelling.
	var converted: Array = []
	for entry: Variant in entries:
		if not entry is Dictionary or not entry.has_all(["name", "points", "level", "round"]) or not entry["name"] is String or entry["name"].length() > 8 or entry["name"].is_empty():
			return []
		if entry.size() != 4: return []
		for character: String in entry["name"]:
			if character not in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ": return []
		var item: Dictionary = entry.duplicate(true)
		var old_name: String = item["name"]
		item["name"] = clean_name(old_name).rpad(NAME_LENGTH, "A")
		if item["name"] != old_name:
			item["legacy_name"] = old_name
		converted.append(item)
	return validate(converted)
