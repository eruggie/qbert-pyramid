#!/usr/bin/env python3
"""Local HTTPS fixture using the production WSGI app; one worker by default.

Self-signed test certificates and SQLite are kept in a new private state folder.
The optional threaded mode is a stress scenario, not the free hosting capacity.
"""
import argparse
import gzip
import io
import json
from pathlib import Path
import ssl
import subprocess
import sys
import time
from socketserver import ThreadingMixIn
from wsgiref.simple_server import WSGIServer, WSGIRequestHandler
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from hosted_wsgi import create_application, PREFIX
from leaderboard_server import Leaderboard

class Server(WSGIServer):
    request_queue_size = 128

class ThreadedServer(ThreadingMixIn, Server):
    daemon_threads = True

class Quiet(WSGIRequestHandler):
    def log_message(self,*args):pass


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('site',type=Path)
    parser.add_argument('--state',type=Path,required=True)
    parser.add_argument('--port',type=int,default=8799)
    parser.add_argument('--threaded',action='store_true')
    args=parser.parse_args()
    site=args.site.resolve(strict=True);state=args.state.resolve()
    if state.exists() or state.is_relative_to(site):parser.error('Use a new private state directory.')
    state.mkdir(parents=True)
    subprocess.run(['openssl','req','-x509','-newkey','rsa:2048','-nodes','-days','2',
        '-keyout',str(state/'localhost.key'),'-out',str(state/'localhost.crt'),
        '-subj','/CN=localhost','-addext','subjectAltName=DNS:localhost,IP:127.0.0.1'],
        check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
    scores=Leaderboard(state/'scores.sqlite3')
    for i,points in enumerate([6000,5000,4000,3000,2000,1000]):
        scores.submit({'submission':f'{i+1:032x}','name':chr(65+i)*3,'points':points,'level':1,'round':1})
    app=create_application(site,state/'scores.sqlite3',f'https://localhost:{args.port}')
    trace=state/'responses.jsonl'
    def wrapper(environ,start_response):
        path=environ.get('PATH_INFO','')
        if path in ('/','/personal.css'):
            file=site/('index.html' if path=='/' else 'personal.css')
            body=file.read_bytes()
            start_response('200 OK',[('Content-Type','text/html' if path=='/' else 'text/css'),('Content-Length',str(len(body)))])
            return [body]
        if path!=PREFIX+'api/leaderboard':return app(environ,start_response)
        payload=None
        if environ.get('REQUEST_METHOD')=='POST':
            data=environ['wsgi.input'].read(int(environ.get('CONTENT_LENGTH','0')))
            environ['wsgi.input']=io.BytesIO(data)
            try:payload=json.loads(data)
            except ValueError:pass
        result=[];begin=time.monotonic()
        stream=app(environ,lambda status,headers:result.append((status,headers)))
        try:raw=b''.join(stream)
        finally:
            if hasattr(stream,'close'):stream.close()
        compressed='gzip' in environ.get('HTTP_ACCEPT_ENCODING','') and len(raw)>=200
        body=gzip.compress(raw) if compressed else raw
        status,headers=result[0]
        headers=[(k,v) for k,v in headers if k.lower()!='content-length']
        headers.append(('Content-Length',str(len(body))))
        if compressed:headers.append(('Content-Encoding','gzip'))
        start_response(status,headers)
        with trace.open('a') as out:
            out.write(json.dumps({'time':begin,'seconds':time.monotonic()-begin,'method':environ['REQUEST_METHOD'],
                'status':int(status[:3]),'gzip':compressed,'payload':payload,'snapshot':json.loads(raw)})+'\n')
        return [body]
    server=(ThreadedServer if args.threaded else Server)(('127.0.0.1',args.port),Quiet)
    server.set_app(wrapper)
    context=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(state/'localhost.crt',state/'localhost.key')
    server.socket=context.wrap_socket(server.socket,server_side=True)
    print(f'Isolated HTTPS fixture: https://localhost:{args.port}{PREFIX}; workers={"threaded" if args.threaded else 1}',flush=True)
    try:server.serve_forever()
    except KeyboardInterrupt:pass
    finally:server.server_close()

if __name__=='__main__':main()
