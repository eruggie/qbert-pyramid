#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

[[ $# -eq 0 ]] || ap_fail 'Uso: bash tools/build_windows.sh'
ap_require_commands bash python3 git zip unzip timeout sha256sum mktemp realpath cp mv mkdir ln
# Fail before export if there is no reviewable source revision.
git -C "$AP_ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || ap_fail 'Repository senza commit: creare un commit locale prima della build.'
bash "$AP_ROOT/tools/doctor.sh"
bash "$AP_ROOT/tools/test.sh"
ap_select_engine
ap_timeout 180
ap_prepare_state build
mkdir -p -- "$AP_STATE/data/godot/export_templates"
ln -s -- "$AP_TEMPLATES" "$AP_STATE/data/godot/export_templates/$AP_TEMPLATE_VERSION"
package="$AP_STATE/package"
mkdir -p -- "$package/docs"
for relative_path in README.md SPEC.md PLAN.md TEST.md TESTS.md THIRD_PARTY_NOTICES.txt CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md CITATION.cff docs/INSTALL_WINDOWS.md docs/BUILD_FROM_SOURCE.md docs/RELEASING.md docs/RELEASE_CHECKLIST.md docs/LICENSING.md docs/VALIDATION.md docs/PUBLICATION_AUDIT.md docs/PHASE7.md docs/releases/v1.0.0.md docs/screenshots/gameplay.png docs/screenshots/README.md docs/ACCEPTANCE_PHASE6.md docs/TESTING.md docs/PLAYER_GUIDE.md docs/REBUILD.md docs/REFERENCE.md docs/ASSET_LICENSES.md docs/ASSET_CATALOG.md docs/ARCADE_REVIEW.md docs/THIRD_PARTY_NOTICES.txt; do
	[[ -s "$AP_ROOT/$relative_path" ]] || ap_fail "Documento richiesto mancante o vuoto: $relative_path"
	mkdir -p -- "$package/$(dirname -- "$relative_path")"
	cp -- "$AP_ROOT/$relative_path" "$package/$relative_path"
done
if [[ -f "$AP_ROOT/LICENSE" ]]; then
	cp -- "$AP_ROOT/LICENSE" "$package/LICENSE"
fi
revision="$(python3 "$AP_ROOT/tools/verify_results.py" build-info "$AP_ROOT" "$package" "$AP_TOOLCHAIN" "$AP_GODOT" "$AP_TEMPLATES" "$AP_VERSION")"
phase="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["phase"])' "$AP_TOOLCHAIN")"
[[ "$phase" =~ ^[0-9]+$ ]] || ap_fail 'Fase non valida in toolchain.json.'
artifact="QBertPyramid-phase${phase}-Windows-x86_64-${revision}-$(date -u +%Y%m%dT%H%M%SZ)-${AP_STATE##*.}"
ap_run_logged 'Esportazione Windows release x86_64' "$AP_STATE/export.log" \
	"$AP_GODOT" --headless --path "$AP_ROOT" --log-file "$AP_STATE/export-engine.log" \
	--export-release 'Windows Desktop' "$package/QBertPyramid.exe"
ap_check_logs "$AP_STATE/export-engine.log"
[[ -s "$package/QBertPyramid.exe" && -s "$package/QBertPyramid.pck" ]] || ap_fail 'Export incompleto: servono EXE e PCK separati non vuoti.'
# Load both exported entry points with isolated Linux user data before packaging.
# This detects missing PCK dependencies, but does not validate the Windows EXE.
for scene in main_menu rules_lab game_screen; do
	ap_run_logged "Caricamento PCK: $scene (Linux headless)" "$AP_STATE/pck-$scene.log" \
		"$AP_GODOT" --headless --audio-driver Dummy --path "$AP_STATE" \
		--main-pack "$package/QBertPyramid.pck" --scene "res://scenes/$scene.tscn" \
		--quit-after 10 --log-file "$AP_STATE/pck-$scene-engine.log"
	ap_check_logs "$AP_STATE/pck-$scene-engine.log"
done
ap_run_logged 'Risorse audiovisive del PCK isolato' "$AP_STATE/pck-resources.log" \
	"$AP_GODOT" --headless --audio-driver Dummy --path "$AP_STATE" \
	--main-pack "$package/QBertPyramid.pck" --script "$AP_ROOT/tests/pck_resources_smoke.gd"
python3 "$AP_ROOT/tools/verify_results.py" source-archive "$AP_ROOT" "$package"
python3 "$AP_ROOT/tools/verify_results.py" checksums "$package"
archive="$AP_STATE/$artifact.zip"
(cd -- "$package" && zip -q -r -X "$archive" .)
unzip -t "$archive" >"$AP_STATE/zip-check.log"
python3 "$AP_ROOT/tools/verify_results.py" zip "$archive"
python3 "$AP_ROOT/tools/verify_results.py" source-check "$AP_ROOT" "$package"
mkdir -p -- "$AP_ROOT/builds"
[[ ! -e "$AP_ROOT/builds/$artifact" && ! -e "$AP_ROOT/builds/$artifact.zip" ]] || ap_fail 'Nome build già esistente; nessun file sarà sovrascritto.'
mv -- "$package" "$AP_ROOT/builds/$artifact"
mv -- "$archive" "$AP_ROOT/builds/$artifact.zip"
(cd -- "$AP_ROOT/builds" && sha256sum -- "$artifact.zip" >"$artifact.zip.sha256")
printf 'Build verificata: %s\n' "$AP_ROOT/builds/$artifact.zip"
printf 'Log: %s\n' "$AP_STATE"
printf 'Collaudo su Windows reale: ANCORA DA ESEGUIRE.\n'
