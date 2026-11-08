extends RefCounted
const Cues = preload("res://scripts/presentation/game_audio_cues.gd")
const Profile = preload("res://scripts/core/player_profile.gd")
const Scores = preload("res://scripts/core/high_scores.gd")
var runner: SceneTree

func run(tree: SceneTree) -> void:
	runner = tree
	_test_green_paths()
	_test_green_contacts()
	_test_delayed_chaser()
	_test_audio_transitions()
	_test_rankings()
	await _test_results_screen()
	await _test_record_retry()
	await _test_audio_lifecycle()

func _game() -> PyramidGame:
	var game: PyramidGame = PyramidGame.new()
	game.world.spawning_enabled = false
	game.world.stasis_enabled = false
	return game

func _step(game: PyramidGame, input: Array[Dictionary] = []) -> Array[String]:
	var before: Dictionary = Cues.before_step(game)
	return Cues.resolve(before, game, game.step(input))

func _test_green_paths() -> void:
	_begin("053_green_seed_paths_apex_hops_exit_and_no_respawn")
	var paths: Dictionary = {}
	for seed_value: int in range(12):
		var first: PyramidGame = _game()
		var second: PyramidGame = _game()
		for game: PyramidGame in [first, second]:
			game.round_index = 2
			game._begin_round()
			game.world.stasis_enabled = true
			game.world.seed(seed_value)
			game.world.tick = 719
			# This stationary corner is outside the green paths of the tested seeds.
			game.simulation.cell = Vector2i(6, 6)
			_step(game)
			_check(game.world.stasis_cell == Vector2i.ZERO and game.world.stasis_available, "Nasce all'apice al tick 720.")
		var path: Array[Vector2i] = [Vector2i.ZERO]
		var falls: int = 0
		for tick: int in range(400):
			var old_cell: Vector2i = first.world.stasis_cell
			var cues: Array[String] = _step(first)
			_step(second)
			_check(first.world.snapshot() == second.world.snapshot(), "Stesso seed produce stesso percorso, stato e uscita.")
			if "stasis_fall" in cues:
				falls += 1
			if first.world.stasis_cell != old_cell:
				var cell: Vector2i = first.world.stasis_cell
				_check(cell in [PyramidBoard.neighbor(old_cell, 2), PyramidBoard.neighbor(old_cell, 3)], "Ogni passo scende di una diagonale.")
				if cell.x <= 6:
					_check(PyramidBoard.is_valid_cell(cell), "Prima del bordo tutte le celle sono valide.")
				path.append(cell)
		paths[str(path)] = true
		_check(path.size() == 8 and path[-1].x == 7 and falls == 1 and not first.world.stasis_available, "Sette salti, uscita unica, pillola rimossa.")
		_check(first.score.points == 0 and first.score.lives == 3 and first.state == PyramidGame.State.PLAYING, "Perderla non dà punti e non uccide il giocatore.")
		_check(first.world.falling_actors.is_empty(), "L'animazione di caduta termina e viene rimossa.")
	_check(paths.size() > 1, "Seed differenti producono più percorsi.")

func _test_green_contacts() -> void:
	_begin("053_green_collection_crossing_expiry_cleanup_and_pause")
	var game: PyramidGame = _game()
	game.world.stasis_available = true
	game.world.stasis_spawned = true
	game.world.stasis_cell = Vector2i(1, 0)
	game.world.stasis_motion = {"from": Vector2i(1, 0), "to": Vector2i(2, 0), "moving": false, "start": 0, "end": 0, "next": 100}
	_step(game, [{"type": "press", "direction": 2}])
	_step(game, [{"type": "release", "direction": 2}])
	for tick: int in range(16): _step(game)
	_check(_step(game) == ["stasis_collect"] and game.score.points == 125 and game.world.stasis_remaining == 300, "Raccolta effettiva: cue dedicato, 100 punti più colore.")
	for tick: int in range(10): _check(_step(game).is_empty(), "Nessuna ripetizione del cue raccolta.")
	game = _game()
	game.simulation.reset(0, Vector2i(2, 0))
	game.world.stasis_available = true
	game.world.stasis_spawned = true
	game.world.stasis_cell = Vector2i(1, 0)
	game.world.stasis_motion = {"from": Vector2i(1, 0), "to": Vector2i(2, 0), "moving": true, "start": 0, "end": 24, "next": 42}
	_step(game, [{"type": "press", "direction": 1}])
	var collected: int = 0
	for tick: int in range(24):
		if "stasis_collect" in _step(game): collected += 1
	_check(collected == 1 and not game.world.stasis_available, "Incrocio sui salti opposti raccoglie una sola volta.")
	game = _game()
	game.round_index = 2
	game._begin_round()
	game.world.stasis_enabled = true
	game.world.tick = 719
	game.simulation.cell = Vector2i(6, 6)
	_step(game)
	game.set_paused(true)
	var snapshot: Dictionary = game.snapshot()
	for tick: int in range(60): _step(game)
	_check(snapshot == game.snapshot(), "Pausa congela anche pillola, percorso RNG e animazione.")
	game.set_paused(false)
	_check(game.request_death(&"contact") and not game.world.stasis_available and game.world.stasis_motion.is_empty(), "Morte elimina la pillola senza falsa caduta.")
	_check(game.world.stasis_spawned, "Una sola comparsa per round, anche dopo morte.")

func _test_delayed_chaser() -> void:
	_begin("053_chaser_disc_target_survives_transport_and_freeze")
	for side: int in range(2):
		for frozen: bool in [false, true]:
			var game: PyramidGame = _game()
			var edge: Vector2i = Vector2i(3, 0) if side == 0 else Vector2i(5, 5)
			game.simulation.reset(0, edge)
			game.protection_ticks = 10
			var chaser: Dictionary = {"id": 92, "kind": 1, "cell": edge, "from": edge, "to": edge, "moving": false, "start": 0, "end": 0, "next": 100}
			game.world.actors.append(chaser)
			if frozen: game.world.stasis_remaining = 160
			_check(_step(game, [{"type": "press", "direction": side}]) == ["rescue"], "Disco parte, nessun premio di caduta anticipato.")
			for tick: int in range(72): _step(game)
			_check(game.rescue_remaining == 0 and game.world.actors.has(chaser) and game.score.points == 0, "Il disco è terminato prima della partenza del nemico.")
			var count: int = 0
			var saw_fall: bool = false
			for tick: int in range(150):
				var cues: Array[String] = _step(game)
				if "lure" in cues:
					count += 1
					saw_fall = not game.world.falling_actors.is_empty()
			_check(count == 1 and saw_fall and game.world.actors.is_empty(), "Segugio cade davvero, cue unico e animazione di uscita.")
			_check(game.score.points == 500 and game.score.lives == 3 and game.state == PyramidGame.State.PLAYING, "500 punti unici, nessuna morte del protagonista.")
			_check(game.world.falling_actors.is_empty(), "Residuo grafico rimosso dopo la caduta.")
	var distant: PyramidGame = _game()
	distant.simulation.reset(0, Vector2i(3, 0))
	distant.protection_ticks = 1000
	distant.world.actors.append({"id": 93, "kind": 1, "cell": Vector2i(6, 3), "from": Vector2i(6, 3), "to": Vector2i(6, 3), "moving": false, "start": 0, "end": 0, "next": 100})
	_step(distant, [{"type": "press", "direction": 0}])
	var distant_falls: int = 0
	for tick: int in range(300):
		if "lure" in _step(distant): distant_falls += 1
	_check(distant_falls == 0 and distant.score.points == 0 and distant.world.actors.size() == 1, "Un Segugio lontano che non raggiunge il bordo durante il disco non viene attirato per sempre.")
	var normal: PyramidGame = _game()
	var actor: Dictionary = {"kind": 1, "cell": Vector2i(3, 0)}
	_check(PyramidBoard.is_valid_cell(normal.world._destination(actor, Vector2i.ZERO)), "Il Segugio non cade casualmente da un bordo senza disco.")

func _test_audio_transitions() -> void:
	_begin("053_round_level_game_over_audio_once_and_pause")
	for index: int in range(12):
		var game: PyramidGame = _game()
		game.round_index = index
		game._begin_round()
		for cell: Vector2i in game.simulation.board.cells():
			game.simulation.board.apply_landing(cell)
			if game.simulation.board.color_mode == 1:
				game.simulation.board.apply_landing(cell)
		var before: Dictionary = Cues.before_step(game)
		game.step()
		var cues: Array[String] = Cues.resolve(before, game, [])
		_check(cues == ["level" if index % 4 == 3 else "round"], "Un solo segnale distingue round e livello.")
		game.set_paused(true)
		_check(_step(game).is_empty(), "Pausa non riemette la transizione.")
		game.set_paused(false)
		for tick: int in range(180): _check(_step(game).is_empty(), "Attesa e nuovo round non duplicano il segnale.")
	var combined: PyramidGame = _game()
	combined.round_index = 3
	combined._begin_round()
	combined.score.credit("fixture", 7500)
	for cell: Vector2i in combined.simulation.board.cells():
		if cell != Vector2i(1, 0): combined.simulation.board.apply_landing(cell)
	combined.world.stasis_available = true
	combined.world.stasis_spawned = true
	combined.world.stasis_cell = Vector2i(1, 0)
	_step(combined, [{"type": "press", "direction": 2}])
	_step(combined, [{"type": "release", "direction": 2}])
	for tick: int in range(16): _step(combined)
	_check(_step(combined) == ["level", "stasis_collect", "extra"], "Fine livello, raccolta ed extra simultanei: tre eventi distinti, nessun round duplicato.")
	_check(_step(combined).is_empty(), "Nessuna ripetizione delle transizioni coincidenti.")
	var game: PyramidGame = _game()
	game.score.lives = 1
	game.request_death(&"fall")
	for tick: int in range(89): _check(_step(game).is_empty(), "Nessun Game Over prima della fine effettiva.")
	_check(_step(game) == ["game_over"], "Game Over emesso all'esaurimento delle vite e dell'attesa.")
	for tick: int in range(20): _check(_step(game).is_empty(), "Game Over non viene ripetuto.")

func _test_rankings() -> void:
	_begin("053_scores_legacy_migration_validation_ties_roundtrip")
	for version: int in [1, 2]:
		var old: Dictionary = Profile.defaults()
		old.erase("leaderboard")
		old["schema"] = version
		if version == 1: old["music"] = .7
		old["record"] = 12345
		old["record_level"] = 3
		old["record_round"] = 2
		var migrated: Dictionary = Profile.validate(old)
		_check(migrated["schema"] == 4 and migrated["leaderboard"] == [{"name": "STO", "legacy_name": "STORICO", "points": 12345, "level": 3, "round": 2}], "Vecchio massimo diventa un record senza inventare iniziali.")
		for key: String in ["master", "effects", "bindings", "record", "record_level", "record_round"]:
			_check(migrated[key] == old[key], "Migrazione conserva " + key)
	var entries: Array = []
	for points: int in [100, 500, 200, 400, 300, 600, 700, 800, 900, 1000]: entries = Scores.insert(entries, points, 1, 1, "ABC")
	_check(not Scores.qualifies(entries, 100) and not Scores.qualifies(entries, 99), "Piena: pari all'ultimo o inferiore non qualifica.")
	_check(Scores.insert(entries, 1100, 2, 4, " ab!?cdefghij ")[0]["name"] == "ABC", "Nome breve normalizzato e limitato.")
	entries = Scores.insert(entries, 1100, 2, 4, "WIN")
	_check(entries.size() == 10 and entries[0]["points"] == 1100 and entries[-1]["points"] == 200, "Inserimento ordinato e rimozione soltanto dell'ultimo.")
	var data: Dictionary = Profile.defaults()
	data["record"] = 1100
	data["leaderboard"] = entries
	var repository: PlayerProfile = Profile.new("user://records-053.json")
	_check(repository.save_profile(data) and Profile.new(repository.path).load_profile() == data, "Classifica persiste al riavvio con preferenze e massimo.")
	var reversed_entries: Array = entries.duplicate()
	reversed_entries.reverse()
	for bad: Variant in [[{"name": "BAD!", "points": 1, "level": 1, "round": 1}], [{"name": "A", "points": 1.5, "level": 1, "round": 1}], entries + entries, reversed_entries]:
		var invalid: Dictionary = data.duplicate(true)
		invalid["leaderboard"] = bad
		_check(Profile.validate(invalid).is_empty(), "Classifica malformata rifiutata atomicamente.")

func _test_results_screen() -> void:
	_begin("053_game_over_banner_and_results_qualified_and_unqualified")
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	for qualified: bool in [true, false]:
		_check(runner.change_scene_to_file("res://scenes/game_screen.tscn") == OK, "Schermata di partita caricata.")
		await runner.process_frame
		await runner.process_frame
		var screen: GameScreen = runner.current_scene as GameScreen
		screen.set_physics_process(false)
		screen.set_process(false)
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		app.data = Profile.defaults()
		if not qualified:
			for points: int in [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]: app.data["leaderboard"] = Scores.insert(app.data["leaderboard"], points, 1, 1, "OLD")
			app.data["record"] = 1000
		screen.game.score.credit("fixture", 50)
		screen.game.score.lives = 1
		screen.game.request_death(&"fall")
		for tick: int in range(89): screen.advance_one_tick()
		_check(not screen.game_over_banner.visible, "Banner assente durante l'ultima morte.")
		screen.advance_one_tick()
		screen.show_settings()
		_check(not is_instance_valid(screen.settings_panel), "Game Over non apre un secondo pannello sopra il flusso record.")
		_check(screen.game_over_banner.visible and screen.game.state == PyramidGame.State.GAME_OVER, "GAME OVER al centro solo alla conclusione effettiva.")
		screen._process(.6)
		screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
		screen._process(2.0)
		_check(not screen.records_opened, "Focus perso ferma il passaggio alla classifica.")
		screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
		screen._process(29.41)
		_check(screen.records_opened and is_instance_valid(screen.records_panel), "Ogni Game Over apre la schermata dedicata.")
		var panel: RecordsPanel = screen.records_panel
		_check(panel.name_edit.visible == qualified and panel.save_button.visible == qualified, "Inserimento disponibile soltanto se qualificato.")
		if qualified:
			var snapshot: Dictionary = screen.game.snapshot()
			for key: int in [KEY_Q, KEY_E, KEY_Z, KEY_C, KEY_P]:
				var event: InputEventKey = InputEventKey.new()
				event.keycode = key
				event.physical_keycode = key
				event.pressed = true
				_check(not screen.handle_input_event(event), "Tasti del nome lasciati alla GUI senza controllare la partita.")
			_check(snapshot == screen.game.snapshot() and screen.input_adapter.drain_events().is_empty(), "Nessun comando di gioco accodato mentre si scrive.")
			panel.name_edit.text = ""
			panel.name_edit.grab_focus()
			_key(KEY_A, 97)
			_key(KEY_B, 98)
			_key(KEY_BACKSPACE)
			_key(KEY_C, 99)
			_check(panel.name_edit.text == "ac", "Digitazione e correzione passano realmente dal LineEdit.")
			_key(KEY_TAB)
			_check(panel.save_button.has_focus(), "Tab naviga dal nome alla conferma.")
			panel.name_edit.text = "ABC"
			_key(KEY_ENTER)
			panel.save_result()
			_check(app.data["leaderboard"].size() == 1 and app.data["leaderboard"][0]["name"] == "ABC", "Conferma ripetuta non duplica il record.")
			_check(Profile.new(app.store.path).load_profile()["leaderboard"] == app.data["leaderboard"], "Record confermato leggibile da nuova istanza.")
		else:
			_check(panel.continue_button.has_focus(), "Non qualificato: focus sul comando per proseguire.")
		_key(KEY_ENTER) # Activate the focused Continue button through GUI input.
		await runner.process_frame
		await runner.process_frame
		_check(runner.current_scene is MainMenu, "Continua torna al menu in entrambi i casi.")
	app.data = original
	app.apply_preferences()
	app.flush()
	app.stop_effects()
	await runner.create_timer(.2).timeout

func _test_record_retry() -> void:
	_begin("053_record_write_failure_retry_and_settings_preserve_ranking")
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	var original_store: PlayerProfile = app.store
	app.data = Profile.defaults()
	app.store = Profile.new("user://missing-053/profile.json")
	var panel: RecordsPanel = RecordsPanel.new()
	panel.app = app
	panel.points = 123
	runner.root.add_child(panel)
	panel.name_edit.text = "RETRY"
	panel.save_result()
	_check(panel.submitted and app.data["leaderboard"].size() == 1 and panel.status_label.text.contains("non disponibile"), "Errore di scrittura conserva record in memoria e consente retry.")
	panel.save_result()
	_check(app.data["leaderboard"].size() == 1, "Retry fallito non inserisce nuovamente lo stesso record.")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://missing-053"))
	panel.save_result()
	_check(panel.save_button.disabled and Profile.new(app.store.path).load_profile()["leaderboard"] == app.data["leaderboard"], "Retry riuscito persiste una sola copia del record.")
	app.reset_settings()
	_check(app.data["leaderboard"].size() == 1 and app.data["record"] == 123, "Ripristino preferenze conserva classifica e massimo.")
	panel.queue_free()
	await runner.process_frame
	app.data = original
	app.store = original_store
	app.apply_preferences()
	app.flush()


func _test_audio_lifecycle() -> void:
	_begin("053_auxiliary_audio_once_mute_pause_focus_restart_scenes")
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	app.data = Profile.defaults()
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	app.set_audio_paused(false)
	app.apply_preferences()
	var started: Array[String] = []
	var listener: Callable = func(effect: String) -> void: started.append(effect)
	app.effect_started.connect(listener)
	for cue: String in ["level", "extra", "stasis_collect", "lure"]: app.play_effect(cue)
	_check(started == ["level", "extra", "stasis_collect", "lure"], "Ogni segnale parte una sola volta al proprio evento, senza attendere la fine livello.")
	for player: AudioStreamPlayer in app.effect_players:
		_check(player.playing, "Le quattro voci previste possono essere attive per eventi distinti.")
	app.play_effect("jump")
	_check(app.current_effect == "jump" and app.effect_players[2].playing and app.effect_players[3].playing, "Nuovo salto immediato senza troncare la raccolta o la caduta del nemico.")
	for operation: String in ["master", "effects", "mute", "pause", "focus", "restart", "scene"]:
		app.stop_effects()
		app.set_audio_paused(false)
		for cue: String in ["level", "extra", "stasis_fall", "lure"]: app.play_effect(cue)
		match operation:
			"master", "effects":
				app.update_setting(operation, 0.0)
				app.update_setting(operation, .8)
			"mute":
				app.update_setting("muted", true)
				app.update_setting("muted", false)
			"pause":
				app.set_audio_paused(true)
				app.set_audio_paused(false)
			"focus":
				app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
				app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
			"restart", "scene":
				runner.change_scene_to_file("res://scenes/game_screen.tscn")
				await runner.process_frame
				await runner.process_frame
				var screen: GameScreen = runner.current_scene as GameScreen
				screen.set_physics_process(false)
				if operation == "restart": screen.start_new_game()
		for player: AudioStreamPlayer in app.effect_players:
			_check(not player.playing and player.stream == null, "Nessuna voce residua dopo " + operation)
		_check(app.queued_effects.is_empty(), "Nessuna coda residua dopo " + operation)
	app.effect_started.disconnect(listener)
	app.data = original
	app.apply_preferences()
	app.flush()
	app.stop_effects()
	await runner.create_timer(.2).timeout

func _key(key: int, unicode_value: int = 0) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.unicode = unicode_value
	event.pressed = true
	runner.root.push_input(event)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	runner.root.push_input(event)

func _begin(name: String) -> void: runner.call("_begin_test", name)
func _check(condition: bool, message: String) -> void: runner.call("_check", condition, message)
