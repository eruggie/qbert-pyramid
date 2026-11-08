extends RefCounted

const Game = preload("res://scripts/core/pyramid_game.gd")
const World = preload("res://scripts/core/pyramid_world.gd")
const Progression = preload("res://scripts/core/progression.gd")
var _runner: SceneTree


func run(runner: SceneTree) -> void:
	_runner = runner
	_test_progression()
	_test_configurable_progression()
	_test_seeded_spawns()
	_test_real_spawn_and_pause()
	_test_chaser_round_pacing()
	_test_chaser_normal_play_and_respawn()
	_test_spawn_caps_and_inbound_safety()
	_test_destinations()
	_test_collision_precedence()
	_test_crossings()
	_test_saboteur()
	_test_simultaneous_sabotage_prevents_win()
	_test_stasis()
	_test_stasis_contact_protection()
	_test_stasis_crossing_and_fall()
	_test_stasis_expiry_and_reset()
	_test_spider_round_three_spawns()
	_test_gottlieb_character_schedule()
	_test_gottlieb_runtime_and_respawn()
	_test_spider_round_transition_clears_state()
	_test_spider_contacts_and_discs()
	_test_platforms()
	_test_lure_and_fall_priority()
	_test_rescue_occupancy()


func _test_progression() -> void:
	_begin("phase3_progression_bounds")
	var policy: Progression = Progression.new(Game.DEFAULT_MODES)
	_check(policy.spawn_interval(0) == 300 and policy.spawn_interval(11) == 120, "Intervalli iniziali della specifica.")
	_check(policy.enemy_cap(0) == 2 and policy.enemy_cap(11) == 6, "Massimi dei primi dodici round.")
	_check(policy.color_mode(12) == 0 and policy.color_mode(16) == 1 and policy.color_mode(20) == 2 and policy.color_mode(24) == 0, "Ciclo delle modalità oltre il livello tre.")
	_check(policy.spawn_interval(12) == 120 and policy.spawn_interval(15) == 102, "Formula degli intervalli al livello quattro.")
	_check(policy.spawn_interval(400) == 72 and policy.enemy_cap(400) == 8 and is_equal_approx(policy.speed_factor(400), 0.6), "Limiti della progressione continua.")


func _test_configurable_progression() -> void:
	_begin("phase3_configurable_progression_is_atomic")
	var game: Game = _game()
	var settings: Dictionary = {"continuous_modes": [2, 0], "minimum_spawn_seconds": 1.5,
		"maximum_enemies": 7, "spawn_reduction_per_level": 0.2}
	_check(game.start_new_game(Game.DEFAULT_MODES, settings), "Configurazione continua valida accettata.")
	settings["continuous_modes"][0] = 1
	_check(game.progression.color_mode(12) == 2 and game.progression.color_mode(16) == 0, "Ciclo configurato e copia indipendente.")
	_check(game.progression.spawn_interval(400) == 90 and game.progression.enemy_cap(400) == 7, "Soglie configurate rispettate anche in livelli alti.")
	var before: Dictionary = game.snapshot()
	_check(not game.start_new_game(Game.DEFAULT_MODES, {"continuous_modes": []}), "Ciclo vuoto rifiutato.")
	_check(not game.start_new_game(Game.DEFAULT_MODES, {"cap_growth_levels": 0}) and game.snapshot() == before, "Configurazione invalida rifiutata senza modificare la partita.")
	_check(not game.start_new_game(Game.DEFAULT_MODES, {"spawn_start_seconds": "errato"}) and game.snapshot() == before, "Tipi numerici non validi rifiutati atomicamente senza errori.")


func _test_seeded_spawns() -> void:
	_begin("phase3_seed_spawn_warning_and_safe_cell")
	var first: World = World.new()
	var second: World = World.new()
	var policy: Progression = Progression.new(Game.DEFAULT_MODES)
	first.seed(1024)
	second.seed(1024)
	first.reset_round(6, policy)
	second.reset_round(6, policy)
	first.stasis_enabled = false
	second.stasis_enabled = false
	var position: Dictionary = {"cell": Vector2i.ZERO, "tick": 0, "is_airborne": false}
	for time: int in range(1800):
		first.advance(position, position, true)
		second.advance(position, position, true)
		first.depart_and_spawn(Vector2i.ZERO, false)
		second.depart_and_spawn(Vector2i.ZERO, false)
		_check(first.actors == second.actors and first.warning_kind == second.warning_kind and first.rng.state == second.rng.state, "Stesso seed e input producono lo stesso mondo.")
	_check(first.tick == 1800, "Replay avanzato con seed.")
	var blocked: World = World.new()
	blocked.seed(3)
	blocked.reset_round(0, policy)
	var blocked_position: Dictionary = position.duplicate()
	blocked_position["cell"] = Vector2i(6, 3)
	for time: int in range(264):
		blocked.advance(blocked_position, blocked_position, true)
		blocked.depart_and_spawn(blocked_position["cell"], false)
	_check(blocked.warning_kind == 1 and blocked.actors.is_empty(), "Segugio preannunciato 36 tick prima della prima apparizione.")
	for time: int in range(36):
		blocked.advance(blocked_position, blocked_position, true)
		blocked.depart_and_spawn(blocked_position["cell"], false)
	_check(blocked.actors.is_empty(), "Apparizione rinviata se l'apice è occupato.")
	blocked_position["cell"] = Vector2i(1, 1)
	blocked.advance(blocked_position, blocked_position, true)
	blocked.depart_and_spawn(Vector2i(1, 1), false)
	_check(blocked.actors.size() == 1 and blocked.actors[0]["kind"] == 1, "Segugio appare quando la cella torna sicura.")


func _test_real_spawn_and_pause() -> void:
	_begin("phase3_game_drives_actual_enemy_spawns")
	var game: Game = Game.new()
	game.world.seed(17)
	game.world.stasis_enabled = false
	_jump(game, 3)
	for time: int in range(245):
		game.step()
	_check(game.world.tick == 264 and game.world.warning_kind == 1, "La partita preannuncia il Segugio dopo 264 tick attivi.")
	game.set_paused(true)
	var before: Dictionary = game.snapshot()
	for time: int in range(80):
		game.step()
	_check(game.snapshot() == before, "Pausa congela preavviso, RNG, attori e apparizioni.")
	game.set_paused(false)
	for time: int in range(36):
		game.step()
	_check(game.world.actors.size() == 1 and game.world.actors[0]["kind"] == 1, "Il Segugio appare in partita al tick 300 sulla cella libera del fondo.")


func _test_chaser_round_pacing() -> void:
	_begin("refinement_chaser_pacing_four_rounds")
	var policy: Progression = Progression.new(Game.DEFAULT_MODES)
	var world: World = World.new()
	var expected: Array[int] = [81, 75, 68, 62]
	for round_index: int in range(4):
		world.reset_round(round_index, policy)
		_check(world.move_period(1) == expected[round_index], "Intervallo Segugio progressivo nel round %d." % (round_index + 1))
		_check(world.move_period(0) == roundi(72.0 * policy.speed_factor(round_index)), "Il ritmo della Scoria resta invariato.")
	for round_index: int in range(12, 16):
		world.reset_round(round_index, policy)
		if round_index > 12:
			var actual: int = world.move_period(1)
			world.round_index -= 1
			_check(actual < world.move_period(1), "Anche nei livelli successivi il Segugio accelera fra i round.")


func _test_chaser_normal_play_and_respawn() -> void:
	_begin("refinement_chaser_first_spawn_lethal_and_respawn")
	var game: Game = Game.new()
	game.world.seed(44)
	game.world.stasis_enabled = false
	_jump(game, 3)
	for time: int in range(281):
		game.step()
	_check(game.world.actors.size() == 1 and game.world.actors[0]["kind"] == 1, "Partita normale: primo avversario Segugio al tick 300.")
	if game.world.actors.size() != 1:
		return
	var chaser: Dictionary = game.world.actors[0]
	_check(chaser["cell"] == Vector2i(6, 3) and chaser["next"] == 381, "Apparizione e prima partenza rispettano posizione e ritmo.")
	game.simulation.cell = Vector2i(5, 2)
	for time: int in range(81):
		game.step()
	_check(chaser["moving"] and chaser["to"] == Vector2i(5, 2), "Il Segugio insegue la cella del giocatore.")
	for time: int in range(24):
		game.step()
	_check(game.state == Game.State.DYING and game.score.lives == 2, "Il contatto del Segugio sottrae una sola vita.")
	_check(not game.request_death(&"contact") and game.score.lives == 2, "Contatti ripetuti non sottraggono altre vite.")
	for time: int in range(90):
		game.step()
	_check(game.state == Game.State.PLAYING and game.world.actors.is_empty() and game.protection_ticks == 120, "Respawn rimuove il Segugio e ripristina la protezione contatti.")
	_check(game.world.first_chaser_spawned, "Il respawn non impone un secondo primo Segugio nello stesso round.")


func _test_spawn_caps_and_inbound_safety() -> void:
	_begin("phase3_spawn_caps_and_inbound_safety")
	var policy: Progression = Progression.new(Game.DEFAULT_MODES)
	var world: World = World.new()
	world.seed(3)
	world.reset_round(11, policy)
	world.stasis_enabled = false
	world.actors = [_actor(1, 1, Vector2i(2, 0)), _actor(2, 2, Vector2i(2, 1)),
		_actor(3, 2, Vector2i(2, 2)), _actor(4, 3, Vector2i(3, 1))]
	world.tick = 83
	var player: Dictionary = {"cell": Vector2i(1, 1), "tick": 0, "is_airborne": false}
	world.advance(player, player, true)
	world.depart_and_spawn(Vector2i(1, 1), false)
	_check(world.warning_kind == 0, "Al cap di inseguitori, laterali e sabotatori può essere scelta solo una Scoria.")
	var blocked: World = World.new()
	blocked.reset_round(0, policy)
	blocked.stasis_enabled = false
	blocked.tick = 299
	blocked.warning_kind = 0
	blocked.warning_cell = Vector2i.ZERO
	blocked.warning_until = 300
	var inbound: Dictionary = _actor(1, 1, Vector2i(1, 0))
	inbound.merge({"moving": true, "from": Vector2i(1, 0), "to": Vector2i.ZERO, "start": 290, "end": 314}, true)
	blocked.actors.append(inbound)
	blocked.advance(player, player, true)
	blocked.depart_and_spawn(Vector2i(1, 1), false)
	_check(blocked.actors.size() == 1 and blocked.warning_kind == 0, "Un avversario in arrivo rende l'apice non sicuro per lo spawn.")
	blocked.actors.clear()
	blocked.advance(player, player, true)
	blocked.depart_and_spawn(Vector2i(1, 1), true, Vector2i.ZERO)
	_check(blocked.actors.is_empty(), "Anche la destinazione del salto del giocatore impedisce l'apparizione.")


func _test_destinations() -> void:
	_begin("phase3_four_enemy_roles")
	var world: World = World.new()
	world.seed(7)
	var descent: Dictionary = _actor(1, 0, Vector2i(3, 1))
	for count: int in range(20):
		_check(world._destination(descent, Vector2i.ZERO) in [Vector2i(4, 1), Vector2i(4, 2)], "Scoria scende con scelte controllate dal seed.")
	var chaser: Dictionary = _actor(2, 1, Vector2i(3, 1))
	_check(world._destination(chaser, Vector2i(5, 2)) in [Vector2i(4, 1), Vector2i(4, 2)], "L'inseguitore riduce la distanza logica.")
	_check(world._destination(_actor(3, 2, Vector2i(5, 0)), Vector2i.ZERO) == Vector2i(4, 0), "Laterale sinistra risale il bordo.")
	_check(world._destination(_actor(4, 2, Vector2i(5, 5)), Vector2i.ZERO) == Vector2i(4, 4), "Laterale destra risale il bordo.")
	_check(world._destination(_actor(5, 3, Vector2i(4, 2)), Vector2i.ZERO) in [Vector2i(5, 2), Vector2i(5, 3)], "Sabotatore discende.")


func _test_collision_precedence() -> void:
	_begin("phase3_lethal_precedes_last_cell_and_collections")
	var game: Game = _game()
	var target: Vector2i = Vector2i(1, 1)
	for cell: Vector2i in game.simulation.board.cells():
		if cell != target:
			game.simulation.board.apply_landing(cell)
	game.world.actors.append(_actor(1, 0, target))
	game.world.actors.append(_actor(2, 3, target))
	game.world.actors.append(_actor(3, 1, target))
	game.world.stasis_available = true
	game.world.stasis_cell = target
	_jump(game, 3)
	_check(game.state == Game.State.DYING and game.score.lives == 2, "Contatti letali simultanei causano una sola morte.")
	_check(game.simulation.board.get_state(target) == 0 and game.score.points == 0, "La morte prevale su colore, raccolte, punti e fine round.")
	_check(not game.simulation.board.all_complete, "Ultima cella non completata dopo morte simultanea.")


func _test_crossings() -> void:
	_begin("phase3_crossings_unequal_jump_lengths")
	var game: Game = _game()
	game.simulation.reset(0, Vector2i(1, 0))
	var enemy: Dictionary = _actor(1, 0, Vector2i.ZERO)
	enemy.merge({"moving": true, "from": Vector2i.ZERO, "to": Vector2i(1, 0), "start": 0, "end": 24}, true)
	game.world.actors.append(enemy)
	game.step([{"type": "press", "direction": 1}])
	for time: int in range(14):
		game.step()
	_check(game.state == Game.State.DYING and game.simulation.is_airborne, "Salti opposti di 18 e 24 tick collidono fra due tick prima dell'atterraggio.")
	var other: Game = _game()
	other.simulation.reset(0, Vector2i(1, 0))
	var arc: Dictionary = _actor(1, 0, Vector2i(1, 1))
	arc.merge({"moving": true, "from": Vector2i(1, 1), "to": Vector2i(2, 1), "start": 0, "end": 24}, true)
	other.world.actors.append(arc)
	other.step([{"type": "press", "direction": 3}])
	for time: int in range(10):
		other.step()
	_check(other.state == Game.State.PLAYING, "Archi diversi non collidono per sovrapposizione grafica.")


func _test_saboteur() -> void:
	_begin("phase3_saboteur_collection_before_color_change")
	var game: Game = _game()
	game.simulation.reset(1, Vector2i(2, 1))
	var enemy: Dictionary = _actor(12, 3, Vector2i.ZERO)
	enemy.merge({"moving": true, "from": Vector2i.ZERO, "to": Vector2i(1, 1), "start": -5, "end": 19}, true)
	game.world.actors.append(enemy)
	_jump(game, 1)
	_check(game.state == Game.State.PLAYING and game.score.points == 315, "Sabotatore raccolto vale 300 più il colore intermedio 15.")
	_check(game.world.actors.is_empty() and game.simulation.board.get_state(Vector2i(1, 1)) == 1, "La raccolta precede il sabotaggio della stessa cella.")
	var other: Game = _game()
	other.simulation.reset(1)
	other.simulation.board.apply_landing(Vector2i(1, 1))
	other.simulation.board.apply_landing(Vector2i(1, 1))
	var sabotage: Dictionary = _actor(10, 3, Vector2i.ZERO)
	sabotage.merge({"moving": true, "from": Vector2i.ZERO, "to": Vector2i(1, 1), "start": -23, "end": 1}, true)
	other.world.actors.append(sabotage)
	other.simulation.cell = Vector2i(2, 0)
	other.step()
	_check(other.simulation.board.get_state(Vector2i(1, 1)) == 1, "Il sabotatore superstite arretra il colore di uno stato.")


func _test_simultaneous_sabotage_prevents_win() -> void:
	_begin("phase3_simultaneous_sabotage_prevents_round_completion")
	var game: Game = _game()
	var target: Vector2i = Vector2i(1, 1)
	var sabotaged: Vector2i = Vector2i(2, 1)
	for cell: Vector2i in game.simulation.board.cells():
		if cell != target:
			game.simulation.board.apply_landing(cell)
	var enemy: Dictionary = _actor(21, 3, Vector2i(1, 0))
	enemy.merge({"moving": true, "from": Vector2i(1, 0), "to": sabotaged, "start": -5, "end": 19}, true)
	game.world.actors.append(enemy)
	_jump(game, 3)
	_check(game.state == Game.State.PLAYING and game.simulation.board.get_state(target) == 1, "Ultimo atterraggio del giocatore colora la propria cella.")
	_check(game.simulation.board.get_state(sabotaged) == 0 and game.score.points == 25, "Il sabotaggio simultaneo impedisce vittoria e bonus ma conserva i punti dell'atterraggio.")


func _test_stasis() -> void:
	_begin("phase3_stasis_finishes_inflight_and_freezes_departures")
	var schedule: Game = _game()
	schedule.round_index = 2
	schedule._begin_round()
	schedule.world.stasis_enabled = true
	schedule.simulation.cell = Vector2i(6, 6)
	for time: int in range(719):
		schedule.step()
	_check(not schedule.world.stasis_available, "Stasi assente prima dei 720 tick attivi.")
	schedule.step()
	_check(schedule.world.stasis_available and schedule.world.stasis_spawned, "Stasi compare dopo 12 secondi attivi.")
	var game: Game = _game()
	game.world.stasis_available = true
	game.world.stasis_spawned = true
	game.world.stasis_cell = Vector2i(1, 0)
	var enemy: Dictionary = _actor(1, 0, Vector2i(5, 0))
	enemy.merge({"moving": true, "from": Vector2i(5, 0), "to": Vector2i(6, 0), "start": 0, "end": 24, "next": 25}, true)
	game.world.actors.append(enemy)
	_jump(game, 2)
	_check(game.world.stasis_remaining == 300 and game.score.points == 125, "Stasi raccolta per 100 punti e durata 300 tick.")
	for time: int in range(5):
		game.step()
	_check(not enemy["moving"] and enemy["cell"] == Vector2i(6, 0), "Il salto nemico già in corso termina durante Stasi.")
	game.set_paused(true)
	for time: int in range(40):
		game.step()
	_check(game.world.stasis_remaining == 295, "La pausa congela anche Stasi.")
	game.set_paused(false)
	for time: int in range(294):
		game.step()
	_check(not enemy["moving"] and game.world.stasis_remaining == 1, "Nuove partenze bloccate fino alla scadenza.")
	game.step()
	_check(game.world.stasis_remaining == 0 and enemy["moving"], "Le partenze riprendono alla scadenza.")


func _test_stasis_contact_protection() -> void:
	_begin("phase3_stasis_collected_all_hostile_contacts_safe")
	for kind: int in [0, 1, 2]:
		var game: Game = _game()
		game.world.stasis_available = true
		game.world.stasis_spawned = true
		game.world.stasis_cell = Vector2i(1, 0)
		_jump(game, 2)
		_check(game.world.stasis_remaining == 300 and game.score.points == 125, "Raccolta reale attiva Stasi e premio unico.")
		game.step()
		game.step()
		var enemy: Dictionary = _actor(50, kind, Vector2i(2, 1))
		game.world.actors.append(enemy)
		_jump(game, 3)
		_check(game.simulation.cell == Vector2i(2, 1) and game.state == Game.State.PLAYING and game.score.lives == 3, "Atterraggio su ogni famiglia letale innocuo durante Stasi.")
		_check(game.world.actors.has(enemy) and game.score.points == 150, "Il contatto protetto non consuma il nemico né assegna punti extra.")
		_check(not game.request_death(&"contact"), "Anche il contratto di morte rifiuta contatti durante energia.")
		game.step()
		game.step()
		_jump(game, 0)
		_check(game.simulation.cell == Vector2i(1, 0) and game.state == Game.State.PLAYING and game.score.points == 150, "Si può lasciare il nemico; rivisitare Stasi non duplica il premio.")


func _test_stasis_crossing_and_fall() -> void:
	_begin("phase3_stasis_protects_crossings_not_falls")
	var game: Game = _game()
	game.world.stasis_remaining = 60
	game.simulation.reset(0, Vector2i(1, 0))
	var enemy: Dictionary = _actor(1, 1, Vector2i.ZERO)
	enemy.merge({"moving": true, "from": Vector2i.ZERO, "to": Vector2i(1, 0), "start": 0, "end": 24}, true)
	game.world.actors.append(enemy)
	_jump(game, 1)
	_check(game.state == Game.State.PLAYING and game.simulation.cell == Vector2i.ZERO and game.score.lives == 3, "Incrocio con serpente già in volo innocuo durante Stasi.")
	var fall: Game = _game()
	fall.world.stasis_remaining = 60
	_jump(fall, 0)
	_check(fall.state == Game.State.DYING and fall.score.lives == 2 and fall.world.stasis_remaining == 0, "Caduta reale letale anche durante energia, che viene annullata.")


func _test_stasis_expiry_and_reset() -> void:
	_begin("phase3_stasis_exact_expiry_pause_and_independent_protection")
	var game: Game = _game()
	game.world.stasis_remaining = 2
	game.world.actors.append(_actor(1, 0, Vector2i.ZERO))
	game.world.actors.append(_actor(2, 1, Vector2i.ZERO))
	game.set_paused(true)
	var snapshot: Dictionary = game.snapshot()
	for index: int in range(40):
		game.step()
	_check(game.snapshot() == snapshot, "Pausa congela energia e contatti condivisi.")
	game.set_paused(false)
	game.step()
	_check(game.world.stasis_remaining == 1 and game.state == Game.State.PLAYING, "Ultimo tick di energia protegge tutte le sovrapposizioni.")
	game.step()
	_check(game.world.stasis_remaining == 0 and game.state == Game.State.DYING and game.score.lives == 2, "Allo zero i contatti tornano letali con una sola vita persa.")
	_check(not game.request_death(&"contact") and game.score.lives == 2, "Nessuna morte duplicata dopo la scadenza.")
	for index: int in range(90):
		game.step()
	_check(game.protection_ticks == 120 and game.world.stasis_remaining == 0 and game.world.actors.is_empty(), "Respawn non ripristina energia e conserva protezione propria.")
	var protected: Game = _game()
	protected.world.stasis_remaining = 1
	protected.protection_ticks = 3
	protected.world.actors.append(_actor(1, 2, Vector2i.ZERO))
	protected.step()
	_check(protected.world.stasis_remaining == 0 and protected.protection_ticks == 2 and protected.state == Game.State.PLAYING, "Scadenza Stasi non azzera la protezione indipendente del respawn.")
	protected.world.stasis_remaining = 150
	protected.start_new_game()
	_check(protected.world.stasis_remaining == 0 and protected.score.lives == 3, "Nuova partita elimina energia residua.")
	protected.world.stasis_remaining = 150
	protected._begin_round()
	_check(protected.world.stasis_remaining == 0, "Anche il cambio round azzera l'energia.")


func _test_spider_round_three_spawns() -> void:
	_begin("phase3_spiders_available_in_third_round_normal_scheduler")
	var seen_left: bool = false
	var seen_right: bool = false
	for seed_value: int in range(16):
		var game: Game = Game.new()
		game.round_index = 2
		game._begin_round()
		game.world.seed(seed_value)
		game.world.stasis_enabled = false
		game.simulation.cell = Vector2i(2, 1)
		game.protection_ticks = 3000
		for time: int in range(760):
			game.step()
			for actor: Dictionary in game.world.actors:
				if actor["kind"] == 2:
					seen_left = seen_left or actor["cell"].y == 0
					seen_right = seen_right or actor["cell"].y == actor["cell"].x
	_check(seen_left and seen_right, "Il vero scheduler della partita può far apparire ragnetti su entrambi i bordi nel round 1/3.")
	for round_index: int in [0, 1]:
		var world: World = World.new()
		world.reset_round(round_index, Progression.new(Game.DEFAULT_MODES))
		world.first_chaser_spawned = true
		world.tick = 500
		for attempt: int in range(32):
			world.warning_kind = -1
			world.depart_and_spawn(Vector2i(2, 1), false)
			_check(world.warning_kind != 2, "Nessun ragnetto ammesso nei primi due round.")
	var world: World = World.new()
	world.reset_round(2, Progression.new(Game.DEFAULT_MODES))
	world.seed(3)
	world.tick = 468
	world.first_chaser_spawned = true
	# Retain existing first-chaser policy, caps and random selection.
	world.actors = [_actor(1, 1, Vector2i(2, 1))]
	world.next_spawn = 504
	# Selection itself is seeded; a warning must always last the full 36 ticks.
	for attempt: int in range(50):
		world.warning_kind = -1
		world.depart_and_spawn(Vector2i(1, 0), false)
		if world.warning_kind == 2:
			break
	_check(world.warning_kind == 2 and world.warning_until == 504, "Preavviso ragnetto di 36 tick, usando l'intervallo esistente del round.")
	world.tick = 503
	world.depart_and_spawn(Vector2i(1, 0), false)
	_check(world.actors.size() == 1, "Nessuna apparizione anticipata.")
	world.tick = 504
	world.depart_and_spawn(world.warning_cell, false)
	_check(world.actors.size() == 1, "Ragnetto rinviato se il bordo è occupato dal giocatore.")
	world.depart_and_spawn(Vector2i(1, 0), false)
	_check(world.actors.size() == 2 and world.actors[1]["kind"] == 2, "Apparizione appena il bordo torna sicuro.")


func _test_gottlieb_character_schedule() -> void:
	_begin("phase3_gottlieb_all_character_warnings_spawns_and_green_schedule")
	# Independent transcription of the manual's character names for levels I-IV.
	# R=red, C=Coily, U=Ugg/Wrong-Way, S=Slick/Sam, G=green ball.
	var expected: Array[String] = [
		"RC", "RC", "CUSG", "RCSG",
		"CUSG", "CUSG", "RCSG", "RCUSG",
		"RCSG", "CUSG", "RCUSG", "RCUSG",
		"RCSG", "RCUSG", "RCUSG", "RCUSG",
	]
	var symbols: Array[String] = ["R", "C", "U", "S", "G"]
	var policy: Progression = Progression.new(Game.DEFAULT_MODES)
	var indices: Array[int] = []
	for index: int in range(36):
		indices.append(index)
	for index: int in [400, 401, 402, 403, 400000, 400001, 400002, 400003]:
		indices.append(index)
	for index: int in indices:
		var roster: String = expected[index] if index < expected.size() else "RCUSG"
		var seen: Array[bool] = [false, false, false, false]
		for seed_value: int in range(48):
			var world: World = World.new()
			world.reset_round(index, policy)
			world.seed(seed_value)
			world.first_chaser_spawned = true
			world.stasis_enabled = false
			world.tick = world.next_spawn - World.WARNING
			world.depart_and_spawn(Vector2i(1, 0), false)
			var selected: int = world.warning_kind
			_check(selected >= 0 and selected < 4, "Sempre un candidato disponibile nel round %d." % index)
			if selected < 0 or selected > 3:
				continue
			_check(roster.contains(symbols[selected]), "Preavviso conforme alla tabella Gottlieb nel round %d." % index)
			world.tick = world.warning_until
			world.depart_and_spawn(Vector2i(1, 0), false)
			_check(world.actors.size() == 1 and world.actors[0]["kind"] == selected, "Il tipo ammesso compare effettivamente dopo il preavviso.")
			for actor: Dictionary in world.actors:
				_check(roster.contains(symbols[int(actor["kind"])]), "Nessun personaggio vietato appare nel round %d." % index)
				seen[int(actor["kind"])] = true
		for kind: int in range(4):
			_check(seen[kind] == roster.contains(symbols[kind]), "Tutti e soli i ruoli previsti possono apparire: round %d, ruolo %s." % [index, symbols[kind]])
		var green: Game = _game()
		green.round_index = index
		green._begin_round()
		green.world.stasis_enabled = true
		green.simulation.cell = Vector2i(6, 6)
		green.world.tick = 718
		green.step()
		_check(not green.world.stasis_available and not green.world.stasis_spawned, "Sfera verde assente prima del tick 720.")
		green.step()
		_check(green.world.stasis_available == roster.contains("G") and green.world.stasis_spawned == roster.contains("G"), "Sfera verde compare solo nei round documentati, al tick previsto.")
		green.step()
		_check(green.world.stasis_available == roster.contains("G"), "Nessuna comparsa tardiva della sfera verde in un round vietato.")


func _test_gottlieb_runtime_and_respawn() -> void:
	_begin("phase3_gottlieb_live_game_and_post_death_roster")
	# Document oracle for the first four levels, independent of the world's mask.
	var expected: Array[String] = ["RC", "RC", "CUSG", "RCSG", "CUSG", "CUSG", "RCSG", "RCUSG", "RCSG", "CUSG", "RCUSG", "RCUSG", "RCSG", "RCUSG", "RCUSG", "RCUSG"]
	var symbols: Array[String] = ["R", "C", "U", "S"]
	for index: int in range(20):
		var allowed: String = expected[index] if index < 16 else "RCUSG"
		var game: Game = Game.new()
		game.round_index = index
		game._begin_round()
		game.world.seed(11)
		game.simulation.cell = Vector2i(2, 1)
		# Observe normal scheduling without contacts ending the observation.
		game.protection_ticks = 5000
		for tick: int in range(1000):
			game.step()
			if game.world.warning_kind >= 0:
				_check(allowed.contains(symbols[game.world.warning_kind]), "Partita effettiva: nessun preavviso vietato.")
			for actor: Dictionary in game.world.actors:
				_check(allowed.contains(symbols[int(actor["kind"])]), "Partita effettiva: tutti gli attori rispettano il round.")
		_check(game.world.stasis_spawned == allowed.contains("G"), "Partita effettiva: sfera verde comparsa secondo Gottlieb, anche se già raccolta o caduta.")
		game.protection_ticks = 0
		game.world.stasis_remaining = 0
		_check(game.request_death(&"contact"), "Morte amministrata per verificare la ripresa dello scheduler.")
		for tick: int in range(90):
			game.step()
		game.protection_ticks = 5000
		for tick: int in range(150):
			game.step()
			if game.world.warning_kind >= 0:
				_check(allowed.contains(symbols[game.world.warning_kind]), "Anche dopo morte/respawn il preavviso rispetta il calendario.")
			for actor: Dictionary in game.world.actors:
				_check(allowed.contains(symbols[int(actor["kind"])]), "Il respawn non riabilita famiglie escluse.")


func _test_spider_round_transition_clears_state() -> void:
	_begin("phase3_spider_round_boundaries_no_actor_or_warning_leak")
	for index: int in range(36):
		var game: Game = Game.new()
		game.round_index = index
		game._begin_round()
		game.world.stasis_enabled = false
		var kind: int = 2 if game.world.is_character_available(2) else 1
		game.world.actors.append(_actor(90, kind, Vector2i(6, 0)))
		game.world.warning_kind = kind
		game.world.stasis_available = game.world.is_character_available(4)
		game.world.stasis_spawned = game.world.stasis_available
		game.world.stasis_remaining = 20 if game.world.stasis_available else 0
		game.world.warning_until = 99999
		for cell: Vector2i in game.simulation.board.cells():
			while not game.simulation.board.is_target(cell):
				game.simulation.board.apply_landing(cell)
		game.step()
		_check(game.state == Game.State.ROUND_END, "Il round si conclude con lo stato avversari ancora presente.")
		for tick: int in range(Game.ROUND_END_TICKS):
			game.step()
		_check(game.round_index == index + 1 and game.world.round_index == index + 1, "Transizione effettiva fra round e livelli.")
		_check(game.world.actors.is_empty() and game.world.warning_kind == -1 and not game.world.stasis_available and not game.world.stasis_spawned and game.world.stasis_remaining == 0, "Nessun attore, preavviso o Stasi ereditato dal round precedente.")
		game.world.seed(3)
		game.world.first_chaser_spawned = true
		game.world.tick = game.world.next_spawn - World.WARNING
		game.world.depart_and_spawn(Vector2i.ZERO, false)
		_check(game.world.is_character_available(game.world.warning_kind), "Il calendario del nuovo round si applica subito alla selezione.")


func _test_spider_contacts_and_discs() -> void:
	_begin("phase3_spiders_side_routes_lethal_respawn_and_disc")
	for side: int in range(2):
		var origin: Vector2i = Vector2i(5, 0) if side == 0 else Vector2i(5, 5)
		var target: Vector2i = Vector2i(4, 0) if side == 0 else Vector2i(4, 4)
		var game: Game = _game()
		game.simulation.cell = target
		var spider: Dictionary = _actor(1, 2, origin)
		spider["next"] = 1
		game.world.actors.append(spider)
		game.step()
		_check(spider["moving"] and spider["to"] == target, "Ragnetto risale il rispettivo bordo.")
		_check(game.world._destination(_actor(2, 2, origin), Vector2i.ZERO) == game.world._destination(_actor(2, 2, origin), Vector2i(6, 3)), "La rotta laterale non insegue il giocatore, come descritto nel manuale.")
		game.set_paused(true)
		var before: Dictionary = game.snapshot()
		game.step()
		_check(game.snapshot() == before, "Pausa congela il salto del ragnetto.")
		game.set_paused(false)
		for index: int in range(24):
			game.step()
		_check(game.state == Game.State.DYING and game.score.lives == 2, "Atterraggio ragnetto letale una sola volta.")
		for index: int in range(90):
			game.step()
		_check(game.state == Game.State.PLAYING and game.world.actors.is_empty() and game.protection_ticks == 120, "Respawn ripulisce ragnetti e protegge il giocatore.")
		var rescue: Game = _game()
		var edge: Vector2i = Vector2i(3, 0) if side == 0 else Vector2i(5, 5)
		rescue.simulation.reset(0, edge)
		rescue.world.stasis_remaining = 150
		var lateral: Dictionary = _actor(3, 2, edge)
		lateral["next"] = 1
		rescue.world.actors.append(lateral)
		rescue.step([{"type": "press", "direction": side}])
		_check(rescue.rescue_remaining == 72 and not rescue.platforms[side], "Stasi consente l'uscita sul disco anche con un ragnetto sulla cella.")
		for index: int in range(72):
			rescue.step()
		_check(rescue.simulation.cell == Vector2i.ZERO and rescue.score.lives == 3 and rescue.score.points == 0, "Disco completa il viaggio senza premio Segugio per il ragnetto.")
		_check(rescue.world.actors.has(lateral) and not lateral["moving"] and rescue.world.stasis_remaining == 77, "Stasi ferma ragnetto durante il viaggio e mantiene il timer esistente.")


func _test_platforms() -> void:
	_begin("phase3_platform_consumption_protection_and_return")
	var game: Game = _game()
	game.simulation.reset(0, Vector2i(3, 0))
	game.step([{"type": "press", "direction": 0}])
	_check(not game.platforms[0] and game.rescue_remaining == 72 and game.score.lives == 3, "Piattaforma sinistra consumata una volta al decollo.")
	game.set_paused(true)
	for time: int in range(10):
		game.step()
	_check(game.rescue_remaining == 72, "Viaggio di salvataggio fermo in pausa.")
	game.set_paused(false)
	for time: int in range(72):
		game.step()
	_check(game.rescue_remaining == 0 and game.simulation.cell == Vector2i.ZERO and game.simulation.board.get_state(Vector2i.ZERO) == 0, "Ritorno all'apice dopo 72 tick senza colorare.")
	game.simulation.reset(0, Vector2i(3, 0))
	_jump(game, 0)
	_check(game.state == Game.State.DYING and game.score.lives == 2, "Uscita ripetuta senza piattaforma produce caduta.")
	var fatal: Game = _game()
	fatal.simulation.reset(0, Vector2i(3, 0))
	fatal.world.actors.append(_actor(1, 0, Vector2i(3, 0)))
	var events: Array[Dictionary] = fatal.step([{"type": "press", "direction": 0}])
	_check(fatal.state == Game.State.DYING and fatal.platforms[0], "La collisione precede la partenza della piattaforma.")
	_check(events.is_empty() and not fatal.simulation.is_airborne, "La collisione simultanea impedisce anche l'emissione di una partenza.")
	var arrival: Game = _game()
	arrival.simulation.reset(0, Vector2i(3, 1))
	var incoming: Dictionary = _actor(7, 0, Vector2i(4, 1))
	incoming.merge({"moving": true, "from": Vector2i(4, 1), "to": Vector2i(3, 1), "start": -23, "end": 1}, true)
	arrival.world.actors.append(incoming)
	var emitted: Array[Dictionary] = arrival.step([{"type": "press", "direction": 3}])
	_check(arrival.state == Game.State.DYING and emitted.is_empty() and not arrival.simulation.is_airborne, "Atterraggio avversario simultaneo prevale su una nuova partenza.")


func _test_lure_and_fall_priority() -> void:
	_begin("phase3_lured_chaser_and_fall_priority")
	var game: Game = _game()
	game.simulation.reset(0, Vector2i(3, 0))
	game.protection_ticks = 10
	var chaser: Dictionary = _actor(1, 1, Vector2i(3, 0))
	chaser["next"] = 1
	game.world.actors.append(chaser)
	game.world.actors.append(_actor(2, 0, Vector2i(6, 0)))
	game.step([{"type": "press", "direction": 0}])
	_check(game.rescue_remaining == 72 and chaser.get("lured", false), "L'inseguitore sul bordo segue il salvataggio fuori dalla piramide.")
	for time: int in range(24):
		game.step()
	_check(game.score.points == 500 and game.world.actors.is_empty(), "Inseguitore attirato fuori: 500 punti unici e rimozione avversari.")
	for time: int in range(50):
		game.step()
	_check(game.score.points == 500 and game.simulation.cell == Vector2i.ZERO, "Il premio non viene duplicato al ritorno.")
	var chase: Game = _game()
	chase.simulation.reset(0, Vector2i(3, 0))
	var in_flight: Dictionary = _actor(8, 1, Vector2i(4, 0))
	in_flight.merge({"moving": true, "from": Vector2i(4, 0), "to": Vector2i(3, 0), "start": -20, "end": 4, "next": 58}, true)
	chase.world.actors.append(in_flight)
	chase.step([{"type": "press", "direction": 0}])
	for time: int in range(71):
		chase.step()
	_check(chase.rescue_remaining == 1 and in_flight.get("lured", false), "Un inseguitore già in volo viene attirato durante il viaggio senza protezione precedente.")
	for time: int in range(11):
		chase.step()
	_check(chase.rescue_remaining == 0 and chase.score.points == 500, "Il premio resta valido quando la caduta dell'inseguitore termina dopo il ritorno.")
	var fall: Game = _game()
	fall.step([{"type": "press", "direction": 0}])
	fall.world.actors.append(_actor(4, 3, Vector2i.ZERO))
	fall.world.stasis_available = true
	fall.world.stasis_cell = Vector2i.ZERO
	for time: int in range(18):
		fall.step()
	_check(fall.state == Game.State.DYING and fall.score.points == 0, "Caduta terminale precede raccolte apparenti nella cella di partenza.")
	var before: int = fall.active_ticks
	for time: int in range(50):
		fall.step()
	_check(fall.active_ticks == before, "Il tempo attivo resta fermo durante l'attesa della morte.")


func _test_rescue_occupancy() -> void:
	_begin("phase3_rescue_does_not_collect_from_departure_cell")
	var game: Game = _game()
	game.simulation.reset(0, Vector2i(3, 0))
	game.step([{"type": "press", "direction": 0}])
	game.world.actors.append(_actor(4, 3, Vector2i(3, 0)))
	game.world.stasis_available = true
	game.world.stasis_cell = Vector2i(3, 0)
	game.step()
	_check(game.score.points == 0 and game.world.actors.size() == 1 and game.world.stasis_available, "In viaggio non si raccolgono oggetti rimasti sulla cella di partenza.")
	var endpoint: Game = _game()
	endpoint.simulation.reset(0, Vector2i(3, 0))
	endpoint.step([{"type": "press", "direction": 0}])
	endpoint.world.actors.append(_actor(1, 0, Vector2i.ZERO))
	endpoint.rescue_remaining = 1
	endpoint.step()
	_check(endpoint.state == Game.State.DYING and endpoint.score.lives == 2, "Al termine del salvataggio la collisione all'apice precede nuove azioni.")


func _game() -> Game:
	var game: Game = Game.new()
	game.world.spawning_enabled = false
	game.world.stasis_enabled = false
	return game


func _actor(id: int, kind: int, cell: Vector2i) -> Dictionary:
	return {"id": id, "kind": kind, "cell": cell, "from": cell, "to": cell,
		"moving": false, "start": 0, "end": 0, "next": 99999}


func _jump(game: Game, direction: int) -> void:
	game.step([{"type": "press", "direction": direction}])
	game.step([{"type": "release", "direction": direction}])
	for time: int in range(17):
		game.step()


func _begin(name: String) -> void:
	_runner.call("_begin_test", name)


func _check(value: bool, message: String) -> void:
	_runner.call("_check", value, message)
