# Releasing

## Availability

Version 1.0.0: https://github.com/eruggie/qbert-pyramid/releases/tag/v1.0.0
Source: https://github.com/eruggie/qbert-pyramid
Catalog: https://github.com/eruggie/80-arcade-games

The public repository starts with the current reviewed source snapshot only.
No earlier private history or historical reference material is published.

## Procedure

Review changes, licenses, asset provenance, privacy and actual Windows evidence.
Commit the final source using a private/noreply identity, create its release tag,
and run bash tools/build_windows.sh from that exact clean revision. The pipeline
already runs doctor and all tests, then export/PCK/archive/source checks.
Use tools/smoke_linux.sh for relevant graphics checks and Windows for EXE checks.

Attach Windows ZIP, corresponding-source ZIP, their SHA-256 files, BUILD_INFO
and SOURCE_FILES manifest to the release. Keep binaries out of normal Git history.
GitHub automatic source archives do not replace the playable Windows package.
Download public assets, verify them, extract/run on Windows without external
Godot/development tools, and rebuild a clean checkout of the public tag using
BUILD_FROM_SOURCE.md. Record exact outcomes and limits honestly. Rebuildability
does not promise timestamped files will be identical bit for bit.
