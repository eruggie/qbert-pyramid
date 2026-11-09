# Build from source

## Toolchain

Verified route: Windows host, Ubuntu 22.04 x86_64 under WSL2, Bash >=5.1,
Python >=3.10 (standard library), Git >=2.34, zip/unzip, coreutils and Godot
**4.7.2 standard**, exact `4.7.2.stable.official.ed1daf0bf`, with matching
Windows x86_64 export templates. Hashes are recorded in `tools/toolchain.json`.
Set `GODOT_BIN` and `GODOT_TEMPLATE_DIR` if they are outside standard locations.
No C# SDK, assistant account or cloud service is required.

The Windows build additionally requires **NSIS 3.08** `makensis`. Use a system
compiler or set `MAKENSIS_BIN=/absolute/path/to/makensis`. A portable extraction
can use `NSISDIR=/absolute/path/to/usr/share/nsis`. No script installs software
or changes global configuration. NSIS documentation: https://nsis.sourceforge.io/Docs/.
The local review uses Ubuntu packages `nsis` / `nsis-common` 3.08-2, extracted
under `.local-state/nsis-toolchain/`, not installed globally.

## Obtain sources

For the published version, clone https://github.com/eruggie/qbert-pyramid and
checkout its exact release tag, using `git checkout --detach v1.1.0`. The release source asset contains the
matching complete source snapshot. Rebuild using the recorded toolchain:

```bash
cd source
sha256sum -c ../SOURCE_FILES.sha256
git init
git add .
git -c user.name='Local builder' -c user.email='builder@example.invalid' commit -m 'Import reviewed source snapshot'
```

The source ZIP is a standalone snapshot containing the complete current project,
It contains the exact public release files and their clean public history; it
contains no private development history, profiles or caches. `PROVENANCE.json` records the base commit and
snapshot digest; it does not imply that the private base commit is public.
The initialization above is for an independent recipient rebuilding an extracted
snapshot. It is not an instruction to commit the pending development release.
Public source changes must preserve the separate clean public lineage.

## Test and export

```bash
bash tools/doctor.sh
bash tools/test.sh
bash tools/smoke_linux.sh
bash tools/build_windows.sh
```

The build runs doctor and the complete suite, exports EXE/PCK, loads isolated
PCK scenes and audiovisual resources, creates an installer and verifies CRCs,
checksums and the source snapshot. It fails on errors, empty test suites or source
changes during export. `--self-test-empty` / `--self-test-failure` are negative
runner modes and must exit nonzero. Scripts resolve paths independently of cwd.

Outputs are under `builds/<build-id>/`: `runtime/`, Windows portable ZIP,
`*-Setup.exe`, separate `QBertPyramid-source.zip` and `SHA256SUMS.txt`.
`BUILD_INFO.json` records engine/templates, base commit, dirty state and source
identity. Snapshot equality is checked; timestamped binaries need not be byte-identical.
Tests, cache and logs are isolated under `.local-state/`. Generated binaries and
private state remain ignored. WSLg/export success is not Windows manual acceptance.

The installer script is `tools/windows_installer.nsi`. It uses an explicit payload
allowlist, current-user registry/shortcuts and explicit uninstall deletions, and
preserves player data. It bundles no sources or build tools. Publish matching
source and binary downloads together only after owner approval, signing decisions,
asset-rights review and Windows acceptance. No automatic publication is implemented.
