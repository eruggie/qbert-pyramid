# Backend gratuito PythonAnywhere — Web 1.2.1

Documentazione della release 1.2.1, **17 novembre 2026**. Il servizio esistente
è https://ruge.eu.pythonanywhere.com/80_arcade_games/qbert/ ; account EU `ruge`.
Gli esempi sotto permettono anche una nuova installazione. Per aggiornare
mantenere `/home/ruge/qbert-data/leaderboard.sqlite3`, fuori dai file pubblici.
Caricare i nuovi file in una directory distinta (es. `~/qbert-web-1.2.1`),
verificarli, aggiornare il percorso WSGI e ricaricare l'app. Conservare la
configurazione e la directory precedenti per il rollback. Un backup deve essere
eseguito con l'API SQLite o a servizio fermo, mai copiando un DB in scrittura.
Il reload può interrompere richieste in coda; riprovare un invio non confermato
senza ricaricare la pagina per conservare il suo identificativo.

## Perché questa scelta

Google Drive non esegue un'app Python/WSGI; il precedente hosting Web di Drive
è stato dismesso: [avviso ufficiale Google](https://workspaceupdates.googleblog.com/2016/07/reminder-turn-down-of-google-drive-web.html).
Può conservare ZIP e backup, ma non sostituisce il backend della classifica.
Google AI Plus non comprende automaticamente hosting o crediti Cloud.

Il piano **Beginner gratuito** PythonAnywhere offre un sottodominio del servizio,
una web app con un worker e 512 MiB di spazio. Le nuove app gratuite richiedono
rinnovo manuale mensile; limiti di risorse e durata non sono garanzie di uptime.
Non scegliere un piano a pagamento e non inserire una carta per questo progetto.
Fonti ufficiali: [prezzi](https://www.pythonanywhere.com/pricing/),
[limiti gratuiti](https://help.pythonanywhere.com/pages/FreeAccountsFeatures/),
[scadenza e rinnovo](https://blog.pythonanywhere.com/129/),
[quota disco](https://help.pythonanywhere.com/pages/DiskQuota).

SQLite è disponibile a tutti ma il provider non lo raccomanda per carichi di
produzione importanti: [database](https://help.pythonanywhere.com/pages/KindsOfDatabases/).
Questa configurazione è per il piccolo progetto arcade, con un solo worker;
conservare backup e rivalutare l'hosting se cresce il traffico. Se il disco è
pieno i salvataggi possono fallire; se l'app scade il gioco/API non rispondono.
Non viene attivato un upgrade automatico o un piano a consumo dal nostro codice.

## 1. Account e caricamento

Creare il piano Beginner: https://www.pythonanywhere.com/registration/register/beginner/ .
Usare il proprio indirizzo email e verificare l'account. Non inviare password
né token nella chat o nel repository. Comunicare solo username e dominio scelti.

Dalla scheda Files caricare `QBertPyramid-1.2.1-Runtime.zip` nella propria home.
Nella console Bash del servizio:

```bash
mkdir -p ~/qbert-web ~/qbert-data
python3 -m zipfile -e ~/QBertPyramid-1.2.1-Runtime.zip ~/qbert-web
```

Il database verrà creato in `~/qbert-data/leaderboard.sqlite3`, fuori dal sito.
Non caricare nel repository un database reale o copie dei dati dei giocatori.

## 2. Web app WSGI

In Web → Add a new web app scegliere il sottodominio gratuito,
**Manual configuration** e Python >=3.10. Aprire il file WSGI indicato nella
scheda Web e sostituire il contenuto con:

```python
import sys
from pathlib import Path

root = Path.home() / 'qbert-web'
sys.path.insert(0, str(root / 'server'))
from hosted_wsgi import create_application

application = create_application(
    root / 'site',
    Path.home() / 'qbert-data' / 'leaderboard.sqlite3',
    'https://USERNAME.pythonanywhere.com',
    'https://eruggie.github.io/',
)
```

Sostituire USERNAME con il dominio reale mostrato dal servizio; nel sistema EU
usare l'esatto hostname assegnato. Non scegliere un hostname ipotetico.
Non occorrono pip, Flask, Gunicorn, processi sempre attivi o servizi esterni.

**Lasciare vuote le static mappings per questo progetto:** `hosted_wsgi.py`
serve i soli file pubblici consentiti e l'API alla stessa origine, con MIME
WASM/PCK e streaming. Una mapping sull'intera cartella del gioco potrebbe
intercettare erroneamente `/api/leaderboard`. La radice `/` rimanda alla home
GitHub Pages, così HOME e il menu tornano al sito personale.

Salvare, abilitare Force HTTPS se disponibile e premere Reload. La configurazione
non deve usare `serve_web.py`: quello è soltanto il server di localhost.

## 3. Verifica online e Pages

1. Aprire `https://DOMINIO-REALE/80_arcade_games/qbert/` e avviare il gioco.
2. Verificare che `.wasm` sia `application/wasm`, `.pck` octet-stream e le
   worklet JavaScript rispondano senza errori. Nessun requisito COOP/COEP.
3. Aprire `/80_arcade_games/qbert/api/leaderboard`: deve rispondere JSON.
4. Registrare un risultato dal gioco, leggerlo in un altro browser/profilo,
   fare Reload dell'app e verificare che persista. Non usare punteggi fittizi
   nel database pubblico definitivo.
5. Preparare Pages con l'URL reale usando `tools/prepare_pages.py`; pubblicare
   la home approvata su eruggie.github.io e verificare entrambi i collegamenti.
6. Verificare HOME e “Torna in Sala Giochi 80 ARCADE GAMES” verso Pages.

Conservare il database durante aggiornamenti e rinnovi. Effettuare backup a
servizio fermo o tramite API di backup SQLite; non copiare solo parte di un DB
mentre è in scrittura. Il gioco non include anti-cheat o identità degli utenti.
Il rinnovo mensile è un'attività del titolare, non un automatismo del pacchetto.

Le verifiche locali del modulo WSGI non certificano il deployment pubblico;
registrare URL, data, esiti e limiti effettivi nel README del repository del sito.
