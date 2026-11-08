#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

mode=normal
case "${1:-}" in
	'') ;;
	--self-test-empty) mode=empty ;;
	--self-test-failure) mode=failure ;;
	--help)
		printf 'Uso: bash tools/test.sh [--self-test-empty|--self-test-failure]\nLe modalità negative devono terminare con codice diverso da zero.\n'
		exit 0 ;;
	*) ap_fail 'Argomento sconosciuto. Usare --help.' ;;
esac
[[ $# -le 1 ]] || ap_fail 'Troppi argomenti. Usare --help.'
ap_require_commands python3 realpath timeout mktemp mkdir
ap_select_engine
ap_timeout 120
ap_prepare_state test
export AP_TEST_STATE_DIR="$AP_STATE"
export AP_TEST_RUN_ID="$(basename -- "$AP_STATE")"
export AP_TEST_REPORT_PATH="$AP_STATE/report.json"
printf 'Stato isolato: %s\n' "$AP_STATE"
ap_run_logged 'Regressioni pacchetto e ricostruzione sorgenti' "$AP_STATE/release-tests.log" \
	python3 -B "$AP_ROOT/tests/tooling/test_release_sources.py"
ap_run_logged 'Rigenerazione asset e integrità PCM' "$AP_STATE/asset-tests.log" \
	python3 -B "$AP_ROOT/tests/tooling/test_arcade_assets.py"
ap_run_logged 'Importazione risorse headless' "$AP_STATE/import.log" \
	"$AP_GODOT" --headless --path "$AP_ROOT" --log-file "$AP_STATE/import-engine.log" --import
ap_check_logs "$AP_STATE/import-engine.log"
ap_run_logged 'Test GDScript headless' "$AP_STATE/tests.log" \
	"$AP_GODOT" --headless --path "$AP_ROOT" --log-file "$AP_STATE/tests-engine.log" \
	--script res://tests/run_tests.gd -- "--mode=$mode"
ap_check_logs "$AP_STATE/tests-engine.log"
python3 "$AP_ROOT/tools/verify_results.py" report "$AP_TEST_REPORT_PATH" "$AP_TEST_RUN_ID" "$AP_STATE/tests.log"
printf 'Test superati. Report: %s\n' "$AP_TEST_REPORT_PATH"
