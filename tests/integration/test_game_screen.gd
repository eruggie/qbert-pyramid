extends RefCounted

const Screen = preload("res://scripts/presentation/game_screen.gd")
const Game = preload("res://scripts/core/pyramid_game.gd")
var _runner: SceneTree
var _screen: Screen


func run(runner: SceneTree) -> void:
	_runner = runner
	_begin("game_menu_entry_and_layout")
	_check(_runner.change_scene_to_file("res://scenes/main_menu.tscn") == OK, "Menu caricabile.")
	await _frames()
	var menu: Node = _runner.current_scene
	(menu.get_node("%GameButton") as Button).pressed.emit()
	await _frames()
	_screen = _runner.current_scene as Screen
	_check(_screen != null, "Il pulsante Nuova partita deve aprire la scena effettiva.")
	if _screen == null:
		return
	_screen.set_physics_process(false)
	_screen.game.world.spawning_enabled = false
	_screen.game.world.stasis_enabled = false
	_check(_screen.game.score.lives == 3 and _screen.view.simulation == _screen.game.simulation, "HUD/vista devono condividere il nucleo effettivo.")
	for size: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		_runner.root.size = size
		await _frames()
		var bounds: Rect2 = _runner.root.get_visible_rect().grow(1)
		for path: String in ["%GameTitleLabel", "%HudLabel", "%ProgressLabel", "%PauseButton", "%NewGameButton", "%BackButton", "%StateLabel", "%InputLegendLabel"]:
			var control: Control = _screen.get_node(path) as Control
			_check(bounds.encloses(control.get_global_rect()), "Partita: controllo contenuto a %s: %s" % [size, path])
	_test_device_input()
	_test_energy_input_and_hud()
	await _test_rescue_view_continuity()
	await _test_pause_focus()
	_test_death_restart()
	_test_round_transition()
	await _test_exit_reentry()


func _test_device_input() -> void:
	_begin("game_letters_arrows_keypad_and_no_duplicate_sources")
	var bindings: Array = [[KEY_Q, KEY_LEFT, KEY_KP_7], [KEY_E, KEY_UP, KEY_KP_9], [KEY_Z, KEY_DOWN, KEY_KP_1], [KEY_C, KEY_RIGHT, KEY_KP_3]]
	var targets: Array[Vector2i] = [Vector2i(3, 1), Vector2i(3, 2), Vector2i(5, 2), Vector2i(5, 3)]
	for direction: int in range(4):
		for key: int in bindings[direction]:
			_screen.start_new_game()
			_screen.game.simulation.reset(0, Vector2i(4, 2))
			_send(key, true)
			_check(_runner.root.is_input_handled(), "Il movimento deve essere consumato senza navigazione UI.")
			_ticks(1)
			_send(key, false)
			_ticks(40)
			_check(_screen.game.simulation.cell == targets[direction] and _screen.game.score.points == 25, "Ogni binding deve atterrare e aggiornare il punteggio.")
	_screen.start_new_game()
	_send(KEY_Z, true)
	_ticks(11)
	_send(KEY_DOWN, true)
	_send(KEY_Z, false)
	_send(KEY_DOWN, false)
	_ticks(40)
	_check(_screen.game.simulation.cell == Vector2i(1, 0) and _screen.game.score.points == 25, "Secondo equivalente durante salto non deve introdurre un buffer extra.")
	_check((_screen.get_node("%HudLabel") as Label).text.contains("Punti 25"), "Il punteggio deve apparire nell'HUD.")


func _test_energy_input_and_hud() -> void:
	_begin("phase3_energy_real_keyboard_hud_expiry")
	_screen.start_new_game()
	_screen.game.round_index = 2
	_screen.game._begin_round()
	_screen.game.world.stasis_available = true
	_screen.game.world.stasis_spawned = true
	_screen.game.world.stasis_cell = Vector2i(1, 0)
	_send(KEY_DOWN, true)
	_ticks(1)
	_send(KEY_DOWN, false)
	_ticks(18)
	_check(_screen.game.world.stasis_remaining == 300 and (_screen.get_node("%StateLabel") as Label).text.contains("Contatti innocui"), "Raccolta con freccia attiva protezione e istruzione HUD.")
	_screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_ticks(30)
	_check(_screen.game.paused and _screen.game.world.stasis_remaining == 300, "Perdita del focus congela l'energia.")
	_screen.set_game_paused(false)
	_ticks(2)
	_screen.game.world.actors.append({"id": 50, "kind": 2, "cell": Vector2i(2, 1), "from": Vector2i(2, 1), "to": Vector2i(2, 1), "moving": false, "start": 0, "end": 0, "next": 99999})
	_send(KEY_C, true)
	_ticks(1)
	_send(KEY_C, false)
	_ticks(18)
	_check(_screen.game.state == Game.State.PLAYING and _screen.game.simulation.cell == Vector2i(2, 1) and _screen.game.score.lives == 3, "Lettera dopo freccia: atterraggio su ragnetto consentito con Stasi.")
	_screen.game.world.stasis_remaining = 1
	_ticks(1)
	_check(_screen.game.state == Game.State.DYING and _screen.game.score.lives == 2 and not (_screen.get_node("%StateLabel") as Label).text.contains("Contatti innocui"), "Scadenza ripristina danno e aggiorna l'HUD senza vita duplicata.")


func _test_rescue_view_continuity() -> void:
	_begin("refinement_rescue_both_sides_and_sizes")
	for size: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		_runner.root.size = size
		await _frames()
		for side: int in range(2):
			_screen.start_new_game()
			var origin: Vector2i = Vector2i(3, 0) if side == 0 else Vector2i(5, 5)
			var key: int = KEY_Q if side == 0 else KEY_E
			_screen.game.simulation.reset(0, origin)
			var origin_canvas: Vector2 = _screen.view.cell_to_canvas(origin)
			var disk: Vector2 = _screen.view.platform_canvas_position(side)
			_check(disk.y < origin_canvas.y and (disk.x < origin_canvas.x if side == 0 else disk.x > origin_canvas.x), "Il disco deve essere rialzato e sul lato corretto della cella.")
			_send(key, true)
			_ticks(1)
			_send(key, false)
			_check(_screen.game.rescue_remaining == 72 and _screen.view.actor_canvas_position().distance_to(origin_canvas) < 0.01, "Il viaggio inizia senza scatto dalla cella di bordo.")
			var previous: Vector2 = _screen.view.actor_canvas_position()
			var limit: float = absf(disk.x - origin_canvas.x) * 0.35
			for elapsed: int in range(1, 73):
				_ticks(1)
				var current: Vector2 = _screen.view.actor_canvas_position()
				_check(current.distance_to(previous) <= limit, "Il movimento resta continuo al tick %d, lato %d, risoluzione %s." % [elapsed, side, size])
				if elapsed == 18:
					_check(current.distance_to(disk) < 0.01 and _screen.view.actor_shadow_position().distance_to(disk) < 0.01, "Attore e ombra raggiungono il disco al termine del salto.")
				if elapsed > 18 and elapsed < 72:
					_check(current.distance_to(_screen.view.rescue_disk_position()) < 0.01, "Durante il trasporto l'attore rimane sul disco mobile.")
				previous = current
			_check(_screen.game.rescue_remaining == 0 and _screen.game.simulation.cell == Vector2i.ZERO, "Il ritorno logico all'apice avviene al tick 72.")
			_check(previous.distance_to(_screen.view.cell_to_canvas(Vector2i.ZERO)) < 0.01, "La posizione finale coincide con il respawn senza scatti.")


func _test_pause_focus() -> void:
	_begin("game_pause_focus_and_fresh_input")
	_screen.start_new_game()
	_send(KEY_DOWN, true)
	_ticks(4)
	_send(KEY_P, true)
	_send(KEY_P, false)
	var frozen: Dictionary = _screen.game.snapshot()
	_send(KEY_DOWN, false)
	_send(KEY_RIGHT, true)
	_send(KEY_RIGHT, false)
	_ticks(100)
	_check(_screen.game.snapshot() == frozen, "Pausa e navigazione non devono mutare la partita.")
	_send(KEY_P, true)
	_send(KEY_P, false)
	_ticks(40)
	_check(_screen.game.simulation.cell == Vector2i(1, 0) and _screen.game.score.points == 25, "Nessun comando UI residuo alla ripresa.")
	Input.parse_input_event(_key(KEY_DOWN, true))
	await _frames()
	_ticks(4)
	_screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_screen.set_process_input(false)
	Input.parse_input_event(_key(KEY_DOWN, false))
	await _frames()
	_screen.set_process_input(true)
	_screen.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(_screen.game.paused, "Il ritorno del focus non deve riprendere automaticamente.")
	_screen.set_game_paused(false)
	_ticks(40)
	var id: int = _screen.game.simulation.jump_id
	_send(KEY_DOWN, true)
	_ticks(1)
	_send(KEY_DOWN, false)
	_check(_screen.game.simulation.jump_id > id, "La prima pressione dopo un rilascio fuori finestra deve funzionare.")
	_ticks(40)


func _test_death_restart() -> void:
	_begin("game_falls_game_over_new_game_no_residual")
	_screen.start_new_game()
	for death: int in range(3):
		_send(KEY_Q, true)
		_send(KEY_LEFT, true)
		_ticks(19)
		_check(_screen.game.state == Game.State.DYING and _screen.game.score.lives == 2 - death, "Ogni caduta effettiva toglie una sola vita.")
		_ticks(90)
		var before: int = _screen.game.simulation.jump_id
		_ticks(40)
		_check(_screen.game.simulation.jump_id == before, "I tasti mantenuti prima della caduta non devono causare un'altra morte.")
		_send(KEY_Q, false)
		_send(KEY_LEFT, false)
	_check(_screen.game.state == Game.State.GAME_OVER, "Tre cadute portano a Game Over.")
	var restart: Button = _screen.get_node("%NewGameButton") as Button
	_check(restart.disabled and _screen.records_button.has_focus(), "Game Over dà focus alla classifica prima della nuova partita.")
	_check(_screen.game_over_banner.visible and _screen.game_over_label.text == "GAME OVER", "Game Over centrale visibile.")
	_screen.start_new_game() # Administrative fixture reset; UI goes through records first.
	_ticks(40)
	_check(_screen.game.state == Game.State.PLAYING and _screen.game.score.lives == 3 and _screen.game.score.points == 0, "Il pulsante deve iniziare una partita pulita.")
	_check(_screen.game.simulation.jump_id == 0, "La nuova partita non deve ereditare comandi.")


func _test_round_transition() -> void:
	_begin("game_round_end_hud_and_completion")
	_screen.start_new_game()
	# Near-complete fixture tests UI wiring; unit suite solves all 12 with real paths.
	var target: Vector2i = Vector2i(1, 1)
	for cell: Vector2i in _screen.game.simulation.board.cells():
		if cell != target:
			_screen.game.simulation.board.apply_landing(cell)
	_send(KEY_RIGHT, true)
	_ticks(19)
	_check(_screen.game.state == Game.State.ROUND_END and _screen.game.score.points == 1125, "Ultima cella accredita 25 e un unico bonus di 1000.")
	_check((_screen.get_node("%StateLabel") as Label).text.contains("Bonus 1000"), "Bonus visibile nella transizione.")
	_ticks(Game.ROUND_END_TICKS)
	_ticks(40)
	_check(_screen.game.round_index == 1 and _screen.game.simulation.jump_id == 0, "Il tasto mantenuto non deve saltare nel round nuovo.")
	_send(KEY_RIGHT, false)
	# After the twelfth round, progress continuously instead of finishing.
	_screen.game.round_index = 11
	_screen.game.simulation.reset(2)
	for cell: Vector2i in _screen.game.simulation.board.cells():
		if cell != target:
			_screen.game.simulation.board.apply_landing(cell)
	_send(KEY_C, true)
	_ticks(1)
	_send(KEY_C, false)
	_ticks(18 + Game.ROUND_END_TICKS)
	_check(_screen.game.state == Game.State.PLAYING and _screen.game.round_index == 12, "Dopo il round 12 deve iniziare il livello 4.")
	_check((_screen.get_node("%LevelLabel") as Label).text.contains("Livello 4"), "Il livello 4 deve essere visibile.")
	_screen.set_game_paused(true)
	(_screen.get_node("%NewGameButton") as Button).pressed.emit()
	_check(_screen.game.round_index == 0 and _screen.game.score.points == 0, "Nuova partita disponibile in pausa.")


func _test_exit_reentry() -> void:
	_begin("game_escape_consumed_menu_reentry")
	_send(KEY_DOWN, true)
	_ticks(4)
	_send(KEY_ESCAPE, true)
	_check(_runner.root.is_input_handled(), "Esc deve essere consumato anche dopo la rimozione della scena.")
	await _frames()
	_send(KEY_ESCAPE, false)
	_send(KEY_DOWN, false)
	var menu: Node = _runner.current_scene
	_check(menu.scene_file_path == "res://scenes/main_menu.tscn", "Esc torna al menu senza errori.")
	(menu.get_node("%GameButton") as Button).pressed.emit()
	await _frames()
	_screen = _runner.current_scene as Screen
	_screen.set_physics_process(false)
	_ticks(40)
	_check(_screen.game.simulation.jump_id == 0 and _screen.game.score.points == 0, "Rientro dal menu senza input e punti residui.")
	_screen.queue_free()
	_runner.current_scene = null
	await _frames()


func _ticks(count: int) -> void:
	for tick: int in range(count):
		_screen.advance_one_tick()


func _send(key: int, pressed: bool) -> void:
	_runner.root.push_input(_key(key, pressed))


func _key(key: int, pressed: bool) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	return event


func _frames() -> void:
	await _runner.process_frame
	await _runner.process_frame


func _begin(name: String) -> void:
	_runner.call("_begin_test", name)


func _check(value: bool, message: String) -> void:
	_runner.call("_check", value, message)
