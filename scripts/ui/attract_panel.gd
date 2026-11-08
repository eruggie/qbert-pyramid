class_name AttractPanel
extends PanelContainer
## Original, skippable instructions -> autonomous demo -> local ranking -> menu.
signal closed
const Identity = preload("res://scripts/core/game_identity.gd")
const Records = preload("res://scripts/ui/records_panel.gd")
const Cues = preload("res://scripts/presentation/game_audio_cues.gd")
var app: Node
var elapsed: float = 0.0
var stage: String = ""
var body: VBoxContainer
var tips: Array[Label] = []
var demo_view: PyramidView
var demo: PyramidGame
var ranking: RecordsPanel
var demo_accumulator: float = 0.0
var next_move: int = 0
var finished: bool = false
var inactive: bool = false
const TIPS: Array[String] = [
	"Salta sulle celle e portale al colore obiettivo.",
	"Q / E / Z / C, frecce o tastierino: quattro diagonali.",
	"Evita gli avversari; raccogli i verdi per punti e Stasi.",
	"Il disco ti riporta in cima: attira il Segugio al bordo.",
	"Extra a 8.000 punti, poi ogni 14.000. P mette in pausa."
]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 200
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("101024")
	style.content_margin_left = 36
	style.content_margin_right = 36
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	add_theme_stylebox_override("panel", style)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	add_child(body)
	var title: Label = Label.new()
	title.text = Identity.TITLE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", load("res://assets/arcade/arcade_font.fnt") as Font)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("ffe276"))
	body.add_child(title)
	var count_label: Label = Label.new()
	count_label.text = Identity.PROGRESSION
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(count_label)
	for tip: String in TIPS:
		var label: Label = Label.new()
		label.text = "• " + tip
		label.add_theme_font_size_override("font_size", 20)
		body.add_child(label)
		tips.append(label)
	demo_view = PyramidView.new()
	demo_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(demo_view)
	var skip: Button = Button.new()
	skip.text = "Vai al menu · Invio o tasto di gioco"
	skip.pressed.connect(finish)
	body.add_child(skip)
	skip.grab_focus()
	set_stage("instructions")

func set_stage(value: String) -> void:
	stage = value
	app.stop_effects()
	for tip: Label in tips: tip.visible = value == "instructions"
	demo_view.visible = value == "demo"
	if value == "demo":
		demo = PyramidGame.new()
		demo.world.seed(54)
		demo_view.game = demo
		demo_view.simulation = demo.simulation
		next_move = 0
	if value == "records":
		ranking = Records.new()
		ranking.app = app
		ranking.read_only = true
		ranking.closed.connect(finish)
		add_child(ranking)

func _process(delta: float) -> void:
	if finished or inactive: return
	elapsed += delta
	if elapsed >= 46.0:
		finish()
		return
	if elapsed >= 38.0 and stage != "records": set_stage("records")
	elif elapsed >= 18.0 and elapsed < 38.0 and stage != "demo": set_stage("demo")
	if stage == "instructions":
		for index: int in range(tips.size()): tips[index].visible = elapsed >= index * 3.0
	elif stage == "demo":
		demo_accumulator += minf(delta, .25)
		while demo_accumulator >= 1.0 / 60:
			demo_accumulator -= 1.0 / 60
			_demo_tick()
		demo_view.queue_redraw()

func _demo_tick() -> void:
	if demo.state == PyramidGame.State.GAME_OVER:
		demo.start_new_game()
		next_move = 0
	var input: Array[Dictionary] = []
	if demo.accepts_movement and not demo.simulation.is_airborne and demo.active_ticks >= next_move:
		var candidates: Array[int] = []
		for direction: int in range(4):
			if PyramidBoard.is_valid_cell(PyramidBoard.neighbor(demo.simulation.cell, direction)): candidates.append(direction)
		var direction: int = candidates[demo.world.rng.randi_range(0, candidates.size() - 1)]
		input = [{"type": "press", "direction": direction}, {"type": "release", "direction": direction}]
		next_move = demo.active_ticks + 36
	var before: Dictionary = Cues.before_step(demo)
	var events: Array[Dictionary] = demo.step(input)
	for cue: String in Cues.resolve(before, demo, events): app.play_effect(cue)
	# Demo score stays in this isolated model; never calls observe_score/submit_score.

func handle_input(event: InputEvent) -> bool:
	if event.is_echo() or not event.is_pressed(): return false
	for action: StringName in [&"ui_focus_next", &"ui_focus_prev", &"ui_up", &"ui_down"]:
		if event.is_action_pressed(action): return true
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
		finish()
		return true
	for action: StringName in [&"move_nw", &"move_ne", &"move_sw", &"move_se"]:
		if event.is_action_pressed(action):
			finish()
			return true
	return false

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: inactive = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN: inactive = false

func finish() -> void:
	if finished: return
	finished = true
	app.stop_effects()
	closed.emit()
