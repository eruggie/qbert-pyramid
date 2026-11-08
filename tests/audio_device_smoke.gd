extends SceneTree
## Device delivery smoke, not a human listening test.
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var app: Node = root.get_node("App")
	var driver: String = AudioServer.get_driver_name()
	var report: Dictionary = {"driver": driver, "devices": AudioServer.get_output_device_list(), "human_listening": "not performed", "windows": "not performed", "peaks_db": {}}
	var failed: bool = driver == "Dummy"
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	app.set_audio_paused(false)
	app.data["muted"] = false
	app.data["master"] = 0.8
	app.data["effects"] = 0.8
	app.apply_preferences()
	for effect: String in app.FX:
		app.stop_effects()
		app.play_effect(effect)
		var stream: AudioStream = load(app.FX[effect]) as AudioStream
		var sample_count: int = ceili((stream.get_length() + 0.10) / 0.02)
		var peak: float = -200.0
		for sample_index: int in range(sample_count):
			await create_timer(0.02).timeout
			peak = maxf(peak, AudioServer.get_bus_peak_volume_left_db(0, 0))
		report["peaks_db"][effect] = peak
		failed = failed or peak < -60.0
	app.stop_effects()
	await create_timer(0.2).timeout
	report["passed"] = not failed
	var file: FileAccess = FileAccess.open(OS.get_environment("AP_AUDIO_REPORT"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print(JSON.stringify(report))
	quit(1 if failed else 0)
