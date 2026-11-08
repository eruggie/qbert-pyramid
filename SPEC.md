# Q*Bert Pyramid 1.0.0 — implemented behavior

Independent isometric arcade game, Godot standard 4.7.2, Compatibility renderer,
Windows 11 x86_64. GPL-3.0-only for original code and assets.

The board has 28 tiles in seven rows, four diagonal moves and one result per
jump. Fixed Q/Left, E/Up, Z/Down, C/Right and keypad 7/9/1/3 coexist with optional
extra bindings. Semantic input, deterministic rules and presentation are separate.
Color rules are permanent, two-step and reversible. Four rounds per level,
twelve configured opening rounds, then continuous progression with bounded
spawn intervals/caps. Opponents follow the implemented Gottlieb-derived calendar.

Four opponent roles, consumable rescue discs and the moving green pickup interact
with logical collisions and one life lost per lethal episode. Three initial
lives; extras at 8000 then every 14000 points, capped at five. Respawn, pause,
focus loss, simultaneous interactions, score deduplication and transition
precedence are tested. Contact protection does not prevent falling.

The public menu offers game, About/instructions, settings, scores, presentation
and exit. The technical lab is hidden by default. GAME OVER follows the terminal
death, blinks and lasts 30 seconds with focus or until a fresh game key/Enter.
Every Game Over reaches results. The top ten stores exactly three-letter initials,
score, level and round, with supported profile migrations, backup and I/O recovery.
Original event effects have volume/mute and stop correctly on pause/scene/restart;
there is no continuous music. The application icon derives from the player sprite.

See tests/ for precise rule/timing regressions, data/initial_rounds.tres for the
configured progression, PLAYER_GUIDE for play and docs/VALIDATION.md for evidence.
No web/Android port, multiplayer or interrupted-game save is implemented.
