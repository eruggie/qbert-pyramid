#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"
[[ $# -eq 0 ]] || ap_fail 'Uso: bash tools/build_web.sh'
ap_require_commands python3 git unzip sha256sum timeout
ap_select_engine
python3 -B "$AP_ROOT/tests/tooling/test_web_server.py"
python3 -B "$AP_ROOT/tests/tooling/test_web_distribution.py"
python3 -B "$AP_ROOT/tests/tooling/test_web_multiuser.py"
python3 "$AP_ROOT/tools/web_package.py" templates "$AP_TEMPLATES"
bash "$AP_ROOT/tools/doctor.sh"
bash "$AP_ROOT/tools/test.sh"
ap_select_engine
export AP_WEB_ENGINE="$AP_GODOT"
ap_timeout 180
ap_prepare_state web-build
mkdir -p "$AP_STATE/data/godot/export_templates"
ln -s "$AP_TEMPLATES" "$AP_STATE/data/godot/export_templates/$AP_TEMPLATE_VERSION"
site="$AP_STATE/site"
game="$site/80_arcade_games/qbert"
mkdir -p "$game"
python3 "$AP_ROOT/tools/web_package.py" before "$AP_STATE"
ap_run_logged 'Export Web single-thread' "$AP_STATE/export.log" \
 "$AP_GODOT" --headless --path "$AP_ROOT" --log-file "$AP_STATE/export-engine.log" --export-release Web "$game/index.html"
ap_check_logs "$AP_STATE/export-engine.log"
python3 "$AP_ROOT/tools/web_package.py" package "$AP_STATE"
IFS= read -r delivery < "$AP_STATE/delivery-path.txt"
python3 "$AP_ROOT/tools/verify_web.py" "$delivery/site" > "$AP_STATE/web-verification.json"
printf 'HTTP, MIME, link relativi e sorgenti verificati: %s\n' "$AP_STATE/web-verification.json"
python3 "$AP_ROOT/tools/verify_web_runtime.py" "$delivery/QBertPyramid-$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["web"]["version"])' "$AP_TOOLCHAIN")-Runtime.zip" > "$AP_STATE/runtime-verification.json"
printf 'Runtime estratto e API verificati: %s\n' "$AP_STATE/runtime-verification.json"
