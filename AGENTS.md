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


## Web 1.2.0 release authorization

Owner tested and accepted the latest candidate, personal home and packages on
2026-11-16, and explicitly authorized final version, documentation freeze,
release commit/tag, GitHub release and GitHub Pages publication. That approval
supersedes the previous RC review gate; do not ask for it again.
Keep public Windows v1.1.0 tags/assets unchanged. Publish exact corresponding
sources and checksums. Backend deployment requires an actual authenticated
host with persistent storage; do not invent a URL, expose credentials, activate
billing or silently replace server scores with local browser scores.
The tagged Markdown documents are frozen; operational deployment status may
be recorded separately in the site repository. See RELEASE.md.

## Web 1.2.1 authorization

On 2026-11-17 the owner explicitly approved both tested leaderboard fixes,
the requested game page text/control/license changes, release commit and
publication/deployment of Web 1.2.1. Preserve Web 1.2.0 and Windows 1.1.0
tags/assets, the existing production database and personal homepage design.
The incident reports describe the earlier proposal phase; this approval
supersedes their pending approval gate for these exact changes.
