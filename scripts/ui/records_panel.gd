class_name RecordsPanel
extends PanelContainer
## Dedicated original results screen, keyboard/GUI input independent of gameplay.
signal closed
const Scores = preload("res://scripts/core/high_scores.gd")
var points: int = 0
var level_number: int = 1
var round_number: int = 1
var submitted: bool = false
var read_only: bool = false
var ranking_grid: GridContainer
var ranking_rows: Array[Array] = []
var legacy_label: Label
var app: Node
var name_edit: LineEdit
var save_button: Button
var continue_button: Button
var table_label: Label
var status_label: Label

func _ready() -> void:
	name = "RecordsPanel"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("080812")
	add_theme_stylebox_override("panel", style)
	var center: CenterContainer = CenterContainer.new()
	add_child(center)
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	center.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size.x = 600
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)
	var title: Label = Label.new()
	title.text = "CLASSIFICA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", load("res://assets/arcade/arcade_font.fnt") as Font)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("ffe276"))
	box.add_child(title)
	var final_score: Label = Label.new()
	final_score.text = "Punteggio finale: %d  ·  Livello %d / Round %d" % [points, level_number, round_number]
	final_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(final_score)
	ranking_grid = GridContainer.new()
	ranking_grid.columns = 5
	ranking_grid.add_theme_constant_override("h_separation", 12)
	ranking_grid.add_theme_constant_override("v_separation", 3)
	box.add_child(ranking_grid)
	for heading: String in ["#", "NOME", "PUNTI", "LIVELLO", "ROUND"]:
		var label: Label = Label.new()
		label.text = heading
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if heading in ["PUNTI", "LIVELLO", "ROUND"] else HORIZONTAL_ALIGNMENT_LEFT
		label.add_theme_color_override("font_color", Color("ffe276"))
		ranking_grid.add_child(label)
	for index: int in range(Scores.CAPACITY):
		var row: Array = []
		for column: int in range(5):
			var label: Label = Label.new()
			label.add_theme_font_size_override("font_size", 18)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if column >= 2 else HORIZONTAL_ALIGNMENT_LEFT
			ranking_grid.add_child(label)
			row.append(label)
		ranking_rows.append(row)
	legacy_label = Label.new()
	legacy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legacy_label.add_theme_font_size_override("font_size", 14)
	box.add_child(legacy_label)
	name_edit = LineEdit.new()
	name_edit.name = "PlayerName"
	name_edit.max_length = Scores.NAME_LENGTH
	name_edit.placeholder_text = "Tre lettere A–Z"
	name_edit.text = "AAA"
	name_edit.text_submitted.connect(func(_text: String) -> void: save_result())
	box.add_child(name_edit)
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status_label)
	save_button = Button.new()
	save_button.text = "Conferma nome e salva · Invio"
	save_button.pressed.connect(save_result)
	box.add_child(save_button)
	continue_button = Button.new()
	continue_button.text = "Continua · Menu"
	continue_button.pressed.connect(request_continue)
	box.add_child(continue_button)
	var eligible: bool = not read_only and Scores.qualifies(app.data["leaderboard"], points)
	name_edit.text_changed.connect(_name_changed)
	final_score.visible = not read_only
	name_edit.visible = eligible
	save_button.visible = eligible
	status_label.text = "Inserisci tre lettere. Backspace corregge, Tab cambia comando." if eligible else "Partita conclusa. Invio o Esc per proseguire."
	if read_only:
		status_label.text = "I migliori dieci punteggi salvati su questo PC."
	_refresh_table()
	if eligible:
		name_edit.grab_focus()
		name_edit.select_all()
	else:
		continue_button.grab_focus()

func save_result() -> void:
	if read_only:
		return
	if not submitted and (name_edit.text.length() != 3 or Scores.clean_name(name_edit.text) != name_edit.text.to_upper()):
		status_label.text = "Servono esattamente tre lettere A–Z."
		save_button.disabled = true
		return
	var saved: bool
	if submitted:
		saved = app.flush()
	else:
		if not Scores.qualifies(app.data["leaderboard"], points):
			return
		saved = app.submit_score(points, level_number, round_number, name_edit.text)
		submitted = true # In-memory insertion is not repeated if disk persistence failed.
	name_edit.editable = false
	_refresh_table()
	status_label.text = "Record salvato." if saved else "Salvataggio non disponibile: record in memoria. Riprova o continua."
	save_button.text = "Riprova salvataggio" if not saved else "Salvato"
	save_button.disabled = saved
	continue_button.grab_focus()

func _name_changed(value: String) -> void:
	if submitted: return
	save_button.disabled = value.length() != 3 or Scores.clean_name(value) != value.to_upper()

func _refresh_table() -> void:
	var legacy_names: Array[String] = []
	for index: int in range(Scores.CAPACITY):
		var cells: Array = [str(index + 1), "—", "—", "—", "—"]
		if index < app.data["leaderboard"].size():
			var entry: Dictionary = app.data["leaderboard"][index]
			cells = [str(index + 1), entry["name"], str(entry["points"]), str(entry["level"]), str(entry["round"])]
			if entry.has("legacy_name"):
				legacy_names.append("%s: %s" % [entry["name"], entry["legacy_name"]])
		for column: int in range(5):
			(ranking_rows[index][column] as Label).text = cells[column]
	legacy_label.text = "Nomi precedenti: " + "; ".join(legacy_names) if not legacy_names.is_empty() else ""
	legacy_label.visible = not legacy_names.is_empty()


func request_continue() -> void:
	if not read_only and name_edit.visible and not submitted:
		save_result()
		if not submitted: return
	closed.emit()
