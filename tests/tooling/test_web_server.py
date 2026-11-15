#!/usr/bin/env python3
"""Real HTTP/SQLite regressions: durability, concurrency, isolation and retry."""
import concurrent.futures
import functools
import http.server
import json
import pathlib
import sqlite3
import sys
import tempfile
import threading
import unittest
import urllib.error
import urllib.request

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / 'tools'))
from leaderboard_server import Leaderboard, LeaderboardHandlerMixin

class QuietHandler(LeaderboardHandlerMixin, http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass

class ServerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        root = pathlib.Path(self.temp.name)
        self.db = root / 'private/ranking.sqlite3'
        public = root / 'site'; public.mkdir()
        self.server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), functools.partial(QuietHandler, directory=str(public)))
        self.server.leaderboard = Leaderboard(self.db)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True); self.thread.start()
        self.url = f'http://127.0.0.1:{self.server.server_port}/nested/80_arcade_games/qbert/api/leaderboard'

    def tearDown(self):
        self.server.shutdown(); self.server.server_close(); self.thread.join(); self.temp.cleanup()

    def call(self, payload=None, headers=None):
        data = json.dumps(payload).encode() if payload is not None else None
        request = urllib.request.Request(self.url, data=data, headers=headers or {'Content-Type': 'application/json'})
        try:
            with urllib.request.urlopen(request, timeout=15) as response:
                return response.status, json.load(response)
        except urllib.error.HTTPError as error:
            return error.code, json.load(error)

    @staticmethod
    def score(index, points=100):
        return {'submission': f'{index:032x}', 'name': 'ABC', 'points': points, 'level': 1, 'round': 1}

    def test_no_fabricated_scores_and_server_record(self):
        status, value = self.call()
        self.assertEqual((status, value['leaderboard'], value['record']), (200, [], 0))
        self.assertEqual(self.call(self.score(1, 120))[0], 200)
        # A fresh client and repository use the same persisted server state.
        self.assertEqual(self.call()[1]['leaderboard'][0]['points'], 120)
        self.assertEqual(Leaderboard(self.db).read()['record'], 120)

    def test_response_lost_retry_does_not_duplicate(self):
        payload = self.score(1)
        self.call(payload)  # Simulate server commit whose response was lost.
        self.assertEqual(self.call(payload)[0], 200)
        self.assertEqual(len(self.call()[1]['leaderboard']), 1)
        with sqlite3.connect(self.db) as db:
            self.assertEqual(db.execute('SELECT COUNT(*) FROM scores').fetchone()[0], 1)
        changed = {**payload, 'points': 200}
        self.assertEqual(self.call(changed)[0], 409)

    def test_invalid_payloads_cannot_change_ranking(self):
        for key, value in [('name', '<X>'), ('points', -1), ('points', True), ('points', 1.5), ('level', 1000001), ('round', 0), ('submission', 'bad')]:
            self.assertEqual(self.call({**self.score(1), key: value})[0], 400)
        self.assertEqual(self.call()[1]['revision'], 0)

    def test_wrong_origin_and_content_type_rejected(self):
        self.assertEqual(self.call(self.score(1), {'Content-Type': 'application/json', 'Origin': 'https://elsewhere.invalid'})[0], 403)
        self.assertEqual(self.call(self.score(1), {'Content-Type': 'text/plain'})[0], 415)
        self.assertEqual(self.call()[1]['record'], 0)

    def test_concurrent_writes_and_stable_ties(self):
        self.call({**self.score(1, 500), 'name': 'ONE'})
        self.call({**self.score(2, 500), 'name': 'TWO'})
        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
            responses = list(pool.map(lambda i: self.call(self.score(i, i)), range(3, 23)))
        self.assertTrue(all(r[0] == 200 for r in responses))
        ranking = self.call()[1]['leaderboard']
        self.assertEqual(len(ranking), 10)
        self.assertEqual([entry['name'] for entry in ranking[:2]], ['ONE', 'TWO'])
        self.assertEqual([entry['points'] for entry in ranking[2:]], list(range(22, 14, -1)))

    def test_database_not_exposed_by_static_handler(self):
        with self.assertRaises(urllib.error.HTTPError) as error:
            urllib.request.urlopen(self.url.split('/nested/')[0] + '/private/ranking.sqlite3')
        self.assertEqual(error.exception.code, 404)

if __name__ == '__main__':
    unittest.main()
