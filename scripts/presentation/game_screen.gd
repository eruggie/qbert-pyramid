class_name GameScreen
extends Control

@onready var app: Node = get_node("/root/App")
## Input/view bridge only. Session rules live in PyramidGame.

const GAME_OVER_SECONDS: float = 30.0
const PROGRESSION_INFO: String = "Livelli: illimitati · Round/livello: 4 · Round totali: illimitati"
const Records = preload("res://scripts/ui/records_panel.gd")
const AudioCues = preload("res://scripts/presentation/game_audio_cues.gd")
const Game = preload("res://scripts/core/pyramid_game.gd")
const Adapter = preload("res://scripts/input/directional_input_adapter.gd")
const CONFIG = preload("res://data/initial_rounds.tres")

var settings_panel: SettingsPanel
var records_panel: RecordsPanel
var game_over_banner: PanelContainer
var game_over_label: Label
var records_button: Button
var game_over_elapsed: float = 0.0
var records_opened: bool = false
var ending_suspended: bool = false

var game: Game = Game.new()
var input_adapter: Adapter = Adapter.new()

@onready var view: PyramidView = %PyramidView
@onready var pause_button: Button = %PauseButton
@onready var new_game_button: Button = %NewGameButton


func _ready() -> void:
	_create_game_over_banner()
	%InputLegendLabel.text += "\n" + PROGRESSION_INFO
	%SettingsButton.pressed.connect(show_settings)
	app.stop_effects()
	pause_button.pressed.connect(_toggle_pause)
	new_game_button.pressed.connect(start_new_game)
	%BackButton.pressed.connect(return_to_menu)
	game.world.rng.randomize()
	start_new_game()
	_focus_pause.call_deferred()


func _focus_pause() -> void:
	if is_inside_tree():
		pause_button.grab_focus()


func start_new_game() -> void:
	if is_instance_valid(records_panel):
		records_panel.queue_free()
		records_panel = null
	records_opened = false
	game_over_elapsed = 0.0
	ending_suspended = false
	app.observe_score(game.score.points, game.level_number, game.round_number)
	if not game.start_new_game(CONFIG.color_modes, CONFIG.progression_settings()):
		push_error("Configurazione dei round o della progressione non valida.")
		return
	app.stop_effects()
	app.set_audio_paused(false)
	input_adapter.flush_require_fresh()
	view.simulation = game.simulation
	view.game = game
	_sync_input_context()
	_refresh_ui()


func _physics_process(_delta: float) -> void:
	advance_one_tick()


func advance_one_tick() -> Array[Dictionary]:
	var before: Dictionary = AudioCues.before_step(game)
	var previous_state: int = game.state
	var events: Array[Dictionary] = game.step(input_adapter.drain_events())
	app.observe_score(game.score.points, game.level_number, game.round_number)
	for cue: String in AudioCues.resolve(before, game, events):
		app.play_effect(cue)
	_sync_input_context()
	_refresh_ui()
	if previous_state != game.state and game.state in [Game.State.GAME_OVER, Game.State.COMPLETED]:
		game_over_elapsed = 0.0
		game_over_label.show()
		records_button.grab_focus()
	return events


func _input(event: InputEvent) -> void:
	# Preserve the viewport before Esc can remove the current scene.
	var viewport: Viewport = get_viewport()
	if handle_input_event(event):
		viewport.set_input_as_handled()


func handle_input_event(event: InputEvent) -> bool:
	if is_instance_valid(records_panel):
		if event.is_action_pressed(&"ui_cancel") and not event.is_echo():
			records_panel.request_continue()
			return true
		if event.is_action_pressed(&"toggle_fullscreen") and not event.is_echo():
			app.toggle_fullscreen()
			return true
		return false # LineEdit and GUI handle typing, correction, Tab and Enter.
	if game.state == Game.State.GAME_OVER and not event.is_echo() and event.is_pressed() and (event.is_action_pressed(&"ui_accept") or _is_game_key(event)):
		show_records()
		return true
	if game.state == Game.State.GAME_OVER and event.is_action_pressed(&"ui_cancel"):
		return true
	if is_instance_valid(settings_panel):
		return settings_panel.handle_input(event)
	if not event.is_echo():
		if event.is_action_pressed(&"ui_cancel"):
			return_to_menu()
			return true
		if event.is_action_pressed(&"lab_pause"):
			_toggle_pause()
			return true
		if event.is_action_pressed(&"toggle_fullscreen"):
			app.toggle_fullscreen()
			return true
	var recognized: bool = input_adapter.feed_event(event)
	return recognized and game.accepts_movement


func set_game_paused(value: bool) -> void:
	game.set_paused(value)
	app.set_audio_paused(game.paused)
	_sync_input_context()
	_refresh_ui()


func _toggle_pause() -> void:
	set_game_paused(not game.paused)


func _sync_input_context() -> void:
	var suspended: bool = not game.accepts_movement
	if input_adapter.is_suspended != suspended:
		input_adapter.set_suspended(suspended)


func return_to_menu(skip_records: bool = false) -> void:
	if game.state == Game.State.GAME_OVER and not skip_records:
		show_records()
		return
	app.observe_score(game.score.points, game.level_number, game.round_number)
	app.flush()
	app.stop_effects()
	game.set_paused(true)
	input_adapter.set_suspended(true)
	var error: Error = get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if error != OK:
		push_error("Impossibile aprire il menu: %s" % error_string(error))


func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		ending_suspended = true
		set_game_paused(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		ending_suspended = false
		input_adapter.reconcile_focus()


func _refresh_ui() -> void:
	%HudLabel.text = "Punti %d\nRecord %d" % [game.score.points, app.data["record"]]
	%LevelLabel.text = "Livello %d\nRound %d" % [game.level_number, game.round_number]
	%ProgressLabel.text = "Celle %d/28 · Vite %d · Prossima vita %d · Dischi %d · Stasi %.1f s" % [game.simulation.board.completed_count(), game.score.lives, game.score.next_extra, int(game.platforms[0]) + int(game.platforms[1]), game.world.stasis_remaining / 60.0]
	pause_button.text = "Riprendi · P" if game.paused else "Pausa · P"
	pause_button.disabled = game.state in [Game.State.GAME_OVER, Game.State.COMPLETED]
	new_game_button.disabled = game.state == Game.State.GAME_OVER or (not game.paused and game.state != Game.State.COMPLETED)
	%SettingsButton.disabled = game.state == Game.State.GAME_OVER
	%BackButton.disabled = game.state == Game.State.GAME_OVER
	game_over_banner.visible = game.state == Game.State.GAME_OVER and not records_opened
	var text: String = "Colora tutte le celle. Evita gli avversari e usa i dischi ai bordi."
	match game.state:
		Game.State.DYING:
			text = ("CADUTA" if game.simulation.fallen else "CONTATTO") + " · %s fra %.1f s" % ["Game Over" if game.score.lives == 0 else "ritorno in cima", game.remaining_ticks / 60.0]
		Game.State.ROUND_END:
			text = "ROUND COMPLETATO · Bonus %d + dischi %d · %.1f s" % [game.last_bonus, game.last_platform_bonus, game.remaining_ticks / 60.0]
		Game.State.GAME_OVER:
			text = "Partita conclusa · %d punti · Classifica" % game.score.points
		Game.State.COMPLETED:
			text = "12 ROUND COMPLETATI · %d punti · Nuova partita o Menu" % game.score.points
	if game.state == Game.State.PLAYING and game.rescue_remaining > 0:
		text = "SALVATAGGIO · Ritorno in cima: %.1f s" % (game.rescue_remaining / 60.0)
	if game.state == Game.State.PLAYING and game.protection_ticks > 0:
		text = "Protezione contatti: %.1f s · Le cadute restano letali" % (game.protection_ticks / 60.0)
	if game.state == Game.State.PLAYING and game.world.stasis_remaining > 0:
		text = "STASI · Contatti innocui: %.1f s · Le cadute restano letali" % (game.world.stasis_remaining / 60.0)
	if game.paused:
		text = "IN PAUSA · " + text
	if not app.save_message.is_empty():
		text += " · " + app.save_message
	%StateLabel.text = text
	view.queue_redraw()


func show_settings() -> void:
	if game.state == Game.State.GAME_OVER:
		return
	if is_instance_valid(settings_panel):
		return
	set_game_paused(true)
	settings_panel = SettingsPanel.new()
	settings_panel.closed.connect(func() -> void:
		settings_panel = null
		input_adapter.flush_require_fresh()
		pause_button.grab_focus())
	add_child(settings_panel)


func _create_game_over_banner() -> void:
	game_over_banner = PanelContainer.new()
	game_over_banner.name = "GameOverBanner"
	game_over_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	game_over_banner.offset_left = -220
	game_over_banner.offset_right = 220
	game_over_banner.offset_top = -65
	game_over_banner.offset_bottom = 65
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("0b0b16")
	style.border_color = Color("ffe276")
	style.set_border_width_all(3)
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	game_over_banner.add_theme_stylebox_override("panel", style)
	view.add_child(game_over_banner)
	var box: VBoxContainer = VBoxContainer.new()
	game_over_banner.add_child(box)
	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_override("font", load("res://assets/arcade/arcade_font.fnt") as Font)
	game_over_label.add_theme_font_size_override("font_size", 38)
	box.add_child(game_over_label)
	records_button = Button.new()
	records_button.text = "Classifica · Tasto di gioco o Invio"
	records_button.pressed.connect(show_records)
	box.add_child(records_button)
	game_over_banner.hide()

func _process(delta: float) -> void:
	if game.state != Game.State.GAME_OVER or records_opened or ending_suspended:
		return
	game_over_elapsed += delta
	# Gentle color pulse; no rapid flash or changes to simulation ticks.
	game_over_label.visible = fmod(game_over_elapsed, 1.0) < .5
	if game_over_elapsed >= GAME_OVER_SECONDS:
		show_records()

func show_records() -> void:
	if game.state != Game.State.GAME_OVER or records_opened:
		return
	records_opened = true
	game_over_banner.hide()
	input_adapter.set_suspended(true)
	app.stop_effects()
	records_panel = Records.new()
	records_panel.app = app
	records_panel.points = game.score.points
	records_panel.level_number = game.level_number
	records_panel.round_number = game.round_number
	records_panel.closed.connect(func() -> void: return_to_menu(true))
	add_child(records_panel)


static func _is_game_key(event: InputEvent) -> bool:
	for action: StringName in Adapter.ACTIONS:
		if event.is_action_pressed(action): return true
	return false
