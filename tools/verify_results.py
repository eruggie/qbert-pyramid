#!/usr/bin/env python3
"""Validate engine output, runner reports, toolchain and release metadata."""
import datetime
import hashlib
import json
import pathlib
import re
import struct
import subprocess
import sys
import zipfile
import release_sources


def fail(message):
    raise ValueError(message)


def digest(path):
    hasher = hashlib.sha256()
    with pathlib.Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            hasher.update(block)
    return hasher.hexdigest()


def check_pe_x64(path):
    with pathlib.Path(path).open("rb") as stream:
        if stream.read(2) != b"MZ":
            fail("Eseguibile Windows non valido: " + str(path))
        stream.seek(0x3C)
        pe_offset = struct.unpack("<I", stream.read(4))[0]
        stream.seek(pe_offset)
        if stream.read(4) != b"PE\0\0" or struct.unpack("<H", stream.read(2))[0] != 0x8664:
            fail("Il binario Windows deve essere PE x86_64: " + str(path))


def check_logs(paths):
    error_pattern = re.compile(r"(?:^|\n)\s*(?:SCRIPT ERROR:|ERROR:|Parse Error:|Fatal error:|USER ERROR:)|Failed to load script|GDScript parse error", re.IGNORECASE)
    for name in paths:
        path = pathlib.Path(name)
        if not path.is_file():
            fail("Log mancante: " + str(path))
        content = path.read_text(encoding="utf-8", errors="replace")
        if error_pattern.search(content):
            fail("Errore Godot rilevato in " + str(path) + "\n" + content)


def check_report(report_path, run_id, log_path):
    report = json.loads(pathlib.Path(report_path).read_text(encoding="utf-8"))
    if report.get("protocol") != "qbert-pyramid-tests-v1" or report.get("run_id") != run_id:
        fail("Protocollo o identificativo del report non valido.")
    if report.get("complete") is not True or report.get("success") is not True:
        fail("Suite incompleta o fallita.")
    for field in ("tests", "assertions", "failures"):
        if type(report.get(field)) is not int:
            fail("Conteggio report non valido: " + field)
    if report["tests"] <= 0 or report["assertions"] <= 0 or report["failures"] != 0:
        fail("Suite vuota o con fallimenti.")
    lines = pathlib.Path(log_path).read_text(encoding="utf-8", errors="replace").splitlines()
    if lines.count("AP_TEST_COMPLETE " + run_id) != 1:
        fail("Sentinella finale del runner mancante o duplicata.")
    print("Report valido: {tests} test, {assertions} verifiche.".format(**report))


def check_toolchain(config_path, engine_path, templates_path):
    config = json.loads(pathlib.Path(config_path).read_text(encoding="utf-8"))
    if digest(engine_path) != config["engine"]["linux_x86_64_sha256"]:
        fail("SHA-256 del motore diverso dal binario standard registrato in toolchain.json.")
    templates = pathlib.Path(templates_path)
    version = (templates / "version.txt").read_text(encoding="utf-8").strip()
    if version != config["export_templates"]["version"]:
        fail("Versione dei modelli di esportazione non corrispondente.")
    for filename, expected in config["export_templates"].items():
        if filename == "version":
            continue
        path = templates / filename
        check_pe_x64(path)
        if digest(path) != expected:
            fail("SHA-256 del modello diverso dalla versione registrata: " + filename)
        print("Modello verificato: " + filename + " (PE x86_64, SHA-256 conforme)")
    print("Motore standard e modelli " + version + " verificati.")


def git_output(root, *args):
    return subprocess.check_output(["git", "-C", str(root), *args])


def source_snapshot(root):
    return release_sources.snapshot(root)


def build_info(root_path, package_path, config_path, engine_path, templates_path, version):
    root = pathlib.Path(root_path)
    package = pathlib.Path(package_path)
    commit = git_output(root, "rev-parse", "--verify", "HEAD").decode().strip()
    if not re.fullmatch(r"[0-9a-f]{40,64}", commit):
        fail("Identificativo Git della build non valido.")
    dirty = bool(git_output(root, "status", "--porcelain=v1", "--untracked-files=all"))
    source_manifest, source_identity = source_snapshot(root)
    (package / "SOURCE_FILES.sha256").write_text(source_manifest, encoding="utf-8", newline="\n")
    config = json.loads(pathlib.Path(config_path).read_text(encoding="utf-8"))
    info = {
        "schema_version": 1,
        "project": "Q*Bert Pyramid",
        "phase": config["phase"],
        "project_version": config["project_version"],
        "build_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
        "target": config["target"],
        "engine": {"version": version, "edition": "standard", "binary_sha256": digest(engine_path)},
        "templates": {
            "version": config["export_templates"]["version"],
            "windows_release_x86_64_sha256": digest(pathlib.Path(templates_path) / "windows_release_x86_64.exe"),
        },
        "git": {
            "commit": commit,
            "dirty": dirty,
            "source_identity_sha256": source_identity,
            "source_manifest": "SOURCE_FILES.sha256",
            "source_scope": "distributable working tree files selected by tools/release_sources.py; excludes local references, images and private state",
        },
        "source_archive": "../QBertPyramid-source.zip",
        "distribution": "release 1.1.0; unsigned; author metadata is not Authenticode signing",
        "windows_validation": "owner-reported manual Windows acceptance passed on 2026-11-09",
    }
    (package / "BUILD_INFO.json").write_text(json.dumps(info, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(commit[:12] + ("-dirty" if dirty else ""))


def source_check(root_path, package_path):
    root = pathlib.Path(root_path)
    package = pathlib.Path(package_path)
    info = json.loads((package / "BUILD_INFO.json").read_text(encoding="utf-8"))["git"]
    actual_commit = git_output(root, "rev-parse", "--verify", "HEAD").decode().strip()
    actual_dirty = bool(git_output(root, "status", "--porcelain=v1", "--untracked-files=all"))
    actual_manifest, actual_identity = source_snapshot(root)
    recorded_manifest = (package / "SOURCE_FILES.sha256").read_text(encoding="utf-8")
    if (actual_commit != info["commit"] or actual_dirty != info["dirty"]
            or actual_identity != info["source_identity_sha256"] or actual_manifest != recorded_manifest):
        fail("I sorgenti o HEAD sono cambiati durante la build: nessun nuovo ZIP viene pubblicato. Ripetere la build a modifiche concluse.")
    print("Identità dei sorgenti invariata durante l'esportazione.")


def package_checksums(package_path):
    package = pathlib.Path(package_path)
    check_pe_x64(package / "QBertPyramid.exe")
    if (package / "QBertPyramid.pck").stat().st_size == 0:
        fail("PCK vuoto.")
    records = [digest(path) + "  " + path.relative_to(package).as_posix()
               for path in sorted(package.rglob("*")) if path.is_file() and path.name != "SHA256SUMS.txt"]
    (package / "SHA256SUMS.txt").write_text("\n".join(records) + "\n", encoding="utf-8", newline="\n")


def check_zip(zip_path):
    required = {"QBertPyramid.exe", "QBertPyramid.pck", "LICENSE", "BUILD_INFO.json", "SOURCE_FILES.sha256", "SHA256SUMS.txt", "docs/INSTALL_WINDOWS.md", "docs/LICENSING.md", "THIRD_PARTY_NOTICES.txt", "docs/ASSET_LICENSES.md", "docs/PLAYER_GUIDE.md", "docs/THIRD_PARTY_NOTICES.txt" , "SOURCE_NOTICE.txt"}
    with zipfile.ZipFile(zip_path) as archive:
        names = archive.namelist()
        if not required.issubset(names):
            fail("ZIP incompleto: " + ", ".join(sorted(required.difference(names))))
        if len(names) != len(set(names)):
            fail("Voci duplicate nello ZIP.")
        for name in names:
            if name.startswith("/") or ".." in pathlib.PurePosixPath(name).parts or "\\" in name:
                fail("Percorso non valido nello ZIP: " + name)
        info = json.loads(archive.read("BUILD_INFO.json"))
        release_sources.verify((pathlib.Path(zip_path).parent / "QBertPyramid-source.zip").read_bytes(),
                               archive.read("SOURCE_FILES.sha256").decode("utf-8"),
                               info["git"]["commit"])
        if hashlib.sha256(archive.read("SOURCE_FILES.sha256")).hexdigest() != info["git"]["source_identity_sha256"]:
            fail("Identità manifest diversa dai metadati.")
        bad_file = archive.testzip()
        if bad_file:
            fail("CRC ZIP non valido: " + bad_file)
        expected_files = {entry.filename for entry in archive.infolist() if not entry.is_dir()} - {"SHA256SUMS.txt"}
        listed_files = set()
        for record in archive.read("SHA256SUMS.txt").decode("utf-8").splitlines():
            match = re.fullmatch(r"([0-9a-f]{64})  (.+)", record)
            if match is None:
                fail("Formato SHA256SUMS.txt non valido.")
            expected, name = match.groups()
            if name in listed_files or name not in expected_files:
                fail("Voce checksum duplicata o non valida: " + name)
            listed_files.add(name)
            if hashlib.sha256(archive.read(name)).hexdigest() != expected:
                fail("Checksum ZIP non valido: " + name)
        if listed_files != expected_files:
            fail("SHA256SUMS.txt deve coprire esattamente tutti i file dello ZIP, escluso sé stesso.")
    print("ZIP verificato: file richiesti, CRC e SHA-256 conformi.")


def main():
    mode, *args = sys.argv[1:]
    commands = {
        "logs": check_logs,
        "report": check_report,
        "toolchain": check_toolchain,
        "build-info": build_info,
        "source-check": source_check,
        "source-archive": lambda root, package: release_sources.create(pathlib.Path(root), pathlib.Path(package)),
        "checksums": package_checksums,
        "zip": check_zip,
    }
    if mode == "logs":
        check_logs(args)
    else:
        commands[mode](*args)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, TypeError, struct.error, subprocess.CalledProcessError, zipfile.BadZipFile) as error:
        print("ERRORE: " + str(error), file=sys.stderr)
        sys.exit(1)
