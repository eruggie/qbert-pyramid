#!/usr/bin/env python3
"""Isolated concurrency checks for the actual WSGI/SQLite leaderboard.

No request is sent to the published site. All databases are temporary.
"""
import concurrent.futures
import io
import json
import multiprocessing
from pathlib import Path
import sqlite3
import sys
import tempfile
import threading
import time
import unittest
import urllib.request
from wsgiref.simple_server import make_server, WSGIServer, WSGIRequestHandler
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from web_wsgi import create_application
from leaderboard_server import Leaderboard

ORIGIN = 'https://multiuser.example.invalid'
ENDPOINT = '/80_arcade_games/qbert/api/leaderboard'


def score(index, points=None):
    return {'submission': f'{index:032x}', 'name': 'ABC',
            'points': points if points is not None else 100 + (index % 23) * 100,
            'level': 1 + index % 8, 'round': 1 + index % 4}


def call(app, payload=None):
    data = json.dumps(payload).encode() if payload is not None else b''
    output = []
    started = time.monotonic()
    stream = app({'PATH_INFO': ENDPOINT, 'REQUEST_METHOD': 'POST' if payload is not None else 'GET',
        'CONTENT_TYPE': 'application/json', 'CONTENT_LENGTH': str(len(data)),
        'HTTP_ORIGIN': ORIGIN, 'wsgi.input': io.BytesIO(data)},
        lambda status, headers: output.append((int(status[:3]), dict(headers))))
    try:
        body = json.loads(b''.join(stream))
    finally:
        if hasattr(stream, 'close'):
            stream.close()
    return output[0][0], body, time.monotonic() - started


def process_writes(database, start, count):
    app = create_application(database, ORIGIN)
    results = []
    for index in range(start, start + count):
        payload = score(index)
        results.append(call(app, payload)[0])
        results.append(call(app, payload)[0])
    return results


class MultiuserTests(unittest.TestCase):
    metrics = {}

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='qbert multiuser ')
        self.db = Path(self.temp.name)/'private/scores.sqlite3'
        self.app = create_application(self.db, ORIGIN)

    def tearDown(self):
        self.temp.cleanup()

    def assert_snapshot(self, state):
        self.assertEqual(state['schema'], 1)
        entries = state['leaderboard']
        self.assertLessEqual(len(entries), 10)
        self.assertEqual([x['points'] for x in entries], sorted([x['points'] for x in entries], reverse=True))
        best = entries[0] if entries else {'points': 0, 'level': 1, 'round': 1}
        self.assertEqual((state['record'], state['record_level'], state['record_round']),
                         (best['points'], best['level'], best['round']))

    def assert_final_database(self, count):
        with sqlite3.connect(self.db) as db:
            self.assertEqual(db.execute('PRAGMA integrity_check').fetchone()[0], 'ok')
            self.assertEqual(db.execute('SELECT COUNT(*),COUNT(DISTINCT submission) FROM scores').fetchone(), (count, count))
            expected = [dict(zip(['name','points','level','round'], row)) for row in
                db.execute('SELECT name,points,level,round FROM scores ORDER BY points DESC,id ASC LIMIT 10')]
        status, state, _ = call(self.app)
        self.assertEqual(status, 200)
        self.assert_snapshot(state)
        self.assertEqual(state['leaderboard'], expected)
        self.assertEqual(state['revision'], count)

    def test_32_clients_mixed_reads_unique_writes_and_retries(self):
        stop = threading.Event()
        reads = []
        errors = []
        barrier = threading.Barrier(32)
        def reader():
            last = -1
            while not stop.is_set():
                status, state, _ = call(self.app)
                if status != 200: errors.append(('read', status)); continue
                self.assert_snapshot(state)
                self.assertGreaterEqual(state['revision'], last)
                last = state['revision']; reads.append(last)
                time.sleep(.002)
        def writer(worker):
            barrier.wait(timeout=10)
            result = []
            for step in range(4):
                payload = score(1 + worker * 4 + step)
                for _ in range(2):
                    status, state, duration = call(self.app, payload)
                    result.append((status, duration))
                    if status == 200: self.assert_snapshot(state)
            return result
        with concurrent.futures.ThreadPoolExecutor(max_workers=36) as pool:
            readers = [pool.submit(reader) for _ in range(4)]
            try:
                futures = [pool.submit(writer, i) for i in range(32)]
                results = [item for f in futures for item in f.result(timeout=40)]
            finally:
                stop.set()
                for f in readers: f.result(timeout=15)
        self.assertFalse(errors)
        self.assertEqual({x[0] for x in results}, {200})
        self.assertGreater(len(reads), 0)
        self.assert_final_database(128)
        self.metrics['mixed'] = {'clients': 32, 'unique_scores': 128, 'post_requests': len(results),
            'consistent_reads': len(reads), 'max_post_seconds': max(x[1] for x in results), 'lost_or_duplicate_scores': 0}

    def test_32_real_http_clients_one_wsgi_worker(self):
        class Server(WSGIServer):
            request_queue_size = 128
        class Quiet(WSGIRequestHandler):
            def log_message(self, *args): pass
        server = make_server('127.0.0.1', 0, self.app, server_class=Server, handler_class=Quiet)
        thread = threading.Thread(target=server.serve_forever, daemon=True); thread.start()
        url = f'http://127.0.0.1:{server.server_port}'+ENDPOINT
        barrier = threading.Barrier(32)
        def user(index):
            barrier.wait(timeout=10)
            results = []
            for payload in [score(index+1), score(index+1), None]:
                request = urllib.request.Request(url, data=json.dumps(payload).encode() if payload else None,
                    headers={'Content-Type':'application/json','Origin':ORIGIN})
                start = time.monotonic()
                with urllib.request.urlopen(request, timeout=8) as response:
                    self.assertEqual(response.status, 200)
                    self.assert_snapshot(json.load(response))
                results.append(time.monotonic()-start)
            return results
        try:
            with concurrent.futures.ThreadPoolExecutor(max_workers=32) as pool:
                durations = [item for result in pool.map(user, range(32)) for item in result]
        finally:
            server.shutdown();server.server_close();thread.join()
        self.assert_final_database(32)
        self.metrics['single_worker_http'] = {'clients':32,'http_requests':len(durations),
            'worker_count':1,'max_request_seconds':max(durations),'all_status_200':True,'unique_scores':32}

    def test_32_simultaneous_identical_submissions_insert_once(self):
        barrier = threading.Barrier(32)
        payload = score(1, 9876)
        def invoke(_):
            barrier.wait(timeout=10)
            return call(self.app, payload)[0]
        with concurrent.futures.ThreadPoolExecutor(max_workers=32) as pool:
            results = list(pool.map(invoke, range(32)))
        self.assertEqual(results, [200]*32)
        self.assert_final_database(1)
        self.metrics['same_submission'] = {'concurrent_requests': 32, 'stored_rows': 1}

    def test_conflicting_payloads_with_same_submission(self):
        barrier = threading.Barrier(16)
        def invoke(index):
            barrier.wait(timeout=10)
            return call(self.app, score(1, index+1))[0]
        with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
            results = list(pool.map(invoke, range(16)))
        self.assertEqual(results.count(200), 1)
        self.assertEqual(results.count(409), 15)
        self.assert_final_database(1)
        self.metrics['conflicting_submission'] = {'requests': 16, 'accepted': 1, 'conflicts': 15}

    def test_same_initials_are_different_attempts_and_ties_follow_commit(self):
        first = score(1, 9000); first['name'] = 'ONE'
        second = score(2, 9000); second['name'] = 'TWO'
        self.assertEqual(call(self.app, first)[0], 200)
        self.assertEqual(call(self.app, second)[0], 200)
        self.assertEqual(call(self.app, score(3, 7000))[0], 200)
        self.assertEqual(call(self.app, score(4, 7000))[0], 200)
        entries = call(self.app)[1]['leaderboard']
        self.assertEqual([e['name'] for e in entries], ['ONE','TWO','ABC','ABC'])
        self.assert_final_database(4)

    def test_four_independent_processes_and_restart(self):
        context = multiprocessing.get_context('spawn')
        with concurrent.futures.ProcessPoolExecutor(max_workers=4, mp_context=context) as pool:
            futures = [pool.submit(process_writes, str(self.db), 1+i*24, 24) for i in range(4)]
            results = [status for future in futures for status in future.result(timeout=40)]
        self.assertEqual(results, [200]*192)
        self.app = create_application(self.db, ORIGIN)
        self.assert_final_database(96)
        self.metrics['processes'] = {'processes': 4, 'unique_scores': 96, 'requests_with_retry': 192, 'survive_restart': True}

    def test_busy_writer_is_bounded_reads_survive_and_retry_is_safe(self):
        self.assertEqual(call(self.app, score(1, 1000))[0], 200)
        locker = sqlite3.connect(self.db)
        locker.execute('BEGIN IMMEDIATE')
        try:
            status, state, duration = call(self.app, score(2, 2000))
            self.assertEqual(status, 503)
            self.assertLess(duration, 6.0, 'Lock wait must finish before the 8-second browser timeout.')
            status, state, _ = call(self.app)
            self.assertEqual((status, state['record'], state['revision']), (200, 1000, 1))
        finally:
            locker.rollback(); locker.close()
        for _ in range(2):
            self.assertEqual(call(self.app, score(2, 2000))[0], 200)
        self.assert_final_database(2)
        self.metrics['busy_lock'] = {'response': 503, 'seconds': duration,
            'reads_during_reserved_lock': 'valid committed snapshot', 'retry_duplicates': 0}

    def test_rollback_discards_uncommitted_score(self):
        with self.assertRaises(RuntimeError):
            with Leaderboard(self.db).connect() as db:
                db.execute('BEGIN IMMEDIATE')
                db.execute('INSERT INTO scores(submission,name,points,level,round) VALUES(?,?,?,?,?)',
                    ('f'*32, 'TMP', 99999, 1, 1))
                raise RuntimeError('Simulated worker failure before commit')
        self.assert_final_database(0)
        self.assertEqual(call(self.app, score(1))[0], 200)
        self.assert_final_database(1)


if __name__ == '__main__':
    if '--report' in sys.argv:
        i = sys.argv.index('--report'); report = Path(sys.argv[i+1]); del sys.argv[i:i+2]
    else:
        report = None
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(MultiuserTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps({'successful': result.wasSuccessful(), 'tests': result.testsRun,
            'metrics': MultiuserTests.metrics, 'environment': 'local WSL filesystem; actual WSGI app; isolated databases'}, indent=2)+'\n')
    sys.exit(0 if result.wasSuccessful() else 1)
