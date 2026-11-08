class_name PlayerProfile
extends RefCounted
## Validated, versioned player data. Never depends on scenes or input dispatch.
const VERSION: int = 4
const Scores = preload("res://scripts/core/high_scores.gd")
const FIXED_KEYS: Array[int] = [KEY_Q, KEY_E, KEY_Z, KEY_C, KEY_P, KEY_R]
var path: String
var notice: String = ""
var legacy_path: String = ""
var read_only: bool = false

func _init(location: String = "user://profile.json", previous_location: String = "") -> void:
	path = location
	legacy_path = previous_location

static func defaults() -> Dictionary:
	return {"schema": VERSION, "leaderboard": [], "record": 0, "record_level": 1, "record_round": 1,
		"master": 0.8, "effects": 0.8, "muted": false,
		"fullscreen": false, "width": 1280, "height": 720, "bindings": [0, 0, 0, 0]}

static func binding_error(bindings: Array, direction: int, key: int) -> String:
	if direction < 0 or direction > 3 or bindings.size() != 4:
		return "Direzione non valida."
	if key == 0:
		return ""
	if not ((key >= KEY_A and key <= KEY_Z) or (key >= KEY_0 and key <= KEY_9)) or key in FIXED_KEYS:
		return "Usa una lettera o cifra libera; i comandi predefiniti restano disponibili."
	for index: int in range(4):
		if index != direction and int(bindings[index]) == key:
			return "Tasto già usato da un'altra direzione."
	return ""

static func validate(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	var source: Dictionary = value
	var result: Dictionary = defaults()
	for key: String in result:
		if key == "leaderboard" and (source.get("schema", VERSION) == 1 or source.get("schema", VERSION) == 2):
			continue
		if not source.has(key):
			return {}
	for key: String in ["schema", "record", "record_level", "record_round", "width", "height"]:
		if typeof(source[key]) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(source[key])) or float(source[key]) != floorf(float(source[key])):
			return {}
		result[key] = int(source[key])
	if result["schema"] not in [1, 2, 3, VERSION] or result["record"] < 0 or result["record"] > 2147483647 or result["record_level"] < 1 or result["record_level"] > 1000000 or result["record_round"] < 1 or result["record_round"] > 4:
		return {}
	if result["width"] < 960 or result["width"] > 7680 or result["height"] < 540 or result["height"] > 4320:
		return {}
	# Schema 1 (phase 5) had a music volume. Validate then discard only that field.
	if result["schema"] == 1:
		if not source.has("music") or typeof(source["music"]) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(source["music"])) or float(source["music"]) < 0.0 or float(source["music"]) > 1.0:
			return {}
	if result["schema"] in [1, 2]:
		if result["record"] > 0:
			result["leaderboard"] = Scores.migrate_legacy([{"name": "STORICO", "points": result["record"], "level": result["record_level"], "round": result["record_round"]}])
	else:
		if not source["leaderboard"] is Array or source["leaderboard"].size() > Scores.CAPACITY:
			return {}
		result["leaderboard"] = Scores.migrate_legacy(source["leaderboard"]) if result["schema"] == 3 else Scores.validate(source["leaderboard"])
		if result["leaderboard"].size() != source["leaderboard"].size():
			return {}
		if not result["leaderboard"].is_empty() and int(result["leaderboard"][0]["points"]) > result["record"]:
			return {}
	result["schema"] = VERSION
	for key: String in ["master", "effects"]:
		if typeof(source[key]) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(source[key])) or float(source[key]) < 0.0 or float(source[key]) > 1.0:
			return {}
		result[key] = float(source[key])
	for key: String in ["muted", "fullscreen"]:
		if typeof(source[key]) != TYPE_BOOL:
			return {}
		result[key] = source[key]
	if not source["bindings"] is Array or source["bindings"].size() != 4:
		return {}
	var bindings: Array = source["bindings"].duplicate()
	for index: int in range(4):
		if typeof(bindings[index]) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(bindings[index])) or float(bindings[index]) < 0.0 or float(bindings[index]) > KEY_Z or float(bindings[index]) != floorf(float(bindings[index])):
			return {}
		bindings[index] = int(bindings[index])
		if not binding_error(bindings, index, int(bindings[index])).is_empty():
			return {}
	result["bindings"] = bindings
	return result

func load_profile() -> Dictionary:
	notice = ""
	read_only = false
	var raw: Variant = _read(path)
	if raw == null and not FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".bak") and not legacy_path.is_empty():
		for old_path: String in [legacy_path, legacy_path + ".bak"]:
			var migrated: Dictionary = validate(_read(old_path))
			if not migrated.is_empty():
				notice = "Profilo precedente recuperato; l'originale resta conservato."
				return migrated
	if raw is Dictionary and typeof(raw.get("schema")) in [TYPE_FLOAT, TYPE_INT] and float(raw["schema"]) > VERSION:
		read_only = true
		notice = "Dati di una versione futura: uso i predefiniti senza sovrascriverli."
		return defaults()
	var valid: Dictionary = validate(raw)
	if not valid.is_empty():
		return valid
	valid = validate(_read(path + ".bak"))
	if not valid.is_empty():
		notice = "Dati recuperati dalla copia di sicurezza."
		return valid
	if FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak"):
		notice = "Dati non leggibili: uso i predefiniti. La partita può continuare."
	return defaults()

func save_profile(value: Dictionary) -> bool:
	var valid: Dictionary = validate(value)
	if read_only or valid.is_empty():
		return false
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		notice = "Salvataggio non disponibile; i dati restano in memoria."
		return false
	file.store_string(JSON.stringify(valid, "\t") + "\n")
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK or validate(_read(path + ".tmp")).is_empty():
		notice = "Scrittura incompleta; conservata la copia precedente."
		return false
	# Copy only a validated primary: never replace a good backup with corruption.
	if not validate(_read(path)).is_empty():
		if DirAccess.copy_absolute(path, path + ".bak.tmp") != OK or DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak") != OK:
			notice = "Impossibile aggiornare il backup; conservati i dati precedenti."
			return false
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		notice = "Impossibile sostituire i dati; conservata la copia precedente."
		return false
	notice = ""
	return true

func _read(location: String) -> Variant:
	if not FileAccess.file_exists(location):
		return null
	var file: FileAccess = FileAccess.open(location, FileAccess.READ)
	if file == null:
		return null
	if file.get_length() > 65536:
		file.close()
		return null
	var text: String = file.get_as_text()
	file.close()
	var parser: JSON = JSON.new()
	return parser.data if parser.parse(text) == OK else null
