#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

[[ $# -eq 0 ]] || ap_fail 'Uso: bash tools/doctor.sh'
ap_require_commands bash python3 git zip unzip timeout sha256sum mktemp realpath cp mv mkdir
(( BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 1) )) || ap_fail 'Serve Bash 5.1 o successivo.'
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' || ap_fail 'Serve Python 3.10 o successivo.'
ap_select_engine
printf 'Progetto: %s\n' "$AP_ROOT"
printf 'Architettura: %s\n' "$(uname -m)"
[[ "$(uname -m)" == x86_64 ]] || ap_fail 'Toolchain iniziale verificata solo su host x86_64.'
if [[ -r /etc/os-release ]]; then
	python3 -c 'import pathlib; print(next((line.split("=",1)[1].strip("\"") for line in pathlib.Path("/etc/os-release").read_text().splitlines() if line.startswith("PRETTY_NAME=")), "Distribuzione non identificata"))'
fi
if [[ "$(uname -r)" == *[Mm]icrosoft* ]]; then
	printf 'Ambiente WSL: %s\n' "$(uname -r)"
else
	printf 'NOTA: host non identificato come WSL; il target Windows richiede comunque collaudo reale.\n'
fi
printf 'Git: %s\n' "$(git --version)"
git -C "$AP_ROOT" rev-parse --is-inside-work-tree >/dev/null || ap_fail 'La cartella deve essere un repository Git locale.'
if git -C "$AP_ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
	printf 'Commit: %s\n' "$(git -C "$AP_ROOT" rev-parse HEAD)"
else
	printf 'NOTA: repository senza commit; la build richiederà un commit locale.\n'
fi
printf 'Godot standard: %s\n' "$AP_VERSION"
[[ -f "$AP_ROOT/project.godot" ]] || ap_fail 'project.godot mancante.'
[[ -f "$AP_ROOT/export_presets.cfg" ]] || ap_fail 'export_presets.cfg mancante.'
python3 "$AP_ROOT/tools/verify_results.py" toolchain "$AP_TOOLCHAIN" "$AP_GODOT" "$AP_TEMPLATES"
printf 'Prerequisiti verificati. Esportazione e collaudo Windows sono verifiche distinte.\n'
