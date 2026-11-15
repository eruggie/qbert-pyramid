#!/usr/bin/env python3
"""Package exact reviewed sources with a local-only static Web candidate."""
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import sys
import zipfile
import release_sources

ROOT = pathlib.Path(__file__).resolve().parent.parent
TEMPLATES = {
    'web_nothreads_release.zip': 'd3ee2f08cef0cf3cf6678a6355a92a8db48ccdd35cbd2e8bfd5f0e8a0b4032a0',
    'web_nothreads_debug.zip': '08962aefef811b603541d7951ac67ef00413aad2d978855183c28adee98f626a',
}
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    mode, location = sys.argv[1:]
    state = pathlib.Path(location)
    if mode == 'templates':
        for name, expected in TEMPLATES.items():
            if digest(state / name) != expected:
                raise SystemExit('Template Web non conforme: ' + name)
        print('Template Web 4.7.2 senza thread: hash conformi.')
        return
    manifest, identity = release_sources.snapshot(ROOT)
    if mode == 'before':
        (state / 'source-before.sha256').write_text(manifest)
        return
    if manifest != (state / 'source-before.sha256').read_text():
        raise SystemExit('Sorgenti cambiati durante export: ripetere la build.')
    site = state / 'site'
    game = site / '80_arcade_games/qbert'
    for name in ['index.html', 'index.js', 'index.wasm', 'index.pck']:
        if not (game / name).stat().st_size:
            raise SystemExit('Export incompleto: ' + name)
    for source, target in [('LICENSE', 'LICENSE.txt'), ('THIRD_PARTY_NOTICES.txt', 'THIRD_PARTY_NOTICES.txt')]:
        shutil.copyfile(ROOT / source, game / target)
    shutil.copyfile(ROOT / 'docs/THIRD_PARTY_NOTICES.txt', game / 'DEPENDENCY_LICENSES.txt')
    shutil.copyfile(ROOT / 'assets/fonts/DejaVuSans-LICENSE.txt', game / 'DejaVuSans-LICENSE.txt')
    shutil.copyfile(ROOT / 'web/site-index.html', site / 'index.html')
    (site / '.nojekyll').touch()
    for name in ['arcade.css', 'game-screen.png']:
        shutil.copyfile(ROOT / 'web' / name, game / name)
    release_sources.create(ROOT, game)
    (game / 'SOURCE_NOTICE.txt').write_text(
        'Q*Bert Pyramid Web 1.2.0-rc.3; classic baseline Windows 1.1.0.\n'
        'Copyright (c) Eugenio Ruggieri 2026. Original code/assets: GPL-3.0-only.\n'
        'Exact corresponding sources: QBertPyramid-1.2.0-rc.3-Source.zip supplied beside the runtime, or source/ in Complete.zip.\n'
        'Verify SOURCE_FILES.sha256 and PROVENANCE.json in that archive.\n'
        'Source repository: https://github.com/eruggie/qbert-pyramid\n'
        'Complete dependency licenses: DEPENDENCY_LICENSES.txt\n')
    info = {'candidate': '1.2.0-rc.3', 'release_status': 'RC2 functional tests accepted by owner; new presentation and distribution awaiting final approval',
            'classic_tag': 'v1.1.0', 'classic_commit': 'e833fd622596c109997a817afa73c9ea80644622',
            'commit': subprocess.check_output(['git','-C',str(ROOT),'rev-parse','HEAD'],text=True).strip(),
            'dirty': bool(subprocess.check_output(['git','-C',str(ROOT),'status','--porcelain'])),
            'source_identity_sha256': identity,
            'engine': subprocess.check_output([os.environ.get('AP_WEB_ENGINE','godot'),'--version'],text=True).strip(),
            'templates': TEMPLATES, 'threads': False, 'extensions': False,
            'leaderboard': 'same-origin HTTP API with server SQLite; static-only hosting is insufficient',
            'web_audio_playback': 'Stream',
            'files': {p.name: p.stat().st_size for p in game.iterdir() if p.is_file()}}
    (game / 'BUILD_INFO.json').write_text(json.dumps(info,indent=2)+'\n')
    destination = ROOT / 'builds' / ('web-1.2.0-rc.3-' + identity[:12])
    if destination.exists():
        raise SystemExit('Build già esistente: '+str(destination))
    destination.mkdir(parents=True)
    shutil.move(str(site), destination / 'site')
    source_archive = destination / 'QBertPyramid-1.2.0-rc.3-Source.zip'
    shutil.move(str(destination / 'site/80_arcade_games/qbert/QBertPyramid-source.zip'), source_archive)
    server = destination / 'server'
    server.mkdir()
    for name in ['serve_web.py', 'leaderboard_server.py', 'web_wsgi.py']:
        shutil.copyfile(ROOT / 'tools' / name, server / name)
    for source, target in [('docs/DEPLOY_WEB.md', 'DEPLOY_WEB.md'),
                           ('docs/GITHUB_PUBLICATION.md', 'GITHUB_PUBLICATION.md'),
                           ('docs/RUNTIME_README.md', 'README.md'), ('RELEASE.md', 'RELEASE.md'),
                           ('TEST.md', 'TEST.md'), ('LICENSE', 'LICENSE.txt'), ('THIRD_PARTY_NOTICES.txt', 'THIRD_PARTY_NOTICES.txt')]:
        shutil.copyfile(ROOT / source, destination / target)
    for name in ['RELEASE.md', 'TEST.md']:
        document = destination / name
        document.write_text(document.read_text().replace('(docs/DEPLOY_WEB.md)', '(DEPLOY_WEB.md)').replace('(docs/GITHUB_PUBLICATION.md)', '(GITHUB_PUBLICATION.md)'))
    runtime_files = [p for folder in ['site', 'server'] for p in sorted((destination / folder).rglob('*')) if p.is_file()]
    runtime_files += [destination / name for name in ['README.md', 'DEPLOY_WEB.md', 'GITHUB_PUBLICATION.md', 'RELEASE.md', 'TEST.md', 'LICENSE.txt', 'THIRD_PARTY_NOTICES.txt']]
    with zipfile.ZipFile(destination / 'QBertPyramid-1.2.0-rc.3-Runtime.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in runtime_files:
            archive.write(path, path.relative_to(destination))
    with zipfile.ZipFile(destination / 'QBertPyramid-1.2.0-rc.3-WebStatic.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in sorted((destination / 'site').rglob('*')):
            if path.is_file():
                archive.write(path, path.relative_to(destination / 'site'))
    with zipfile.ZipFile(destination / 'QBertPyramid-1.2.0-rc.3-Complete.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in runtime_files:
            archive.write(path, path.relative_to(destination))
        with zipfile.ZipFile(source_archive) as sources:
            for name in sources.namelist():
                archive.writestr(name, sources.read(name))
    with (destination / 'SHA256SUMS.txt').open('w') as output:
        for path in sorted(destination.rglob('*')):
            if path.is_file() and path.name != 'SHA256SUMS.txt':
                output.write(digest(path)+'  '+str(path.relative_to(destination))+'\n')
    (state / 'delivery-path.txt').write_text(str(destination)+'\n')
    print('Build Web locale:', destination)

if __name__ == '__main__':
    main()
