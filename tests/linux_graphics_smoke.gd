extends SceneTree
## Optional graphical Linux/WSLg check. Never substitutes for Windows validation.

var _state_dir: String = ""
var _failures: int = 0
var _captures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_state_dir = OS.get_environment("AP_GRAPHICS_STATE_DIR")
	if _state_dir.is_empty() or DisplayServer.get_name() == "headless":
		printerr("Serve un display Linux reale e AP_GRAPHICS_STATE_DIR isolata.")
		quit(1)
		return
	# The project entry scene may already exist when a SceneTree script starts.
	# Remove that instance so a hidden startup overlay cannot consume lab input.
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
		await process_frame
		await process_frame
	root.get_node("App").intro_seen = true
	root.size = Vector2i(1280, 720)
	var menu_resource: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	if menu_resource == null:
		quit(1)
		return
	var menu: Node = menu_resource.instantiate()
	root.add_child(menu)
	await _capture("menu_1280x720.png")
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		menu.call("show_instructions")
		await _capture("arcade_instructions_%dx%d.png" % [dimensions.x, dimensions.y])
		var dialog: AcceptDialog = menu.get_node("%InstructionsDialog")
		var available: Vector2 = root.get_visible_rect().size if dialog.is_embedded() else Vector2(root.size)
		if dialog.size.y > available.y or dialog.position.y < 0 or dialog.position.y + dialog.size.y > available.y:
			_failures += 1
			printerr("Le istruzioni escono dalla finestra.")
		menu.call("close_dialogs")
	menu.call("show_settings")
	root.size = Vector2i(960, 540)
	await _capture("phase4_menu_settings_960x540.png")
	(menu.get("settings_panel") as SettingsPanel).close_panel()
	await process_frame
	root.size = Vector2i(1280, 720)
	menu.queue_free()
	await process_frame
	var lab_resource: PackedScene = load("res://scenes/rules_lab.tscn") as PackedScene
	if lab_resource == null:
		quit(1)
		return
	var lab: Node = lab_resource.instantiate()
	root.add_child(lab)
	await process_frame
	lab.set_physics_process(false)
	for color_mode: int in range(3):
		lab.call("select_mode", color_mode)
		root.size = Vector2i(1280, 720)
		await _capture("lab_mode_%d_1280x720.png" % color_mode)
	lab.call("select_mode", 0)
	lab.call("set_lab_paused", false)
	var press: InputEventKey = InputEventKey.new()
	press.keycode = KEY_RIGHT
	press.physical_keycode = KEY_RIGHT
	press.pressed = true
	# Leave the post-draw callback before injecting viewport input.
	await process_frame
	root.push_input(press)
	await process_frame
	var first_events: Array = lab.call("advance_one_tick")
	if not first_events.any(func(event: Dictionary) -> bool: return event["type"] == "jump_started"):
		_failures += 1
		printerr("Il primo input del laboratorio non ha avviato un salto.")
	for index: int in range(8):
		lab.call("advance_one_tick")
	await _capture("lab_mid_jump.png")
	var release: InputEventKey = InputEventKey.new()
	release.keycode = KEY_RIGHT
	release.physical_keycode = KEY_RIGHT
	release.pressed = false
	await process_frame
	root.push_input(release)
	await process_frame
	for index: int in range(10):
		lab.call("advance_one_tick")
	var simulation: RefCounted = lab.get("simulation") as RefCounted
	if simulation == null or simulation.get("cell") != Vector2i(1, 1):
		_failures += 1
		printerr("Il ponte grafico/input non ha prodotto l'atterraggio atteso.")
	await _capture("lab_landed.png")
	for size_value: Vector2i in [Vector2i(960, 540), Vector2i(1920, 1080)]:
		root.size = size_value
		await _capture("lab_%dx%d.png" % [size_value.x, size_value.y])
	lab.queue_free()
	await process_frame
	await _capture_game()
	var report: Dictionary = {
		"platform": OS.get_name(),
		"display_server": DisplayServer.get_name(),
		"rendering_method": RenderingServer.get_current_rendering_method(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"failures": _failures,
		"captures": _captures,
		"windows_validation": "not performed",
		"manual_keyboard_validation": "not performed; scripted events only"
	}
	var output: FileAccess = FileAccess.open(_state_dir.path_join("graphics-report.json"), FileAccess.WRITE)
	if output == null:
		quit(1)
		return
	output.store_string(JSON.stringify(report, "\t") + "\n")
	output.close()
	# Drain playback while App and its players still belong to the tree.
	root.get_node("App").call("stop_effects")
	await create_timer(0.15).timeout
	print("AP_LINUX_GRAPHICS_COMPLETE " + JSON.stringify(report))
	await process_frame
	quit(0 if _failures == 0 else 1)


func _capture(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result: Image = root.get_texture().get_image()
	if result == null or result.is_empty() or result.save_png(_state_dir.path_join(filename)) != OK:
		_failures += 1
		printerr("Cattura grafica fallita: " + filename)
	else:
		_captures.append(filename)


func _capture_game() -> void:
	var resource: PackedScene = load("res://scenes/game_screen.tscn") as PackedScene
	if resource == null:
		_failures += 1
		return
	var screen: GameScreen = resource.instantiate() as GameScreen
	root.add_child(screen)
	screen.set_physics_process(false)
	for size_value: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = size_value
		await _capture("game_%dx%d.png" % [size_value.x, size_value.y])
	root.size = Vector2i(1280, 720)
	# Display all roles in an allowed round (II/4), without waiting for RNG.
	screen.game.round_index = 7
	screen.game._begin_round()
	_game_ticks(screen, 1)
	for kind: int in range(4):
		var cell: Vector2i = Vector2i(4, kind)
		screen.game.world.actors.append({"id": kind + 1, "kind": kind, "cell": cell,
			"from": cell, "to": cell, "moving": false, "start": 0, "end": 0, "next": 99999})
	screen.game.world.stasis_available = true
	screen.game.world.stasis_cell = Vector2i(3, 1)
	screen.view.queue_redraw()
	for size_value: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = size_value
		await _capture("refinement_actors_%dx%d.png" % [size_value.x, size_value.y])
	root.size = Vector2i(1280, 720)
	await _capture("game_phase3_actors.png")
	screen.start_new_game()
	_graphics_key(KEY_RIGHT, true)
	_game_ticks(screen, 9)
	await _capture("game_mid_jump.png")
	_graphics_key(KEY_RIGHT, false)
	_game_ticks(screen, 10)
	if screen.game.score.points != 25 or screen.game.simulation.cell != Vector2i(1, 1):
		_failures += 1
		printerr("Atterraggio/punteggio della partita grafica errati.")
	await _capture("game_landed.png")
	screen.start_new_game()
	_graphics_key(KEY_RIGHT, true)
	_game_ticks(screen, 1)
	_graphics_key(KEY_RIGHT, false)
	_game_ticks(screen, 299)
	if screen.game.world.actors.size() != 1 or screen.game.world.actors[0]["kind"] != 1:
		_failures += 1
		printerr("Il primo Segugio non è apparso nella partita effettiva.")
	await _capture("game_phase3_spawn.png")
	screen.start_new_game()
	screen.game.simulation.reset(0, Vector2i(3, 0))
	_graphics_key(KEY_Q, true)
	_game_ticks(screen, 1)
	_graphics_key(KEY_Q, false)
	_game_ticks(screen, 36)
	if screen.game.rescue_remaining != 36:
		_failures += 1
		printerr("Il viaggio della piattaforma non è attivo.")
	await _capture("game_phase3_rescue.png")
	screen.start_new_game()
	for death: int in range(3):
		_graphics_key(KEY_LEFT, true)
		_game_ticks(screen, 1)
		_graphics_key(KEY_LEFT, false)
		_game_ticks(screen, 18)
		if death == 0:
			await _capture("game_death.png")
			screen.set_game_paused(true)
			_game_ticks(screen, 30)
			if screen.game.remaining_ticks != 90:
				_failures += 1
			await _capture("game_paused.png")
			screen.set_game_paused(false)
		_game_ticks(screen, 90)
		if death == 0:
			await _capture("game_respawn.png")
	if screen.game.state != PyramidGame.State.GAME_OVER:
		_failures += 1
		printerr("Le tre cadute grafiche non hanno prodotto Game Over.")
	await _capture("game_over.png")
	screen.start_new_game()
	# Near-complete setup is only for visual coverage; reachability is tested by paths.
	for cell: Vector2i in screen.game.simulation.board.cells():
		if cell != Vector2i(1, 1):
			screen.game.simulation.board.apply_landing(cell)
	_graphics_key(KEY_C, true)
	_game_ticks(screen, 1)
	_graphics_key(KEY_C, false)
	_game_ticks(screen, 18)
	await _capture("game_round_end.png")
	_game_ticks(screen, PyramidGame.ROUND_END_TICKS)
	await _capture("game_next_round.png")
	screen.game.round_index = 11
	screen.game.simulation.reset(2)
	for cell: Vector2i in screen.game.simulation.board.cells():
		if cell != Vector2i(1, 1):
			screen.game.simulation.board.apply_landing(cell)
	_graphics_key(KEY_RIGHT, true)
	_game_ticks(screen, 1)
	_graphics_key(KEY_RIGHT, false)
	_game_ticks(screen, 18 + PyramidGame.ROUND_END_TICKS)
	if screen.game.state != PyramidGame.State.PLAYING or screen.game.round_index != 12:
		_failures += 1
		printerr("Progressione al livello 4 non raggiunta.")
	await _capture("game_level_4.png")
	await _capture_rescue_views(screen)
	await _capture_energy_and_spiders(screen)
	await _capture_gottlieb_calendar(screen)
	await _capture_phase4(screen)
	await _capture_arcade_review(screen)
	await _capture_corrective_review(screen)
	await _capture_revision_054(screen)
	await _capture_coil_death(screen)
	screen.queue_free()
	await process_frame


func _capture_rescue_views(screen: GameScreen) -> void:
	# Controlled board positions, but each trip uses the real keyboard/event bridge.
	for size_value: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = size_value
		await process_frame
		await process_frame
		for side: int in range(2):
			screen.start_new_game()
			screen.game.world.spawning_enabled = false
			screen.game.world.stasis_enabled = false
			var origin: Vector2i = Vector2i(3, 0) if side == 0 else Vector2i(5, 5)
			var key: int = KEY_Q if side == 0 else KEY_E
			var label: String = "left" if side == 0 else "right"
			screen.game.simulation.reset(0, origin)
			_graphics_key(key, true)
			_game_ticks(screen, 1)
			_graphics_key(key, false)
			for elapsed: int in [0, 9, 18, 45, 71, 72]:
				var already: int = 72 - screen.game.rescue_remaining if screen.game.rescue_remaining > 0 else 72
				_game_ticks(screen, elapsed - already)
				await _capture("refinement_%dx%d_%s_t%02d.png" % [size_value.x, size_value.y, label, elapsed])
			if screen.game.rescue_remaining != 0 or screen.game.simulation.cell != Vector2i.ZERO or screen.game.platforms[side]:
				_failures += 1
				printerr("Salvataggio non completato correttamente: " + label)


func _capture_energy_and_spiders(screen: GameScreen) -> void:
	# Round fixture selects 1/3; actors are spawned by the actual scheduler.
	screen.start_new_game()
	screen.game.round_index = 2
	screen.game._begin_round()
	screen.game.world.seed(3)
	screen.game.world.spawning_enabled = true
	screen.game.world.stasis_enabled = false
	screen.game.simulation.cell = Vector2i(2, 1)
	screen.game.protection_ticks = 3000
	var found: bool = false
	for tick: int in range(760):
		_game_ticks(screen, 1)
		for actor: Dictionary in screen.game.world.actors:
			if actor["kind"] == 2:
				found = true
		if found:
			break
	if not found:
		_failures += 1
		printerr("Nessun ragnetto dal vero scheduler del round 1/3 con seed 3.")
	await _capture("spider_round3_actual_spawn.png")
	for size_value: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = size_value
		screen.start_new_game()
		screen.game.round_index = 2
		screen.game._begin_round()
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		_game_ticks(screen, 1)
		# Both side variants in the same fixture, plus a hop for visual legibility.
		for side: int in range(2):
			var cell: Vector2i = Vector2i(4, 0) if side == 0 else Vector2i(4, 4)
			screen.game.world.actors.append({"id": side + 1, "kind": 2, "cell": cell,
				"from": cell, "to": Vector2i(3, 0) if side == 0 else Vector2i(3, 3),
				"moving": side == 1, "start": -12, "end": 12, "next": 99999})
		screen.view.queue_redraw()
		await _capture("spiders_both_%dx%d.png" % [size_value.x, size_value.y])
		screen.start_new_game()
		screen.game.round_index = 2
		screen.game._begin_round()
		screen.game.world.stasis_available = true
		screen.game.world.stasis_spawned = true
		screen.game.world.stasis_cell = Vector2i(1, 0)
		_graphics_key(KEY_DOWN, true)
		_game_ticks(screen, 1)
		_graphics_key(KEY_DOWN, false)
		_game_ticks(screen, 20)
		screen.game.world.actors.append({"id": 40, "kind": 2, "cell": Vector2i(2, 1),
			"from": Vector2i(2, 1), "to": Vector2i(2, 1), "moving": false,
			"start": 0, "end": 0, "next": 99999})
		_graphics_key(KEY_C, true)
		_game_ticks(screen, 1)
		_graphics_key(KEY_C, false)
		_game_ticks(screen, 18)
		if screen.game.score.lives != 3 or screen.game.simulation.cell != Vector2i(2, 1):
			_failures += 1
			printerr("Contatto protetto non riuscito nello smoke grafico.")
		await _capture("stasis_safe_contact_%dx%d.png" % [size_value.x, size_value.y])
		screen.game.world.stasis_remaining = 1
		_game_ticks(screen, 1)
		if screen.game.state != PyramidGame.State.DYING or screen.game.score.lives != 2:
			_failures += 1
		await _capture("stasis_expired_%dx%d.png" % [size_value.x, size_value.y])


func _capture_gottlieb_calendar(screen: GameScreen) -> void:
	root.size = Vector2i(1280, 720)
	for entry: Dictionary in [
		{"index": 0, "kinds": [0, 1], "green": false},
		{"index": 2, "kinds": [1, 2, 3], "green": true},
		{"index": 4, "kinds": [1, 2, 3], "green": true},
		{"index": 16, "kinds": [0, 1, 2, 3], "green": true}]:
		screen.start_new_game()
		screen.game.round_index = entry["index"]
		screen.game._begin_round()
		screen.game.world.seed(3)
		screen.game.world.spawning_enabled = true
		screen.game.world.stasis_enabled = true
		screen.game.simulation.cell = Vector2i(2, 1)
		screen.game.protection_ticks = 3000
		var valid: bool = true
		for tick: int in range(800):
			_game_ticks(screen, 1)
			if screen.game.world.warning_kind >= 0:
				valid = valid and entry["kinds"].has(screen.game.world.warning_kind)
			for actor: Dictionary in screen.game.world.actors:
				valid = valid and entry["kinds"].has(actor["kind"])
		valid = valid and screen.game.world.stasis_spawned == entry["green"]
		if not valid:
			_failures += 1
			printerr("Calendario personaggi non rispettato nello scenario grafico %d." % entry["index"])
		await _capture("gottlieb_level%d_round%d.png" % [screen.game.level_number, screen.game.round_number])


func _capture_phase4(screen: GameScreen) -> void:
	screen.start_new_game()
	screen.show_settings()
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		await _capture("phase4_settings_%dx%d.png" % [dimensions.x, dimensions.y])
		if not screen.game.paused or screen.settings_panel == null:
			_failures += 1
	# Show the lower controls at the smallest resolution, with keyboard focus.
	root.size = Vector2i(960, 540)
	(screen.settings_panel.find_child("CloseSettings", true, false) as Button).grab_focus()
	await _capture("phase4_settings_bindings_960x540.png")
	screen.settings_panel.close_panel()
	await process_frame
	if not screen.game.paused:
		_failures += 1
	screen.set_game_paused(false)
	root.size = Vector2i(1280, 720)
	await _capture("phase4_game_record.png")


func _graphics_key(key: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	root.push_input(event)


func _game_ticks(screen: GameScreen, count: int) -> void:
	for index: int in range(count):
		screen.advance_one_tick()


func _capture_arcade_review(screen: GameScreen) -> void:
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		for index: int in range(5):
			screen.start_new_game()
			screen.game.round_index = index
			screen.game._begin_round()
			screen.game.world.spawning_enabled = false
			screen.game.world.stasis_enabled = false
			screen.game.simulation.cell = Vector2i(4, 2)
			for cell: Vector2i in screen.game.simulation.board.cells():
				for pass_index: int in range((cell.x + cell.y) % 3):
					screen.game.simulation.board.apply_landing(cell)
			screen._refresh_ui()
			await _capture("arcade_palette_L%d_R%d_%dx%d.png" % [screen.game.level_number, screen.game.round_number, dimensions.x, dimensions.y])
		# Explicit gallery fixture, all roles allowed in V/1; no new spawn rules.
		screen.start_new_game()
		screen.game.round_index = 16
		screen.game._begin_round()
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		screen.game.simulation.cell = Vector2i(3, 1)
		for entry: Array in [[0, Vector2i(2, 0)], [1, Vector2i(2, 2)], [2, Vector2i(4, 0)], [2, Vector2i(4, 4)], [3, Vector2i(5, 2)]]:
			var cell: Vector2i = entry[1]
			screen.game.world.actors.append({"id": screen.game.world.actors.size() + 1, "kind": entry[0], "cell": cell, "from": cell, "to": cell, "moving": false, "start": 0, "end": 0, "next": 99999})
		screen.game.world.stasis_available = true
		screen.game.world.stasis_cell = Vector2i(5, 4)
		screen._refresh_ui()
		await _capture("arcade_cast_%dx%d.png" % [dimensions.x, dimensions.y])
	root.size = Vector2i(1280, 720)
	for direction: int in range(4):
		screen.start_new_game()
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		screen.game.simulation.reset(0, Vector2i(3, 1))
		var keys: Array[int] = [KEY_Q, KEY_E, KEY_Z, KEY_C]
		_graphics_key(keys[direction], true)
		_game_ticks(screen, 1)
		_graphics_key(keys[direction], false)
		_game_ticks(screen, 8)
		await _capture("arcade_hop_direction%d.png" % direction)
		_game_ticks(screen, 10)
		await _capture("arcade_landed_direction%d.png" % direction)


func _capture_corrective_review(screen: GameScreen) -> void:
	var app: Node = root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	screen.set_process(false)
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		var suffix: String = "%dx%d.png" % [dimensions.x, dimensions.y]
		screen.start_new_game()
		screen.game.world.spawning_enabled = false
		screen.game.round_index = 2
		screen.game._begin_round()
		screen.game.world.seed(5)
		screen.game.world.stasis_enabled = true
		screen.game.world.tick = 719
		screen.game.simulation.cell = Vector2i(6, 6)
		_game_ticks(screen, 1)
		await _capture("053_green_apex_" + suffix)
		_game_ticks(screen, 54)
		await _capture("053_green_hop_" + suffix)
		_game_ticks(screen, 274)
		if screen.game.world.stasis_available or screen.game.world.falling_actors.is_empty():
			_failures += 1
			printerr("Pillola non caduta nello scenario grafico.")
		await _capture("053_green_fall_" + suffix)
		screen.start_new_game()
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		screen.game.simulation.reset(0, Vector2i(3, 0))
		screen.game.protection_ticks = 10
		screen.game.world.actors.append({"id": 321, "kind": 1, "cell": Vector2i(3, 0), "from": Vector2i(3, 0), "to": Vector2i(3, 0), "moving": false, "start": 0, "end": 0, "next": 100})
		_graphics_key(KEY_Q, true)
		_game_ticks(screen, 1)
		_graphics_key(KEY_Q, false)
		_game_ticks(screen, 133)
		if screen.game.score.points != 500 or screen.game.world.falling_actors.is_empty():
			_failures += 1
			printerr("Caduta ritardata del Segugio non rappresentata.")
		await _capture("053_chaser_fall_" + suffix)
		screen.start_new_game()
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		app.data["leaderboard"] = []
		screen.game.score.credit("graphics-final", 50)
		screen.game.score.lives = 1
		screen.game.request_death(&"fall")
		_game_ticks(screen, 90)
		await _capture("053_game_over_" + suffix)
		if not screen.view.get_global_rect().encloses(screen.game_over_banner.get_global_rect()):
			_failures += 1
			printerr("Banner Game Over fuori dall'area di gioco.")
		screen.show_records()
		await _capture("053_records_qualified_" + suffix)
		if not screen.records_panel.name_edit.visible or not root.get_visible_rect().encloses(screen.records_panel.continue_button.get_global_rect()):
			_failures += 1
			printerr("Classifica qualificata o comando Menu fuori finestra.")
		screen.records_panel.name_edit.text = "ABC"
		screen.records_panel.save_result()
		await _capture("053_records_saved_" + suffix)
		screen.start_new_game()
		screen.game.world.spawning_enabled = false
		screen.game.world.stasis_enabled = false
		screen.game.score.lives = 1
		screen.game.request_death(&"fall")
		_game_ticks(screen, 90)
		screen.show_records()
		await _capture("053_records_unqualified_" + suffix)
		if screen.records_panel.name_edit.visible or not screen.records_panel.continue_button.has_focus():
			_failures += 1
			printerr("Classifica senza qualificazione non utilizzabile.")
	app.data = original
	app.apply_preferences()
	app.flush()


func _capture_revision_054(screen: GameScreen) -> void:
	var app: Node = root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	screen.set_process(false)
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		var suffix: String = "%dx%d.png" % [dimensions.x, dimensions.y]
		app.data = PlayerProfile.defaults()
		for i: int in range(10): app.data["leaderboard"] = HighScores.insert(app.data["leaderboard"], (i + 1) * 12345, i + 1, i % 4 + 1, "ABC")
		app.data["leaderboard"][0]["points"] = 2147483647
		app.data["leaderboard"][0]["level"] = 1000000
		app.data["record"] = 2147483647
		var intro: AttractPanel = AttractPanel.new()
		intro.app = app
		root.add_child(intro)
		intro.set_process(false)
		intro._process(12)
		await _capture("054_intro_instructions_" + suffix)
		intro._process(6)
		for tick: int in range(420): intro._demo_tick()
		intro.demo_view.queue_redraw()
		await _capture("054_intro_demo_" + suffix)
		intro._process(20)
		await _capture("054_intro_top_ten_" + suffix)
		if not root.get_visible_rect().encloses(intro.ranking.continue_button.get_global_rect()):
			_failures += 1
			printerr("Classifica iniziale fuori finestra.")
		intro.finish()
		intro.queue_free()
		await process_frame
		screen.start_new_game()
		screen.game.score.credit("054-final", 150000)
		screen.game.score.lives = 0
		screen.game.state = PyramidGame.State.GAME_OVER
		screen._refresh_ui()
		screen._process(.25)
		await _capture("054_game_over_on_" + suffix)
		screen._process(.30)
		await _capture("054_game_over_off_" + suffix)
		if screen.game_over_label.visible or screen.records_opened:
			_failures += 1
			printerr("Lampeggio o attesa Game Over errati.")
		screen.show_records()
		await _capture("054_records_full_" + suffix)
		var panel: RecordsPanel = screen.records_panel
		for row: Array in panel.ranking_rows:
			for column: int in range(5):
				if not is_equal_approx(row[column].get_global_rect().position.x, panel.ranking_rows[0][column].get_global_rect().position.x):
					_failures += 1
		if not root.get_visible_rect().encloses(panel.continue_button.get_global_rect()): _failures += 1
	app.data = original
	app.apply_preferences()
	app.flush()


func _capture_coil_death(screen: GameScreen) -> void:
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		for cell: Vector2i in [Vector2i.ZERO, Vector2i(3, 1), Vector2i(6, 0), Vector2i(6, 6)]:
			screen.start_new_game()
			screen.game.world.spawning_enabled = false
			screen.game.world.stasis_enabled = false
			screen.game.simulation.reset(0, cell)
			screen.game.score.lives = 1
			screen.game.world.actors.append({"id": 731, "kind": 1, "cell": cell, "from": cell, "to": cell, "moving": false, "start": 0, "end": 0, "next": 99999})
			_game_ticks(screen, 1)
			if not screen.view.shows_coil_death(): _failures += 1
			await _capture("coil_%d_%d_%dx%d.png" % [cell.x, cell.y, dimensions.x, dimensions.y])
			_game_ticks(screen, 90)
			if screen.view.shows_coil_death(): _failures += 1
			await _capture("coil_gameover_%d_%d_%dx%d.png" % [cell.x, cell.y, dimensions.x, dimensions.y])
