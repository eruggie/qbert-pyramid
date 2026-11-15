#!/usr/bin/env python3
"""Local-only site and durable shared leaderboard. No deployment is performed."""
import argparse
import functools
import http.server
import pathlib
from leaderboard_server import Leaderboard, LeaderboardHandlerMixin

class Handler(LeaderboardHandlerMixin, http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map,
                      '.wasm': 'application/wasm', '.pck': 'application/octet-stream', '.js': 'text/javascript'}
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=pathlib.Path)
    parser.add_argument('--port', type=int, default=8765)
    parser.add_argument('--db', type=pathlib.Path,
                        default=pathlib.Path(__file__).resolve().parent.parent / '.local-state/web-server/leaderboard.sqlite3')
    args = parser.parse_args()
    root = args.directory.resolve(strict=True)
    database = args.db.resolve()
    if not (root / '80_arcade_games/qbert/index.html').is_file():
        parser.error('Passare la directory site/ della build, non la sottocartella del gioco.')
    if database.is_relative_to(root):
        parser.error('Il database deve stare fuori dalla directory pubblica site/.')
    server = http.server.ThreadingHTTPServer(('127.0.0.1', args.port), functools.partial(Handler, directory=str(root)))
    server.leaderboard = Leaderboard(database)
    print(f'http://localhost:{args.port}/80_arcade_games/qbert/', flush=True)
    print(f'Classifica condivisa sul server: {database}', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == '__main__':
    main()
