extends RefCounted
## Phase 1 pure-rule tests. The shared SceneTree runner owns reports and exit codes.

const BoardScript = preload("res://scripts/core/pyramid_board.gd")
const BufferScript = preload("res://scripts/core/pyramid_input_buffer.gd")
const SimulationScript = preload("res://scripts/core/pyramid_simulation.gd")


func run(runner: SceneTree) -> void:
	_test_coordinates(runner)
	_test_colors(runner)
	_test_path_landings(runner)
	_test_complete_traversals(runner)
	_test_jump_timing(runner)
	_test_buffer_boundaries(runner)
	_test_input_order(runner)
	_test_latest_and_held(runner)
	_test_invalid_inputs(runner)
	_test_pause(runner)
	_test_reset_and_fall(runner)
	_test_snapshot_independence(runner)
	_test_seeded_replay(runner)


func _begin(runner: SceneTree, name: String) -> void:
	runner.call("_begin_test", "foundation_" + name)


func _check(runner: SceneTree, condition: bool, message: String) -> void:
	runner.call("_check", condition, message)


func _press(direction: int) -> Dictionary:
	return {"type": "press", "direction": direction}


func _release(direction: int) -> Dictionary:
	return {"type": "release", "direction": direction}


func _advance_to(simulation: PyramidSimulation, target_tick: int) -> void:
	while simulation.tick < target_tick and not simulation.fallen and not simulation.paused:
		simulation.step()


func _jump(simulation: PyramidSimulation, direction: int) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	while simulation.is_airborne or simulation.is_recovering:
		events.append_array(simulation.step())
	events.append_array(simulation.step([_press(direction)]))
	events.append_array(simulation.step([_release(direction)]))
	while simulation.is_airborne:
		events.append_array(simulation.step())
	return events


func _test_coordinates(runner: SceneTree) -> void:
	_begin(runner, "coordinates_and_edges")
	var board: PyramidBoard = BoardScript.new()
	var coordinates: Array[Vector2i] = board.cells()
	_check(runner, coordinates.size() == 28, "La piramide contiene esattamente 28 celle.")
	var unique: Dictionary = {}
	var offsets: Array[Vector2i] = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(1, 1)]
	var opposites: Array[int] = [3, 2, 1, 0]
	var valid_edges: int = 0
	for coordinate: Vector2i in coordinates:
		unique[coordinate] = true
		_check(runner, board.is_valid_cell(coordinate), "Ogni cella enumerata è valida.")
		for direction: int in range(4):
			var expected: Vector2i = coordinate + offsets[direction]
			var destination: Vector2i = board.neighbor(coordinate, direction)
			_check(runner, destination == expected, "La direzione rispetta le coordinate logiche.")
			if board.is_valid_cell(destination):
				valid_edges += 1
				_check(runner, board.neighbor(destination, opposites[direction]) == coordinate, "Ogni collegamento valido è percorribile al contrario.")
	_check(runner, unique.size() == 28 and valid_edges == 84, "Celle uniche e 42 collegamenti bidirezionali.")
	for row: int in range(-2, 10):
		for column: int in range(-2, 10):
			var coordinate: Vector2i = Vector2i(row, column)
			var expected_valid: bool = row >= 0 and row < 7 and column >= 0 and column <= row
			_check(runner, board.is_valid_cell(coordinate) == expected_valid, "Confini esaustivi del rettangolo di prova.")
			if not expected_valid:
				_check(runner, board.get_state(coordinate) == -1, "Lettura invalida restituisce il valore sentinella.")
	var before: Dictionary = board.get_snapshot()
	for direction: int in [-8, -1, 4, 99]:
		_check(runner, board.neighbor(Vector2i.ZERO, direction) == board.INVALID_CELL, "Direzione invalida non inventa una cella.")
	_check(runner, board.apply_landing(Vector2i(7, 0)).is_empty() and board.get_snapshot() == before, "Atterraggio esterno non modifica la board.")
	coordinates.clear()
	_check(runner, board.cells().size() == 28, "L'enumerazione è una copia indipendente.")


func _test_colors(runner: SceneTree) -> void:
	for mode: int in range(3):
		_begin(runner, "color_mode_%d" % mode)
		var board: PyramidBoard = BoardScript.new()
		_check(runner, board.reset(mode), "Modalità valida accettata.")
		_check(runner, board.completed_count() == 0 and not board.all_complete, "La board nuova non è completata.")
		for visit: int in range(1, 7):
			for coordinate: Vector2i in board.cells():
				var previous: int = board.get_state(coordinate)
				var transition: Dictionary = board.apply_landing(coordinate)
				var expected: int = 1
				if mode == 1:
					expected = mini(visit, 2)
				elif mode == 2:
					expected = visit % 2
				_check(runner, board.get_state(coordinate) == expected, "Transizione cromatica corretta per ogni cella/visita.")
				_check(runner, transition["before"] == previous and transition["after"] == expected, "L'evento descrive il cambiamento effettivo.")
			var expected_complete: bool = mode == 0 or (mode == 1 and visit >= 2) or (mode == 2 and visit % 2 == 1)
			_check(runner, board.all_complete == expected_complete, "Il completamento è derivato dagli stati correnti.")
			_check(runner, board.completed_count() == (28 if expected_complete else 0), "Conteggio obiettivi senza fine round implicita.")
		var before: Dictionary = board.get_snapshot()
		_check(runner, not board.reset(-1) and not board.reset(3), "Modalità invalide rifiutate.")
		_check(runner, board.get_snapshot() == before, "Reset board invalido è atomico.")


func _test_path_landings(runner: SceneTree) -> void:
	_begin(runner, "reachable_cells_and_color_paths")
	for mode: int in range(3):
		for target: Vector2i in BoardScript.new().cells():
			var simulation: PyramidSimulation = SimulationScript.new()
			simulation.reset(mode)
			var visits: Dictionary = {}
			var route: Array[int] = []
			for unused: int in range(target.x - target.y):
				route.append(2)
			for unused: int in range(target.y):
				route.append(3)
			var outward: Array[int] = route.duplicate()
			for index: int in range(outward.size() - 1, -1, -1):
				route.append(1 if outward[index] == 2 else 0)
			for direction: int in route:
				var events: Array[Dictionary] = _jump(simulation, direction)
				_check(runner, events.size() == 2 and events.back()["type"] == "jump_landed", "Ogni salto nel percorso ha un atterraggio unico.")
				visits[simulation.cell] = int(visits.get(simulation.cell, 0)) + 1
			_check(runner, simulation.cell == Vector2i.ZERO and not simulation.fallen, "Ogni cella è raggiungibile e il percorso torna all'apice.")
			for coordinate: Vector2i in simulation.board.cells():
				var count: int = visits.get(coordinate, 0)
				var expected: int = mini(count, 1)
				if mode == 1:
					expected = mini(count, 2)
				elif mode == 2:
					expected = count % 2
				_check(runner, simulation.board.get_state(coordinate) == expected, "Solo gli atterraggi colorano lungo percorsi reali.")


func _dfs_route(coordinate: Vector2i, visited: Dictionary, route: Array[int]) -> void:
	visited[coordinate] = true
	var opposites: Array[int] = [3, 2, 1, 0]
	for direction: int in range(4):
		var destination: Vector2i = BoardScript.neighbor(coordinate, direction)
		if BoardScript.is_valid_cell(destination) and not visited.has(destination):
			route.append(direction)
			_dfs_route(destination, visited, route)
			route.append(opposites[direction])


func _test_complete_traversals(runner: SceneTree) -> void:
	_begin(runner, "complete_board_through_real_jumps")
	var route: Array[int] = []
	var visited: Dictionary = {}
	_dfs_route(Vector2i.ZERO, visited, route)
	_check(runner, visited.size() == 28 and route.size() == 54, "DFS attraversa l'intera piramide e torna all'apice.")
	for mode: int in range(3):
		var simulation: PyramidSimulation = SimulationScript.new()
		simulation.reset(mode)
		var counts: Dictionary = {}
		for pass_index: int in range(2):
			for direction: int in route:
				var events: Array[Dictionary] = _jump(simulation, direction)
				_check(runner, events.size() == 2 and events.back()["type"] == "jump_landed", "DFS produce un esito per salto.")
				counts[simulation.cell] = int(counts.get(simulation.cell, 0)) + 1
				for coordinate: Vector2i in simulation.board.cells():
					var count: int = counts.get(coordinate, 0)
					var expected: int = mini(count, 1) if mode == 0 else (mini(count, 2) if mode == 1 else count % 2)
					_check(runner, simulation.board.get_state(coordinate) == expected, "Stati DFS confrontati con conteggio visite indipendente.")
			_check(runner, simulation.cell == Vector2i.ZERO, "DFS torna all'apice.")
			if mode == 0 or (mode == 1 and pass_index == 1):
				_check(runner, simulation.board.all_complete, "Permanente/two-step completabili attraverso salti effettivi.")
			_check(runner, not simulation.fallen and simulation.tick > 0, "Completamento non avvia round o interrompe il laboratorio.")


func _test_jump_timing(runner: SceneTree) -> void:
	_begin(runner, "jump_18_recovery_2")
	var simulation: PyramidSimulation = SimulationScript.new()
	_check(runner, simulation.tick == 0 and simulation.board.get_state(Vector2i.ZERO) == 0, "La comparsa non colora.")
	var events: Array[Dictionary] = simulation.step([_press(3)])
	_check(runner, events.size() == 1 and events[0]["type"] == "jump_started", "Una pressione avvia un salto.")
	_check(runner, simulation.tick == 1 and simulation.jump_start_tick == 1 and simulation.jump_end_tick == 19, "Timeline esplicita: fine a start+18.")
	_check(runner, simulation.is_airborne and is_zero_approx(simulation.jump_progress), "Progressione iniziale zero.")
	_advance_to(simulation, 18)
	_check(runner, simulation.is_airborne and simulation.cell == Vector2i.ZERO, "Prima del tick finale la cella logica resta l'origine.")
	_check(runner, simulation.board.get_state(Vector2i(1, 1)) == 0, "Nessun colore in volo.")
	events = simulation.step()
	_check(runner, simulation.tick == 19 and events.size() == 1 and events[0]["type"] == "jump_landed", "Atterraggio una sola volta al tick 19.")
	_check(runner, simulation.cell == Vector2i(1, 1) and simulation.board.get_state(simulation.cell) == 1, "Atterraggio applica posizione e colore insieme.")
	_check(runner, simulation.recovery_ticks_remaining == 2, "Recupero di due tick all'atterraggio.")
	_check(runner, simulation.step().is_empty() and simulation.tick == 20 and simulation.is_recovering, "Nessuna ripartenza durante il recupero.")
	events = simulation.step()
	_check(runner, events.size() == 1 and events[0]["type"] == "jump_started" and simulation.jump_start_tick == 21, "Il mantenuto ripete dopo 20 tick fra partenze.")
	_check(runner, simulation.jump_id == 2, "ID nuovo per ogni salto.")


func _test_buffer_boundaries(runner: SceneTree) -> void:
	_begin(runner, "buffer_exact_ttl")
	for age: int in [0, 11, 12, 13]:
		var buffer: PyramidInputBuffer = BufferScript.new()
		buffer.accept_events([_press(2)], 100)
		buffer.accept_events([_release(2)], 100)
		_check(runner, buffer.take_direction(100 + age) == (2 if age < 12 else -1), "Buffer valido solo per age<12, anche dopo rilascio.")
	for press_tick: int in [9, 10]:
		var simulation: PyramidSimulation = SimulationScript.new()
		simulation.step([_press(3)])
		simulation.step([_release(3)])
		_advance_to(simulation, press_tick - 1)
		simulation.step([_press(2)])
		simulation.step([_release(2)])
		_advance_to(simulation, 21)
		_check(runner, simulation.is_airborne == (press_tick == 10), "Confine TTL verificato nella simulazione completa.")
		if press_tick == 10:
			_check(runner, simulation.jump_to == Vector2i(2, 1), "Il buffer valido parte nel primo istante utile.")


func _permutations(values: Array[int]) -> Array:
	var result: Array = []
	if values.is_empty():
		result.append([])
		return result
	for index: int in range(values.size()):
		var remaining: Array[int] = values.duplicate()
		var first: int = remaining[index]
		remaining.remove_at(index)
		for tail: Array in _permutations(remaining):
			var permutation: Array[int] = [first]
			for direction: int in tail:
				permutation.append(direction)
			result.append(permutation)
	return result


func _test_input_order(runner: SceneTree) -> void:
	_begin(runner, "simultaneous_input_permutations")
	for permutation: Array in _permutations([0, 1, 2, 3]):
		var events: Array[Dictionary] = []
		for direction: int in permutation:
			events.append(_press(direction))
		var simulation: PyramidSimulation = SimulationScript.new()
		simulation.reset(0, Vector2i(3, 1))
		simulation.step(events)
		_check(runner, simulation.jump_to == Vector2i(2, 0), "NO vince tutte le 24 permutazioni simultanee.")
	var tap: PyramidInputBuffer = BufferScript.new()
	tap.accept_events([_press(1), _release(1)], 1)
	_check(runner, tap.take_direction(1) == 1 and tap.take_direction(2) == -1, "Un tap nello stesso tick conserva il buffer ma non il mantenuto.")
	var repress: PyramidInputBuffer = BufferScript.new()
	repress.accept_events([_release(1), _press(1)], 1)
	_check(runner, repress.take_direction(1) == 1 and repress.take_direction(2) == 1, "Release+press nello stesso tick termina mantenuto.")
	var simulation: PyramidSimulation = SimulationScript.new()
	simulation.step([_press(3), _release(3)])
	_advance_to(simulation, 60)
	_check(runner, simulation.jump_id == 1 and simulation.cell == Vector2i(1, 1) and not simulation.is_airborne, "Un tap rapido causa esattamente un salto anche dopo un secondo.")


func _test_latest_and_held(runner: SceneTree) -> void:
	_begin(runner, "latest_press_buffer_before_held")
	var simulation: PyramidSimulation = SimulationScript.new()
	simulation.step([_press(2)])
	_advance_to(simulation, 9)
	simulation.step([_press(3)])
	simulation.step([_release(3)])
	_advance_to(simulation, 21)
	_check(runner, simulation.jump_to == Vector2i(2, 1), "La nuova pressione rilasciata nel buffer precede il mantenuto precedente.")
	_advance_to(simulation, 41)
	_check(runner, simulation.jump_to == Vector2i(3, 1), "Consumata la pressione buffered torna il mantenuto più recente ancora attivo.")
	var buffer: PyramidInputBuffer = BufferScript.new()
	buffer.accept_events([_press(2)], 1)
	buffer.take_direction(1)
	buffer.accept_events([_press(3)], 2)
	_check(runner, buffer.take_direction(2) == 3 and buffer.take_direction(3) == 3, "Fra mantenuti vince la nuova pressione.")
	buffer.accept_events([_release(3)], 4)
	_check(runner, buffer.take_direction(4) == 2, "Rilasciare il più recente rivela il precedente mantenuto.")
	buffer.flush()
	buffer.accept_events([_press(1)], 10)
	buffer.accept_events([_press(1)], 20)
	buffer.accept_events([_release(1)], 20)
	_check(runner, buffer.take_direction(22) == -1, "Una pressione duplicata non rinnova il TTL.")


func _test_invalid_inputs(runner: SceneTree) -> void:
	_begin(runner, "invalid_inputs_are_atomic")
	var invalid: Array[Dictionary] = [{}, {"type": "other", "direction": 0}, {"type": "press", "direction": -1}, {"type": "press", "direction": 4}, {"type": "press", "direction": 1.0}, {"type": "press", "direction": true}, {"type": 12, "direction": 0}]
	var simulation: PyramidSimulation = SimulationScript.new()
	simulation.reset(1, Vector2i(3, 1))
	for event: Dictionary in invalid:
		var before: Dictionary = simulation.get_snapshot()
		_check(runner, simulation.step([_press(2), event]).is_empty(), "Batch invalido non emette eventi.")
		_check(runner, simulation.get_snapshot() == before, "Nessuna applicazione parziale e nessun avanzamento del tick.")
	var before: Dictionary = simulation.get_snapshot()
	_check(runner, not simulation.reset(3) and not simulation.reset(1, Vector2i(7, 0)), "Reset invalido rifiutato.")
	_check(runner, simulation.get_snapshot() == before, "Reset invalido preserva tutto lo stato.")
	var buffer: PyramidInputBuffer = BufferScript.new()
	buffer.accept_events([_press(0)], 10)
	before = buffer.get_snapshot()
	_check(runner, not buffer.accept_events([_release(0)], 9) and buffer.get_snapshot() == before, "Timestamp retrogrado rifiutato senza mutazioni.")


func _test_pause(runner: SceneTree) -> void:
	_begin(runner, "pause_flush_and_timer_freeze")
	var simulation: PyramidSimulation = SimulationScript.new()
	simulation.step([_press(3)])
	_advance_to(simulation, 8)
	simulation.step([_press(2)])
	simulation.set_paused(true)
	var frozen: Dictionary = simulation.get_snapshot()
	for unused: int in range(40):
		_check(runner, simulation.step([_press(2)]).is_empty() and simulation.get_snapshot() == frozen, "Pausa congela tick, traiettoria, colori e ignora input.")
	simulation.set_paused(false)
	_advance_to(simulation, 40)
	_check(runner, simulation.cell == Vector2i(1, 1) and not simulation.is_airborne, "Il salto riprende e termina, ma buffer e mantenuti prepausa non ripartono.")
	_check(runner, simulation.step([_press(2)]).size() == 1 and simulation.is_airborne, "Una pressione nuova dopo la pausa è accettata.")


func _test_reset_and_fall(runner: SceneTree) -> void:
	_begin(runner, "reset_cancels_run_and_fall_is_terminal")
	var simulation: PyramidSimulation = SimulationScript.new()
	var events: Array[Dictionary] = _jump(simulation, 0)
	_check(runner, events.size() == 2 and events[1]["type"] == "jump_fallen", "Un salto esterno produce una sola caduta.")
	_check(runner, simulation.fallen and simulation.tick == 19 and simulation.cell == Vector2i.ZERO, "Caduta terminale senza vita o respawn impliciti.")
	var old_id: int = simulation.jump_id
	var frozen: Dictionary = simulation.get_snapshot()
	for unused: int in range(40):
		_check(runner, simulation.step([_press(3)]).is_empty() and simulation.get_snapshot() == frozen, "Nessun secondo esito e nessuna simulazione dopo la caduta.")
	_check(runner, simulation.reset(2), "Reset esplicito riapre il laboratorio.")
	_check(runner, not simulation.fallen and simulation.tick == 0 and simulation.board.completed_count() == 0, "Reset ripristina posizione, colori e tempo senza colorare la comparsa.")
	simulation.step([_press(3)])
	_check(runner, simulation.jump_id > old_id, "Gli ID non vengono riutilizzati dopo reset.")
	_advance_to(simulation, 5)
	simulation.set_paused(true)
	simulation.reset(1)
	_advance_to(simulation, 40)
	_check(runner, simulation.cell == Vector2i.ZERO and simulation.board.completed_count() == 0 and not simulation.is_airborne and not simulation.paused, "Reset in volo/pausa cancella il vecchio salto e gli input.")


func _test_snapshot_independence(runner: SceneTree) -> void:
	_begin(runner, "snapshots_and_events_do_not_alias")
	var simulation: PyramidSimulation = SimulationScript.new()
	var events: Array[Dictionary] = simulation.step([_press(3)])
	var snapshot: Dictionary = simulation.get_snapshot()
	var expected: Dictionary = simulation.get_snapshot()
	snapshot["board"]["states"][0] = 9
	snapshot["input"]["held"][0] = true
	events[0]["to"] = Vector2i(9, 9)
	_check(runner, simulation.get_snapshot() == expected, "Modificare snapshot/eventi restituiti non altera il nucleo.")


func _test_seeded_replay(runner: SceneTree) -> void:
	_begin(runner, "seeded_replays")
	var first: PyramidSimulation = SimulationScript.new()
	var second: PyramidSimulation = SimulationScript.new()
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 0x5A17
	var visits: Dictionary = {}
	for index: int in range(1200):
		if index % 73 == 0:
			var mode: int = random.randi_range(0, 2)
			var coordinate: Vector2i = Vector2i(3, random.randi_range(0, 3))
			first.reset(mode, coordinate)
			second.reset(mode, coordinate)
			visits.clear()
		if index % 41 == 0:
			var pause_value: bool = random.randi_range(0, 1) == 1
			first.set_paused(pause_value)
			second.set_paused(pause_value)
		var events: Array[Dictionary] = []
		for unused: int in range(random.randi_range(0, 3)):
			var direction: int = random.randi_range(0, 3)
			events.append(_press(direction) if random.randi_range(0, 1) == 1 else _release(direction))
		var first_events: Array[Dictionary] = first.step(events)
		var second_events: Array[Dictionary] = second.step(events)
		_check(runner, first_events == second_events, "Stessi eventi semantici/seed producono gli stessi eventi logici.")
		for event: Dictionary in first_events:
			if event["type"] == "jump_landed":
				visits[event["to"]] = int(visits.get(event["to"], 0)) + 1
		for coordinate: Vector2i in first.board.cells():
			var count: int = visits.get(coordinate, 0)
			var expected: int = mini(count, 1) if first.board.color_mode == 0 else (mini(count, 2) if first.board.color_mode == 1 else count % 2)
			_check(runner, first.board.get_state(coordinate) == expected, "Replay confrontato con riferimento cromatico da visite, anche reversibile.")
		_check(runner, first.get_snapshot() == second.get_snapshot(), "Replay deterministico tick per tick, incluse pausa e reset.")
