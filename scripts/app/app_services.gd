extends Node
## Persistent application services. Gameplay rules never depend on this singleton.
signal profile_changed
const Scores = preload("res://scripts/core/high_scores.gd")
const Profile = preload("res://scripts/core/player_profile.gd")
const ACTIONS: Array[StringName] = [&"move_nw", &"move_ne", &"move_sw", &"move_se"]
const FX: Dictionary = {
	"jump": "res://assets/audio/jump.wav", "land": "res://assets/audio/land.wav",
	"color": "res://assets/audio/color.wav", "fall": "res://assets/audio/fall.wav",
	"contact": "res://assets/audio/contact.wav", "rescue": "res://assets/audio/rescue.wav",
	"collect": "res://assets/audio/collect.wav", "round": "res://assets/audio/round.wav",
	"extra": "res://assets/audio/extra.wav", "lure": "res://assets/audio/lure.wav",
	"stasis_collect": "res://assets/audio/stasis_collect.wav", "stasis_fall": "res://assets/audio/stasis_fall.wav",
	"level": "res://assets/audio/level.wav", "game_over": "res://assets/audio/game_over.wav"}
const AUXILIARY: Dictionary = {"extra": 1, "stasis_fall": 2, "stasis_collect": 2, "lure": 3}
# Compatibility identifier for the 0.5.3 data folder only.
var store: Profile = Profile.new("user://profile.json", OS.get_user_data_dir().get_base_dir().path_join("Arcade" + "Pyramid/profile.json"))
var intro_seen: bool = false
var data: Dictionary = Profile.defaults()
var save_message: String = ""
signal effect_started(effect: String)
var queued_effects: Array[String] = []
var current_effect: String = ""
var effect_players: Array[AudioStreamPlayer] = []
var _custom_events: Dictionary = {}
var _save_timer: Timer
var _audio_paused: bool = false
var _focus_lost: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	data = store.load_profile()
	save_message = store.notice
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 0.4
	_save_timer.timeout.connect(flush)
	add_child(_save_timer)
	for bus: String in ["Effects"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	for index: int in range(4):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "Effects"
		add_child(player)
		effect_players.append(player)
	apply_preferences()
	if DisplayServer.get_name() != "headless":
		get_window().size = Vector2i(data["width"], data["height"])
		get_window().mode = Window.MODE_FULLSCREEN if data["fullscreen"] else Window.MODE_WINDOWED
		get_window().size_changed.connect(_window_resized)

func apply_preferences() -> void:
	for entry: Array in [["Master", "master"], ["Effects", "effects"]]:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(entry[0]), linear_to_db(maxf(0.00001, float(data[entry[1]]))))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(entry[0]), float(data[entry[1]]) == 0.0)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), data["muted"] or float(data["master"]) == 0.0)
	for direction: int in range(4):
		if _custom_events.has(direction):
			InputMap.action_erase_event(ACTIONS[direction], _custom_events[direction])
			_custom_events.erase(direction)
		var code: int = int(data["bindings"][direction])
		if code != 0:
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = code
			InputMap.action_add_event(ACTIONS[direction], event)
			_custom_events[direction] = event
	if data["muted"] or float(data["master"]) == 0.0 or float(data["effects"]) == 0.0:
		stop_effects()
	profile_changed.emit()

func update_setting(key: String, value: Variant) -> bool:
	if key not in ["master", "effects", "muted", "fullscreen", "width", "height"]:
		return false
	var candidate: Dictionary = data.duplicate(true)
	candidate[key] = value
	if Profile.validate(candidate).is_empty():
		return false
	data = candidate
	apply_preferences()
	if DisplayServer.get_name() != "headless" and key in ["fullscreen", "width", "height"]:
		get_window().mode = Window.MODE_FULLSCREEN if data["fullscreen"] else Window.MODE_WINDOWED
		if not data["fullscreen"]:
			get_window().size = Vector2i(data["width"], data["height"])
	_save_timer.start()
	return true

func set_binding(direction: int, code: int) -> String:
	var error: String = Profile.binding_error(data["bindings"], direction, code)
	if not error.is_empty():
		return error
	data["bindings"][direction] = code
	apply_preferences()
	_save_timer.start()
	return ""

func reset_settings() -> void:
	var clean: Dictionary = Profile.defaults()
	for key: String in ["record", "record_level", "record_round", "leaderboard"]:
		clean[key] = data[key]
	data = clean
	apply_preferences()
	if DisplayServer.get_name() != "headless":
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = Vector2i(1280, 720)
	_save_timer.start()

func observe_score(points: int, level: int, round_number: int) -> void:
	if points <= int(data["record"]) or points > 2147483647 or level < 1 or round_number < 1 or round_number > 4:
		return
	data["record"] = points
	data["record_level"] = mini(level, 1000000)
	data["record_round"] = round_number
	profile_changed.emit()
	_save_timer.start()

func submit_score(points: int, level: int, round_number: int, player_name: String) -> bool:
	if Scores.clean_name(player_name).length() != Scores.NAME_LENGTH or not Scores.qualifies(data["leaderboard"], points) or points > 2147483647 or level < 1 or level > 1000000 or round_number < 1 or round_number > 4:
		return false
	observe_score(points, level, round_number)
	data["leaderboard"] = Scores.insert(data["leaderboard"], points, level, round_number, player_name)
	return flush()


func flush() -> bool:
	_save_timer.stop()
	var success: bool = store.save_profile(data)
	save_message = store.notice
	profile_changed.emit()
	return success

func toggle_fullscreen() -> void:
	update_setting("fullscreen", not bool(data["fullscreen"]))

func _window_resized() -> void:
	if get_window().mode == Window.MODE_WINDOWED:
		var dimensions: Vector2i = get_window().size
		data["width"] = clampi(dimensions.x, 960, 7680)
		data["height"] = clampi(dimensions.y, 540, 4320)
		_save_timer.start()

func play_effect(effect: String) -> void:
	if not FX.has(effect) or _audio_paused or _focus_lost or data["muted"] or float(data["master"]) == 0.0 or float(data["effects"]) == 0.0:
		return
	# The extra-life signal starts at the award, even with a long round cue.
	if AUXILIARY.has(effect):
		var extra_player: AudioStreamPlayer = effect_players[AUXILIARY[effect]]
		extra_player.stream = load(FX[effect]) as AudioStream
		extra_player.play()
		effect_started.emit(effect)
		return
	# A long presentation cue must not delay the next actual action.
	if effect == "jump" or (effect in ["rescue", "collect", "round", "lure"] and current_effect in ["rescue", "lure", "round", "collect"] and effect_players[0].playing):
		stop_effects(false)
	if effect in ["fall", "contact", "game_over", "round", "level"]:
		stop_effects()
	if queued_effects.has(effect):
		return
	if queued_effects.size() >= 3:
		queued_effects.pop_front()
	queued_effects.append(effect)
	_play_next_effect()

func _process(_delta: float) -> void:
	_play_next_effect()

func _play_next_effect() -> void:
	if queued_effects.is_empty() or effect_players.is_empty() or effect_players[0].playing or _audio_paused or _focus_lost:
		return
	var effect: String = queued_effects.pop_front()
	var player: AudioStreamPlayer = effect_players[0]
	player.stream = load(FX[effect]) as AudioStream
	current_effect = effect
	player.play()
	effect_started.emit(effect)

func stop_effects(include_extra: bool = true) -> void:
	current_effect = ""
	queued_effects.clear()
	for index: int in range(effect_players.size()):
		if index > 0 and not include_extra:
			continue
		effect_players[index].stop()
		effect_players[index].stream = null

func set_audio_paused(value: bool) -> void:
	_audio_paused = value
	if value:
		stop_effects()

func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_focus_lost = true
		stop_effects()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_focus_lost = false
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		flush()

func _exit_tree() -> void:
	for player: AudioStreamPlayer in effect_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	# Playback stops are queued to the audio thread. Let one device buffer drain
	# before the engine releases audio resources (also for --quit-after exports).
	OS.delay_msec(60)
