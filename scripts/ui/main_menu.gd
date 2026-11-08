class_name MainMenu
extends Control

@onready var app: Node = get_node("/root/App")
## Menu and player services; rules remain in the independent game model.

@onready var lab_button: Button = %LabButton
@onready var instructions_button: Button = %InstructionsButton
@onready var status_button: Button = %StatusButton
@onready var exit_button: Button = %ExitButton
@onready var instructions_dialog: AcceptDialog = %InstructionsDialog
@onready var status_dialog: AcceptDialog = %StatusDialog
@onready var phase_label: Label = %PhaseLabel
@onready var focus_label: Label = %FocusLabel

const Attract = preload("res://scripts/ui/attract_panel.gd")
const Records = preload("res://scripts/ui/records_panel.gd")
const Identity = preload("res://scripts/core/game_identity.gd")
var attract_panel: AttractPanel
var rankings_panel: RecordsPanel
var settings_panel: SettingsPanel

var rules_lab_enabled: bool = false
var is_focus_suspended: bool = false
var _tree_was_paused_before_focus_loss: bool = false
var _last_menu_button: Button


func _ready() -> void:
	_configure_lab_entry()
	instructions_dialog.get_label().add_theme_font_size_override("font_size", 16)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	%TitleLabel.add_theme_font_override("font", load("res://assets/arcade/arcade_font.fnt") as Font)
	%TitleLabel.add_theme_font_size_override("font_size", 40)
	%PhaseLabel.add_theme_color_override("font_color", Color("f45aa0"))
	get_node("%SettingsButton").pressed.connect(show_settings)
	app.stop_effects()
	app.set_audio_paused(false)
	app.profile_changed.connect(_refresh_record)
	_refresh_record()
	var lines: PackedStringArray = instructions_dialog.dialog_text.split("\n")
	if not rules_lab_enabled:
		var public_lines: PackedStringArray = []
		for line: String in lines:
			if not line.begins_with("Laboratorio:"):
				public_lines.append(line)
		lines = public_lines
	lines.insert(1, Identity.PROGRESSION)
	instructions_dialog.dialog_text = "\n".join(lines)
	get_node("Margin/Content/IntroLabel").text = "Colora 28 celle, evita gli avversari e supera i round.\n" + Identity.PROGRESSION
	%IntroButton.pressed.connect(show_attract)
	lab_button.pressed.connect(show_lab)
	%GameButton.pressed.connect(show_game)
	instructions_button.pressed.connect(show_instructions)
	status_button.pressed.connect(show_status)
	exit_button.pressed.connect(_request_exit)
	instructions_dialog.close_requested.connect(close_dialogs)
	status_dialog.close_requested.connect(close_dialogs)
	instructions_dialog.visibility_changed.connect(_on_dialog_visibility_changed)
	status_dialog.visibility_changed.connect(_on_dialog_visibility_changed)
	instructions_dialog.window_input.connect(_on_dialog_input)
	status_dialog.window_input.connect(_on_dialog_input)
	_last_menu_button = lab_button if rules_lab_enabled else %GameButton
	_restore_menu_focus()
	if not app.intro_seen:
		app.intro_seen = true
		show_attract.call_deferred()


func _configure_lab_entry() -> void:
	rules_lab_enabled = bool(ProjectSettings.get_setting("developer/rules_lab_enabled", false))
	lab_button.visible = rules_lab_enabled
	lab_button.disabled = not rules_lab_enabled
	lab_button.focus_mode = Control.FOCUS_ALL if rules_lab_enabled else Control.FOCUS_NONE
	var game_button: Button = %GameButton
	var next_button: Button = lab_button if rules_lab_enabled else instructions_button
	game_button.focus_neighbor_bottom = game_button.get_path_to(next_button)
	game_button.focus_next = game_button.get_path_to(next_button)
	var previous_button: Button = lab_button if rules_lab_enabled else game_button
	instructions_button.focus_neighbor_top = instructions_button.get_path_to(previous_button)
	instructions_button.focus_previous = instructions_button.get_path_to(previous_button)


func _input(event: InputEvent) -> void:
	if is_instance_valid(attract_panel) and attract_panel.handle_input(event):
		get_viewport().set_input_as_handled()
	elif is_instance_valid(rankings_panel) and event.is_action_pressed(&"ui_cancel"):
		close_dialogs()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if _handle_shortcut(event):
		get_viewport().set_input_as_handled()


func _on_dialog_input(event: InputEvent) -> void:
	_handle_shortcut(event)


func _handle_shortcut(event: InputEvent) -> bool:
	if is_instance_valid(settings_panel):
		return settings_panel.handle_input(event)
	if event.is_echo():
		return false
	if event.is_action_pressed(&"toggle_fullscreen"):
		toggle_fullscreen()
		return true
	if event.is_action_pressed(&"ui_cancel"):
		if instructions_dialog.visible or status_dialog.visible:
			close_dialogs()
			return true
	return false


func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_set_focus_suspended(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_set_focus_suspended(false)


func show_game() -> void:
	app.flush()
	var error: Error = get_tree().change_scene_to_file("res://scenes/game_screen.tscn")
	if error != OK:
		push_error("Impossibile avviare la partita: %s" % error_string(error))


func show_lab() -> void:
	if not rules_lab_enabled:
		return
	var error: Error = get_tree().change_scene_to_file("res://scenes/rules_lab.tscn")
	if error != OK:
		push_error("Impossibile aprire il laboratorio: %s" % error_string(error))


func show_instructions() -> void:
	status_dialog.hide()
	_last_menu_button = instructions_button
	instructions_dialog.popup_centered()


func show_status() -> void:
	show_rankings()
	return


func show_project_status() -> void:
	instructions_dialog.hide()
	_last_menu_button = status_button
	status_dialog.dialog_text = "Record: %d punti\nLivello %d / Round %d\n\nRevisione audiovisiva arcade.\nSolo effetti di gioco, nessuna musica continua.\nCollaudo finale Windows nella fase 6.\n%s" % [app.data["record"], app.data["record_level"], app.data["record_round"], app.save_message]
	status_dialog.popup_centered()


func close_dialogs() -> void:
	if is_instance_valid(attract_panel):
		attract_panel.finish()
	if is_instance_valid(rankings_panel):
		rankings_panel.queue_free()
		rankings_panel = null
	instructions_dialog.hide()
	status_dialog.hide()
	_restore_menu_focus()


func toggle_fullscreen() -> void:
	app.toggle_fullscreen()

func get_phase_label() -> String:
	return phase_label.text


func _set_focus_suspended(suspended: bool) -> void:
	if suspended == is_focus_suspended:
		return
	is_focus_suspended = suspended
	focus_label.visible = suspended
	if suspended:
		_tree_was_paused_before_focus_loss = get_tree().paused
		get_tree().paused = true
	else:
		get_tree().paused = _tree_was_paused_before_focus_loss


func _on_dialog_visibility_changed() -> void:
	if not instructions_dialog.visible and not status_dialog.visible:
		_restore_menu_focus()


func _restore_menu_focus() -> void:
	_apply_menu_focus.call_deferred()


func _apply_menu_focus() -> void:
	if not is_inside_tree() or not is_instance_valid(_last_menu_button):
		return
	if not _last_menu_button.is_inside_tree():
		return
	if instructions_dialog.visible or status_dialog.visible or is_instance_valid(settings_panel) or is_instance_valid(attract_panel) or is_instance_valid(rankings_panel):
		return
	_last_menu_button.grab_focus()


func _request_exit() -> void:
	app.flush()
	get_tree().quit()


func show_settings() -> void:
	if is_instance_valid(settings_panel):
		return
	close_dialogs()
	_last_menu_button = %SettingsButton
	settings_panel = SettingsPanel.new()
	settings_panel.closed.connect(func() -> void:
		settings_panel = null
		_restore_menu_focus())
	add_child(settings_panel)

func _refresh_record() -> void:
	if is_node_ready():
		phase_label.text = "1 GIOCATORE · Record %d · %s" % [app.data["record"], app.save_message]


func show_attract() -> void:
	if is_instance_valid(attract_panel): return
	instructions_dialog.hide()
	status_dialog.hide()
	if is_instance_valid(rankings_panel):
		rankings_panel.queue_free()
		rankings_panel = null
	attract_panel = Attract.new()
	attract_panel.app = app
	attract_panel.closed.connect(func() -> void:
		attract_panel.queue_free()
		attract_panel = null
		_restore_menu_focus())
	add_child(attract_panel)

func show_rankings() -> void:
	close_dialogs()
	rankings_panel = Records.new()
	rankings_panel.app = app
	rankings_panel.read_only = true
	rankings_panel.closed.connect(close_dialogs)
	add_child(rankings_panel)
