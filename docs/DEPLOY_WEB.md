# Download e deployment del gioco Web 1.2.1

Documentazione congelata: 17 novembre 2026. Software e pubblicazione approvati
dall’utente; la verifica di un host pubblico è separata dal collaudo del runtime.

## 1. Download da GitHub

Aprire il repository ufficiale `https://github.com/eruggie/qbert-pyramid`,
sezione Releases, scegliere **Q*Bert Pyramid WEB 1.2.1**, poi Assets.
Release e tag stabili: `v1.2.1`. Asset:

| Asset | Uso |
|---|---|
| `QBertPyramid-1.2.1-Runtime.zip` | Gioco pronto con backend e istruzioni, senza progetto Godot |
| `QBertPyramid-1.2.1-Complete.zip` | Gioco pronto più intero progetto modificabile, test e strumenti |
| `QBertPyramid-1.2.1-Source.zip` | Solo sorgenti corrispondenti |
| `QBertPyramid-1.2.1-WebStatic.zip` | Frontend statico per integrazione; richiede API separata |
| `SHA256SUMS.txt` | Hash SHA-256 dei download |

Gli ZIP automatici “Source code” di GitHub non sono
il gioco già esportato. Non servono i pacchetti Windows 1.1.0 per giocare Web.

Per verificare un archivio scaricato:

```powershell
Get-FileHash .\QBertPyramid-1.2.1-Runtime.zip -Algorithm SHA256
```

Confrontare con la riga corrispondente in SHA256SUMS.txt. Su Linux usare
`sha256sum -c SHA256SUMS.txt` avendo scaricato gli artefatti elencati.

## 2. Localhost Windows, WSL, Linux o macOS

Estrarre Runtime o Complete in una cartella. Non occorre compilare il gioco.
Dalla cartella estratta:

```bash
python3 server/serve_web.py site --port 8765 --db ../qbert-data/leaderboard.sqlite3
```

Windows PowerShell con il launcher Python:

```powershell
py -3 server/serve_web.py site --port 8765 --db ../qbert-data/leaderboard.sqlite3
```

Visitare http://localhost:8765/, scegliere 80 Arcade Games e poi GIOCA ORA. Il servizio ascolta
solo su localhost. Usare Python >=3.10 con il modulo SQLite standard.
Il percorso `--db` deve essere fuori da `site/`; per aggiornare usare la nuova
cartella gioco ma lo stesso database. Backup del file a server fermo.
Il database non è distribuito nei download e non contiene dati di prova.

Complete aggiunge `source/`, SOURCE_FILES.sha256 e PROVENANCE.json. Per
ricostruire: verificare il manifest dalla cartella `source/`, inizializzare un
checkout Git locale se si usa lo snapshot senza `.git`, installare la toolchain
Godot indicata e seguire source/docs/BUILD_FROM_SOURCE.md. Per il solo avvio
non sono richiesti Godot, Git, Bash o strumenti di sviluppo.

## 3. Cosa significa “qualsiasi web server”

HTML, JavaScript, WASM e PCK sono contenuti statici e possono essere serviti da
un normale server HTTP. **La classifica condivisa richiede anche esecuzione
server e storage persistente.** Un hosting esclusivamente statico o PHP-only
non esegue automaticamente l'API Python inclusa. Non si promette compatibilità
con ogni piano di hosting esistente.

Il pacchetto fornisce un adattatore WSGI per host Python, utilizzabile dietro
Nginx o Apache. Sono necessari Python >=3.10, SQLite su filesystem scrivibile
persistente, HTTPS, possibilità di avviare un servizio WSGI o equivalente.
Non usare il server `http.server` di localhost direttamente come servizio
pubblico: [documentazione Python](https://docs.python.org/3/library/http.server.html).

## 4. Esempio su un proprio server Python/WSGI

Esempio da adattare dall'amministratore all'host scelto.
Gunicorn e Nginx sono esempi, non dipendenze installate dal nostro build.
Nessun container, VM o abbonamento viene creato da questi file.

1. Copiare `site/` nella document root, ad esempio `/srv/qbert/site`.
2. Copiare `server/` fuori dalla document root, ad esempio `/srv/qbert/server`.
3. Dare all'utente del servizio accesso alla directory privata persistente
   `/var/lib/qbert`, che non deve essere servita via HTTP.
4. Configurare l'origine HTTPS esatta e avviare il modulo WSGI:

```bash
export QBERT_SCORE_DB=/var/lib/qbert/leaderboard.sqlite3
export QBERT_PUBLIC_ORIGIN=https://games.example.org
gunicorn --chdir /srv/qbert/server --bind 127.0.0.1:8766 web_wsgi:application
```

`games.example.org` è un **segnaposto**, non una destinazione predisposta.
Usare il proprio dominio e un gestore dei processi adeguato all'hosting.
Il modulo rifiuta l'avvio funzionale senza configurazione e non memorizza
password/token nel repository. Configurazione Gunicorn:
[istruzioni ufficiali](https://gunicorn.org/run/).

5. Nel server Nginx già configurato per HTTPS, servire i file da `site/` e
   inoltrare solo l'API allo stesso host/origine. Esempio di location:

```nginx
root /srv/qbert/site;
index index.html;

location = /80_arcade_games/qbert/api/leaderboard {
    proxy_pass http://127.0.0.1:8766;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location ~ \.wasm$ {
    default_type application/wasm;
    try_files $uri =404;
}

location ~ \.pck$ {
    default_type application/octet-stream;
    try_files $uri =404;
}

location / {
    try_files $uri $uri/ =404;
}
```

Il certificato HTTPS, il dominio e l'installazione del servizio restano a
carico della configurazione dell'host. Riferimento:
[Nginx proxy_pass](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass).
Apache con un ambiente WSGI equivalente può esporre lo stesso modulo.

6. Controllare MIME: `.wasm` application/wasm, `.js` JavaScript, `.pck`
   application/octet-stream. Non riscrivere gli asset mancanti verso index.html.
7. Verificare l'endpoint GET `/80_arcade_games/qbert/api/leaderboard`, poi un
   risultato salvato dal gioco, la lettura da altro browser e un riavvio.

Thread/GDExtension/PWA sono disabilitati: non sono richiesti SharedArrayBuffer
né header COOP/COEP. Il gioco e l'API restano sulla stessa origine e percorso;
non serve modificare CORS o inserire URL del backend nel client.

## 5. Hosting gratuito predisposto

PythonAnywhere Beginner: adattatore `server/hosted_wsgi.py` incluso, stesso
backend Python/SQLite e streaming dei file del gioco, senza dipendenze esterne.
[Account, configurazione, limiti e rinnovo](PYTHONANYWHERE_DEPLOY.md).
L’attivazione richiede un account reale dell’utente: non viene dichiarato
un URL attivo prima del deployment e della verifica.

## 6. Aggiornamenti e limiti

Conservare il database fuori dal pacchetto, fermare il servizio per il backup,
sostituire i file del gioco/backend e riavviare con lo stesso `--db` o
QBERT_SCORE_DB. Tenere un pacchetto precedente per rollback.
I record sono dichiarati dal client: non è incluso un sistema anti-cheat.
Quote, gestione del processo, monitoraggio e protezioni di un servizio pubblico
vanno valutati sull'host scelto prima dell'esposizione. Le configurazioni di
produzione mostrate sono documentate, non installate o certificate qui.
