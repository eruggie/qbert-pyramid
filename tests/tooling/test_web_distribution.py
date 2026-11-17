#!/usr/bin/env python3
"""Distribution checks for a WSGI host and the static GitHub Pages gateway."""
import io
import json
import pathlib
import sys
import tempfile
import unittest
from unittest import mock
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / 'tools'))
from web_wsgi import create_application
from prepare_pages import prepare
from hosted_wsgi import create_application as create_hosted
import web_wsgi

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

    def test_wsgi_unconfigured_reports_retryable_503(self):
        responses = []
        with mock.patch.dict('os.environ', {}, clear=True), mock.patch.object(web_wsgi, '_configured', None):
            body = b''.join(web_wsgi.application({}, lambda status, headers: responses.append((status, dict(headers)))))
        self.assertEqual(responses[0][0], '503 Service Unavailable')
        self.assertEqual(responses[0][1]['Retry-After'], '1')
        self.assertIn('error', json.loads(body))

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

class HostedDistributionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp.name)
        self.site = self.root/'site'
        self.game = self.site/'80_arcade_games/qbert'
        self.game.mkdir(parents=True)
        for name in ['index.html','index.wasm','index.pck','index.audio.worklet.js']:
            (self.game/name).write_bytes(b'game fixture')
        self.database = self.root/'private/scores.sqlite3'
        self.app = create_hosted(self.site, self.database, 'https://host.pythonanywhere.com')

    def tearDown(self):
        self.temp.cleanup()

    def request(self, path, method='GET', payload=None):
        body = json.dumps(payload).encode() if payload is not None else b''
        result = []
        stream = self.app({'PATH_INFO':path,'REQUEST_METHOD':method,
            'HTTP_ORIGIN':'https://host.pythonanywhere.com','CONTENT_TYPE':'application/json',
            'CONTENT_LENGTH':str(len(body)),'wsgi.input':io.BytesIO(body)},
            lambda status, headers: result.append((int(status[:3]),dict(headers))))
        try: content = b''.join(stream)
        finally:
            if hasattr(stream,'close'): stream.close()
        return *result[0],content

    def test_game_streaming_mime_head_and_worklet(self):
        for name,mime in [('index.wasm','application/wasm'),('index.pck','application/octet-stream'),('index.audio.worklet.js','text/javascript')]:
            status,headers,body=self.request('/80_arcade_games/qbert/'+name)
            self.assertEqual((status,headers['Content-Type'],body),(200,mime,b'game fixture'))
        status,headers,body=self.request('/80_arcade_games/qbert/','HEAD')
        self.assertEqual((status,int(headers['Content-Length']),body),(200,12,b''))

    def test_private_files_traversal_and_symlink_are_never_public(self):
        (self.game/'scores.sqlite3').write_bytes(b'private')
        (self.root/'secret').write_bytes(b'private')
        (self.game/'BUILD_INFO.json').symlink_to(self.root/'secret')
        for path in ['/80_arcade_games/qbert/scores.sqlite3','/80_arcade_games/qbert/../secret',
                     '/80_arcade_games/qbert/.env','/80_arcade_games/qbert/BUILD_INFO.json','/private/scores.sqlite3']:
            self.assertEqual(self.request(path)[0],404,path)
        with self.assertRaises(ValueError):create_hosted(self.site,self.site/'scores.sqlite3','https://host.pythonanywhere.com')

    def test_shared_api_and_persistence_across_wsgi_reload(self):
        path='/80_arcade_games/qbert/api/leaderboard'
        payload={'submission':'b'*32,'name':'TST','points':321,'level':1,'round':1}
        self.assertEqual(self.request(path,'POST',payload)[0],200)
        self.app=create_hosted(self.site,self.database,'https://host.pythonanywhere.com')
        status,headers,body=self.request(path)
        self.assertEqual(json.loads(body)['record'],321)
        self.assertEqual(len(json.loads(self.request(path,'POST',payload)[2])['leaderboard']),1)

    def test_home_redirect_and_methods(self):
        self.assertEqual(self.request('/')[1]['Location'],'https://eruggie.github.io/')
        self.assertEqual(self.request('/80_arcade_games/qbert')[1]['Location'],'/80_arcade_games/qbert/')
        self.assertEqual(self.request('/80_arcade_games/qbert/','POST')[0],405)
        with self.assertRaises(ValueError):create_hosted(self.site,self.database,'http://host.pythonanywhere.com')

if __name__ == '__main__':
    unittest.main()
