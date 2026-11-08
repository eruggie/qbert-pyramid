extends RefCounted
const Profile = preload("res://scripts/core/player_profile.gd")
var runner: SceneTree

func run(tree: SceneTree) -> void:
	runner = tree
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	_begin("arcade_event_audio_volumes_mute_no_music")
	_check(app.FX.size() == 14 and AudioServer.get_bus_index("Music") == -1, "Quattordici effetti di eventi e nessun bus musicale.")
	for location: String in app.FX.values():
		var stream: AudioStreamWAV = load(location) as AudioStreamWAV
		_check(stream != null and stream.get_length() > 0.025 and stream.get_length() < 2.8 and not stream.data.is_empty() and stream.loop_mode == AudioStreamWAV.LOOP_DISABLED, "Effetto finito, non ciclico ed esportabile: " + location)
	_check(not app.update_setting("music", 0.5), "L'opzione musica non esiste più.")
	app.update_setting("master", 0.5)
	app.update_setting("effects", 0.7)
	_check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.5), "Volume Master applicato al mixer.")
	_check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects"))), 0.7), "Volume effetti indipendente.")
	app.update_setting("muted", true)
	_check(AudioServer.is_bus_mute(0), "Modalità silenziosa applicata al mixer.")
	app.play_effect("jump")
	_check(app.queued_effects.is_empty() and not app.effect_players[0].playing, "Mute non accoda effetti da riprodurre dopo.")
	app.update_setting("muted", false)
	app.set_audio_paused(false)
	app.play_effect("rescue")
	_check(app.effect_players.size() == 4 and app.effect_players[0].playing, "Voce principale attiva, seconda voce riservata alla vita extra.")
	app.play_effect("extra")
	_check(app.queued_effects.is_empty() and app.effect_players[1].playing, "La vita extra parte al premio senza attendere il salvataggio.")
	app.set_audio_paused(true)
	app.set_audio_paused(false)
	_check(not app.effect_players[0].playing and not app.effect_players[1].playing and app.queued_effects.is_empty(), "Pausa/ripresa non riavvia musica o vecchi effetti.")

	_begin("phase4_settings_capture_conflicts_and_game_isolation")
	_check(runner.change_scene_to_file("res://scenes/game_screen.tscn") == OK, "Partita caricabile con i servizi.")
	await _frames()
	var screen: GameScreen = runner.current_scene as GameScreen
	screen.set_physics_process(false)
	screen.game.world.spawning_enabled = false
	screen.game.world.stasis_enabled = false
	screen.show_settings()
	await _frames()
	var panel: SettingsPanel = screen.settings_panel
	_check(panel.find_child("MusicaSlider", true, false) == null, "Nessun controllo musica privo di funzione.")
	_check(panel != null and screen.game.paused, "Impostazioni accessibili dalla partita, automaticamente in pausa.")
	var slider: HSlider = panel.find_child("MasterSlider", true, false) as HSlider
	slider.value = 63
	_check(is_equal_approx(float(app.data["master"]), 0.63), "Il controllo UI aggiorna il mixer e il profilo.")
	var frozen: Dictionary = screen.game.snapshot()
	panel.begin_capture(2)
	_send(KEY_S, true)
	_send(KEY_S, false)
	_check(app.data["bindings"][2] == KEY_S and panel.capture_direction == -1, "Evento reale acquisito come azione semantica.")
	panel.begin_capture(3)
	_send(KEY_S, true)
	_send(KEY_S, false)
	_check(app.data["bindings"][3] == 0 and panel.capture_direction == 3, "Conflitto fra direzioni respinto.")
	_send(KEY_ESCAPE, true)
	_send(KEY_ESCAPE, false)
	_check(screen.settings_panel == panel and panel.capture_direction == -1, "Esc annulla solo la cattura, senza cambiare scena.")
	panel.begin_capture(3)
	_send(KEY_P, true)
	_send(KEY_P, false)
	_check(screen.game.paused and panel.capture_direction == 3, "Un comando riservato non riprende il gioco né diventa binding.")
	_send(KEY_ESCAPE, true)
	_send(KEY_ESCAPE, false)
	_send(KEY_DOWN, true)
	_send(KEY_DOWN, false)
	for tick: int in range(30):
		screen.advance_one_tick()
	_check(screen.game.snapshot() == frozen, "Navigazione/cattura UI non modifica movimento, timer o buffer della partita.")
	_send(KEY_ESCAPE, true)
	_send(KEY_ESCAPE, false)
	await _frames()
	_check(screen.game.paused and screen.settings_panel == null, "Chiudere le impostazioni mantiene la pausa.")
	screen.set_game_paused(false)
	_send(KEY_S, true)
	screen.advance_one_tick()
	_send(KEY_DOWN, true)
	_send(KEY_S, false)
	_send(KEY_DOWN, false)
	for tick: int in range(40):
		screen.advance_one_tick()
	_check(screen.game.simulation.cell == Vector2i(1, 0) and screen.game.score.points == 25, "Tasto personalizzato e freccia equivalenti: un solo salto, niente buffer extra.")
	screen.set_game_paused(true)
	screen.start_new_game()
	_check(not screen.game.paused and not app.effect_players[0].playing and not app.effect_players[1].playing and app.queued_effects.is_empty(), "Nuova partita riprende senza musica né effetti residui.")
	_check(app.data["record"] >= 25, "Il punteggio reale aggiorna il record.")
	var record: int = app.data["record"]
	app.observe_score(0, 1, 1)
	_check(app.data["record"] == record, "Nuova partita/punteggio minore non azzera il record.")
	_check(app.flush(), "Record e impostazioni salvati.")
	var reloaded: Dictionary = Profile.new().load_profile()
	_check(reloaded["record"] == record and reloaded["bindings"][2] == KEY_S, "Ricaricamento da disco preserva record e comandi.")
	for direction: int in range(4):
		var keys: Array[int] = [KEY_A, KEY_D, KEY_S, KEY_F]
		var targets: Array[Vector2i] = [Vector2i(3, 1), Vector2i(3, 2), Vector2i(5, 2), Vector2i(5, 3)]
		_check(app.set_binding(direction, keys[direction]).is_empty(), "Tasto personalizzato valido per ogni direzione.")
		screen.start_new_game()
		screen.game.simulation.reset(0, Vector2i(4, 2))
		_send(keys[direction], true)
		screen.advance_one_tick()
		_send(keys[direction], false)
		for tick: int in range(25):
			screen.advance_one_tick()
		_check(screen.game.simulation.cell == targets[direction] and screen.game.score.points == 25, "Ogni nuovo binding produce il movimento semantico corretto.")
	app.reset_settings()
	_check(app.data["record"] == record and app.data["bindings"] == [0, 0, 0, 0], "Ripristino impostazioni conserva il record e rimuove i binding personalizzati.")
	for direction: int in range(4):
		_check(InputMap.action_get_events(app.ACTIONS[direction]).size() >= 3, "Lettere/frecce/tastierino restano associati.")
	var connections: int = app.profile_changed.get_connections().size()
	for cycle: int in range(5):
		screen.show_settings()
		await _frames()
		var dialog: SettingsPanel = screen.settings_panel
		for button: Node in dialog.find_children("*", "Button", true, false):
			if button is Button and (button as Button).text == "Ripristina impostazioni":
				(button as Button).pressed.emit()
				break
		await _frames()
		dialog.close_panel()
		await _frames()
	_check(app.profile_changed.get_connections().size() == connections, "Aprire, ripristinare e chiudere cinque volte non accumula connessioni o nodi.")
	app.data = original
	app.apply_preferences()
	app.flush()
	screen.queue_free()
	runner.current_scene = null
	await _frames()

func _send(key: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	runner.root.push_input(event)

func _frames() -> void:
	await runner.process_frame
	await runner.process_frame

func _begin(name: String) -> void:
	runner.call("_begin_test", name)

func _check(value: bool, message: String) -> void:
	runner.call("_check", value, message)
