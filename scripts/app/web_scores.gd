extends Node
## Server-authoritative Web ranking. Preferences and Windows scores are separate.
signal changed
const Scores = preload("res://scripts/core/high_scores.gd")
var entries: Array = []
var record: int = 0
var record_level: int = 1
var record_round: int = 1
var busy: bool = false
var loaded: bool = false
var notice: String = "Caricamento classifica dal server…"
var pending: Dictionary = {}
var saved_submission: String = ""
var ranked: bool = false
var endpoint: String = ""
var _request: HTTPRequest
var _operation: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_request = HTTPRequest.new()
	# Browser Fetch already decodes Content-Encoding; do not decompress twice.
	_request.accept_gzip = false
	_request.timeout = 8.0
	add_child(_request)
	_request.request_completed.connect(_completed)
	var poll: Timer = Timer.new()
	poll.wait_time = 5.0
	poll.timeout.connect(refresh)
	add_child(poll)
	poll.start()
	refresh()

func refresh() -> void:
	if busy or not pending.is_empty() or endpoint.is_empty():
		return
	_send("read")

func submit(points: int, level: int, round_number: int, player_name: String) -> void:
	if busy:
		return
	if pending.is_empty():
		pending = {"submission": Crypto.new().generate_random_bytes(16).hex_encode(),
			"name": player_name.to_upper(), "points": points, "level": level, "round": round_number}
	_send("save")

func retry() -> void:
	if not pending.is_empty() and not busy:
		_send("save")

func _send(operation: String) -> void:
	_operation = operation
	busy = true
	notice = "Salvataggio sul server in corso…" if operation == "save" else ("" if loaded else "Caricamento classifica dal server…")
	changed.emit()
	var error: Error
	if operation == "save":
		error = _request.request(endpoint, PackedStringArray(["Content-Type: application/json"]), HTTPClient.METHOD_POST, JSON.stringify(pending))
	else:
		error = _request.request(endpoint)
	if error != OK:
		_failed()

func _failed() -> void:
	busy = false
	notice = "Salvataggio server non confermato. Premi Riprova." if not pending.is_empty() else "Classifica server non raggiungibile. Nuovo tentativo automatico."
	changed.emit()

func _completed(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or status != 200:
		_failed()
		return
	var payload: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not payload is Dictionary or payload.get("schema") != 1 or not payload.get("leaderboard") is Array:
		_failed()
		return
	var valid: Array = Scores.validate(payload["leaderboard"])
	if valid.size() != payload["leaderboard"].size():
		_failed()
		return
	var best: Dictionary = valid[0] if not valid.is_empty() else {"points": 0, "level": 1, "round": 1}
	if payload.get("record") != best["points"] or payload.get("record_level") != best["level"] or payload.get("record_round") != best["round"]:
		_failed()
		return
	if _operation == "save" and (payload.get("submission") != pending.get("submission") or not payload.get("ranked") is bool):
		_failed()
		return
	entries = valid
	record = int(best["points"])
	record_level = int(best["level"])
	record_round = int(best["round"])
	loaded = true
	busy = false
	notice = "" if pending.is_empty() else "Salvataggio server non confermato. Premi Riprova."
	if _operation == "save":
		saved_submission = pending["submission"]
		ranked = payload["ranked"]
		pending = {}
		notice = "Punteggio salvato sul server." if ranked else "Punteggio salvato sul server; fuori dai primi dieci."
	changed.emit()
