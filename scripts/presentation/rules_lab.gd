class_name RulesLab
extends Control

@onready var app: Node = get_node("/root/App")
## Phase 1 rules laboratory. This controller only connects input, model and view.

const SimulationScript = preload("res://scripts/core/pyramid_simulation.gd")
const InputAdapterScript = preload("res://scripts/input/directional_input_adapter.gd")

@onready var pyramid_view: PyramidView = %PyramidView
@onready var mode_selector: OptionButton = %ModeSelector
@onready var progress_label: Label = %ProgressLabel
@onready var state_label: Label = %StateLabel
@onready var pause_button: Button = %PauseButton

var simulation: SimulationScript = SimulationScript.new()
var input_adapter: InputAdapterScript = InputAdapterScript.new()


func _ready() -> void:
	app.stop_effects()
	app.set_audio_paused(false)
	mode_selector.add_item("Permanente", 0)
	mode_selector.add_item("Due passaggi", 1)
	mode_selector.add_item("Reversibile", 2)
	mode_selector.select(0)
	mode_selector.item_selected.connect(select_mode)
	mode_selector.get_popup().about_to_popup.connect(_on_mode_popup_opened)
	mode_selector.get_popup().popup_hide.connect(_on_mode_popup_closed)
	%ResetButton.pressed.connect(reset_lab)
	pause_button.pressed.connect(_toggle_pause)
	%BackButton.pressed.connect(return_to_menu)
	simulation.reset(0)
	pyramid_view.simulation = simulation
	_refresh_ui()
	_apply_initial_focus.call_deferred()


func _apply_initial_focus() -> void:
	if is_inside_tree() and is_instance_valid(pause_button) and pause_button.is_inside_tree():
		pause_button.grab_focus()


func _physics_process(_delta: float) -> void:
	advance_one_tick()


func _input(event: InputEvent) -> void:
	# Esc removes this scene from the tree before the handler returns.
	var input_viewport: Viewport = get_viewport()
	if handle_input_event(event):
		input_viewport.set_input_as_handled()


func handle_input_event(event: InputEvent) -> bool:
	if event.is_echo():
		return _feed_direction_event(event)
	if event.is_action_pressed(&"lab_pause"):
		_toggle_pause()
		return true
	if event.is_action_pressed(&"lab_reset"):
		reset_lab()
		return true
	if event.is_action_pressed(&"ui_cancel"):
		return_to_menu()
		return true
	if event.is_action_pressed(&"toggle_fullscreen"):
		_toggle_fullscreen()
		return true
	return _feed_direction_event(event)


func _feed_direction_event(event: InputEvent) -> bool:
	# Track releases while suspended, but let the GUI own navigation in pause.
	var recognized: bool = input_adapter.feed_event(event)
	return recognized and not simulation.paused


func _on_mode_popup_opened() -> void:
	set_lab_paused(true)


func _on_mode_popup_closed() -> void:
	# Popup windows may receive releases that never reach this Control.
	input_adapter.reconcile_focus()


func advance_one_tick() -> Array[Dictionary]:
	var events: Array[Dictionary] = simulation.step(input_adapter.drain_events())
	for event: Dictionary in events:
		if event["type"] == "jump_started":
			app.play_effect("jump")
		elif event["type"] == "jump_landed":
			app.play_effect("color" if event.get("color_after", 0) != event.get("color_before", 0) else "land")
		elif event["type"] == "jump_fallen":
			app.play_effect("fall")
	_refresh_ui()
	return events


func select_mode(mode: int) -> void:
	if mode < 0 or mode > 2:
		return
	mode_selector.select(mode)
	reset_lab()


func reset_lab() -> void:
	app.stop_effects()
	var was_paused: bool = simulation.paused
	simulation.reset(mode_selector.selected)
	simulation.set_paused(was_paused)
	input_adapter.flush_require_fresh()
	input_adapter.set_suspended(was_paused)
	_refresh_ui()


func set_lab_paused(paused: bool) -> void:
	simulation.set_paused(paused)
	app.set_audio_paused(paused)
	input_adapter.set_suspended(paused)
	_refresh_ui()


func resume_lab() -> void:
	set_lab_paused(false)


func return_to_menu() -> void:
	simulation.set_paused(true)
	input_adapter.set_suspended(true)
	var error: Error = get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if error != OK:
		push_error("Impossibile aprire il menu: %s" % error_string(error))


func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		set_lab_paused(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		input_adapter.reconcile_focus()
	# Regaining focus deliberately leaves the laboratory paused until P/Resume.


func _toggle_pause() -> void:
	set_lab_paused(not simulation.paused)


func _toggle_fullscreen() -> void:
	app.toggle_fullscreen()

func _refresh_ui() -> void:
	progress_label.text = "Celle obiettivo: %d/28" % simulation.board.completed_count()
	pause_button.text = "Riprendi · P" if simulation.paused else "Pausa · P"
	if simulation.paused:
		state_label.text = "IN PAUSA · premi P per riprendere"
	elif simulation.fallen:
		state_label.text = "CADUTA · premi R per reimpostare"
	elif simulation.board.all_complete:
		state_label.text = "OBIETTIVO RAGGIUNTO · puoi continuare o premere R"
	else:
		state_label.text = "Tick %d · %s" % [simulation.tick, _state_text()]
	pyramid_view.queue_redraw()


func _state_text() -> String:
	match simulation.state:
		&"jumping":
			return "salto %d" % simulation.jump_id
		&"recovering":
			return "atterraggio"
		_:
			return "pronto"
