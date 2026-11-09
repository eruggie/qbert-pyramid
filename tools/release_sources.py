#!/usr/bin/env python3
"""Standalone source snapshot without Git history; no caches or private reference material."""
import hashlib
import io
import json
import pathlib
import re
import subprocess
import zipfile

ROOT_FILES = {'AGENTS.md', 'SPEC.md', 'PLAN.md', 'README.md', 'TEST.md', 'TESTS.md', 'LICENSE',
              'THIRD_PARTY_NOTICES.txt', 'CHANGELOG.md', 'CONTRIBUTING.md',
              'CODE_OF_CONDUCT.md', 'SECURITY.md', 'CITATION.cff',
              'project.godot', 'export_presets.cfg', '.gitignore', '.gitattributes'}
ROOT_DIRS = {'scripts', 'scenes', 'assets', 'data', 'tests', 'tools', '.vscode', '.codex', '.github'}


def selected(name):
    path = pathlib.PurePosixPath(name)
    if path.is_absolute() or '..' in path.parts or '\\' in name:
        return False
    if any(part.startswith('.env') or part in {'.git', '.godot', '.local-state',
           '__pycache__', 'builds'} for part in path.parts):
        return False
    if path.suffix in {'.pyc', '.keystore', '.jks'} or path.name == 'export_credentials.cfg':
        return False
    return name in ROOT_FILES or (len(path.parts) > 1 and (
        path.parts[0] in ROOT_DIRS or
        (path.parts[0] == 'docs' and (path.suffix in {'.md', '.txt'} or
         path.as_posix() == 'docs/screenshots/gameplay.png'))))


def entries(root):
    result = subprocess.check_output(['git', '-C', str(root), 'ls-files', '-z',
                                    '--cached', '--others', '--exclude-standard'])
    return sorted({n.decode('utf-8') for n in result.split(b'\0') if n and selected(n.decode('utf-8'))})


def snapshot(root):
    records = []
    for name in entries(root):
        path = root / name
        if path.is_symlink():
            raise ValueError('Symlink non ammesso nei sorgenti distribuibili: ' + name)
        if not path.exists():
            continue  # A tracked deletion must remain absent from the distributed snapshot.
        if not path.is_file():
            raise ValueError('Sorgente non regolare: ' + name)
        records.append(hashlib.sha256(path.read_bytes()).hexdigest() + '  ' + name)
    manifest = '\n'.join(records) + '\n'
    return manifest, hashlib.sha256(manifest.encode()).hexdigest()


def create(root, package):
    manifest, identity = snapshot(root)
    commit = subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD']).decode().strip()
    with zipfile.ZipFile(package / 'QBertPyramid-source.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        archive.writestr('SOURCE_FILES.sha256', manifest)
        archive.writestr('PROVENANCE.json', json.dumps({'commit': commit,
            'source_identity_sha256': identity,
            'format': 'standalone-snapshot-v1'}, indent=2) + '\n')
        for record in manifest.splitlines():
            name = record.split('  ', 1)[1]
            archive.write(root / name, 'source/' + name)

    verify((package / 'QBertPyramid-source.zip').read_bytes(), manifest, commit)


def verify(content, expected_manifest=None, expected_commit=None):
    with zipfile.ZipFile(io.BytesIO(content)) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise ValueError('Voci duplicate nei sorgenti.')
        if not {'PROVENANCE.json', 'SOURCE_FILES.sha256'}.issubset(names):
            raise ValueError('Archivio sorgenti incompleto.')
        if archive.testzip():
            raise ValueError('CRC sorgenti errato.')
        manifest = archive.read('SOURCE_FILES.sha256').decode('utf-8')
        info = json.loads(archive.read('PROVENANCE.json'))
        if not re.fullmatch('[0-9a-f]{40,64}', info['commit']):
            raise ValueError('Commit sorgenti non valido.')
        if expected_commit is not None and info['commit'] != expected_commit:
            raise ValueError('Commit sorgenti diverso dalla build.')
        if hashlib.sha256(manifest.encode()).hexdigest() != info['source_identity_sha256']:
            raise ValueError('Identità sorgenti errata.')
        if expected_manifest is not None and manifest != expected_manifest:
            raise ValueError('Manifest sorgenti diverso dalla build.')
        remaining = set(names) - {'PROVENANCE.json', 'SOURCE_FILES.sha256'}
        seen = set()
        for record in manifest.splitlines():
            match = re.fullmatch(r'([0-9a-f]{64})  (.+)', record)
            if not match or not selected(match[2]) or match[2] in seen:
                raise ValueError('Voce manifest sorgenti non valida.')
            value, name = match.groups()
            seen.add(name)
            path = 'source/' + name
            if path not in remaining or hashlib.sha256(archive.read(path)).hexdigest() != value:
                raise ValueError('Sorgente mancante o alterato: ' + name)
            remaining.remove(path)
        if remaining or not {'project.godot', 'tools/build_windows.sh', 'tools/toolchain.json'}.issubset(seen):
            raise ValueError('Contenuto sorgenti inatteso o incompleto.')
        if info.get('format') != 'standalone-snapshot-v1':
            raise ValueError('Formato sorgenti non valido.')
