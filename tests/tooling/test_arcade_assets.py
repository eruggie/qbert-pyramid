"""Rebuild original assets in isolation and verify deliverable PCM integrity."""
import importlib.util
import pathlib
import struct
import tempfile
import unittest
import wave

ROOT = pathlib.Path(__file__).resolve().parents[2]

def generator(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / 'tools' / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

class ArcadeAssets(unittest.TestCase):
    def test_reproducible_graphics_and_audio(self):
        for name, directory, suffixes in [('generate_audio', 'audio', ['.wav', '.txt']), ('generate_arcade_art', 'arcade', ['.png', '.fnt'])]:
            module = generator(name)
            with tempfile.TemporaryDirectory(dir=ROOT / '.local-state') as folder:
                module.ROOT = pathlib.Path(folder)
                module.main()
                generated = sorted(p.name for p in module.ROOT.iterdir())
                current = sorted(p.name for p in (ROOT/'assets'/directory).iterdir() if p.suffix in suffixes)
                self.assertEqual(generated, current)
                for filename in generated:
                    self.assertEqual((module.ROOT/filename).read_bytes(), (ROOT/'assets'/directory/filename).read_bytes(), filename)

    def test_event_pcm_is_short_nonempty_and_unclipped(self):
        paths = list((ROOT/'assets/audio').glob('*.wav'))
        self.assertEqual(len(paths), 14)
        for path in paths:
            with wave.open(str(path)) as wav:
                self.assertEqual((wav.getnchannels(), wav.getsampwidth(), wav.getframerate()), (1, 2, 22050))
                self.assertTrue(.025 < wav.getnframes()/wav.getframerate() < 2.8)
                samples = struct.unpack('<' + 'h'*wav.getnframes(), wav.readframes(wav.getnframes()))
                peak = max(abs(v) for v in samples)
                self.assertTrue(500 < peak < 12000, path.name)
                self.assertLess(abs(samples[0]), 10)
                self.assertLess(abs(samples[-1]), 100)
        self.assertFalse(any('music' in p.name or p.stem == 'menu' for p in paths))

    def test_audio_fits_actions_and_movement_balance(self):
        # Independent presentation budgets: no sound spills into the next
        # logical action/round. These limits do not change simulation timing.
        budgets = {'jump': .10, 'land': .15, 'color': .15, 'collect': .60,
                   'contact': 1.5, 'fall': 1.5, 'rescue': 1.2,
                   'round': 3.0, 'extra': .35, 'lure': 1.5,
                   'stasis_collect': .6, 'stasis_fall': .6, 'level': 3.0, 'game_over': 1.2}
        rms = {}
        for name, budget in budgets.items():
            with wave.open(str(ROOT/'assets/audio'/(name+'.wav'))) as wav:
                self.assertLess(wav.getnframes()/wav.getframerate(), budget)
                samples = struct.unpack('<'+'h'*wav.getnframes(), wav.readframes(wav.getnframes()))
                rms[name] = (sum(v*v for v in samples)/len(samples))**.5
                self.assertLess(abs(sum(samples)/len(samples)), 100, name)
        self.assertLess(rms['jump'], rms['color']*.4)
        self.assertLess(rms['color'], rms['contact'])
        self.assertLess(rms['rescue'], rms['lure'])

    def test_app_icon_comes_from_actual_player_atlas_and_rebuilds(self):
        import zlib
        def decode(content):
            self.assertEqual(content[:8], b'\x89PNG\r\n\x1a\n')
            width, height, depth, color = struct.unpack('>IIBB', content[16:26])
            self.assertEqual((depth, color), (8, 6))
            offset, compressed = 8, b''
            while offset < len(content):
                length = struct.unpack('>I', content[offset:offset + 4])[0]
                if content[offset + 4:offset + 8] == b'IDAT':
                    compressed += content[offset + 8:offset + 8 + length]
                offset += length + 12
            raw = zlib.decompress(compressed)
            self.assertTrue(all(raw[y * (width * 4 + 1)] == 0 for y in range(height)))
            return width, height, b''.join(raw[y * (width * 4 + 1) + 1:(y + 1) * (width * 4 + 1)] for y in range(height))
        module = generator('generate_app_icon')
        with tempfile.TemporaryDirectory(dir=ROOT / '.local-state') as folder:
            module.ROOT = pathlib.Path(folder)
            module.main()
            for name in ['qbert.png', 'qbert.ico']:
                self.assertEqual((module.ROOT / name).read_bytes(), (ROOT / 'assets/ui' / name).read_bytes())
        sw, sh, sheet = decode((ROOT / 'assets/arcade/actors.png').read_bytes())
        sprite = b''.join(sheet[(y * sw + 360) * 4:(y * sw + 400) * 4] for y in range(48))
        self.assertEqual(module.sprite_pixels(), (40, 48, sprite))
        iw, ih, icon = decode((ROOT / 'assets/ui/qbert.png').read_bytes())
        self.assertEqual((iw, ih), (256, 256))
        source_colors = {sprite[n:n + 4] for n in range(0, len(sprite), 4)}
        self.assertTrue({icon[n:n + 4] for n in range(0, len(icon), 4)} <= source_colors)
        self.assertTrue(any(icon[3::4]) and any(v == 0 for v in icon[3::4]))
        ico = (ROOT / 'assets/ui/qbert.ico').read_bytes()
        self.assertEqual(struct.unpack_from('<HHH', ico), (0, 1, 6))
        for index, size in enumerate([16, 32, 48, 64, 128, 256]):
            width, height, _, _, planes, depth, length, offset = struct.unpack_from('<BBBBHHII', ico, 6 + index * 16)
            self.assertEqual((width or 256, height or 256, planes, depth), (size, size, 1, 32))
            self.assertEqual(decode(ico[offset:offset + length])[:2], (size, size))
            if size == 256:
                self.assertEqual(ico[offset:offset + length], (ROOT / 'assets/ui/qbert.png').read_bytes())
        self.assertFalse((ROOT / 'assets/ui/qbert.jpg').exists())

    def test_current_source_branding(self):
        import subprocess
        names = subprocess.check_output(['git', '-C', str(ROOT), 'ls-files', '-co', '--exclude-standard', '-z']).decode().split('\0')
        old_title = 'arcade' + ' pyramid'
        old_compact = 'arcade' + 'pyramid'
        for name in set(names):
            path = ROOT / name
            if not name or not path.is_file():
                continue
            try:
                content = path.read_text().lower()
            except UnicodeError:
                continue
            self.assertNotIn(old_title, content, name)
            self.assertNotIn(old_compact, content, name)

if __name__ == '__main__':
    unittest.main()
