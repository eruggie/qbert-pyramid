#!/usr/bin/env python3
"""Verify an exported static site, matching sources and nested HTTP asset paths."""
import argparse
import hashlib
import http.server
import json
import pathlib
import threading
import urllib.parse
import urllib.request
import zipfile
from html.parser import HTMLParser
import release_sources

class Links(HTMLParser):
    def __init__(self):
        super().__init__(); self.links=[]
    def handle_starttag(self, tag, attrs):
        self.links.extend(value for key,value in attrs if key in ('href','src') and value)

parser=argparse.ArgumentParser()
parser.add_argument('site',type=pathlib.Path)
args=parser.parse_args()
site=args.site.resolve(strict=True)
game=site/'80_arcade_games/qbert'
info=json.loads((game/'BUILD_INFO.json').read_text())
assert info['threads'] is False and info['extensions'] is False
source_path=next(site.parent.glob('QBertPyramid-*-Source.zip'), game/'QBertPyramid-source.zip')
source=source_path.read_bytes()
release_sources.verify(source)
with zipfile.ZipFile(source_path) as z:
    provenance=json.loads(z.read('PROVENANCE.json'))
    assert provenance['source_identity_sha256']==info['source_identity_sha256']
    for required in ['web/shell.html','web/site-index.html','tools/build_web.sh','tools/web_package.py','web/arcade.css','web/game-screen.png','tools/web_wsgi.py','RELEASE.md','docs/DEPLOY_WEB.md','docs/GITHUB_PUBLICATION.md']:
        assert 'source/'+required in z.namelist(),required
class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self,*a,**kw): super().__init__(*a,directory=str(site.parent),**kw)
    def log_message(self,*a): pass
server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler)
thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
base=f'http://127.0.0.1:{server.server_port}/{site.name}/'
checked=[]
try:
    for path in site.rglob('*.html'):
        document_url=urllib.parse.urljoin(base,path.relative_to(site).as_posix())
        document=path.read_text()
        assert 'github.com/eruggie/qbert-pyramid' not in document,'Source links must stay outside the game UI'
        links=Links();links.feed(document)
        for link in links.links:
            if urllib.parse.urlparse(link).scheme or link.startswith('#'): continue
            assert not link.startswith('/'),'Absolute path breaks subfolder hosting: '+link
            target=urllib.parse.urljoin(document_url,link)
            assert target.startswith(base),target
            with urllib.request.urlopen(target) as response:
                assert response.status==200
                response.read()
                checked.append(target.removeprefix(base))
    assert (game/'arcade.css').is_file()
    assert 'class="home-link"' in (game/'index.html').read_text()
    for name,mime in [('index.wasm','application/wasm'),('index.js','text/javascript'),('index.pck','application/octet-stream')]:
        with urllib.request.urlopen(base+'80_arcade_games/qbert/'+name) as response:
            expected={'text/javascript','application/javascript'} if name.endswith('.js') else {mime}
            assert response.headers.get_content_type() in expected,(name,response.headers)
            assert len(response.read())==(game/name).stat().st_size
            checked.append(name)
finally:
    server.shutdown();server.server_close();thread.join()
result={'result':'pass','nested_prefix':'/'+site.name+'/', 'checked':checked,'source_identity':info['source_identity_sha256']}

# Runtime is runnable without the Godot project; Complete contains the exact source snapshot.
version=info['candidate']
with zipfile.ZipFile(site.parent/f'QBertPyramid-{version}-Runtime.zip') as runtime:
    names=runtime.namelist()
    assert 'site/index.html' in names and 'server/web_wsgi.py' in names
    assert 'source/project.godot' not in names
    assert not any(name.endswith(('.sqlite3','.sqlite','.db')) for name in names)
    for name in ['DEPLOY_WEB.md','GITHUB_PUBLICATION.md','RELEASE.md','TEST.md','README.md']:
        assert name in names
    assert runtime.testzip() is None
with zipfile.ZipFile(site.parent/f'QBertPyramid-{version}-Complete.zip') as complete, zipfile.ZipFile(source_path) as sources:
    assert 'site/index.html' in complete.namelist()
    for name in sources.namelist():
        assert complete.read(name)==sources.read(name),name
    assert complete.testzip() is None
result['packages_checked']=True
print(json.dumps(result,indent=2))
