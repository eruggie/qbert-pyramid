class_name GameAudioCues
extends RefCounted
## Converts semantic outcomes to presentation cues, never changes the simulation.
static func before_step(game: PyramidGame) -> Dictionary:
	return {"state": game.state, "score": game.score.snapshot()}

static func resolve(before: Dictionary, game: PyramidGame, events: Array[Dictionary]) -> Array[String]:
	var cues: Array[String] = []
	if before["state"] != game.state and game.state == PyramidGame.State.DYING:
		return ["fall" if game.simulation.fallen else "contact"]
	if before["state"] != game.state and game.state == PyramidGame.State.GAME_OVER:
		return ["game_over"]
	var stasis: bool = false
	var lost_stasis: bool = false
	for event: Dictionary in events:
		stasis = stasis or event["type"] == "stasis_collected"
		lost_stasis = lost_stasis or event["type"] == "stasis_fallen"
	var collection: bool = false
	var chaser: bool = false
	var credits: Dictionary = game.score.snapshot()["credits"]
	for key: String in credits:
		if before["score"]["credits"].has(key):
			continue
		collection = collection or key.contains(":actor:")
		chaser = chaser or key.contains(":chaser:")
	if before["state"] != game.state and game.state == PyramidGame.State.ROUND_END:
		cues.append("level" if game.round_number == 4 else "round")
	elif collection:
		cues.append("collect")
	elif not stasis and not chaser:
		for event: Dictionary in events:
			match event["type"]:
				"jump_started": cues.append("jump")
				"rescue_started": cues.append("rescue")
				"jump_landed": cues.append("color" if event.get("color_after", 0) != event.get("color_before", 0) else "land")
	if chaser:
		cues.append("lure")
	if stasis:
		cues.append("stasis_collect")
	if lost_stasis:
		cues.append("stasis_fall")
	if game.score.lives > int(before["score"]["lives"]):
		cues.append("extra")
	return cues
