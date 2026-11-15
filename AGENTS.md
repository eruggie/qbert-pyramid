# Q*Bert Pyramid development

Godot 4.7.2 standard, GDScript, 2D Compatibility renderer. Windows 11 x86_64 is
the release target; Ubuntu 22.04 / WSL2 is the verified build environment.
No coding assistant or cloud service is required.

Keep rules, input adapters and presentation independent. Fixed controls are
Q/Left, E/Up, Z/Down, C/Right and keypad 7/9/1/3; preserve source equivalence,
mixed buffers and separation of UI navigation from gameplay. Use seeded RNG
for reproducible tests. Save player data under user:// and isolate test profiles.
Preserve .uid and resource import descriptors; do not commit .godot, secrets,
reference media, player saves or generated packages. GPL-3.0-only applies to
original code/assets; keep dependency notices and verify every new asset.

Use bash tools/doctor.sh, tools/test.sh, tools/smoke_linux.sh and tools/build_windows.sh.
The build already runs doctor and the full suite. Failure and empty-suite modes
must return nonzero. Export/WSLg checks are not manual Windows tests. Document
actual test environment, source identity, outcomes and limits. Do not change
approved gameplay merely to satisfy a test. Public releases require an exact
source tag, corresponding sources, provenance and SHA-256 files.


## Web scope

Web classic 1.2 is isolated from public v1.1.0. Run bash tools/build_web.sh. Preserve Windows release tags/assets, input mappings, hold/release and gameplay. Android, smartphones, mobile layout and touch are excluded from current and future releases. Escher is outside this port. Public upload/release/deployment requires explicit user acceptance of the tested candidate. See docs/WEB_PORT.md.


## Release review gate

Test funzionali rc.2 approvati dall’utente. Autorizzate preparazione locale della
nuova home arcade, pacchetti runtime/completo e documentazione rc.3.
Nuova approvazione necessaria per completare la release stabile, creare tag
finali, effettuare push, pubblicare release/repository/sito o scegliere/attivare
l’hosting del backend. Nessuna modifica al gameplay. Vedere RELEASE.md.
