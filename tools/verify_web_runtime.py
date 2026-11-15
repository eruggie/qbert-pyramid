#!/usr/bin/env python3
"""Start an extracted Runtime ZIP from a path containing spaces and exercise its API."""
import argparse
import json
import pathlib
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
import zipfile

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive',type=pathlib.Path)
args=parser.parse_args()
with tempfile.TemporaryDirectory(prefix='qbert runtime review ') as folder:
    root=pathlib.Path(folder)
    with zipfile.ZipFile(args.archive) as archive:
        for name in archive.namelist():
            path=pathlib.PurePosixPath(name)
            if path.is_absolute() or '..' in path.parts:
                raise SystemExit('Invalid ZIP path: '+name)
        archive.extractall(root)
    with socket.socket() as port:
        port.bind(('127.0.0.1',0)); number=port.getsockname()[1]
    process=subprocess.Popen([sys.executable,str(root/'server/serve_web.py'),str(root/'site'),
        '--port',str(number),'--db',str(root/'private/scores.sqlite3')],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
    url=f'http://127.0.0.1:{number}'
    try:
        for attempt in range(50):
            try:
                with urllib.request.urlopen(url+'/',timeout=1) as response:
                    assert response.status==200
                break
            except (OSError,urllib.error.URLError):
                time.sleep(.1)
        else:
            raise RuntimeError('Extracted server did not start')
        with urllib.request.urlopen(url+'/80_arcade_games/qbert/arcade.css') as response:
            assert response.headers.get_content_type()=='text/css'
        endpoint=url+'/80_arcade_games/qbert/api/leaderboard'
        with urllib.request.urlopen(endpoint) as response:
            assert json.load(response)['record']==0
        payload={'submission':'0'*31+'1','name':'TST','points':123,'level':1,'round':1}
        for _ in range(2):
            request=urllib.request.Request(endpoint,data=json.dumps(payload).encode(),headers={'Content-Type':'application/json'})
            with urllib.request.urlopen(request) as response:
                state=json.load(response)
                assert state['record']==123 and len(state['leaderboard'])==1 and state['revision']==1
        assert not (root/'source/project.godot').exists()
        print(json.dumps({'result':'pass','extracted_runtime':True,'path_with_spaces':True,
            'home_http':200,'css_mime':'text/css','api_write_read_retry':True,'godot_needed_to_play':False},indent=2))
    finally:
        process.terminate()
        try:process.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill();process.communicate()
