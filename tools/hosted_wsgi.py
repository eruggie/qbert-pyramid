"""Serve the released game and its existing API on a managed WSGI host.

No framework, background process, CORS change or static mapping is required.
The database must remain outside the public site. Configure via factory or env.
"""
import mimetypes
import os
from pathlib import Path
from urllib.parse import urlsplit
from wsgiref.util import FileWrapper
from web_wsgi import create_application as create_scores

PREFIX = '/80_arcade_games/qbert/'
PUBLIC_FILES = frozenset({
    'index.html', 'index.js', 'index.wasm', 'index.pck', 'index.png',
    'index.icon.png', 'index.apple-touch-icon.png', 'index.audio.worklet.js',
    'index.audio.position.worklet.js', 'arcade.css', 'game-screen.png',
    'licenses.html', 'LICENSE.txt', 'THIRD_PARTY_NOTICES.txt', 'DEPENDENCY_LICENSES.txt',
    'DejaVuSans-LICENSE.txt', 'SOURCE_NOTICE.txt', 'BUILD_INFO.json',
})


def _https_url(value, origin=False):
    parsed = urlsplit(value)
    if (parsed.scheme != 'https' or not parsed.hostname or parsed.username or
            parsed.password or parsed.query or parsed.fragment or
            (origin and parsed.path not in ('', '/'))):
        raise ValueError('Configure a real HTTPS URL without credentials/query/fragment.')
    return value.rstrip('/') if origin else value


def create_application(site, database, public_origin, home_url='https://eruggie.github.io/'):
    root = Path(site).resolve(strict=True)
    game = (root / PREFIX.strip('/')).resolve(strict=True)
    database = Path(database).resolve()
    if database.is_relative_to(root):
        raise ValueError('The database must be outside the public site.')
    origin = _https_url(public_origin, origin=True)
    home = _https_url(home_url)
    scores = create_scores(database, origin)

    def response(start_response, status, body=b'', extra=(), head=False):
        start_response(status, [('Content-Type', 'text/plain; charset=utf-8'),
            ('Content-Length', str(len(body))), ('Cache-Control', 'no-store'), *extra])
        return [] if head else [body]

    def app(environ, start_response):
        path = environ.get('PATH_INFO', '')
        method = environ.get('REQUEST_METHOD', 'GET')
        if path == PREFIX + 'api/leaderboard':
            return scores(environ, start_response)
        if method not in ('GET', 'HEAD'):
            return response(start_response, '405 Method Not Allowed', b'Method not allowed.',
                            [('Allow', 'GET, HEAD')])
        head = method == 'HEAD'
        if path == '/':
            return response(start_response, '302 Found', extra=[('Location', home)], head=head)
        if path == PREFIX.rstrip('/'):
            return response(start_response, '302 Found', extra=[('Location', PREFIX)], head=head)
        name = 'index.html' if path == PREFIX else path.removeprefix(PREFIX)
        if not path.startswith(PREFIX) or name not in PUBLIC_FILES:
            return response(start_response, '404 Not Found', b'Not found.', head=head)
        try:
            file = (game / name).resolve(strict=True)
            if not file.is_relative_to(game) or not file.is_file():
                return response(start_response, '404 Not Found', b'Not found.', head=head)
            size = file.stat().st_size
            stream = None if head else file.open('rb')
        except (OSError, RuntimeError):
            return response(start_response, '404 Not Found', b'Not found.', head=head)
        mime = {'.wasm': 'application/wasm', '.pck': 'application/octet-stream',
                '.js': 'text/javascript'}.get(file.suffix) or mimetypes.guess_type(name)[0] or 'application/octet-stream'
        try:
            start_response('200 OK', [('Content-Type', mime), ('Content-Length', str(size)),
                ('Cache-Control', 'no-cache'), ('X-Content-Type-Options', 'nosniff')])
        except BaseException:
            if stream is not None:
                stream.close()
            raise
        return [] if head else environ.get('wsgi.file_wrapper', FileWrapper)(stream, 65536)
    return app


_configured = None


def application(environ, start_response):
    global _configured
    if _configured is None:
        names = ['QBERT_SITE_ROOT', 'QBERT_SCORE_DB', 'QBERT_PUBLIC_ORIGIN']
        values = [os.environ.get(name) for name in names]
        if not all(values):
            body = b'Backend not configured.'
            start_response('503 Service Unavailable', [('Content-Type', 'text/plain'),
                ('Content-Length', str(len(body))), ('Cache-Control', 'no-store')])
            return [body]
        _configured = create_application(*values, home_url=os.environ.get('QBERT_HOME_URL', 'https://eruggie.github.io/'))
    return _configured(environ, start_response)
