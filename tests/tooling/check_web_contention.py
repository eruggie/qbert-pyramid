#!/usr/bin/env python3
"""Measure real HTTP behavior while an isolated SQLite writer holds a lock."""
import argparse
import concurrent.futures
import io
import json
from pathlib import Path
import sqlite3
import sys
import tempfile
import threading
import time
import urllib.request
import urllib.error
from wsgiref.simple_server import make_server, WSGIRequestHandler
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from web_wsgi import create_application
from leaderboard_server import Leaderboard

class Quiet(WSGIRequestHandler):
    def log_message(self,*args):pass
    def get_stderr(self):return io.StringIO()

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--report',type=Path,required=True)
args=parser.parse_args()
with tempfile.TemporaryDirectory(prefix='qbert contention ') as folder:
    database=Path(folder)/'private/scores.sqlite3'
    app=create_application(database,'https://multiuser.example.invalid')
    server=make_server('127.0.0.1',0,app,handler_class=Quiet)
    thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
    url=f'http://127.0.0.1:{server.server_port}/80_arcade_games/qbert/api/leaderboard'
    locked=threading.Event();release=threading.Event()
    def hold_lock():
        db=sqlite3.connect(database)
        db.execute('BEGIN IMMEDIATE');locked.set();release.wait(timeout=12)
        db.rollback();db.close()
    locker=threading.Thread(target=hold_lock);locker.start();assert locked.wait(timeout=2)
    payload={'submission':'1'*32,'name':'TST','points':123,'level':1,'round':1}
    def request(write):
        start=time.monotonic()
        req=urllib.request.Request(url,data=json.dumps(payload).encode() if write else None,
            headers={'Content-Type':'application/json','Origin':'https://multiuser.example.invalid'})
        try:
            with urllib.request.urlopen(req,timeout=8) as response:
                return {'status':response.status,'elapsed':time.monotonic()-start,'body':json.load(response)}
        except urllib.error.HTTPError as error:
            return {'status':error.code,'elapsed':time.monotonic()-start,'retry_after':error.headers.get('Retry-After')}
        except TimeoutError:
            return {'status':'client_timeout','elapsed':time.monotonic()-start}
    timer=threading.Timer(9.5,release.set);timer.start()
    try:
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            post=pool.submit(request,True)
            time.sleep(1)
            read=pool.submit(request,False)
            result={'post_while_locked':post.result(timeout=15),'other_user_get':read.result(timeout=15)}
        release.set();locker.join(timeout=3);timer.cancel()
        # The request may have committed after the timed-out browser disconnected.
        time.sleep(.15)
        result['rows_before_retry']=Leaderboard(database).read()['revision']
        result['retry_after_unlock']=request(True)
        result['rows_after_retry']=Leaderboard(database).read()['revision']
        assert result['retry_after_unlock']['status']==200 and result['rows_after_retry']==1
        result['server_workers']=1;result['client_timeout_seconds']=8
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(json.dumps(result,indent=2)+'\n')
        print(json.dumps(result,indent=2))
    finally:
        release.set();locker.join(timeout=3);timer.cancel();server.shutdown();server.server_close();thread.join()
