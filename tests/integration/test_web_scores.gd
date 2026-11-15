extends RefCounted

func run(runner: SceneTree) -> void:
	runner._begin_test("web_server_json_numbers_acknowledgement_and_retry")
	var client: Node = preload("res://scripts/app/web_scores.gd").new()
	runner.root.add_child(client)
	var app: Node = runner.root.get_node("App")
	var original: Dictionary = app.data.duplicate(true)
	app.web_scores = client
	client.changed.connect(app._web_scores_changed)
	var good: Dictionary = {"schema": 1, "leaderboard": [{"name": "ABC", "points": 50, "level": 1, "round": 1}],
		"record": 50, "record_level": 1, "record_round": 1}
	# JSON.parse_string produces floats; the score validator normalizes to int.
	client._completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(good).to_utf8_buffer())
	runner._check(client.loaded and client.entries.size() == 1 and client.record == 50, "Valid JSON server scores survive float-to-int normalization.")
	var panel: RecordsPanel = preload("res://scripts/ui/records_panel.gd").new()
	panel.app = app
	panel.points = 50
	runner.root.add_child(panel)
	await runner.process_frame
	panel._web_submission = "00000000000000000000000000000001"
	client.pending = {"submission": "00000000000000000000000000000001", "name": "ABC", "points": 50, "level": 1, "round": 1}
	client._operation = "save"
	client._completed(HTTPRequest.RESULT_SUCCESS, 503, PackedStringArray(), PackedByteArray())
	runner._check(client.saved_submission.is_empty() and not client.pending.is_empty() and client.notice.contains("non confermato"), "A server failure never confirms a score and preserves its retry identity.")
	runner._check(not panel.submitted and panel.continue_button.disabled and panel.status_label.text.contains("non confermato"), "The results UI keeps an unconfirmed score retryable instead of returning to the menu.")
	var invalid: Dictionary = good.duplicate(true)
	invalid["submission"] = "wrong"
	invalid["ranked"] = true
	client._completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(invalid).to_utf8_buffer())
	runner._check(not client.pending.is_empty() and client.saved_submission.is_empty(), "An acknowledgement for another score is rejected.")
	good["submission"] = client.pending["submission"]
	good["ranked"] = true
	client._completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(good).to_utf8_buffer())
	runner._check(client.pending.is_empty() and client.saved_submission == good["submission"] and client.ranked, "Retry is confirmed only by the matching server acknowledgement.")
	runner._check(panel.submitted and not panel.continue_button.disabled and panel.status_label.text.contains("salvato sul server"), "The UI confirms the matching server save and enables Continue.")
	client._operation = "read"
	invalid = good.duplicate(true)
	invalid["leaderboard"][0]["points"] = -1
	client._completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(invalid).to_utf8_buffer())
	runner._check(client.entries[0]["points"] == 50 and client.record == 50, "Invalid remote data cannot replace the last confirmed ranking.")
	panel.queue_free()
	client.changed.disconnect(app._web_scores_changed)
	app.web_scores = null
	app.data = original
	app.apply_preferences()
	client.queue_free()
	await runner.process_frame
