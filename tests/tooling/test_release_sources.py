#!/usr/bin/env python3
"""Release regression tests using a real temporary Git repository."""
import hashlib
import io
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import warnings
import struct
import unittest
import zipfile
sys.dont_write_bytecode = True
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / 'tools'))
import release_sources as release
import verify_results as results


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.state = tempfile.TemporaryDirectory(prefix='release tests ', dir=os.environ['AP_TEST_STATE_DIR'])
        self.base = pathlib.Path(self.state.name)
        self.root = self.base / 'project with spaces'
        self.root.mkdir()
        self.git('init', '-q')
        self.git('config', 'user.name', 'Release fixture')
        self.git('config', 'user.email', 'fixture@example.invalid')
        for name in ['project.godot', 'tools/build_windows.sh', 'tools/toolchain.json', 'scripts/deleted.gd']:
            p = self.root / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text('original\n')
        self.git('add', '.')
        self.git('-c', 'commit.gpgsign=false', 'commit', '-qm', 'Fixture base')
        self.package = self.base / 'package'
        self.package.mkdir()

    def tearDown(self):
        self.state.cleanup()

    def git(self, *args):
        return subprocess.check_output(['git', '-C', str(self.root), *args], stderr=subprocess.STDOUT)

    def archive(self):
        release.create(self.root, self.package)
        return (self.package / 'QBertPyramid-source.zip').read_bytes()

    def mutate(self, content, change):
        target = io.BytesIO()
        with zipfile.ZipFile(io.BytesIO(content)) as source, zipfile.ZipFile(target, 'w') as output:
            files = {n: source.read(n) for n in source.namelist()}
            change(files)
            for n, value in files.items():
                output.writestr(n, value)
        return target.getvalue()

    def test_working_tree_and_git_base_reconstruct(self):
        (self.root / 'project.godot').write_text('modified\n')
        (self.root / 'scripts/new.gd').write_text('new uncommitted\n')
        (self.root / 'scripts/deleted.gd').unlink()
        manifest, identity = release.snapshot(self.root)
        content = self.archive()
        release.verify(content, manifest, self.git('rev-parse', 'HEAD').decode().strip())
        unpacked = self.base / 'unpacked'
        with zipfile.ZipFile(io.BytesIO(content)) as archive:
            archive.extractall(unpacked)
        work = self.base / 'rebuilt'
        subprocess.run(['git', 'clone', '-q', str(unpacked / 'BASE.bundle'), str(work)], check=True, capture_output=True)
        shutil.copytree(unpacked / 'source', work, dirs_exist_ok=True)
        for name in json.loads((unpacked / 'PROVENANCE.json').read_text())['deleted_tracked_files']:
            (work / name).unlink(missing_ok=True)
        self.assertEqual(release.snapshot(work), (manifest, identity))
        self.assertEqual((work / 'scripts/new.gd').read_text(), 'new uncommitted\n')

    def test_current_acceptance_report_in_source_overlay(self):
        report = self.root / 'TEST.md'
        report.write_text('Historical acceptance')
        self.git('add', 'TEST.md')
        self.git('-c', 'commit.gpgsign=false', 'commit', '-qm', 'Historical report')
        report.write_text('Current phase 6: Windows pending')
        content = self.archive()
        with zipfile.ZipFile(io.BytesIO(content)) as archive:
            self.assertEqual(archive.read('source/TEST.md'), report.read_bytes())
            self.assertIn('  TEST.md', archive.read('SOURCE_FILES.sha256').decode())
        before = release.snapshot(self.root)
        report.write_text('Current phase 6: updated evidence')
        self.assertNotEqual(release.snapshot(self.root), before)

    def test_public_docs_templates_and_product_screenshot_in_snapshot(self):
        selected = ['TESTS.md', 'THIRD_PARTY_NOTICES.txt', 'CHANGELOG.md',
                    'CONTRIBUTING.md', 'CODE_OF_CONDUCT.md', 'SECURITY.md',
                    'CITATION.cff', '.github/ISSUE_TEMPLATE/bug_report.md',
                    '.github/pull_request_template.md', 'docs/screenshots/gameplay.png']
        for name in selected:
            p = self.root / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(b'public fixture')
        with zipfile.ZipFile(io.BytesIO(self.archive())) as archive:
            for name in selected:
                self.assertEqual(archive.read('source/' + name), b'public fixture')
            self.assertNotIn('source/docs/image.png', archive.namelist())

    def test_local_and_secret_material_excluded(self):
        for name in ['docs/image.png', 'docs/image.png.import', 'docs/screenshots/reference.png', 'Q-Bert_Instruction_Manual_11-82.pdf',
                     '.env', 'assets/.env.local', 'assets/test.jks', 'tools/__pycache__/x.pyc']:
            p = self.root / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text('private')
        manifest, _ = release.snapshot(self.root)
        self.assertNotIn('private', manifest)
        self.assertEqual(len(manifest.splitlines()), 4)
        release.verify(self.archive())

    def test_symlink_refused(self):
        (self.root / 'scripts/link.gd').symlink_to('/etc/passwd')
        with self.assertRaises(ValueError):
            release.snapshot(self.root)

    def test_changed_or_missing_source_refused(self):
        content = self.archive()
        for change in [lambda f: f.update({'source/project.godot': b'changed'}),
                       lambda f: f.pop('source/project.godot')]:
            with self.assertRaises(ValueError):
                release.verify(self.mutate(content, change))

    def test_unexpected_unsafe_and_duplicate_entries_refused(self):
        content = self.archive()
        for name in ['source/../../escape', 'source/.env', '/absolute', 'source/docs/image.png']:
            with self.assertRaises(ValueError):
                release.verify(self.mutate(content, lambda f: f.update({name: b'x'})))
        target = io.BytesIO(content)
        with zipfile.ZipFile(target, 'a') as archive:
            archive.writestr('unexpected', b'one')
            with warnings.catch_warnings():
                warnings.simplefilter('ignore', UserWarning)
                archive.writestr('unexpected', b'two')
        with self.assertRaises(ValueError):
            release.verify(target.getvalue())

    def test_wrong_commit_manifest_and_bundle_refused(self):
        content = self.archive()
        with self.assertRaises(ValueError):
            release.verify(content, expected_commit='0' * 40)
        with self.assertRaises(ValueError):
            release.verify(content, expected_manifest='wrong')
        with self.assertRaises(ValueError):
            release.verify(self.mutate(content, lambda f: f.update({'BASE.bundle': b'wrong'})))

    def test_working_tree_mutation_changes_identity(self):
        before = release.snapshot(self.root)
        (self.root / 'project.godot').write_text('changed')
        self.assertNotEqual(release.snapshot(self.root), before)
        (self.root / 'docs').mkdir()
        (self.root / 'docs/image.png').write_text('user image')
        after = release.snapshot(self.root)
        (self.root / 'docs/image.png').write_text('user updated image')
        self.assertEqual(release.snapshot(self.root), after)

    def test_build_source_check_rejects_changes(self):
        manifest, identity = release.snapshot(self.root)
        (self.package / 'SOURCE_FILES.sha256').write_text(manifest)
        (self.package / 'BUILD_INFO.json').write_text(json.dumps({'git': {
            'commit': self.git('rev-parse', 'HEAD').decode().strip(),
            'dirty': bool(self.git('status', '--porcelain=v1', '--untracked-files=all')),
            'source_identity_sha256': identity}}))
        results.source_check(str(self.root), str(self.package))
        (self.root / 'project.godot').write_text('changed during build')
        with self.assertRaises(ValueError):
            results.source_check(str(self.root), str(self.package))

    def package_zip(self):
        self.archive()
        manifest, identity = release.snapshot(self.root)
        (self.package / 'SOURCE_FILES.sha256').write_text(manifest)
        (self.package / 'BUILD_INFO.json').write_text(json.dumps({'git': {
            'commit': self.git('rev-parse', 'HEAD').decode().strip(),
            'source_identity_sha256': identity}}))
        names = ['README.md', 'SPEC.md', 'PLAN.md', 'TEST.md', 'LICENSE', 'docs/ACCEPTANCE_PHASE6.md', 'docs/ASSET_LICENSES.md',
                 'docs/ASSET_CATALOG.md', 'docs/TESTING.md', 'docs/PLAYER_GUIDE.md',
                 'docs/REFERENCE.md', 'docs/THIRD_PARTY_NOTICES.txt', 'docs/REBUILD.md']
        for name in names:
            p = self.package / name
            p.parent.mkdir(exist_ok=True)
            p.write_text('Fixture document')
        pe = bytearray(256)
        pe[:2] = b'MZ'
        struct.pack_into('<I', pe, 0x3c, 128)
        pe[128:132] = b'PE\0\0'
        struct.pack_into('<H', pe, 132, 0x8664)
        (self.package / 'QBertPyramid.exe').write_bytes(pe)
        (self.package / 'QBertPyramid.pck').write_bytes(b'fixture pack')
        results.package_checksums(self.package)
        target = self.base / 'release.zip'
        with zipfile.ZipFile(target, 'w') as archive:
            for path in self.package.rglob('*'):
                if path.is_file():
                    archive.write(path, path.relative_to(self.package).as_posix())
        return target

    def test_full_package_and_tampering(self):
        target = self.package_zip()
        results.check_zip(target)
        for change in [lambda f: f.update({'README.md': b'tampered'}),
                       lambda f: f.pop('docs/PLAYER_GUIDE.md'),
                       lambda f: f.pop('TEST.md'),
                       lambda f: f.pop('LICENSE'),
                       lambda f: f.pop('docs/ACCEPTANCE_PHASE6.md'),
                       lambda f: f.update({'../escape': b'unsafe'})]:
            broken = self.base / 'broken.zip'
            broken.write_bytes(self.mutate(target.read_bytes(), change))
            with self.assertRaises(ValueError):
                results.check_zip(broken)

    def test_outer_metadata_bound_to_source_identity(self):
        target = self.package_zip()
        def change(files):
            info = json.loads(files['BUILD_INFO.json'])
            info['git']['source_identity_sha256'] = '0' * 64
            files['BUILD_INFO.json'] = json.dumps(info).encode()
        target.write_bytes(self.mutate(target.read_bytes(), change))
        with self.assertRaises(ValueError):
            results.check_zip(target)


if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ReleaseTests)
    if suite.countTestCases() == 0:
        raise SystemExit('Suite di packaging vuota')
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    raise SystemExit(0 if result.wasSuccessful() else 1)
