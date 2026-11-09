# Release history and process

## Current release — 1.1.0 (2026-11-09)

The public release is tagged `v1.1.0` in
https://github.com/eruggie/qbert-pyramid/releases/tag/v1.1.0.
It follows the public `v1.0.0` source history. Download assets include the NSIS
installer, portable Windows ZIP, corresponding sources, build information and
checksums. The owner reports manual Windows testing passed; automated results
and platform limits are in [docs/releases/v1.1.0.md](releases/v1.1.0.md).

## Previous release — 1.0.0 (2026-11-08)

First public snapshot: tag `v1.0.0`, commit
`45c3b22c2b7a54e5f6afa729ea7535aad384a23b`. Its Windows ZIP, corresponding
source ZIP, build metadata and checksum assets remain available at the tag.
See [the 1.0.0 release notes](releases/v1.0.0.md).

## Rebuilding and future releases

Use `docs/BUILD_FROM_SOURCE.md` with the exact public tag and recorded toolchain.
For a new release, update the application and package versions together, run
`tools/doctor.sh`, `tools/test.sh`, `tools/smoke_linux.sh` and
`tools/build_windows.sh`, then inspect the corresponding source snapshot,
installer payload, notices and checksums. Create a release tag only on the exact
clean tested public commit. Attach the installer, portable ZIP, source archive,
BUILD_INFO, SOURCE_FILES manifest and checksums as separate GitHub Release
assets. Verify the published download checksums after upload.

Do not publish development history, private archives, reference media or player
saves in the public source repository. Keep original releases immutable; publish
updates under a new version tag.
