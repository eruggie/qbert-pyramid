extends RefCounted
const Profile = preload("res://scripts/core/player_profile.gd")
var runner: SceneTree

func run(tree: SceneTree) -> void:
	runner = tree
	_begin("phase4_profile_roundtrip_backup_and_corruption")
	var repository: Profile = Profile.new("user://profile-test.json")
	_check(repository.load_profile() == Profile.defaults(), "Dati assenti avviano con i predefiniti.")
	var data: Dictionary = Profile.defaults()
	data["record"] = 12345
	data["record_level"] = 3
	data["bindings"] = [KEY_A, KEY_D, KEY_S, KEY_F]
	_check(repository.save_profile(data), "Primo salvataggio atomico.")
	_check(Profile.new(repository.path).load_profile() == data, "Una nuova istanza ricarica record e impostazioni.")
	data["record"] = 15000
	_check(repository.save_profile(data), "Secondo salvataggio con backup.")
	_write(repository.path, "{broken")
	var recovered: Dictionary = repository.load_profile()
	_check(recovered["record"] == 12345 and not repository.notice.is_empty(), "File danneggiato recuperato dal backup valido.")
	_check(repository.save_profile(recovered), "Riparazione del primario senza sovrascrivere backup con dati corrotti.")
	_write(repository.path, "[]")
	_write(repository.path + ".bak", "null")
	_check(repository.load_profile() == Profile.defaults(), "Entrambe le copie corrotte: avvio possibile.")
	_write(repository.path + ".tmp", JSON.stringify(data))
	_check(repository.load_profile() == Profile.defaults(), "Una scrittura temporanea incompleta non diventa il profilo ufficiale.")

	_begin("phase4_profile_rejects_invalid_types_and_future_versions")
	for entry: Array in [["record", -1], ["record", 1.5], ["record", "123"], ["master", 2], ["effects", -0.1], ["muted", 1], ["fullscreen", "yes"], ["width", 10], ["height", 99], ["record_round", 5], ["record_level", 0], ["bindings", [KEY_A, KEY_A, 0, 0]], ["bindings", [KEY_Q, 0, 0, 0]], ["bindings", [1e300, 0, 0, 0]]]:
		var bad: Dictionary = Profile.defaults()
		bad[entry[0]] = entry[1]
		_check(Profile.validate(bad).is_empty(), "Profilo malformato rifiutato: %s." % str(entry))
	var future: Dictionary = Profile.defaults()
	future["schema"] = 99
	_write(repository.path, JSON.stringify(future))
	_check(repository.load_profile() == Profile.defaults() and repository.read_only, "Versione futura: avvio con predefiniti, dati protetti.")
	_check(not repository.save_profile(data) and JSON.parse_string(FileAccess.get_file_as_string(repository.path))["schema"] == 99, "Non sovrascrive dati di una versione futura.")

	_begin("phase4_failed_save_preserves_runtime_and_old_copy")
	var failure: Profile = Profile.new("user://nonexistent/subdir/profile.json")
	_check(not failure.save_profile(data) and not failure.notice.is_empty(), "Errore di scrittura riportato senza errore del motore.")
	_check(data["record"] == 15000, "Il fallimento non muta i dati in memoria.")
	var interrupted: Profile = Profile.new("user://interrupted.json")
	_check(interrupted.save_profile(data), "Base valida prima di una scrittura interrotta.")
	DirAccess.make_dir_absolute(interrupted.path + ".tmp")
	_check(not interrupted.save_profile(Profile.defaults()), "Destinazione temporanea non scrivibile rifiutata.")
	_check(Profile.new(interrupted.path).load_profile()["record"] == 15000, "Il vecchio primario resta leggibile dopo errore.")

	_begin("arcade_profile_schema1_migration_preserves_preferences")
	var legacy: Dictionary = Profile.defaults()
	legacy["schema"] = 1
	legacy.erase("leaderboard")
	legacy["music"] = 0.72
	legacy["record"] = 98765
	legacy["record_level"] = 7
	legacy["record_round"] = 3
	legacy["master"] = 0.31
	legacy["effects"] = 0.27
	legacy["muted"] = true
	legacy["fullscreen"] = true
	legacy["bindings"] = [KEY_A, KEY_D, KEY_S, KEY_F]
	var migration: Profile = Profile.new("user://legacy-phase5.json")
	_write(migration.path, JSON.stringify(legacy))
	var migrated: Dictionary = migration.load_profile()
	_check(migrated["schema"] == 4 and not migrated.has("music"), "Schema 1 migrato senza volume musica obsoleto.")
	for key: String in ["record", "record_level", "record_round", "master", "effects", "muted", "fullscreen", "width", "height", "bindings"]:
		_check(migrated[key] == legacy[key], "Migrazione conserva " + key)
	_check(migration.save_profile(migrated) and Profile.new(migration.path).load_profile() == migrated, "Migrazione persiste e si ricarica al riavvio.")
	_write(migration.path, "broken")
	_check(migration.load_profile() == migrated, "Anche il backup schema 1 viene recuperato e migrato.")

	_begin("phase6_profile_schema2_persists_between_processes")
	for mode: String in ["write", "read"]:
		var output: Array = []
		var status: int = OS.execute(OS.get_executable_path(), PackedStringArray([
			"--headless", "--audio-driver", "Dummy", "--path", ProjectSettings.globalize_path("res://"),
			"--script", "res://tests/profile_process_smoke.gd", "--", mode]), output, true)
		_check(status == 0 and str(output).contains("PHASE6_PROFILE_" + mode.to_upper() + "_OK"), "Processo separato " + mode + ": migrazione schema 2, punteggio, metadati e preferenze persistenti.")

func _write(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func _begin(name: String) -> void:
	runner.call("_begin_test", name)

func _check(value: bool, message: String) -> void:
	runner.call("_check", value, message)
