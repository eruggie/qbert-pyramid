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
