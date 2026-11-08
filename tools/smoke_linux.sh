#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"
[[ $# -eq 0 ]] || ap_fail 'Uso: bash tools/smoke_linux.sh'
ap_require_commands python3 realpath timeout mktemp mkdir
[[ "$(uname -s)" == Linux ]] || ap_fail 'La verifica grafica richiede Linux (WSLg nel PC di sviluppo).'
[[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] || ap_fail 'Nessun display Linux disponibile; non verrà usata una modalità headless sostitutiva.'
ap_select_engine
ap_timeout 60
ap_prepare_state linux-graphics
export AP_GRAPHICS_STATE_DIR="$AP_STATE"
ap_run_logged 'Importazione per verifica grafica Linux' "$AP_STATE/import.log" \
	"$AP_GODOT" --headless --path "$AP_ROOT" --log-file "$AP_STATE/import-engine.log" --import
ap_check_logs "$AP_STATE/import-engine.log"
ap_run_logged 'Esecuzione grafica Linux/WSLg' "$AP_STATE/graphics.log" \
	"$AP_GODOT" --audio-driver Dummy --path "$AP_ROOT" --log-file "$AP_STATE/graphics-engine.log" \
	--script res://tests/linux_graphics_smoke.gd
ap_check_logs "$AP_STATE/graphics-engine.log"
python3 - "$AP_STATE/graphics-report.json" "$AP_STATE/graphics.log" <<'PY'
import json,pathlib,sys
report=json.loads(pathlib.Path(sys.argv[1]).read_text())
log=pathlib.Path(sys.argv[2]).read_text()
if report['platform'] != 'Linux' or report['display_server'] == 'headless' or report['failures'] != 0 or not report['captures'] or 'AP_LINUX_GRAPHICS_COMPLETE ' not in log:
    raise SystemExit('Verifica grafica incompleta o fallita.')
print('Display:',report['display_server'],'Renderer:',report['rendering_method'],'GPU:',report['video_adapter'])
PY
printf 'Verifica grafica Linux completata: %s\nNon è un collaudo dell’eseguibile Windows.\n' "$AP_STATE"
