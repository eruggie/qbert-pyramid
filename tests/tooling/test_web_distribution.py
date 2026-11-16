#!/usr/bin/env python3
"""Distribution checks for a WSGI host and the static GitHub Pages gateway."""
import io
import json
import pathlib
import sys
import tempfile
import unittest
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / 'tools'))
from web_wsgi import create_application
from prepare_pages import prepare

class DistributionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp.name)
        self.app = create_application(self.root/'private/scores.sqlite3', 'https://games.example.invalid')

    def tearDown(self):
        self.temp.cleanup()

    def call(self, method='GET', payload=None, origin='https://games.example.invalid'):
        body = json.dumps(payload).encode() if payload is not None else b''
        status = []
        result = self.app({'PATH_INFO': '/80_arcade_games/qbert/api/leaderboard', 'REQUEST_METHOD': method,
            'HTTP_ORIGIN': origin, 'CONTENT_TYPE': 'application/json', 'CONTENT_LENGTH': str(len(body)),
            'wsgi.input': io.BytesIO(body)}, lambda code, headers: status.append(code))
        return int(status[0].split()[0]), json.loads(b''.join(result))

    def test_wsgi_https_origin_and_same_storage(self):
        payload = {'submission': 'a'*32, 'name': 'ABC', 'points': 123, 'level': 1, 'round': 1}
        self.assertEqual(self.call('POST', payload)[0], 200)
        self.assertEqual(self.call()[1]['record'], 123)
        self.assertEqual(len(self.call('POST', payload)[1]['leaderboard']), 1)
        self.assertEqual(self.call('POST', payload, 'https://elsewhere.invalid')[0], 403)

    def test_wsgi_rejects_invalid_payload_and_methods(self):
        self.assertEqual(self.call('POST', {'points': 1})[0], 400)
        self.assertEqual(self.call('DELETE')[0], 405)
        self.assertEqual(self.call()[1]['record'], 0)

    def test_pages_gateway_has_real_target_and_no_engine_or_database(self):
        site = self.root/'site'; assets=site/'80_arcade_games/qbert'; assets.mkdir(parents=True)
        (site/'personal.css').write_text('personal fixture')
        (site/'index.html').write_text('<a href="80_arcade_games/qbert/">PLAY</a>')
        for name in ['arcade.css','game-screen.png','index.icon.png','LICENSE.txt','THIRD_PARTY_NOTICES.txt','DEPENDENCY_LICENSES.txt','DejaVuSans-LICENSE.txt','SOURCE_NOTICE.txt']:
            (assets/name).write_text('fixture')
        output = prepare(site, self.root/'pages', 'https://games.example.invalid/80_arcade_games/qbert/')
        self.assertIn('https://games.example.invalid/80_arcade_games/qbert/',(output/'index.html').read_text())
        self.assertFalse((output/'80_arcade_games/qbert/index.html').exists())
        self.assertTrue((output/'.nojekyll').exists())
        self.assertEqual((output/'personal.css').read_text(), 'personal fixture')
        self.assertEqual((output/'80_arcade_games/qbert/game-screen.png').read_text(), 'fixture')
        with self.assertRaises(ValueError): prepare(site, output, 'https://games.example.invalid/80_arcade_games/qbert/')

    def test_pages_rejects_credentials_and_non_https_targets(self):
        for url in ['http://games.example.invalid/80_arcade_games/qbert/', 'https://name:secret@games.example.invalid/80_arcade_games/qbert/']:
            with self.assertRaises(ValueError): prepare(self.root, self.root/'pages', url)

if __name__ == '__main__':
    unittest.main()
