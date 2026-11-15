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
var _web_submission: String = ""

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
		status_label.text = "Caricamento classifica dal server…" if app.web_scores != null else "I migliori dieci punteggi salvati su questo PC."
	if app.web_scores != null:
		app.web_scores.changed.connect(_refresh_web)
		app.web_scores.refresh()
		_refresh_web()
	_refresh_table()
	if eligible:
		name_edit.grab_focus()
		name_edit.select_all()
	else:
		continue_button.grab_focus()

func save_result() -> void:
	if app.web_scores != null:
		_save_web()
		return
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
	if app.web_scores != null and not read_only and name_edit.visible:
		if not submitted:
			_save_web()
		if not submitted:
			return
	if not read_only and name_edit.visible and not submitted:
		save_result()
		if not submitted: return
	closed.emit()


func _save_web() -> void:
	if read_only or submitted:
		return
	if name_edit.text.length() != 3 or Scores.clean_name(name_edit.text) != name_edit.text.to_upper():
		status_label.text = "Servono esattamente tre lettere A–Z."
		return
	if app.web_scores.busy:
		return
	if app.web_scores.pending.is_empty():
		app.web_scores.submit(points, level_number, round_number, name_edit.text)
	else:
		app.web_scores.retry()
	if not app.web_scores.pending.is_empty():
		_web_submission = app.web_scores.pending["submission"]
	name_edit.editable = false
	_refresh_web()

func _refresh_web() -> void:
	if status_label == null:
		return
	_refresh_table()
	if read_only:
		status_label.text = app.web_scores.notice if not app.web_scores.notice.is_empty() else "Classifica condivisa aggiornata dal server."
		return
	if submitted:
		return
	if not _web_submission.is_empty() and app.web_scores.saved_submission == _web_submission:
		submitted = true
		status_label.text = app.web_scores.notice
		name_edit.editable = false
		save_button.text = "Salvato sul server"
		save_button.disabled = true
		continue_button.disabled = false
		continue_button.grab_focus()
		return
	if submitted:
		return
	if not app.web_scores.pending.is_empty():
		status_label.text = app.web_scores.notice
		save_button.text = "Salvataggio in corso…" if app.web_scores.busy else "Riprova salvataggio sul server"
		save_button.disabled = app.web_scores.busy
		continue_button.disabled = true
	elif app.web_scores.loaded:
		var eligible: bool = Scores.qualifies(app.data["leaderboard"], points)
		save_button.disabled = app.web_scores.busy or name_edit.text.length() != 3 or Scores.clean_name(name_edit.text) != name_edit.text.to_upper()
		name_edit.visible = eligible
		save_button.visible = eligible
		status_label.text = "Tre iniziali A–Z: conferma per salvare sul server." if eligible else "Fuori dai primi dieci. Invio o Esc per proseguire."
	else:
		status_label.text = app.web_scores.notice
