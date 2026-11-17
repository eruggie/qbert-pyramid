#!/usr/bin/env python3
"""Local-only Web regression: a populated leaderboard compressed like the host.

Use a new private --state directory. Never touches the published service or DB.
Run the actual exported Web game against this server, not only Python/native tests.
"""
import argparse
import functools
import gzip
import http.server
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from serve_web import Handler
from leaderboard_server import Leaderboard


class GzipHandler(Handler):
    def send_json(self, status, payload):
        raw = json.dumps(payload, ensure_ascii=False).encode()
        compressed = 'gzip' in self.headers.get('Accept-Encoding', '') and len(raw) >= 200
        body = gzip.compress(raw) if compressed else raw
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Vary', 'Accept-Encoding')
        if compressed:
            self.send_header('Content-Encoding', 'gzip')
        self.end_headers()
        self.wfile.write(body)
        with self.server.trace.open('a') as out:
            out.write(json.dumps({'method': self.command, 'status': status,
                'raw_bytes': len(raw), 'wire_bytes': len(body), 'gzip': compressed,
                'rows': len(payload.get('leaderboard', []))})+'\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('site', type=Path)
    parser.add_argument('--state', type=Path, required=True)
    parser.add_argument('--port', type=int, default=8798)
    args = parser.parse_args()
    site = args.site.resolve(strict=True)
    state = args.state.resolve()
    if state.exists() or state.is_relative_to(site):
        parser.error('Pass a new private state directory outside the public site.')
    state.mkdir(parents=True)
    scores = Leaderboard(state/'scores.sqlite3')
    for i, points in enumerate([6000, 5000, 4000, 3000, 2000, 1000]):
        scores.submit({'submission': f'{i+1:032x}', 'name': chr(65+i)*3,
            'points': points, 'level': 1, 'round': 1})
    server = http.server.ThreadingHTTPServer(('127.0.0.1', args.port), functools.partial(GzipHandler, directory=str(site)))
    server.leaderboard = scores
    server.trace = state/'responses.jsonl'
    print(f'Local gzip fixture: http://localhost:{args.port}/80_arcade_games/qbert/', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
