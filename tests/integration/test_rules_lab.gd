extends RefCounted
## Device → InputMap → deterministic simulation → view integration.
## Only phase 1: no lives, scoring, opponents or round progression.

const LAB_SCENE: String = "res://scenes/rules_lab.tscn"
const MENU_SCENE: String = "res://scenes/main_menu.tscn"
const DIRECTIONS: Array[StringName] = [&"move_nw", &"move_ne", &"move_sw", &"move_se"]
const PRIMARY_KEYS: Array[int] = [KEY_Q, KEY_E, KEY_Z, KEY_C]
const ARROW_KEYS: Array[int] = [KEY_LEFT, KEY_UP, KEY_DOWN, KEY_RIGHT]
const SECONDARY_KEYS: Array[int] = [KEY_KP_7, KEY_KP_9, KEY_KP_1, KEY_KP_3]

var _runner: SceneTree
var _lab: Node
var _base_jump_id: int = 0


func run(runner: SceneTree) -> void:
	_runner = runner
	_begin("rules_lab_load")
	var resource: Resource = load(LAB_SCENE)
	_check(resource is PackedScene, "La scena del laboratorio deve essere caricabile.")
	if not resource is PackedScene:
		return
	_lab = (resource as PackedScene).instantiate()
	_runner.root.add_child(_lab)
	_lab.set_physics_process(false)
	await _runner.process_frame
	var required_methods: Array[StringName] = [&"advance_one_tick", &"handle_input_event", &"select_mode", &"reset_lab", &"set_lab_paused", &"resume_lab", &"return_to_menu"]
	var api_available: bool = true
	for method: StringName in required_methods:
		api_available = api_available and _lab.has_method(method)
	_check(api_available, "Il laboratorio deve esporre il ponte pubblico fra input e simulazione.")
	if not api_available:
		_lab.queue_free()
		await _runner.process_frame
		return
	_check(_simulation() != null and _adapter() != null, "Simulazione e adattatore devono esistere dopo _ready.")
	if _simulation() == null or _adapter() == null:
		_lab.queue_free()
		await _runner.process_frame
		return

	_test_board_view()
	_test_default_bindings_and_directions()
	_test_arrow_bindings()
	_test_equivalent_pairs()
	_test_mixed_buffer()
	_test_mixed_priorities()
	await _test_arrow_ui_context()
	_test_arrow_boundaries()
	_test_multiple_sources()
	_test_os_echo()
	_test_quick_tap()
	await _test_engine_dispatch()
	_test_simultaneous_presses()
	_test_released_buffer()
	_test_pause_flush()
	_test_focus_requires_resume()
	await _test_focus_release_outside_application()
	await _test_focus_still_held()
	_test_mode_and_reset_controls()
	_test_runtime_remap()
	# Developer configuration explicitly enables the technical menu for these tests.
	ProjectSettings.set_setting("developer/rules_lab_enabled", true)
	await _test_menu_navigation()
	ProjectSettings.set_setting("developer/rules_lab_enabled", false)


func _test_board_view() -> void:
	_begin("rules_lab_board_view_bridge")
	_reset()
	var view: Control = _lab.get_node_or_null("%PyramidView") as Control
	_check(view != null, "La vista isometrica deve essere presente.")
	if view == null:
		return
	_check(view.get("simulation") == _simulation(), "La vista deve rappresentare la simulazione effettiva del laboratorio.")
	_check(int(view.call("rendered_cell_count")) == 28, "La vista deve rappresentare tutte le 28 celle.")
	var cells: Array = _board().call("cells")
	var centers: Dictionary = {}
	var valid_polygons: bool = true
	var contained: bool = true
	for cell: Vector2i in cells:
		var center: Vector2 = view.call("cell_to_canvas", cell)
		var polygon: PackedVector2Array = view.call("cell_polygon", cell)
		centers[center] = true
		valid_polygons = valid_polygons and polygon.size() >= 4
		for point: Vector2 in polygon:
			contained = contained and Rect2(Vector2.ZERO, view.size).grow(1.0).has_point(point)
	_check(cells.size() == 28 and centers.size() == 28, "Ciascuna cella logica deve avere una posizione grafica distinta.")
	_check(valid_polygons and contained, "Le superfici delle 28 celle devono esistere ed essere contenute nella vista.")
	_check(_simulation().get("cell") == Vector2i.ZERO and int(_board().call("completed_count")) == 0, "La comparsa non deve colorare l'apice.")


func _test_default_bindings_and_directions() -> void:
	_begin("rules_lab_input_map_four_diagonals")
	var source: Vector2i = Vector2i(3, 1)
	var targets: Array[Vector2i] = [Vector2i(2, 0), Vector2i(2, 1), Vector2i(4, 1), Vector2i(4, 2)]
	for direction: int in range(4):
		var action: StringName = DIRECTIONS[direction]
		_check(InputMap.has_action(action), "Azione diagonale presente: " + str(action))
		_check(InputMap.event_is_action(_key(PRIMARY_KEYS[direction], true), action), "Il tasto principale deve essere un binding effettivo di " + str(action))
		_check(InputMap.event_is_action(_key(SECONDARY_KEYS[direction], true), action), "Il tastierino deve essere un binding effettivo di " + str(action))
		_reset(0, source)
		_check(_feed(PRIMARY_KEYS[direction], true), "L'adattatore deve riconoscere il binding di " + str(action))
		var started: Array = _advance(1)
		_feed(PRIMARY_KEYS[direction], false)
		_check(_has_event(started, &"jump_started"), "Il dispositivo deve produrre un solo comando di salto.")
		_check(_simulation().get("jump_to") == targets[direction], "La direzione InputMap deve raggiungere la cella logica corretta.")
		_check(int(_simulation().get("jump_start_tick")) == 1 and int(_simulation().get("jump_end_tick")) == 19, "Il ponte deve conservare i 18 tick del salto.")
		_advance(18)
		_check(_simulation().get("cell") == targets[direction], "La simulazione deve completare l'atterraggio richiesto.")
		_check(int(_board().call("get_state", targets[direction])) == 1, "L'atterraggio deve aggiornare il colore effettivamente rappresentato.")
		_check(_jump_count() == 1, "Pressione e rilascio non devono duplicare il salto.")


func _test_arrow_bindings() -> void:
	_begin("arrows_all_bindings_and_landings")
	var targets: Array[Vector2i] = [Vector2i(3, 1), Vector2i(3, 2), Vector2i(5, 2), Vector2i(5, 3)]
	for direction: int in range(4):
		for key: int in [PRIMARY_KEYS[direction], SECONDARY_KEYS[direction], ARROW_KEYS[direction]]:
			_reset(0, Vector2i(4, 2))
			_check(InputMap.event_is_action(_key(key, true), DIRECTIONS[direction]), "Lettera, tastierino e freccia devono conservare la stessa azione.")
			_runner.root.push_input(_key(key, true))
			_check(_runner.root.is_input_handled(), "Il laboratorio deve consumare la pressione direzionale.")
			_advance(1)
			_runner.root.push_input(_key(key, false))
			_advance(40)
			_check(_jump_count() == 1 and _simulation().get("cell") == targets[direction], "Ogni binding deve produrre un unico atterraggio nella diagonale prevista.")


func _test_equivalent_pairs() -> void:
	for direction: int in range(4):
		_begin("arrows_equivalent_orders_%d" % direction)
		for press_order: int in range(2):
			for release_order: int in range(2):
				var pair: Array[int] = [PRIMARY_KEYS[direction], ARROW_KEYS[direction]]
				if press_order == 1:
					pair.reverse()
				_reset(0, Vector2i(4, 2))
				_feed(pair[0], true)
				_advance(10)
				_feed(pair[1], true)
				_feed(pair[1], true, true)
				_advance(1)
				_check(_jump_count() == 1, "Il secondo equivalente e l'echo non devono avviare un salto.")
				_feed(pair[release_order], false)
				_advance(10)
				_check(_jump_count() == 2 and int(_adapter().call("held_source_count")) == 1, "Una sorgente deve mantenere la ripetizione fino al tick 21.")
				_feed(pair[1 - release_order], false)
				_advance(40)
				var delta: Vector2i = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(1, 1)][direction]
				_check(_jump_count() == 2 and _simulation().get("cell") == Vector2i(4, 2) + 2 * delta, "Il rilascio finale deve fermare la ripetizione dopo due atterraggi.")
				_check(int(_adapter().call("held_source_count")) == 0, "Nessuna sorgente mantenuta residua.")
				# A late duplicate must not create a fresh buffer after both releases.
				_reset(0, Vector2i(4, 2))
				_feed(pair[0], true)
				_advance(11)
				_feed(pair[1], true)
				_feed(pair[release_order], false)
				_feed(pair[1 - release_order], false)
				_advance(40)
				_check(_jump_count() == 1, "Il secondo equivalente non deve accodare un salto durante il primo.")


func _test_mixed_buffer() -> void:
	_begin("arrows_mixed_buffer_priority_and_expiry")
	for swap: bool in [false, true]:
		var sw: int = KEY_DOWN if swap else KEY_Z
		var sw_equivalent: int = KEY_Z if swap else KEY_DOWN
		var se: int = KEY_C if swap else KEY_RIGHT
		_reset()
		_feed(sw, true)
		_advance(11)
		_feed(se, true)
		_feed(se, false)
		_feed(sw_equivalent, true)
		_advance(10)
		_check(_jump_count() == 2 and _simulation().get("jump_to") == Vector2i(2, 1), "Il secondo equivalente non deve sostituire il buffer di una direzione diversa.")
		_feed(sw, false)
		_feed(sw_equivalent, false)
		_advance(40)
		_check(_jump_count() == 2 and _simulation().get("cell") == Vector2i(2, 1), "Il buffer misto deve produrre un solo atterraggio aggiuntivo.")
		_reset()
		_feed(sw, true)
		_advance(1)
		_feed(sw, false)
		_advance(7)
		_feed(se, true)
		_advance(10)
		var se_equivalent: int = KEY_RIGHT if swap else KEY_C
		_feed(se_equivalent, true)
		_feed(se, false)
		_feed(se_equivalent, false)
		_advance(30)
		_check(_jump_count() == 1, "L'equivalente tardivo non deve rinnovare il TTL: il buffer al tick 9 scade al tick 21.")


func _test_mixed_priorities() -> void:
	_begin("arrows_mixed_simultaneous_and_latest_held")
	for reverse: bool in [false, true]:
		_reset(0, Vector2i(4, 2))
		var keys: Array[int] = [KEY_RIGHT, KEY_Z, KEY_UP, KEY_Q]
		if reverse:
			keys.reverse()
		for key: int in keys:
			_feed(key, true)
		_advance(1)
		_check(_simulation().get("jump_to") == Vector2i(3, 1), "La priorità simultanea NO deve essere indipendente dal tipo di tasto e dall'ordine.")
		for key: int in keys:
			_feed(key, false)
		_advance(40)
		_check(_jump_count() == 1, "Le direzioni perdenti non devono diventare una coda.")
	_reset()
	_feed(KEY_DOWN, true)
	_advance(2)
	_feed(KEY_C, true)
	_advance(19)
	_check(_simulation().get("jump_to") == Vector2i(2, 1), "Scaduto il buffer deve vincere la direzione mantenuta premuta più recentemente.")
	_feed(KEY_C, false)
	_advance(20)
	_check(_simulation().get("jump_to") == Vector2i(3, 1), "Rilasciata l'ultima direzione, deve restare attiva la freccia precedente.")
	_feed(KEY_DOWN, false)
	_advance(40)
	_check(_jump_count() == 3, "L'ultimo rilascio deve terminare anche la sequenza mista.")


func _test_arrow_ui_context() -> void:
	_begin("arrows_lab_ui_context_and_popup")
	_reset()
	var pause_button: Button = _lab.get_node("%PauseButton") as Button
	pause_button.grab_focus()
	_runner.root.push_input(_key(KEY_DOWN, true))
	_advance(1)
	_runner.root.push_input(_key(KEY_DOWN, false))
	_check(pause_button.has_focus() and _jump_count() == 1, "La freccia di gioco deve saltare senza navigare il focus UI.")
	_lab.call("set_lab_paused", true)
	var tick: int = int(_simulation().get("tick"))
	_runner.root.push_input(_key(KEY_LEFT, true))
	_runner.root.push_input(_key(KEY_LEFT, false))
	await _runner.process_frame
	_check(not pause_button.has_focus(), "In pausa la freccia deve navigare i controlli UI.")
	_advance(30)
	_check(int(_simulation().get("tick")) == tick, "La navigazione UI non deve far avanzare la simulazione.")
	_lab.call("resume_lab")
	_advance(40)
	_check(_jump_count() == 1, "La navigazione in pausa non deve accodare salti alla ripresa.")
	var selector: OptionButton = _lab.get_node("%ModeSelector") as OptionButton
	selector.show_popup()
	await _runner.process_frame
	_check(bool(_simulation().get("paused")), "L'apertura del menu Regola deve sospendere i comandi di gioco.")
	var popup: PopupMenu = selector.get_popup()
	var focused_items: Array[int] = []
	popup.id_focused.connect(func(id: int) -> void: focused_items.append(id))
	popup.set_focused_item(0)
	# Deliver through the engine window route, including the popup window ID.
	var down: InputEventKey = _key(KEY_DOWN, true)
	down.window_id = popup.get_window_id()
	Input.parse_input_event(down)
	Input.flush_buffered_events()
	await _runner.process_frame
	var up: InputEventKey = _key(KEY_DOWN, false)
	up.window_id = popup.get_window_id()
	Input.parse_input_event(up)
	await _runner.process_frame
	_check(focused_items.has(1), "La freccia nel popup deve selezionare la seconda opzione: %s" % str(focused_items))
	_advance(30)
	_check(_jump_count() == 1 and bool(_simulation().get("paused")), "Navigare il popup non deve produrre salti o buffer.")
	selector.get_popup().hide()
	await _runner.process_frame
	_check(bool(_simulation().get("paused")), "La chiusura del popup non deve riprendere implicitamente.")
	_lab.call("resume_lab")
	_advance(40)
	_check(_jump_count() == 1, "Il popup non deve lasciare comandi residui.")


func _test_arrow_boundaries() -> void:
	_begin("arrows_mixed_pause_reset_focus")
	for boundary: String in ["pause", "reset", "focus"]:
		_reset()
		_feed(KEY_Z, true)
		_feed(KEY_DOWN, true)
		_advance(4)
		if boundary == "reset":
			_lab.call("reset_lab")
		elif boundary == "focus":
			_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
		else:
			_lab.call("set_lab_paused", true)
		_feed(KEY_Z, false)
		_feed(KEY_DOWN, false)
		if boundary == "focus":
			_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
			_check(bool(_simulation().get("paused")), "Il ritorno focus richiede ripresa esplicita.")
		_lab.call("resume_lab")
		_advance(40)
		_check(_jump_count() == (0 if boundary == "reset" else 1), "La transizione non deve riutilizzare le due sorgenti precedenti.")
		var before: int = int(_simulation().get("jump_id"))
		_feed(KEY_DOWN, true)
		_advance(1)
		_check(int(_simulation().get("jump_id")) > before, "La prima freccia fresca deve funzionare dopo la transizione.")
		_feed(KEY_DOWN, false)


func _test_multiple_sources() -> void:
	_begin("rules_lab_multiple_bindings_one_action")
	_reset()
	_feed(KEY_Z, true)
	_feed(KEY_KP_1, true)
	_feed(KEY_Z, false)
	_check(int(_adapter().call("held_source_count")) == 1, "Rilasciare uno dei due binding deve lasciare attiva l'altra sorgente.")
	_advance(21)
	_check(_jump_count() == 2 and _simulation().get("jump_to") == Vector2i(2, 0), "Il binding ancora mantenuto deve ripetere la diagonale al primo istante utile.")
	_feed(KEY_KP_1, false)
	_advance(40)
	_check(int(_adapter().call("held_source_count")) == 0, "L'ultimo rilascio deve chiudere tutte le sorgenti della direzione.")
	_check(_jump_count() == 2 and _simulation().get("cell") == Vector2i(2, 0), "Dopo l'ultimo rilascio non devono apparire ripetizioni residue.")


func _test_os_echo() -> void:
	_begin("rules_lab_os_echo_is_ignored")
	_reset()
	_feed(KEY_Z, true, true)
	_advance(1)
	_check(int(_simulation().get("jump_id")) == 0, "Un echo senza nuova pressione non deve avviare un salto.")
	_feed(KEY_Z, true)
	_advance(1)
	_feed(KEY_Z, false)
	_feed(KEY_C, true, true)
	_advance(40)
	_check(_jump_count() == 1 and _simulation().get("cell") == Vector2i(1, 0), "Un echo durante il salto non deve rinnovare buffer o mantenuti.")


func _test_quick_tap() -> void:
	_begin("rules_lab_quick_tap_has_no_phantom_hold")
	_reset()
	_feed(KEY_Z, true)
	_feed(KEY_Z, false)
	_advance(60)
	_check(int(_adapter().call("held_source_count")) == 0, "Un tap interamente fra due tick deve risultare fisicamente rilasciato.")
	_check(_jump_count() == 1 and _simulation().get("cell") == Vector2i(1, 0), "Un tap nello stesso tick deve avviare un salto e nessuna ripetizione fantasma.")


func _test_engine_dispatch() -> void:
	_begin("rules_lab_engine_dispatch_to_input_bridge")
	_reset()
	Input.parse_input_event(_key(KEY_Z, true))
	await _runner.process_frame
	_advance(1)
	Input.parse_input_event(_key(KEY_Z, false))
	await _runner.process_frame
	_advance(40)
	_check(_jump_count() == 1 and _simulation().get("cell") == Vector2i(1, 0), "Il dispatch effettivo di Godot deve raggiungere il laboratorio anche con un controllo UI in focus.")


func _test_simultaneous_presses() -> void:
	_begin("rules_lab_same_tick_input_priority")
	_reset(0, Vector2i(3, 1))
	# Reverse arrival order deliberately differs from the declared NW-first priority.
	_feed(KEY_E, true)
	_feed(KEY_Q, true)
	var started: Array = _advance(1)
	_feed(KEY_E, false)
	_feed(KEY_Q, false)
	_check(_simulation().get("jump_to") == Vector2i(2, 0), "Fra pressioni nello stesso tick deve vincere NO, indipendentemente dall'ordine degli eventi.")
	_check(_count_events(started, &"jump_started") == 1, "Due pressioni simultanee devono produrre una sola partenza.")
	_advance(40)
	_check(_jump_count() == 1, "Le pressioni perdenti non devono produrre una coda nascosta.")


func _test_released_buffer() -> void:
	_begin("rules_lab_device_buffer_survives_release")
	_reset()
	_feed(KEY_Z, true)
	_advance(1)
	_feed(KEY_Z, false)
	_advance(10)
	_feed(KEY_C, true)
	_feed(KEY_C, false)
	_advance(10)
	_check(int(_simulation().get("tick")) == 21 and _jump_count() == 2, "Una pressione recente durante il salto deve partire dopo i due tick di recupero anche se già rilasciata.")
	_check(_simulation().get("jump_to") == Vector2i(2, 1), "Il buffer deve conservare la diagonale richiesta dal dispositivo.")

	_begin("rules_lab_device_buffer_exact_expiry")
	_reset()
	_feed(KEY_Z, true)
	_advance(1)
	_feed(KEY_Z, false)
	_advance(7)
	_feed(KEY_C, true)
	_feed(KEY_C, false)
	_advance(13)
	_check(int(_simulation().get("tick")) == 21 and _jump_count() == 1, "La pressione accettata al tick 9 deve essere scaduta al tick 21: età 12 non è valida.")


func _test_pause_flush() -> void:
	_begin("rules_lab_pause_flushes_physical_sources")
	_reset()
	_feed(KEY_Z, true)
	_advance(5)
	var pause_button: Button = _lab.get_node_or_null("%PauseButton") as Button
	_check(pause_button != null, "Il laboratorio deve offrire il controllo di pausa.")
	if pause_button == null:
		return
	pause_button.pressed.emit()
	var paused_tick: int = int(_simulation().get("tick"))
	var paused_progress: float = float(_simulation().get("jump_progress"))
	_advance(30)
	_check(bool(_simulation().get("paused")), "Il controllo UI deve sospendere la simulazione reale.")
	_check(int(_simulation().get("tick")) == paused_tick and is_equal_approx(float(_simulation().get("jump_progress")), paused_progress), "Tick e avanzamento del salto devono restare fermi in pausa.")
	pause_button.pressed.emit()
	_advance(40)
	_check(not bool(_simulation().get("paused")) and _jump_count() == 1, "La ripresa non deve riattivare un tasto mantenuto prima della pausa.")
	_feed(KEY_Z, false)
	_feed(KEY_Z, true)
	_advance(1)
	_feed(KEY_Z, false)
	_check(_jump_count() == 2, "Dopo il rilascio una nuova pressione deve funzionare normalmente.")


func _test_focus_requires_resume() -> void:
	_begin("rules_lab_focus_loss_requires_explicit_resume")
	_reset()
	_feed(KEY_Z, true)
	_advance(4)
	_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var suspended_tick: int = int(_simulation().get("tick"))
	_advance(20)
	_check(bool(_simulation().get("paused")) and int(_simulation().get("tick")) == suspended_tick, "La perdita del focus deve sospendere i tick del laboratorio.")
	_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(bool(_simulation().get("paused")), "Il solo ritorno del focus non deve riprendere la simulazione.")
	_lab.call("resume_lab")
	_advance(40)
	_check(_jump_count() == 1 and _simulation().get("cell") == Vector2i(1, 0), "La ripresa esplicita deve concludere il salto senza riusare il mantenuto precedente.")
	_feed(KEY_Z, false)


func _test_focus_release_outside_application() -> void:
	_begin("rules_lab_focus_reconciles_release_outside_application")
	_reset()
	Input.parse_input_event(_key(KEY_DOWN, true))
	await _runner.process_frame
	_advance(4)
	_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	# The engine receives the release, while the unfocused lab does not receive it.
	_lab.set_process_input(false)
	Input.parse_input_event(_key(KEY_DOWN, false))
	await _runner.process_frame
	_check(not Input.is_physical_key_pressed(KEY_DOWN), "La sorgente globale deve registrare il rilascio fuori dal laboratorio.")
	_check(int(_adapter().call("held_source_count")) == 1, "L'adattatore deve ancora avere il binding bloccato il cui rilascio non è stato consegnato.")
	_lab.set_process_input(true)
	_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(int(_adapter().call("held_source_count")) == 0, "Il ritorno del focus deve riconciliare la sorgente già rilasciata.")
	_check(bool(_simulation().get("paused")), "La riconciliazione non deve riprendere automaticamente il laboratorio.")
	_lab.call("resume_lab")
	_advance(40)
	_check(_jump_count() == 1, "La riconciliazione deve lasciare terminare solo il salto precedente.")
	Input.parse_input_event(_key(KEY_DOWN, true))
	await _runner.process_frame
	_advance(1)
	_check(_jump_count() == 2 and _simulation().get("jump_to") == Vector2i(2, 0), "La prima nuova pressione dopo il ritorno deve essere accettata subito.")
	Input.parse_input_event(_key(KEY_DOWN, false))
	await _runner.process_frame
	_advance(40)
	_check(_jump_count() == 2, "Il primo nuovo tap dopo il focus non deve introdurre ripetizioni residue.")


func _test_focus_still_held() -> void:
	_begin("rules_lab_focus_preserves_block_on_still_held_source")
	_reset()
	Input.parse_input_event(_key(KEY_DOWN, true))
	await _runner.process_frame
	_advance(4)
	_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_lab.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(Input.is_physical_key_pressed(KEY_DOWN), "Il secondo scenario deve mantenere il tasto globalmente premuto.")
	_check(int(_adapter().call("held_source_count")) == 1, "Una sorgente ancora premuta non deve essere cancellata dalla riconciliazione.")
	_lab.call("resume_lab")
	_advance(40)
	_check(_jump_count() == 1, "Il tasto rimasto premuto durante la perdita del focus non deve riprendere a saltare.")
	Input.parse_input_event(_key(KEY_DOWN, false))
	await _runner.process_frame
	Input.parse_input_event(_key(KEY_DOWN, true))
	await _runner.process_frame
	_advance(1)
	_check(_jump_count() == 2, "Dopo il rilascio e una nuova pressione il binding deve tornare operativo.")
	Input.parse_input_event(_key(KEY_DOWN, false))
	await _runner.process_frame
	_advance(40)
	_check(_jump_count() == 2, "Il rilascio finale deve fermare ogni ripetizione del binding riconciliato.")


func _test_mode_and_reset_controls() -> void:
	_begin("rules_lab_mode_and_reset_ui_bridge")
	_reset()
	_feed(KEY_Z, true)
	_advance(1)
	_feed(KEY_Z, false)
	_advance(18)
	_check(int(_board().call("completed_count")) == 1, "La modalità permanente deve aggiornare il progresso dopo l'atterraggio.")
	var selector: OptionButton = _lab.get_node_or_null("%ModeSelector") as OptionButton
	var reset_button: Button = _lab.get_node_or_null("%ResetButton") as Button
	var progress_label: Label = _lab.get_node_or_null("%ProgressLabel") as Label
	_check(selector != null and reset_button != null and progress_label != null, "Selettore modalità, reset e progresso devono esistere.")
	if selector == null or reset_button == null or progress_label == null:
		return
	selector.select(1)
	selector.item_selected.emit(1)
	_check(int(_board().get("color_mode")) == 1 and int(_board().call("target_state")) == 2, "Il selettore deve attivare la regola a due passaggi effettiva.")
	_check(_simulation().get("cell") == Vector2i.ZERO and int(_board().call("completed_count")) == 0, "Il cambio di regola deve riavviare la dimostrazione senza colorare l'apice.")
	_feed(KEY_Z, true)
	_advance(1)
	_feed(KEY_Z, false)
	_advance(18)
	_check(int(_board().call("get_state", Vector2i(1, 0))) == 1 and int(_board().call("completed_count")) == 0, "Un solo atterraggio a due passaggi deve restare intermedio.")
	_check(progress_label.text.replace(" ", "").contains("0/28"), "Il progresso UI deve distinguere celle intermedie e celle completate.")
	selector.select(2)
	selector.item_selected.emit(2)
	_check(int(_board().get("color_mode")) == 2 and int(_board().call("target_state")) == 1, "Il selettore deve attivare la regola reversibile.")
	_feed(KEY_Z, true)
	_advance(1)
	reset_button.pressed.emit()
	_check(int(_board().get("color_mode")) == 2 and int(_simulation().get("jump_id")) == 0, "Il reset deve conservare la modalità e cancellare il salto in corso.")
	_check(_simulation().get("cell") == Vector2i.ZERO and int(_board().call("completed_count")) == 0, "Il reset deve ripristinare attore e colori iniziali.")
	_advance(40)
	_check(int(_simulation().get("jump_id")) == 0, "Il reset non deve riutilizzare il comando mantenuto precedente.")
	_feed(KEY_Z, false)


func _test_runtime_remap() -> void:
	_begin("rules_lab_runtime_input_map_remap")
	_reset()
	var action: StringName = &"move_sw"
	var saved_events: Array[InputEvent] = InputMap.action_get_events(action)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, _key(KEY_T, true))
	var old_accepted: bool = _feed(KEY_Z, true)
	var new_accepted: bool = _feed(KEY_T, true)
	_advance(1)
	_check(not old_accepted and new_accepted, "Dopo rimappatura InputMap l'adattatore deve riconoscere T e ignorare il vecchio Z.")
	_check(_jump_count() == 1 and _simulation().get("jump_to") == Vector2i(1, 0), "Il nuovo binding deve raggiungere la stessa diagonale logica.")
	_feed(KEY_T, false)
	# Restore bindings before any further assertions or scene changes.
	InputMap.action_erase_events(action)
	for event: InputEvent in saved_events:
		InputMap.action_add_event(action, event)
	_reset()
	_check(_feed(KEY_Z, true), "Il binding originale deve funzionare dopo il ripristino.")
	_advance(1)
	_feed(KEY_Z, false)
	_check(_simulation().get("jump_to") == Vector2i(1, 0), "Il ripristino non deve lasciare stato del binding temporaneo.")


func _test_menu_navigation() -> void:
	_begin("rules_lab_back_to_menu_and_reentry")
	_reset()
	var back_button: Button = _lab.get_node_or_null("%BackButton") as Button
	_check(back_button != null, "Il laboratorio deve avere un controllo per tornare al menu.")
	if back_button == null:
		_lab.queue_free()
		await _runner.process_frame
		return
	_runner.current_scene = _lab
	back_button.pressed.emit()
	await _runner.process_frame
	await _runner.process_frame
	var menu: Node = _runner.current_scene
	_check(is_instance_valid(menu) and menu.scene_file_path == MENU_SCENE, "Il pulsante Indietro deve caricare il menu principale reale.")
	if not is_instance_valid(menu):
		return
	var lab_button: Button = menu.get_node_or_null("%LabButton") as Button
	_check(lab_button != null, "Il menu deve offrire l'ingresso al laboratorio.")
	if lab_button == null:
		menu.queue_free()
		_runner.current_scene = null
		await _runner.process_frame
		return
	lab_button.grab_focus()
	_runner.root.push_input(_key(KEY_DOWN, true))
	_runner.root.push_input(_key(KEY_DOWN, false))
	await _runner.process_frame
	_check((menu.get_node("%InstructionsButton") as Button).has_focus(), "Nel menu Giù deve navigare alle istruzioni, senza aprire il laboratorio.")
	_check(_runner.current_scene == menu, "La navigazione del menu non deve cambiare scena.")
	_runner.root.push_input(_key(KEY_UP, true))
	_runner.root.push_input(_key(KEY_UP, false))
	await _runner.process_frame
	_check(lab_button.has_focus(), "Su deve riportare il focus al laboratorio.")
	lab_button.pressed.emit()
	await _runner.process_frame
	await _runner.process_frame
	var reopened: Node = _runner.current_scene
	_check(is_instance_valid(reopened) and reopened.scene_file_path == LAB_SCENE, "L'ingresso dal menu deve aprire il laboratorio reale.")
	if is_instance_valid(reopened):
		reopened.set_physics_process(false)
		var simulation: Object = reopened.get("simulation") as Object
		_check(simulation != null and int(simulation.get("jump_id")) == 0 and simulation.get("cell") == Vector2i.ZERO, "Il rientro deve creare una dimostrazione nuova senza input residui.")
		await _test_escape_navigation(reopened)
	_runner.current_scene = null
	await _runner.process_frame


func _test_escape_navigation(lab: Node) -> void:
	_begin("rules_lab_escape_consumed_across_scene_change")
	for cycle: int in range(3):
		_check(_runner.current_scene == lab and lab.is_inside_tree(), "Esc deve partire dal laboratorio attivo.")
		# Dispatch through the viewport, not directly through handle_input_event:
		# _input must finish consuming Esc after the scene removes itself.
		lab.call("handle_input_event", _key(KEY_Z, true))
		lab.call("handle_input_event", _key(KEY_DOWN, true))
		lab.call("advance_one_tick")
		_runner.root.push_input(_key(KEY_ESCAPE, true))
		_check(_runner.root.is_input_handled(), "Esc deve essere consumato anche quando il laboratorio esce dall'albero.")
		_check(not lab.is_inside_tree(), "Il cambio scena deve rimuovere subito il laboratorio corrente.")
		await _runner.process_frame
		await _runner.process_frame
		var menu: Node = _runner.current_scene
		_check(is_instance_valid(menu) and menu.scene_file_path == MENU_SCENE, "Esc deve completare il ritorno al menu reale.")
		if not is_instance_valid(menu):
			return
		_runner.root.push_input(_key(KEY_ESCAPE, false))
		_runner.root.push_input(_key(KEY_Z, false))
		_runner.root.push_input(_key(KEY_DOWN, false))
		await _runner.process_frame
		_check(_runner.current_scene == menu, "Il rilascio di Esc dopo il cambio scena deve lasciare attivo il menu.")
		var button: Button = menu.get_node("%LabButton") as Button
		_check(button.has_focus(), "Il menu deve conservare il focus sul pulsante del laboratorio.")
		if cycle < 2:
			button.pressed.emit()
			await _runner.process_frame
			await _runner.process_frame
			lab = _runner.current_scene
			lab.set_physics_process(false)
			for tick: int in range(40):
				lab.call("advance_one_tick")
			_check(int(lab.get("simulation").get("jump_id")) == 0, "Il rientro non deve ereditare lettere o frecce della scena precedente.")
		else:
			menu.queue_free()


func _reset(mode: int = 0, start_cell: Vector2i = Vector2i.ZERO) -> void:
	_lab.call("resume_lab")
	for code: int in PRIMARY_KEYS + SECONDARY_KEYS + ARROW_KEYS:
		_feed(code, false)
	_lab.call("select_mode", mode)
	_simulation().call("reset", mode, start_cell)
	_base_jump_id = int(_simulation().call("get_snapshot")["last_jump_id"])


func _jump_count() -> int:
	var current_id: int = int(_simulation().get("jump_id"))
	return 0 if current_id == 0 else current_id - _base_jump_id


func _simulation() -> Object:
	return _lab.get("simulation") as Object


func _adapter() -> Object:
	return _lab.get("input_adapter") as Object


func _board() -> Object:
	return _simulation().get("board") as Object


func _advance(count: int) -> Array:
	var events: Array = []
	for index: int in range(count):
		events.append_array(_lab.call("advance_one_tick"))
	return events


func _feed(code: int, pressed: bool, echo: bool = false) -> bool:
	return bool(_lab.call("handle_input_event", _key(code, pressed, echo)))


func _key(code: int, pressed: bool, echo: bool = false) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	return event


func _has_event(events: Array, event_type: StringName) -> bool:
	return _count_events(events, event_type) > 0


func _count_events(events: Array, event_type: StringName) -> int:
	var count: int = 0
	for event: Dictionary in events:
		if StringName(event.get("type", "")) == event_type:
			count += 1
	return count


func _begin(name: String) -> void:
	_runner.call("_begin_test", name)


func _check(condition: bool, message: String) -> void:
	_runner.call("_check", condition, message)
