#!/usr/bin/env bash
# Shared project-local helpers. This file is sourced by the public commands.
set -euo pipefail

AP_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
AP_TOOLCHAIN="$AP_ROOT/tools/toolchain.json"
AP_ENGINE_VERSION='4.7.2.stable.official.ed1daf0bf'
AP_TEMPLATE_VERSION='4.7.2.stable'

ap_fail() {
	printf 'ERRORE: %s\n' "$*" >&2
	exit 1
}

ap_require_commands() {
	local command_name
	for command_name in "$@"; do
		command -v "$command_name" >/dev/null 2>&1 || ap_fail "Prerequisito mancante: $command_name. Nessun software viene installato."
	done
}

ap_select_engine() {
	local selected
	if [[ -n "${GODOT_BIN:-}" ]]; then
		selected="$GODOT_BIN"
	elif command -v godot >/dev/null 2>&1; then
		selected="$(command -v godot)"
	else
		selected="${HOME:?HOME non definita}/.local/bin/godot"
	fi
	if [[ "$selected" != */* ]]; then
		selected="$(command -v "$selected")" || ap_fail "GODOT_BIN non trovato: $selected"
	fi
	[[ -f "$selected" && -x "$selected" ]] || ap_fail "Eseguibile Godot assente o non eseguibile: $selected"
	AP_GODOT="$(realpath -- "$selected")"
	AP_VERSION="$("$AP_GODOT" --version)" || ap_fail 'Impossibile leggere la versione Godot.'
	[[ "$AP_VERSION" == "$AP_ENGINE_VERSION" ]] || ap_fail "Serve Godot standard $AP_ENGINE_VERSION; rilevato: $AP_VERSION"
	AP_TEMPLATES="${GODOT_TEMPLATE_DIR:-${XDG_DATA_HOME:-${HOME:?HOME non definita}/.local/share}/godot/export_templates/$AP_TEMPLATE_VERSION}"
	if [[ -d "$AP_TEMPLATES" ]]; then
		AP_TEMPLATES="$(realpath -- "$AP_TEMPLATES")"
	fi
}

ap_check_logs() {
	python3 "$AP_ROOT/tools/verify_results.py" logs "$@" || ap_fail 'Godot ha segnalato errori; consultare i log indicati.'
}

ap_prepare_state() {
	local purpose="$1"
	mkdir -p -- "$AP_ROOT/.local-state"
	AP_STATE="$(mktemp -d "$AP_ROOT/.local-state/${purpose}.XXXXXXXX")"
	mkdir -p -- "$AP_STATE/data" "$AP_STATE/config" "$AP_STATE/cache"
	export XDG_DATA_HOME="$AP_STATE/data"
	export XDG_CONFIG_HOME="$AP_STATE/config"
	export XDG_CACHE_HOME="$AP_STATE/cache"
	# HOME is deliberately preserved. Godot user:// follows this isolated XDG data path.
}

ap_timeout() {
	local default_seconds="$1"
	AP_TIMEOUT="${GODOT_TIMEOUT_SECONDS:-$default_seconds}"
	[[ "$AP_TIMEOUT" =~ ^[1-9][0-9]*$ ]] || ap_fail 'GODOT_TIMEOUT_SECONDS deve essere un intero positivo.'
}

ap_run_logged() {
	local label="$1" output="$2"
	shift 2
	printf '%s (log: %s)\n' "$label" "$output"
	if timeout --signal=TERM --kill-after=5s "${AP_TIMEOUT}s" "$@" >"$output" 2>&1; then
		ap_check_logs "$output"
	else
		local status=$?
		cat -- "$output" >&2
		ap_fail "$label fallita (codice $status; 124 indica timeout)."
	fi
}
