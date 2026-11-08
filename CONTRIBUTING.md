# Contributing

Use https://github.com/eruggie/qbert-pyramid/issues and the supplied issue/PR templates.
Describe a reproducible defect, expected behavior, exact build/checksum, environment
and test evidence. For a feature proposal, explain the need before implementing it.
Do not assume approval for gameplay changes, ports or publication automation.

Follow [BUILD_FROM_SOURCE](docs/BUILD_FROM_SOURCE.md). Work in a dedicated branch
once contributing to a published repository; no assistant or cloud account is
needed to edit, run or test the source. Keep rule logic separate from presentation
and input; preserve all fixed movement bindings and deterministic seeds.

Run relevant tests and the complete suite before a release. Use WSLg for layout
checks and Windows for real EXE testing. Never describe automated/headless work
as manual Windows validation. Keep test data under .local-state/.

Contributions must be compatible with GPL-3.0-only, preserve notices and identify
the origin/license of every added asset. No contributor agreement or transfer of
copyright is introduced here. Do not submit ROMs, reference recordings, credentials,
personal profiles or proprietary assets. Read SECURITY.md before reporting a
security-sensitive issue. There is no guaranteed review or response time.
