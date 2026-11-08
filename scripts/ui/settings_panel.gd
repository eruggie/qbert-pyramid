class_name SettingsPanel
extends Control
## Modal settings overlay: UI input never reaches the game adapter.
signal closed
var capture_direction: int = -1
var hint: Label
var binding_buttons: Array[Button] = []
var app: Node
var _profile_callbacks: Array[Callable] = []
var _close_button: Button

func _ready() -> void:
	app = get_node("/root/App")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.025, 0.05, 0.08, 1.0)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	add_child(margin)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	var title: Label = Label.new()
	title.text = "IMPOSTAZIONI · Audio, video e comandi"
	title.add_theme_font_size_override("font_size", 24)
	content.add_child(title)
	var record: Label = Label.new()
	record.text = "Record: %d punti · Livello %d / Round %d" % [app.data["record"], app.data["record_level"], app.data["record_round"]]
	content.add_child(record)
	for entry: Array in [["Master", "master"], ["Effetti", "effects"]]:
		var row: HBoxContainer = HBoxContainer.new()
		content.add_child(row)
		var label: Label = Label.new()
		label.custom_minimum_size.x = 155
		label.text = "%s: %d%%" % [entry[0], roundi(float(app.data[entry[1]]) * 100)]
		row.add_child(label)
		var slider: HSlider = HSlider.new()
		slider.name = str(entry[0]) + "Slider"
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.max_value = 100
		slider.step = 1
		slider.value = float(app.data[entry[1]]) * 100
		row.add_child(slider)
		slider.value_changed.connect(func(value: float) -> void:
			label.text = "%s: %d%%" % [entry[0], roundi(value)]
			app.update_setting(entry[1], value / 100.0))
	for entry: Array in [["Modalità silenziosa", "muted"], ["Schermo intero (anche F11)", "fullscreen"]]:
		var check: CheckButton = CheckButton.new()
		check.text = entry[0]
		check.button_pressed = app.data[entry[1]]
		content.add_child(check)
		check.toggled.connect(func(value: bool) -> void: app.update_setting(entry[1], value))
		var update_check: Callable = func() -> void:
			if is_instance_valid(check):
				check.set_pressed_no_signal(app.data[entry[1]])
		app.profile_changed.connect(update_check)
		_profile_callbacks.append(update_check)
	var resolution: OptionButton = OptionButton.new()
	resolution.name = "Resolution"
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		resolution.add_item("Finestra %d × %d" % [dimensions.x, dimensions.y])
	resolution.select(0 if int(app.data["width"]) < 1280 else (1 if int(app.data["width"]) < 1920 else 2))
	content.add_child(resolution)
	resolution.item_selected.connect(func(index: int) -> void:
		var sizes: Array[Vector2i] = [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]
		app.update_setting("width", sizes[index].x)
		app.update_setting("height", sizes[index].y))
	var explanation: Label = Label.new()
	explanation.text = "Aggiungi un tasto per direzione. Q/← E/↑ Z/↓ C/→ e 7/9/1/3 restano attivi."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(explanation)
	for direction: int in range(4):
		var row: HBoxContainer = HBoxContainer.new()
		content.add_child(row)
		var label: Label = Label.new()
		label.text = ["↖ Alto-sinistra", "↗ Alto-destra", "↙ Basso-sinistra", "↘ Basso-destra"][direction]
		label.custom_minimum_size.x = 190
		row.add_child(label)
		var button: Button = Button.new()
		button.text = _binding_label(direction)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(button)
		binding_buttons.append(button)
		button.pressed.connect(func() -> void: begin_capture(direction))
		var clear: Button = Button.new()
		clear.text = "Rimuovi"
		row.add_child(clear)
		clear.pressed.connect(func() -> void:
			app.set_binding(direction, 0)
			binding_buttons[direction].text = _binding_label(direction))
	hint = Label.new()
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.text = app.save_message
	content.add_child(hint)
	var actions: HBoxContainer = HBoxContainer.new()
	content.add_child(actions)
	var reset: Button = Button.new()
	reset.text = "Ripristina impostazioni"
	actions.add_child(reset)
	reset.pressed.connect(func() -> void:
		app.reset_settings()
		_disconnect_preferences()
		capture_direction = -1
		for child: Node in get_children():
			remove_child(child)
			child.queue_free()
		binding_buttons.clear()
		_ready())
	_close_button = Button.new()
	_close_button.name = "CloseSettings"
	_close_button.text = "Salva e chiudi · Esc"
	actions.add_child(_close_button)
	_close_button.pressed.connect(close_panel)
	var initial: Control = content.find_child("MasterSlider", true, false) as Control
	initial.grab_focus.call_deferred()

func _binding_label(direction: int) -> String:
	var code: int = int(app.data["bindings"][direction])
	return "Scegli tasto…" if code == 0 else OS.get_keycode_string(code)

func begin_capture(direction: int) -> void:
	capture_direction = direction
	hint.text = "Premi una lettera o cifra libera. Esc annulla."

func handle_input(event: InputEvent) -> bool:
	if not visible or not event is InputEventKey or not event.is_pressed() or event.is_echo():
		return false
	var key: InputEventKey = event as InputEventKey
	if capture_direction >= 0:
		if key.keycode == KEY_ESCAPE:
			capture_direction = -1
			hint.text = "Assegnazione annullata."
		elif not key.ctrl_pressed and not key.alt_pressed and not key.meta_pressed and not key.shift_pressed:
			var code: int = key.physical_keycode if key.physical_keycode != 0 else key.keycode
			var error: String = app.set_binding(capture_direction, code)
			hint.text = "Tasto assegnato; valido dopo la chiusura." if error.is_empty() else error
			if error.is_empty():
				binding_buttons[capture_direction].text = _binding_label(capture_direction)
				capture_direction = -1
		return true
	if event.is_action_pressed(&"ui_cancel"):
		close_panel()
		return true
	if event.is_action_pressed(&"toggle_fullscreen"):
		app.toggle_fullscreen()
		return true
	return false

func _input(event: InputEvent) -> void:
	if handle_input(event):
		get_viewport().set_input_as_handled()

func close_panel() -> void:
	capture_direction = -1
	app.flush()
	hide()
	closed.emit()
	queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		capture_direction = -1


func _disconnect_preferences() -> void:
	if is_instance_valid(app):
		for callback: Callable in _profile_callbacks:
			if app.profile_changed.is_connected(callback):
				app.profile_changed.disconnect(callback)
	_profile_callbacks.clear()

func _exit_tree() -> void:
	_disconnect_preferences()
