extends RefCounted

const Game = preload("res://scripts/core/pyramid_game.gd")
const Score = preload("res://scripts/core/pyramid_score.gd")
const CONFIG = preload("res://data/initial_rounds.tres")
var _runner: SceneTree
var _children: Dictionary = {}
var _sizes: Dictionary = {}
var _route: Array[int] = []


func run(runner: SceneTree) -> void:
	_runner = runner
	_test_configuration()
	_test_score()
	_test_death_and_respawn()
	_test_pause_and_game_over()
	_test_reversible_credits()
	_test_campaign()


func _test_configuration() -> void:
	_begin("game_configuration_atomic_and_owned")
	var game: Game = _new_game()
	_check(CONFIG.color_modes == Game.DEFAULT_MODES, "Il file configurabile deve contenere i tre livelli di quattro round.")
	var modes: Array[int] = CONFIG.color_modes.duplicate()
	_check(game.start_new_game(modes), "Configurazione valida accettata.")
	modes[0] = 2
	_check(game.simulation.board.color_mode == 0 and game.snapshot()["modes"][0] == 0, "Il chiamante non deve poter mutare la configurazione della partita.")
	var before: Dictionary = game.snapshot()
	_check(not game.start_new_game([0]), "Configurazione incompleta rifiutata.")
	modes[0] = 99
	_check(not game.start_new_game(modes) and game.snapshot() == before, "Configurazione errata rifiutata senza distruggere la partita.")
	var snapshot: Dictionary = game.snapshot()
	snapshot["score"]["credits"]["fake"] = true
	_check(game.snapshot() == before, "Lo snapshot deve essere indipendente.")


func _test_score() -> void:
	_begin("game_score_thresholds_dedup_and_cap")
	var score: Score = Score.new()
	_check(score.points == 0 and score.lives == 3 and score.next_extra == 8000, "Valori iniziali approvati.")
	_check(not score.credit("", 1) and not score.credit("negative", -1), "Crediti invalidi non consumati.")
	score.credit("first", 7999)
	_check(score.lives == 3, "Nessuna extra prima della soglia.")
	score.credit("boundary", 1)
	_check(score.lives == 4 and score.next_extra == 22000, "Extra esattamente a 8000.")
	_check(not score.credit("boundary", 100000) and score.points == 8000, "ID duplicato non deve accreditare punti o vite.")
	score.credit("many", 42000)
	_check(score.points == 50000 and score.lives == 5 and score.next_extra == 64000, "Tutte le soglie attraversate sono consumate, anche al cap cinque.")
	score.lives -= 1
	score.credit("after_cap", 1)
	_check(score.lives == 4, "Una soglia consumata al cap non può essere recuperata dopo una morte.")
	score.reset()
	_check(score.credit("boundary", 8000) and score.lives == 4, "Nuova partita azzera anche il registro degli accrediti.")


func _test_death_and_respawn() -> void:
	_begin("game_death_once_respawn_preserves_board_score")
	var game: Game = _new_game()
	_jump(game, 2)
	_check(game.score.points == 25, "Atterraggio permanente vale 25.")
	_jump(game, 0)
	_check(game.state == Game.State.DYING and game.score.lives == 2, "Una caduta sottrae una sola vita.")
	var old_id: int = game.simulation.jump_id
	_check(not game.request_death(&"fall") and not game.request_death(&"contact") and game.score.lives == 2, "Cause letali ripetute nello stesso episodio sono ignorate.")
	_ticks(game, 89)
	_check(game.state == Game.State.DYING and game.remaining_ticks == 1, "Il respawn non deve anticipare i 90 tick.")
	game.step()
	_check(game.state == Game.State.PLAYING and game.simulation.cell == Vector2i.ZERO, "Respawn all'apice al tick 90.")
	_check(game.score.points == 25 and game.simulation.board.get_state(Vector2i(1, 0)) == 1 and game.simulation.board.get_state(Vector2i.ZERO) == 0, "Respawn conserva punti/colori e non colora l'apice.")
	_check(game.protection_ticks == 120 and not game.request_death(&"contact"), "Protezione contatti iniziale di 120 tick.")
	_ticks(game, 119)
	_check(game.protection_ticks == 1 and not game.request_death(&"contact"), "Protezione valida fino all'ultimo tick.")
	game.step()
	_check(game.protection_ticks == 0, "Protezione scaduta esattamente al tick 120.")
	_jump(game, 2)
	_check(game.simulation.jump_id > old_id and game.score.points == 25, "ID non riusati e colore già accreditato non ripaga dopo respawn.")
	_check(game.request_death(&"contact"), "Contatto accettato dopo la scadenza (senza introdurre avversari).")
	_ticks(game, 90)
	_check(game.protection_ticks == 120 and game.request_death(&"fall"), "Una caduta ignora la protezione contatti.")
	_ticks(game, 90)
	_check(game.state == Game.State.GAME_OVER and game.score.lives == 0, "L'ultima vita porta a Game Over dopo l'attesa.")


func _test_pause_and_game_over() -> void:
	_begin("game_pause_all_timers_and_restart")
	var game: Game = _new_game()
	game.step([{"type": "press", "direction": 2}])
	_ticks(game, 3)
	game.set_paused(true)
	var before: Dictionary = game.snapshot()
	_ticks(game, 200)
	_check(game.snapshot() == before, "Pausa durante salto congela tutti i timer.")
	game.set_paused(false)
	_ticks(game, 60)
	_check(game.simulation.cell == Vector2i(1, 0) and game.simulation.jump_id == 1, "La ripresa termina il salto senza riusare il mantenuto.")
	game.request_death(&"fall")
	game.set_paused(true)
	before = game.snapshot()
	_ticks(game, 100)
	_check(game.snapshot() == before, "La pausa congela anche l'attesa respawn.")
	game.set_paused(false)
	_ticks(game, 90)
	game.set_paused(true)
	before = game.snapshot()
	_ticks(game, 200)
	_check(game.snapshot() == before and game.protection_ticks == 120, "La protezione non scade in pausa.")
	game.set_paused(false)
	for death: int in range(2):
		game.request_death(&"fall")
		_ticks(game, 90)
	before = game.snapshot()
	_ticks(game, 200)
	_check(game.snapshot() == before and not game.request_death(&"fall"), "Game Over ignora timer, comandi e ulteriori morti.")
	game.start_new_game()
	_check(game.state == Game.State.PLAYING and game.score.points == 0 and game.score.lives == 3 and game.active_ticks == 0, "Nuova partita azzera stato, punti e vite.")
	_check(game.simulation.board.completed_count() == 0 and game.simulation.cell == Vector2i.ZERO, "Nuova partita riparte senza colori residui.")


func _test_reversible_credits() -> void:
	_begin("game_color_milestone_credits")
	var game: Game = _new_game()
	var modes: Array[int] = Game.DEFAULT_MODES.duplicate()
	modes[0] = 2
	game.start_new_game(modes)
	for cycle: int in range(3):
		_jump(game, 2)
		_jump(game, 1)
	_check(game.score.points == 50, "Tre cicli reversibili su due celle pagano ciascuna cella solo una volta.")
	modes[0] = 1
	game.start_new_game(modes)
	_jump(game, 2)
	_check(game.score.points == 15, "Primo passaggio intermedio vale 15.")
	_jump(game, 1)
	_jump(game, 2)
	_check(game.score.points == 55, "Secondo passaggio finale vale 25, oltre ai due intermedi.")
	_jump(game, 1)
	_jump(game, 2)
	_check(game.score.points == 80, "Atterraggi ripetuti su celle finite non danno ulteriori punti.")


func _test_campaign() -> void:
	_begin("game_twelve_rounds_reachable_by_real_jumps")
	var game: Game = _new_game()
	_build_tree(Vector2i.ZERO, {})
	_build_route(Vector2i.ZERO)
	var expected_points: int = 0
	for round_index: int in range(12):
		_check(game.round_index == round_index and game.level_number == round_index / 4 + 1 and game.round_number == round_index % 4 + 1, "Livello/round raggiunto in ordine.")
		_check(game.simulation.board.completed_count() == 0, "Ogni nuovo round azzera i colori.")
		var mode: int = int(Game.DEFAULT_MODES[round_index])
		for pass_index: int in range(2 if mode == 1 else 1):
			for direction: int in _route:
				if game.state != Game.State.PLAYING:
					break
				_jump(game, direction)
		_check(game.state == Game.State.ROUND_END and game.simulation.board.all_complete, "Round risolto con soli salti validi, inclusa parità reversibile.")
		expected_points += (1120 if mode == 1 else 700) + 1100 + 250 * round_index
		_check(game.score.points == expected_points and game.last_bonus == 1000 + 250 * round_index, "Punti celle e bonus esatti e non duplicati.")
		_check(not game.request_death(&"fall"), "Fine round blocca nuovi danni.")
		game.set_paused(true)
		var snapshot: Dictionary = game.snapshot()
		_ticks(game, 200)
		_check(game.snapshot() == snapshot, "Pausa congela anche la transizione round.")
		game.set_paused(false)
		_ticks(game, 179)
		_check(game.state == Game.State.ROUND_END and game.score.points == expected_points, "Bonus unico e attesa completa di 180 tick (VID-01).")
		game.step([{"type": "press", "direction": 3}])
		_check(game.simulation.jump_id == 0, "Input durante transizione non deve saltare nel round nuovo.")
	_check(game.state == Game.State.PLAYING and game.round_index == 12 and game.score.points == 39780, "Il tredicesimo round avvia la progressione continua con 39780 punti.")
	_check(game.score.lives == 5 and game.score.next_extra == 50000, "Extra a 8000/22000/36000 con cap cinque.")
	game.start_new_game()
	_check(game.round_index == 0 and game.score.lives == 3 and game.score.points == 0, "Nuova partita possibile dopo completamento.")


func _build_tree(cell: Vector2i, visited: Dictionary) -> int:
	visited[cell] = true
	_children[cell] = []
	var size: int = 1
	for direction: int in range(4):
		var neighbor: Vector2i = PyramidBoard.neighbor(cell, direction)
		if PyramidBoard.is_valid_cell(neighbor) and not visited.has(neighbor):
			_children[cell].append({"cell": neighbor, "direction": direction})
			size += _build_tree(neighbor, visited)
	_sizes[cell] = size
	return size


func _build_route(cell: Vector2i) -> void:
	# A closed tree walk: edge multiplicity equals subtree size modulo 2.
	# Therefore every vertex receives an odd number of landings (28 even vertices).
	var opposite: Array[int] = [3, 2, 1, 0]
	for child: Dictionary in _children[cell]:
		var direction: int = child["direction"]
		_route.append(direction)
		_build_route(child["cell"])
		_route.append(opposite[direction])
		if int(_sizes[child["cell"]]) % 2 == 0:
			_route.append(direction)
			_route.append(opposite[direction])


func _new_game() -> Game:
	var game: Game = Game.new()
	game.world.spawning_enabled = false
	game.world.stasis_enabled = false
	return game


func _jump(game: Game, direction: int) -> void:
	while game.simulation.is_recovering and game.accepts_movement:
		game.step()
	game.step([{"type": "press", "direction": direction}])
	game.step([{"type": "release", "direction": direction}])
	_ticks(game, 17)


func _ticks(game: Game, count: int) -> void:
	for index: int in range(count):
		game.step()


func _begin(name: String) -> void:
	_runner.call("_begin_test", name)


func _check(value: bool, message: String) -> void:
	_runner.call("_check", value, message)
