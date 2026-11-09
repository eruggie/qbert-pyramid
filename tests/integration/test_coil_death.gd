extends RefCounted

var runner: SceneTree
var screen: GameScreen
var heard: Array[String] = []

func run(test_runner: SceneTree) -> void:
	runner = test_runner
	_test_collision_attribution()
	runner._begin_test("coil_capture_identity_lifecycle_and_audio")
	runner.change_scene_to_file("res://scenes/game_screen.tscn")
	await runner.process_frame
	await runner.process_frame
	screen = runner.current_scene as GameScreen
	screen.set_physics_process(false)
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	app.data["muted"] = false
	app.data["master"] = 0.8
	app.data["effects"] = 0.7
	app.apply_preferences()
	app.effect_started.connect(_heard)
	_reset()
	for life: int in range(3):
		screen.game.protection_ticks = 0
		_capture(1)
		var position: Vector2 = screen.view.actor_canvas_position()
		_check(screen.game.is_coil_death() and screen.view.shows_coil_death(), "Coil alone selects the replacement presentation.")
		_check(screen.game.death_context["killer"] == {"id": 731, "kind": 1} and screen.game.world.actors.is_empty(), "Killer survives world reset.")
		_check(heard == ["qbert_hello"], "One hello, no contact or duplicated cue.")
		_check(screen.game.score.lives == 2 - life and screen.game.remaining_ticks == 90, "Original lives and death duration.")
		for tick: int in range(89): screen.advance_one_tick()
		_check(heard == ["qbert_hello"] and screen.view.shows_coil_death() and screen.view.actor_canvas_position() == position, "Presentation stays fixed throughout death; audio never retriggers.")
		screen.advance_one_tick()
		_check(not screen.view.shows_coil_death() and screen.game.death_context.is_empty(), "Presentation/context cleared at exit, including final life.")
		_check(screen.game.state == (PyramidGame.State.GAME_OVER if life == 2 else PyramidGame.State.PLAYING), "Respawn or game over at original deadline.")
		if life == 2: _check(heard == ["qbert_hello", "game_over"], "Game over cue preserved.")
		else: _check(app.current_effect == "qbert_hello", "Respawn does not stop the clip.")
		heard.clear()
	_reset()
	_capture(1)
	screen.start_new_game()
	_check(not screen.view.shows_coil_death() and screen.game.death_context.is_empty() and app.current_effect.is_empty(), "New game clears visual and audio.")
	for kind: int in [0, 2, 3]:
		_reset()
		_capture(kind)
		_check(not screen.view.shows_coil_death() and not heard.has("qbert_hello"), "Other actors never select Coil presentation.")
	_reset()
	screen.game.request_death(&"fall")
	_check(not screen.view.shows_coil_death(), "Fall never selects Coil presentation.")
	for protection: String in ["protection", "stasis"]:
		_reset()
		if protection == "protection": screen.game.protection_ticks = 30
		else: screen.game.world.stasis_remaining = 30
		_capture(1)
		_check(screen.game.state == PyramidGame.State.PLAYING and screen.game.death_context.is_empty() and heard.is_empty(), "Neutralized contact has no death effect.")
	for setting: String in ["muted", "effects", "master"]:
		_reset()
		app.data[setting] = true if setting == "muted" else 0.0
		app.apply_preferences()
		_capture(1)
		_check(screen.view.shows_coil_death() and heard.is_empty(), "Audio respects " + setting)
		app.data[setting] = false if setting == "muted" else 0.8
		app.apply_preferences()
	# Match the regular Q*BERT atlas frame exactly (40x48 and the same feet anchor).
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		runner.root.size = dimensions
		await runner.process_frame
		await runner.process_frame
		for cell: Vector2i in screen.game.simulation.board.cells():
			screen.game.simulation.reset(0, cell)
			var rect: Rect2 = screen.view.coil_death_rect()
			var player_rect: Rect2 = screen.view.player_sprite_rect()
			var expected_size: Vector2 = Vector2(40, 48) * screen.view._tile_width() / 40.0
			_check(rect == player_rect, "Capture image matches Q*BERT's actual sprite rectangle at " + str(cell))
			_check(rect.size.is_equal_approx(expected_size), "Capture frame uses the actual 40x48 atlas scale at " + str(cell))
	var stream: AudioStreamMP3 = load("res://assets/audio/qbert_hello.mp3") as AudioStreamMP3
	_check(stream != null and not stream.loop and stream.get_length() > 0, "MP3 imports without looping.")
	print("COIL_AUDIO_LENGTH_SECONDS=", stream.get_length())
	app.effect_started.disconnect(_heard)
	app.data = original
	app.apply_preferences()
	_reset()
	_capture(1)
	screen.return_to_menu(true)
	await runner.process_frame
	await runner.process_frame
	_check(runner.current_scene is MainMenu and app.current_effect.is_empty(), "Menu frees the presentation and stops effects.")
	# Audio stop commands are consumed on the mixer thread, not process_frame.
	# Let pending playback release before this final suite quits the engine.
	await runner.create_timer(0.15).timeout

func _reset() -> void:
	screen.start_new_game()
	screen.game.world.spawning_enabled = false
	screen.game.world.stasis_enabled = false
	heard.clear()

func _capture(kind: int) -> void:
	var cell: Vector2i = screen.game.simulation.cell
	screen.game.world.actors.append({"id": 731, "kind": kind, "cell": cell, "from": cell, "to": cell, "moving": false, "start": 0, "end": 0, "next": 99999})
	screen.advance_one_tick()

func _heard(effect: String) -> void:
	heard.append(effect)

func _check(value: bool, message: String) -> void:
	runner._check(value, message)


func _test_collision_attribution() -> void:
	runner._begin_test("coil_crossing_simultaneous_contacts_and_rejected_deaths")
	for kind: int in [0, 1]:
		var game: PyramidGame = PyramidGame.new()
		game.world.spawning_enabled = false
		game.world.stasis_enabled = false
		game.simulation.reset(0, Vector2i(1, 0))
		game.world.actors.append({"id": 81, "kind": kind, "cell": Vector2i.ZERO, "from": Vector2i.ZERO, "to": Vector2i(1, 0), "moving": true, "start": 0, "end": 24, "next": 99999})
		game.step([{"type": "press", "direction": 1}])
		var cues: Array[String] = []
		for tick: int in range(14):
			var before: Dictionary = GameAudioCues.before_step(game)
			cues.append_array(GameAudioCues.resolve(before, game, game.step()))
		_check(game.state == PyramidGame.State.DYING and game.simulation.is_airborne, "Real crossing kills before landing.")
		_check(game.is_coil_death() == (kind == 1), "Crossing attribution comes from colliding actor.")
		_check(cues == (["qbert_hello"] if kind == 1 else ["contact"]), "Crossing produces exactly one correct death cue.")
	# Existing first-lethal ordering is deterministic; a nearby Coil cannot
	# relabel another killer, nor can an unrelated actor relabel Coil.
	for first_kind: int in [0, 1]:
		var game: PyramidGame = PyramidGame.new()
		game.world.spawning_enabled = false
		game.world.stasis_enabled = false
		for kind: int in [first_kind, 1 - first_kind]:
			game.world.actors.append({"id": kind + 10, "kind": kind, "cell": Vector2i.ZERO, "from": Vector2i.ZERO, "to": Vector2i.ZERO, "moving": false, "start": 0, "end": 0, "next": 99999})
		game.step()
		_check(game.death_context["killer"]["kind"] == first_kind and game.is_coil_death() == (first_kind == 1), "Simultaneous contacts preserve first lethal ordering.")
		var context: Dictionary = game.death_context.duplicate(true)
		_check(not game.request_death(&"contact", {"kind": 1 - first_kind}) and game.death_context == context, "Rejected second death cannot change attribution.")
	var fall: PyramidGame = PyramidGame.new()
	fall.world.spawning_enabled = false
	fall.world.stasis_enabled = false
	fall.step([{"type": "press", "direction": 0}])
	var fall_cues: Array[String] = []
	for tick: int in range(18):
		var before: Dictionary = GameAudioCues.before_step(fall)
		fall_cues.append_array(GameAudioCues.resolve(before, fall, fall.step()))
	_check(fall.state == PyramidGame.State.DYING and not fall.is_coil_death() and fall_cues == ["fall"], "Actual fall keeps its normal death audio.")
	var generic: PyramidGame = PyramidGame.new()
	_check(generic.request_death(&"contact") and not generic.is_coil_death(), "Unknown generic contact never guesses Coil.")
