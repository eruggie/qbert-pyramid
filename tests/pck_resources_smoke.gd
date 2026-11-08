extends SceneTree
## Loaded from outside the PCK; the project path is isolated from source files.
func _initialize() -> void:
	var failed: bool = false
	for name: String in ["jump", "land", "color", "fall", "contact", "rescue", "collect", "round", "extra", "lure", "stasis_collect", "stasis_fall", "level", "game_over"]:
		var sound: AudioStreamWAV = load("res://assets/audio/%s.wav" % name) as AudioStreamWAV
		if sound == null or sound.get_length() <= 0 or sound.loop_mode != AudioStreamWAV.LOOP_DISABLED:
			failed = true
	for name: String in ["menu", "menu_music", "game_music"]:
		if ResourceLoader.exists("res://assets/audio/%s.wav" % name):
			failed = true
	for path: String in ["res://assets/arcade/actors.png", "res://assets/arcade/arcade_font.fnt", "res://scripts/presentation/arcade_palette.gd", "res://scripts/presentation/game_audio_cues.gd", "res://scripts/core/high_scores.gd", "res://scripts/ui/records_panel.gd", "res://scripts/core/game_identity.gd", "res://scripts/ui/attract_panel.gd"]:
		if load(path) == null:
			failed = true
	var app_icon: Texture2D = load("res://assets/ui/qbert.png") as Texture2D
	if app_icon == null or app_icon.get_width() != 256 or app_icon.get_height() != 256:
		failed = true
	if ResourceLoader.exists("res://assets/ui/qbert.jpg"):
		failed = true
	print("AP_PCK_RESOURCES_OK" if not failed else "AP_PCK_RESOURCES_FAILED")
	quit(1 if failed else 0)
