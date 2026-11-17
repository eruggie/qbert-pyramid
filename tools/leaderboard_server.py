#!/usr/bin/env python3
"""Same-origin leaderboard API for local acceptance. SQLite stays outside public files."""
import contextlib
import json
import pathlib
import re
import sqlite3
import urllib.parse

API_SUFFIX = '/80_arcade_games/qbert/api/leaderboard'
MAX_BODY = 1024
# Keep lock waits below the Web client request deadline (8 seconds).
DB_BUSY_TIMEOUT_SECONDS = 3.0

class InvalidScore(ValueError):
    pass

class Conflict(ValueError):
    pass

class Leaderboard:
    def __init__(self, path):
        self.path = pathlib.Path(path).resolve()
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self.connect() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS scores (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                submission TEXT NOT NULL UNIQUE,
                name TEXT NOT NULL, points INTEGER NOT NULL,
                level INTEGER NOT NULL, round INTEGER NOT NULL)''')
            db.execute('CREATE INDEX IF NOT EXISTS ranking ON scores(points DESC, id ASC)')

    @contextlib.contextmanager
    def connect(self):
        db = sqlite3.connect(self.path, timeout=DB_BUSY_TIMEOUT_SECONDS)
        try:
            with db:
                yield db
        finally:
            db.close()

    @staticmethod
    def validate(payload):
        if not isinstance(payload, dict) or set(payload) != {'submission', 'name', 'points', 'level', 'round'}:
            raise InvalidScore('Campi del punteggio non validi.')
        if not isinstance(payload['submission'], str) or not re.fullmatch('[0-9a-f]{32}', payload['submission']):
            raise InvalidScore('Identificativo invio non valido.')
        if not isinstance(payload['name'], str) or not re.fullmatch('[A-Z]{3}', payload['name']):
            raise InvalidScore('Servono tre iniziali A-Z.')
        for key, maximum in [('points', 2147483647), ('level', 1000000), ('round', 4)]:
            if type(payload[key]) is not int or not 1 <= payload[key] <= maximum:
                raise InvalidScore('Valore non valido: ' + key)
        return tuple(payload[key] for key in ['submission', 'name', 'points', 'level', 'round'])

    @staticmethod
    def snapshot(db):
        entries = [dict(zip(['name', 'points', 'level', 'round'], row)) for row in
                   db.execute('SELECT name, points, level, round FROM scores ORDER BY points DESC, id ASC LIMIT 10')]
        best = entries[0] if entries else {'points': 0, 'level': 1, 'round': 1}
        return {'schema': 1, 'revision': db.execute('SELECT COALESCE(MAX(id),0) FROM scores').fetchone()[0],
                'leaderboard': entries, 'record': best['points'],
                'record_level': best['level'], 'record_round': best['round']}

    def read(self):
        with self.connect() as db:
            db.execute("BEGIN")
            return self.snapshot(db)

    def submit(self, payload):
        values = self.validate(payload)
        with self.connect() as db:
            db.execute('BEGIN IMMEDIATE')
            previous = db.execute('SELECT submission,name,points,level,round FROM scores WHERE submission=?',
                                  (values[0],)).fetchone()
            if previous is not None and previous != values:
                raise Conflict('Identificativo già usato per un altro punteggio.')
            if previous is None:
                db.execute('INSERT INTO scores(submission,name,points,level,round) VALUES(?,?,?,?,?)', values)
            result = self.snapshot(db)
            in_top = db.execute('SELECT submission FROM scores ORDER BY points DESC,id ASC LIMIT 10').fetchall()
            result.update({'submission': values[0], 'ranked': (values[0],) in in_top})
            return result

class LeaderboardHandlerMixin:
    def is_leaderboard(self):
        path = urllib.parse.urlsplit(self.path).path
        return path.endswith(API_SUFFIX)

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        if status == 503:
            self.send_header('Retry-After', '1')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if not self.is_leaderboard():
            return super().do_GET()
        try:
            self.send_json(200, self.server.leaderboard.read())
        except sqlite3.Error:
            self.send_json(503, {'error': 'Classifica server temporaneamente non disponibile.'})

    def do_POST(self):
        if not self.is_leaderboard():
            self.send_json(404, {'error': 'Endpoint inesistente.'})
            return
        # Browser writes must come from this origin. No credentials or CORS needed.
        origin = self.headers.get('Origin')
        if origin and origin != 'http://' + self.headers.get('Host', ''):
            self.send_json(403, {'error': 'Origine non consentita.'})
            return
        if self.headers.get_content_type() != 'application/json':
            self.send_json(415, {'error': 'Content-Type deve essere application/json.'})
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if not 0 < length <= MAX_BODY:
                self.send_json(413, {'error': 'Dimensione richiesta non valida.'})
                return
            payload = json.loads(self.rfile.read(length))
            self.send_json(200, self.server.leaderboard.submit(payload))
        except Conflict:
            self.send_json(409, {'error': 'Identificativo già usato per un altro punteggio.'})
        except (InvalidScore, ValueError, UnicodeError):
            self.send_json(400, {'error': 'Punteggio non valido.'})
        except sqlite3.Error:
            self.send_json(503, {'error': 'Salvataggio server non disponibile. Riprovare.'})
