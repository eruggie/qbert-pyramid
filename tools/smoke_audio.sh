#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"
[[ $# -eq 0 ]] || ap_fail 'Uso: bash tools/smoke_audio.sh'
ap_select_engine
ap_timeout 30
ap_prepare_state audio-device
export AP_AUDIO_REPORT="$AP_STATE/audio-report.json"
ap_run_logged 'Import audio' "$AP_STATE/import.log" "$AP_GODOT" --headless --path "$AP_ROOT" --import
ap_run_logged 'Consegna effetti al dispositivo Linux (non ascolto umano)' "$AP_STATE/audio.log" \
    "$AP_GODOT" --display-driver x11 --audio-driver PulseAudio --path "$AP_ROOT" --script res://tests/audio_device_smoke.gd
printf 'Report dispositivo: %s\n' "$AP_AUDIO_REPORT"
