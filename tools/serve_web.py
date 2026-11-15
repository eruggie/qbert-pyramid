#!/usr/bin/env python3
"""Serve a generated site root without special isolation headers."""
import argparse
import functools
import http.server
import pathlib

parser=argparse.ArgumentParser()
parser.add_argument('directory',type=pathlib.Path)
parser.add_argument('--port',type=int,default=8765)
args=parser.parse_args()
root=args.directory.resolve(strict=True)
if not (root/'80_arcade_games/qbert/index.html').is_file():
    parser.error('Passare la directory site/ della build, non la sottocartella del gioco.')
class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map={**http.server.SimpleHTTPRequestHandler.extensions_map,'.wasm':'application/wasm','.pck':'application/octet-stream','.js':'text/javascript'}
    def end_headers(self):
        self.send_header('Cache-Control','no-cache')
        super().end_headers()
print(f'http://localhost:{args.port}/80_arcade_games/qbert/',flush=True)
http.server.ThreadingHTTPServer(('127.0.0.1',args.port),functools.partial(Handler,directory=str(root))).serve_forever()
