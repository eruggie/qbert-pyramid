extends SceneTree

const PROTOCOL: String = "qbert-pyramid-tests-v1"
const MENU_SCENE: String = "res://scenes/main_menu.tscn"

var _tests: int = 0
var _assertions: int = 0
var _failures: int = 0
var _test_name: String = ""
var _finished: bool = false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var mode: String = "normal"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			mode = argument.trim_prefix("--mode=")
	if mode == "empty":
		_finish()
		return
	if mode == "failure":
		_begin_test("intentional_failure")
		_check(false, "Fallimento intenzionale per verificare il codice di uscita.")
		_finish()
		return
	if mode != "normal":
		_begin_test("runner_arguments")
		_check(false, "Modalità sconosciuta: " + mode)
		_finish()
		return

	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
		await process_frame
		await process_frame
	_begin_test("project_configuration")
	_check(str(ProjectSettings.get_setting("application/run/main_scene", "")) == MENU_SCENE, "La scena iniziale deve essere il menu del progetto.")
	_check(str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) == "gl_compatibility", "Il progetto deve configurare Compatibility.")
	_check(Engine.get_version_info().get("string", "") == "4.7.2-stable (official)", "Il runner deve usare Godot 4.7.2 stable standard.")

	_begin_test("menu_input_map")
	for action: StringName in [&"ui_accept", &"ui_cancel", &"ui_up", &"ui_down", &"ui_focus_next", &"ui_focus_prev", &"toggle_fullscreen"]:
		_check(InputMap.has_action(action), "Azione InputMap richiesta: " + str(action))
	var has_f11: bool = false
	for event: InputEvent in InputMap.action_get_events(&"toggle_fullscreen"):
		if event is InputEventKey and (event as InputEventKey).keycode == KEY_F11:
			has_f11 = true
	_check(has_f11, "L'azione fullscreen deve includere F11.")

	_begin_test("isolated_user_data")
	var state_directory: String = OS.get_environment("AP_TEST_STATE_DIR")
	_check(not state_directory.is_empty(), "La directory di stato deve essere esplicita.")
	_check(OS.get_user_data_dir().begins_with(state_directory + "/data/"), "user:// deve essere contenuto nello stato isolato.")

	root.get_node("App").intro_seen = true
	_begin_test("menu_load_and_ready")
	var resource: Resource = load(MENU_SCENE)
	_check(resource is PackedScene, "La scena menu deve essere caricabile.")
	if not resource is PackedScene:
		_finish()
		return
	var menu: Node = (resource as PackedScene).instantiate()
	root.add_child(menu)
	await process_frame
	_check(menu is Control, "Il menu deve essere una Control.")
	_check(menu.is_node_ready(), "Il menu deve completare _ready.")
	_check(menu.has_method("show_instructions") and menu.has_method("close_dialogs"), "Il menu espone le API delle istruzioni.")
	_check(menu.has_method("get_phase_label"), "Il menu espone lo stato di fase.")
	if menu.has_method("get_phase_label"):
		_check(not str(menu.call("get_phase_label")).is_empty(), "Il menu deve dichiarare la fase corrente.")
	var instructions_button: Button = menu.get_node_or_null("%InstructionsButton") as Button
	var instructions_dialog: Window = menu.get_node_or_null("%InstructionsDialog") as Window
	var status_button: Button = menu.get_node_or_null("%StatusButton") as Button
	var status_dialog: Window = menu.get_node_or_null("%StatusDialog") as Window
	_check(instructions_button != null and instructions_dialog != null, "Pulsante e dialogo istruzioni devono esistere.")
	_check(status_button != null and status_dialog != null, "Pulsante e dialogo stato devono esistere.")

	if instructions_button != null:
		_check((menu.get_node("%GameButton") as Button).has_focus(), "Il focus iniziale deve essere su Nuova partita.")

	_begin_test("instructions_open_close")
	if instructions_button != null and instructions_dialog != null and menu.has_method("close_dialogs"):
		_check(not instructions_dialog.visible, "Le istruzioni inizialmente sono chiuse.")
		instructions_button.pressed.emit()
		await process_frame
		_check(instructions_dialog.visible, "Il pulsante deve aprire le istruzioni.")
		menu.call("close_dialogs")
		await process_frame
		_check(not instructions_dialog.visible, "Le istruzioni devono richiudersi.")
	else:
		_check(false, "Impossibile verificare il flusso istruzioni.")

	_begin_test("status_open_close")
	if status_button != null and status_dialog != null and menu.has_method("close_dialogs"):
		menu.call("show_project_status")
		await process_frame
		_check(status_dialog.visible, "Il pulsante deve aprire lo stato progetto.")
		menu.call("close_dialogs")
		await process_frame
		_check(not status_dialog.visible, "Il dialogo stato deve richiudersi.")
	else:
		_check(false, "Impossibile verificare il flusso stato.")

	_begin_test("release_1_1_public_menu_and_about")
	var lab_button: Button = menu.get_node("%LabButton") as Button
	var game_button: Button = menu.get_node("%GameButton") as Button
	_check(not lab_button.visible and lab_button.disabled and lab_button.focus_mode == Control.FOCUS_NONE, "Il laboratorio predefinito è nascosto, disabilitato e fuori dal focus.")
	_check(instructions_button.text == "Informazioni sul gioco" and instructions_dialog.title == "Informazioni sul gioco", "Voce e finestra hanno il titolo About richiesto.")
	var about: String = (instructions_dialog as AcceptDialog).dialog_text
	for fragment: String in ["QBERT Rev. 1.1", "Autore: Eugenio Ruggieri", "GNU GPL v3.0", "COME SI GIOCA", "Colora 28 celle", "Q/Sinistra", "Tre vite", "Master", "Extra a 8.000"]:
		# Current audio instructions use Volume rather than a separate Master label.
		if fragment == "Master": fragment = "Volume, mute e tasti"
		_check(about.contains(fragment), "Informazioni preserva contenuti e attribuzioni: " + fragment)
	_check(not about.contains("Laboratorio:"), "Il giocatore non riceve istruzioni sullo strumento tecnico nascosto.")
	menu.call("show_lab")
	_check(menu.is_inside_tree(), "Il laboratorio disabilitato non può cambiare scena tramite il menu.")
	game_button.grab_focus()
	var down: InputEventKey = InputEventKey.new()
	down.keycode = KEY_DOWN
	down.pressed = true
	root.push_input(down)
	down = down.duplicate() as InputEventKey
	down.pressed = false
	root.push_input(down)
	await process_frame
	_check(instructions_button.has_focus(), "Giù salta il laboratorio nascosto e seleziona Informazioni sul gioco.")
	_check(instructions_button.get_node(instructions_button.focus_neighbor_top) == game_button, "Il collegamento Su ritorna a Nuova partita.")

	_begin_test("release_1_1_developer_menu_configuration")
	ProjectSettings.set_setting("developer/rules_lab_enabled", true)
	var developer_menu: MainMenu = (resource as PackedScene).instantiate() as MainMenu
	root.add_child(developer_menu)
	await process_frame
	ProjectSettings.set_setting("developer/rules_lab_enabled", false)
	var developer_lab: Button = developer_menu.get_node("%LabButton") as Button
	_check(developer_lab.visible and not developer_lab.disabled and developer_lab.focus_mode == Control.FOCUS_ALL, "La configurazione tecnica abilita la voce di laboratorio.")
	_check(developer_lab.has_focus() and developer_menu.instructions_dialog.dialog_text.contains("Laboratorio:"), "Configurazione tecnica conserva ingresso e indicazioni operative del laboratorio.")
	developer_menu.queue_free()
	await process_frame
	instructions_button.grab_focus()

	_begin_test("focus_suspend_resume")
	menu.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(paused, "La perdita focus deve sospendere la shell.")
	_check(bool(menu.get("is_focus_suspended")), "Il menu deve registrare la sospensione.")
	menu.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(not paused, "Il ritorno focus deve riprendere la shell.")
	_check(not bool(menu.get("is_focus_suspended")), "Lo stato di sospensione deve cancellarsi.")
	paused = true
	menu.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	menu.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(paused, "Una pausa preesistente deve essere preservata.")
	paused = false

	for window_size: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		_begin_test("menu_layout_%dx%d" % [window_size.x, window_size.y])
		root.size = window_size
		await process_frame
		await process_frame
		var bounds: Rect2 = root.get_visible_rect().grow(1.0)
		for node_path: String in ["%GameButton", "%LabButton", "%TitleLabel", "%PhaseLabel", "%InstructionsButton", "%StatusButton", "%ExitButton", "Margin/Content/IntroLabel", "Margin/Content/HelpLabel"]:
			var control: Control = menu.get_node_or_null(node_path) as Control
			_check(control != null, "Controllo layout esistente: " + node_path)
			if control != null and control.is_visible_in_tree():
				_check(bounds.encloses(control.get_global_rect()), "Il controllo deve restare nel viewport: " + node_path)
				_check(control.get_combined_minimum_size().x <= control.size.x + 1.0, "Il controllo deve contenere la larghezza minima: " + node_path)

	menu.queue_free()
	await process_frame
	await _run_external_suite("res://tests/unit/test_foundation_rules.gd")
	await _run_external_suite("res://tests/integration/test_rules_lab.gd")
	await _run_external_suite("res://tests/unit/test_game_rules.gd")
	await _run_external_suite("res://tests/unit/test_world_rules.gd")
	await _run_external_suite("res://tests/integration/test_game_screen.gd")
	await _run_external_suite("res://tests/unit/test_player_profile.gd")
	await _run_external_suite("res://tests/integration/test_experience.gd")
	await _run_external_suite("res://tests/integration/test_arcade_review.gd")
	await _run_external_suite("res://tests/integration/test_corrective_review.gd")
	await _run_external_suite("res://tests/integration/test_revision_054.gd")
	await _run_external_suite("res://tests/integration/test_coil_death.gd")
	_finish()


func _run_external_suite(path: String) -> void:
	_begin_test("suite_contract:" + path.get_file())
	var resource: Resource = load(path)
	_check(resource is Script, "La suite obbligatoria deve essere uno script caricabile: " + path)
	if not resource is Script:
		return
	var suite: RefCounted = (resource as Script).new() as RefCounted
	_check(suite != null and suite.has_method("run"), "La suite deve esporre run(runner): " + path)
	if suite == null or not suite.has_method("run"):
		return
	var tests_before: int = _tests
	var assertions_before: int = _assertions
	await suite.call("run", self)
	_check(_tests > tests_before and _assertions > assertions_before, "Una suite obbligatoria vuota deve fallire: " + path)


func _begin_test(test_name: String) -> void:
	_tests += 1
	_test_name = test_name
	print("TEST: " + test_name)


func _check(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures += 1
		print("FAIL [%s]: %s" % [_test_name, message])


func _finish() -> void:
	if _finished:
		return
	_finished = true
	if _tests == 0 or _assertions == 0:
		_failures += 1
		print("FAIL: Una suite priva di test o verifiche non può essere superata.")
	var report_path: String = OS.get_environment("AP_TEST_REPORT_PATH")
	var run_id: String = OS.get_environment("AP_TEST_RUN_ID")
	var report: Dictionary = {
		"protocol": PROTOCOL,
		"run_id": run_id,
		"complete": true,
		"tests": _tests,
		"assertions": _assertions,
		"failures": _failures,
		"success": _failures == 0 and _tests > 0 and _assertions > 0
	}
	if report_path.is_empty() or run_id.is_empty():
		print("FAIL: Ambiente del runner incompleto.")
		quit(2)
		return
	var report_file: FileAccess = FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		print("FAIL: Impossibile scrivere il report del runner.")
		quit(2)
		return
	report_file.store_string(JSON.stringify(report, "\t") + "\n")
	report_file.close()
	print("AP_TEST_COMPLETE " + run_id)
	print("Risultato: %d test, %d verifiche, %d fallimenti." % [_tests, _assertions, _failures])
	quit(0 if bool(report["success"]) else 1)
