"""WSGI adapter for the existing leaderboard; static files are served by the web server.

Configure QBERT_SCORE_DB (persistent private file) and QBERT_PUBLIC_ORIGIN
(the exact public HTTPS origin). No hosting is provisioned by this module.
"""
import json
import os
import sqlite3
from http import HTTPStatus
from leaderboard_server import API_SUFFIX, MAX_BODY, Conflict, InvalidScore, Leaderboard


def create_application(database_path, public_origin):
    repository = Leaderboard(database_path)

    def app(environ, start_response):
        status = 200
        payload = None
        try:
            if not environ.get('PATH_INFO', '').endswith(API_SUFFIX):
                status, payload = 404, {'error': 'Endpoint inesistente.'}
            elif environ.get('REQUEST_METHOD') == 'GET':
                payload = repository.read()
            elif environ.get('REQUEST_METHOD') == 'POST':
                origin = environ.get('HTTP_ORIGIN')
                if origin and origin != public_origin:
                    status, payload = 403, {'error': 'Origine non consentita.'}
                elif environ.get('CONTENT_TYPE', '').split(';', 1)[0].strip() != 'application/json':
                    status, payload = 415, {'error': 'Content-Type deve essere application/json.'}
                else:
                    size = int(environ.get('CONTENT_LENGTH', '0'))
                    if not 0 < size <= MAX_BODY:
                        status, payload = 413, {'error': 'Dimensione richiesta non valida.'}
                    else:
                        payload = repository.submit(json.loads(environ['wsgi.input'].read(size)))
            else:
                status, payload = 405, {'error': 'Metodo non consentito.'}
        except Conflict:
            status, payload = 409, {'error': 'Identificativo già usato per un altro punteggio.'}
        except (InvalidScore, ValueError, UnicodeError):
            status, payload = 400, {'error': 'Punteggio non valido.'}
        except sqlite3.Error:
            status, payload = 503, {'error': 'Classifica server temporaneamente non disponibile.'}
        body = json.dumps(payload, ensure_ascii=False).encode()
        start_response(f'{status} {HTTPStatus(status).phrase}', [
            ('Content-Type', 'application/json; charset=utf-8'),
            ('Cache-Control', 'no-store'), ('Content-Length', str(len(body))),
            *([('Retry-After', '1')] if status == 503 else [])])
        return [body]
    return app


_configured = None

def application(environ, start_response):
    global _configured
    if _configured is None:
        database = os.environ.get('QBERT_SCORE_DB')
        origin = os.environ.get('QBERT_PUBLIC_ORIGIN')
        if not database or not origin:
            body = b'{"error":"Backend non configurato."}'
            start_response('503 Service Unavailable', [('Content-Type', 'application/json'),
                ('Cache-Control', 'no-store'), ('Content-Length', str(len(body))),
                ('Retry-After', '1')])
            return [body]
        _configured = create_application(database, origin)
    return _configured(environ, start_response)
