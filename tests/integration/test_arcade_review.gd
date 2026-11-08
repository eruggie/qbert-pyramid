extends RefCounted
const Palette = preload("res://scripts/presentation/arcade_palette.gd")
const Cues = preload("res://scripts/presentation/game_audio_cues.gd")
var runner: SceneTree

func run(tree: SceneTree) -> void:
	runner = tree
	_begin("arcade_palette_round_mapping_and_rule_independence")
	_check(Palette.for_round(0)[0] == Color("5945eb") and Palette.for_round(0)[2] == Color("dce013"), "I/1: viola e giallo osservati in S2.")
	_check(Palette.for_round(1)[0] == Color("f0dd80") and Palette.for_round(1)[2] == Color("0844d9"), "I/2 VID-01 00:43: crema iniziale, blu obiettivo.")
	_check(Palette.for_round(2)[0] == Color("c2d6d4") and Palette.for_round(2)[2] == Color("47494d") and Palette.for_round(3)[2] == Color("b0bb12"), "I/3 e I/4 corrispondono alle tavolozze documentate.")
	_check(Palette.for_round(4)[1] == Color("f0dd80") and Palette.for_round(4)[2] == Color("27bd39"), "II/1: intermedio crema e obiettivo verde.")
	for index: int in range(40):
		var colors: Array[Color] = Palette.for_round(index)
		_check(colors.size() == 5 and colors[0] != colors[1] and colors[1] != colors[2] and colors[0] != colors[2], "Ogni round mantiene tre colori distinguibili.")
	var game: PyramidGame = _game()
	var snapshot: Dictionary = game.snapshot()
	var view: PyramidView = PyramidView.new()
	view.game = game
	view.simulation = game.simulation
	view.size = Vector2(900, 440)
	for index: int in range(12):
		view.palette()
		view.cell_to_canvas(Vector2i(6, 6))
	_check(game.snapshot() == snapshot, "Proiezione e palette non mutano la partita.")
	for direction: int in range(4):
		_check(PyramidView.facing_direction(Vector2i(3, 1), PyramidBoard.neighbor(Vector2i(3, 1), direction)) == direction, "Pose coerenti con le quattro azioni semantiche.")
	game.round_index = 2
	var grey: Array[Color] = view.palette()
	game.world.stasis_remaining = 300
	_check(view.palette() == grey, "I/3 resta grigio con la Stasi attiva.")
	game.world.stasis_remaining = 0
	_check(view.palette() == grey, "I/3 resta grigio dopo la Stasi.")
	game.state = PyramidGame.State.ROUND_END
	for index: int in range(12):
		game.round_index = index
		_check(view.shows_level_card() == ((index + 1) % 4 == 0), "Scheda soltanto al cambio livello; bonus sulla piramide negli altri round.")
	game.state = PyramidGame.State.PLAYING
	_check(not view.shows_level_card(), "Nessuna scheda durante il gioco.")
	view.free()
	_test_audio_outcomes()
	await _test_scene_silence()

func _game() -> PyramidGame:
	var game: PyramidGame = PyramidGame.new()
	game.start_new_game()
	game.world.spawning_enabled = false
	game.world.stasis_enabled = false
	return game

func _step(game: PyramidGame, events: Array[Dictionary] = []) -> Array[String]:
	var before: Dictionary = Cues.before_step(game)
	return Cues.resolve(before, game, game.step(events))

func _jump(game: PyramidGame, direction: int) -> Array[String]:
	_step(game, [{"type": "press", "direction": direction}])
	_step(game, [{"type": "release", "direction": direction}])
	for tick: int in range(16):
		_step(game)
	return _step(game)

func _test_audio_outcomes() -> void:
	_begin("arcade_audio_semantic_landings_reversal_and_priority")
	var game: PyramidGame = _game()
	_check(_step(game, [{"type": "press", "direction": 2}]) == ["jump"], "Una partenza produce salto.")
	_step(game, [{"type": "release", "direction": 2}])
	for tick: int in range(16): _step(game)
	_check(_step(game) == ["color"], "Un atterraggio che cambia colore non suona anche land.")
	game = _game()
	game.simulation.board.apply_landing(Vector2i(1, 0))
	_check(_jump(game, 2) == ["land"], "Cella già completata: soltanto atterraggio.")
	game = _game()
	game.simulation.reset(2)
	game.simulation.board.apply_landing(Vector2i(1, 0))
	_check(_jump(game, 2) == ["color"] and game.simulation.board.get_state(Vector2i(1, 0)) == 0, "Anche il cambio reversibile all'indietro produce color.")
	game = _game()
	game.simulation.reset(0, Vector2i(3, 0))
	_check(_step(game, [{"type": "press", "direction": 0}]) == ["rescue"], "Il disco sostituisce il normale suono di salto.")
	game = _game()
	_check(_jump(game, 0) == ["fall"], "La caduta produce un solo effetto letale.")
	_check(_step(game).is_empty(), "L'attesa di respawn non ripete l'effetto.")
	game = _game()
	for cell: Vector2i in game.simulation.board.cells():
		if cell != Vector2i(1, 0): game.simulation.board.apply_landing(cell)
	game.score.credit("fixture", 7000)
	_check(_jump(game, 2) == ["round", "extra"], "Bonus e vita extra simultanei hanno entrambi segnali, senza raccolta fittizia.")
	game = _game()
	game.round_index = 2
	game._begin_round()
	game.world.stasis_available = true
	game.world.stasis_spawned = true
	game.world.stasis_cell = Vector2i(1, 0)
	_check(_jump(game, 2) == ["stasis_collect"], "Raccolta Stasi prevale sul colore, una sola volta.")
	game = _game()
	game.world.actors.append({"id": 40, "kind": 0, "cell": Vector2i(1, 0), "from": Vector2i(1, 0), "to": Vector2i(1, 0), "moving": false, "start": 0, "end": 0, "next": 99999})
	_check(_jump(game, 2) == ["contact"] and game.score.lives == 2, "Contatto prevale sul colore e sottrae una sola vita.")


	_begin("arcade_audio_collected_saboteur_and_lured_chaser")
	game = _game()
	game.world.actors.append({"id": 41, "kind": 3, "cell": Vector2i(1, 0), "from": Vector2i(1, 0), "to": Vector2i(1, 0), "moving": false, "start": 0, "end": 0, "next": 99999})
	_check(_jump(game, 2) == ["collect"] and game.score.points == 325, "Sabotatore raccolto: evento audio singolo e punteggio reale.")
	_check(_step(game).is_empty(), "Il premio già attribuito non ripete collect.")
	game = _game()
	game.simulation.reset(0, Vector2i(3, 0))
	game.protection_ticks = 10
	game.world.actors.append({"id": 1, "kind": 1, "cell": Vector2i(3, 0), "from": Vector2i(3, 0), "to": Vector2i(3, 0), "moving": false, "start": 0, "end": 0, "next": 1})
	_step(game, [{"type": "press", "direction": 0}])
	var played: Array[String] = []
	for tick: int in range(74):
		played.append_array(_step(game))
	_check(played == ["lure"] and game.score.points == 500, "Segugio attirato: lure una volta, nessuna raccolta fittizia o ripetizione all'apice.")

func _test_scene_silence() -> void:
	_begin("arcade_silence_scene_changes_pause_focus_restart")
	var app: Node = runner.root.get_node("App")
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	for scene: String in ["main_menu", "game_screen", "rules_lab", "main_menu", "game_screen"]:
		app.set_audio_paused(false)
		app.play_effect("round")
		app.play_effect("extra")
		_check(runner.change_scene_to_file("res://scenes/%s.tscn" % scene) == OK, "Cambio scena riuscito: " + scene)
		await runner.process_frame
		await runner.process_frame
		runner.current_scene.set_physics_process(false)
		_check(AudioServer.get_bus_index("Music") == -1 and not app.effect_players[0].playing and not app.effect_players[1].playing and app.queued_effects.is_empty(), "Nessuna musica o jingle al cambio scena.")
	var screen: GameScreen = runner.current_scene as GameScreen
	app.play_effect("jump")
	app.play_effect("extra")
	screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	screen.set_game_paused(false)
	_check(not app.effect_players[0].playing and not app.effect_players[1].playing and app.queued_effects.is_empty(), "Focus e ripresa non riproducono eventi residui.")
	_begin("audio_long_cues_do_not_delay_movement_or_survive_pause")
	app.data["muted"] = false
	app.data["master"] = 0.8
	app.data["effects"] = 0.8
	app.apply_preferences()
	var started: Array[String] = []
	var record_start: Callable = func(effect: String) -> void: started.append(effect)
	app.effect_started.connect(record_start)
	for cue: String in ["rescue", "round", "collect"]:
		started.clear()
		app.stop_effects()
		app.play_effect(cue)
		app.play_effect("extra")
		_check(app.current_effect == cue and app.effect_players[1].playing and app.queued_effects.is_empty(), "Segnale lungo e vita extra avviati al rispettivo evento.")
		_check(started == [cue, "extra"], "Due eventi, esattamente due avvii immediati.")
		app.play_effect("jump")
		_check(started == [cue, "extra", "jump"], "Una partenza per evento anche con segnali lunghi.")
		_check(app.current_effect == "jump" and app.effect_players[1].playing and app.queued_effects.is_empty(), "Nuovo salto immediato; vita extra non interrotta dalla prelazione.")
		app.set_audio_paused(true)
		app.set_audio_paused(false)
		_check(app.current_effect.is_empty() and not app.effect_players[0].playing and not app.effect_players[1].playing and app.queued_effects.is_empty(), "Pausa elimina anche i segnali lunghi.")
	app.effect_started.disconnect(record_start)
	for setting: String in ["master", "effects"]:
		app.play_effect("round")
		app.play_effect("extra")
		app.update_setting(setting, 0.0)
		_check(not app.effect_players[0].playing and not app.effect_players[1].playing and app.queued_effects.is_empty(), "Volume zero interrompe la coda: " + setting)
		app.update_setting(setting, 0.8)
		_check(not app.effect_players[0].playing, "Ripristino volume non riavvia il segnale.")
	app.play_effect("round")
	app.play_effect("extra")
	app.update_setting("muted", true)
	_check(not app.effect_players[0].playing and not app.effect_players[1].playing, "Mute interrompe entrambe le voci già avviate.")
	app.update_setting("muted", false)
	_check(not app.effect_players[0].playing and not app.effect_players[1].playing, "Disattivare mute non riprende gli effetti precedenti.")
	screen.start_new_game()
	_check(not app.effect_players[0].playing, "Nuova partita silenziosa prima del primo evento.")
	screen.queue_free()
	runner.current_scene = null
	await runner.process_frame
	# Rapid headless start/stop commands are retired by the audio thread.
	# Let it release both players' playback references before runner shutdown.
	app.stop_effects()
	await runner.create_timer(0.2).timeout

func _begin(name: String) -> void:
	runner.call("_begin_test", name)
func _check(value: bool, message: String) -> void:
	runner.call("_check", value, message)
