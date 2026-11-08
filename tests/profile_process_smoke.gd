extends SceneTree
## Separate-process persistence probe; caller must isolate XDG user data.
const Profile = preload("res://scripts/core/player_profile.gd")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var mode: String = OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else ""
	var store: PlayerProfile = Profile.new("user://phase6-restart.json")
	var passed: bool = false
	if mode == "write":
		var old: Dictionary = Profile.defaults()
		old["schema"] = 2
		old.erase("leaderboard")
		old["record"] = 45678
		old["record_level"] = 9
		old["record_round"] = 4
		old["effects"] = .35
		old["muted"] = true
		var file: FileAccess = FileAccess.open(store.path, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(old))
			file.close()
			var migrated: Dictionary = store.load_profile()
			passed = migrated["schema"] == 4 and migrated["record"] == 45678 and migrated["record_level"] == 9 and migrated["record_round"] == 4 and is_equal_approx(migrated["effects"], .35) and migrated["muted"] and store.save_profile(migrated)
	elif mode == "read":
		var data: Dictionary = store.load_profile()
		passed = data["schema"] == 4 and data["record"] == 45678 and data["record_level"] == 9 and data["record_round"] == 4 and is_equal_approx(data["effects"], .35) and data["muted"] and data["leaderboard"].size() == 1 and data["leaderboard"][0]["legacy_name"] == "STORICO"
	elif mode == "denied":
		store = Profile.new("user://phase6-no-write/profile.json")
		passed = store.load_profile() == Profile.defaults() and not store.save_profile(Profile.defaults()) and not store.notice.is_empty()
	print("PHASE6_PROFILE_" + mode.to_upper() + ("_OK" if passed else "_FAILED"))
	quit(0 if passed else 1)
