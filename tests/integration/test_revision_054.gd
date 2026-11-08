extends RefCounted
const Profile = preload("res://scripts/core/player_profile.gd")
const Scores = preload("res://scripts/core/high_scores.gd")
const Intro = preload("res://scripts/ui/attract_panel.gd")
const Identity = preload("res://scripts/core/game_identity.gd")
var runner: SceneTree

func run(tree: SceneTree) -> void:
	runner = tree
	_test_scores_and_migration()
	await _test_game_over()
	await _test_intro_and_instructions()
	await _test_ranking_layout()

func _test_scores_and_migration() -> void:
	_begin("054_top_ten_disk_initials_metadata_and_legacy_folder")
	var entries: Array = []
	var names: Array[String] = ["AAA", "AAB", "AAC", "AAD", "AAE", "AAF", "AAG", "AAH", "AAI", "AAJ", "AAK", "AAL"]
	for i: int in range(12): entries = Scores.insert(entries, (i + 1) * 100, i + 1, i % 4 + 1, names[i])
	_check(entries.size() == 10 and entries[0]["points"] == 1200 and entries[-1]["points"] == 300, "Persistono i dieci risultati più alti, ordinati.")
	_check(not Scores.qualifies(entries, 300) and Scores.qualifies(entries, 301), "Soglia top ten e pareggio sull'ultimo definiti.")
	var data: Dictionary = Profile.defaults()
	data["record"] = 1200
	data["leaderboard"] = entries
	var disk: PlayerProfile = Profile.new("user://top-ten-054.json")
	_check(disk.save_profile(data) and Profile.new(disk.path).load_profile() == data, "Classifica completa, nomi, punti e livello/round riletti dal disco.")
	for name: String in ["", "A", "AB", "A1C", "ABCD"]:
		var invalid: Dictionary = data.duplicate(true)
		invalid["leaderboard"][0]["name"] = name
		_check(Profile.validate(invalid).is_empty(), "Esattamente tre lettere nel profilo: " + name)
	var old: Dictionary = Profile.defaults()
	old["schema"] = 3
	old["record"] = 777
	old["effects"] = .27
	old["leaderboard"] = [{"name": "PLAYER12", "points": 777, "level": 6, "round": 3}]
	var legacy_path: String = "user://previous-054.json"
	var file: FileAccess = FileAccess.open(legacy_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(old)); file.close()
	var original: String = FileAccess.get_file_as_string(legacy_path)
	var migrated_store: PlayerProfile = Profile.new("user://renamed-054.json", legacy_path)
	var migrated: Dictionary = migrated_store.load_profile()
	_check(migrated["schema"] == 4 and migrated["effects"] == .27 and migrated["leaderboard"][0] == {"name": "PLA", "legacy_name": "PLAYER12", "points": 777, "level": 6, "round": 3}, "Schema 3 e cartella precedente recuperati senza perdere nomi o metadati.")
	_check(migrated_store.save_profile(migrated) and FileAccess.get_file_as_string(legacy_path) == original, "Salvataggio nel nuovo percorso lascia intatto l'originale.")
	_check(Profile.new(migrated_store.path).load_profile() == migrated, "Avvio successivo legge il nuovo profilo autonomamente.")

func _screen() -> GameScreen:
	runner.change_scene_to_file("res://scenes/game_screen.tscn")
	await runner.process_frame
	await runner.process_frame
	var screen: GameScreen = runner.current_scene as GameScreen
	screen.set_physics_process(false)
	screen.set_process(false)
	return screen

func _test_game_over() -> void:
	_begin("054_game_over_30_seconds_blink_and_all_game_keys")
	var screen: GameScreen = await _screen()
	screen.game.state = PyramidGame.State.GAME_OVER
	screen._refresh_ui()
	var cancel: InputEventKey = InputEventKey.new()
	cancel.keycode = KEY_ESCAPE; cancel.physical_keycode = KEY_ESCAPE; cancel.pressed = true
	screen.handle_input_event(cancel)
	_check(not screen.records_opened, "Esc non scavalca il tempo di Game Over.")
	screen._process(.25)
	_check(screen.game_over_label.visible and screen.game_over_banner.visible, "Fase visibile del lampeggio.")
	screen._process(.30)
	_check(not screen.game_over_label.visible and screen.game_over_banner.visible, "Fase spenta: lampeggia solo il testo, senza sparire il comando.")
	screen.game_over_elapsed = 29.9
	screen._process(.09)
	_check(not screen.records_opened, "Nessun passaggio automatico prima dei 30 secondi.")
	screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	screen._process(100)
	_check(not screen.records_opened, "Focus perso congela il timer.")
	screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	screen._process(.02)
	_check(screen.records_opened, "Dopo 30 secondi apre automaticamente la classifica.")
	for key: int in [KEY_Q, KEY_E, KEY_Z, KEY_C, KEY_LEFT, KEY_UP, KEY_DOWN, KEY_RIGHT, KEY_KP_7, KEY_KP_9, KEY_KP_1, KEY_KP_3]:
		screen.start_new_game()
		screen.game.state = PyramidGame.State.GAME_OVER
		var event: InputEventKey = InputEventKey.new()
		event.keycode = key; event.physical_keycode = key; event.pressed = true
		event.echo = true
		screen.handle_input_event(event)
		_check(not screen.records_opened, "Il mantenuto/echo non salta automaticamente Game Over.")
		event.echo = false
		_check(screen.handle_input_event(event) and screen.records_opened, "Tasto di gioco apre classifica: " + str(key))
		_check(screen.input_adapter.drain_events().is_empty() and screen.game.state == PyramidGame.State.GAME_OVER, "Tasto consumato senza muovere il protagonista.")
	await runner.process_frame

func _test_intro_and_instructions() -> void:
	_begin("054_startup_sequence_isolated_demo_skip_and_menu")
	var app: Node = runner.root.get_node("App")
	var old_seen: bool = app.intro_seen
	app.intro_seen = false
	runner.change_scene_to_file("res://scenes/main_menu.tscn")
	await runner.process_frame
	await runner.process_frame
	var menu: MainMenu = runner.current_scene as MainMenu
	var intro: AttractPanel = menu.attract_panel
	_check(is_instance_valid(intro) and intro.stage == "instructions", "Il primo avvio mostra le istruzioni progressive.")
	intro.set_process(false)
	intro._process(0)
	_check(intro.tips[0].visible and not intro.tips[1].visible, "Testo rivelato progressivamente.")
	var profile: Dictionary = app.data.duplicate(true)
	intro._process(18)
	_check(intro.stage == "demo", "La dimostrazione segue le istruzioni.")
	for tick: int in range(600): intro._demo_tick()
	_check(app.data == profile, "Demo separata: non modifica classifica, record o profilo.")
	intro._process(20)
	_check(intro.stage == "records" and intro.ranking.read_only, "Segue classifica locale senza inserimento.")
	intro._process(8)
	await runner.process_frame
	_check(not is_instance_valid(menu.attract_panel) and menu.get_node("%GameButton").has_focus(), "Il flusso automatico termina sul menu utilizzabile.")
	menu.show_attract()
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_Q; event.physical_keycode = KEY_Q; event.pressed = true
	_check(menu.attract_panel.handle_input(event), "Il tasto di gioco salta la presentazione.")
	await runner.process_frame
	_check(not is_instance_valid(menu.attract_panel), "Skip non avvia una partita o lascia overlay.")
	_check(menu.instructions_dialog.dialog_text.split("\n")[1] == Identity.PROGRESSION, "Seconda riga permanente del dialogo istruzioni.")
	_check(menu.get_node("Margin/Content/IntroLabel").text.split("\n")[1] == Identity.PROGRESSION, "Seconda riga permanente sul menu.")
	var screen: GameScreen = await _screen()
	_check(screen.get_node("%InputLegendLabel").text.split("\n")[1] == Identity.PROGRESSION, "Seconda riga delle istruzioni durante la partita.")
	_check(ProjectSettings.get_setting("application/config/name") == Identity.TITLE, "Titolo e configurazione concordano.")
	app.intro_seen = old_seen
	app.stop_effects()
	await runner.create_timer(.2).timeout

func _test_ranking_layout() -> void:
	_begin("054_ten_aligned_rows_initials_ui_and_continue_save")
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	app.data = Profile.defaults()
	for i: int in range(10): app.data["leaderboard"] = Scores.insert(app.data["leaderboard"], i + 1, i + 1, i % 4 + 1, "ABC")
	app.data["record"] = 10
	var panel: RecordsPanel = RecordsPanel.new()
	panel.app = app; panel.points = 20
	runner.root.add_child(panel)
	await runner.process_frame
	await runner.process_frame
	_check(panel.ranking_rows.size() == 10, "Dieci righe complete.")
	for row: Array in panel.ranking_rows:
		for column: int in range(5):
			_check(is_equal_approx(row[column].get_global_rect().position.x, panel.ranking_rows[0][column].get_global_rect().position.x), "Colonne allineate su ogni riga.")
	panel.name_edit.text = "A1Z"
	panel.request_continue()
	_check(not panel.submitted and panel.save_button.disabled, "Tre lettere obbligatorie prima di salvare e proseguire.")
	panel.name_edit.text = "xyz"
	panel.request_continue()
	_check(panel.submitted and app.data["leaderboard"][0]["name"] == "XYZ", "Continua conferma e salva il risultato qualificato una volta.")
	_check(Profile.new(app.store.path).load_profile()["leaderboard"] == app.data["leaderboard"], "Riga confermata riletta dal disco locale.")
	panel.queue_free()
	await runner.process_frame
	app.data = original; app.apply_preferences(); app.flush()

func _begin(value: String) -> void: runner.call("_begin_test", value)
func _check(value: bool, message: String) -> void: runner.call("_check", value, message)
