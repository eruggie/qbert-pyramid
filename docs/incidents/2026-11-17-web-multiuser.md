# Multiutenza e classifica condivisa — verifica del 17 novembre 2026

> Aggiornamento: entrambe le correzioni approvate dall’utente il 17 novembre
> 2026 per la release 1.2.1. Segue il rapporto della fase di proposta;
> stato corrente e autorizzazione in [RELEASE.md](../../RELEASE.md).

**Stato: proposta locale in attesa di approvazione.** Nessun push, tag,
pacchetto di release o deployment. Il database pubblico non è stato modificato.
Questa verifica integra la [correzione gzip proposta](2026-11-17-web-leaderboard-gzip.md)
per la futura 1.2.1. La documentazione congelata di v1.2.0 resta invariata.

## Architettura e comportamento verificato

Ogni browser esegue la propria partita Godot/WebAssembly. Il server riceve
soltanto letture e invii della classifica: un singolo worker non limita il
gioco a una sola persona, ma serve le richieste HTTP in sequenza.

Il backend apre connessioni SQLite separate. `BEGIN IMMEDIATE` serializza le
scritture; lettura, record e revisione appartengono alla stessa transazione.
La colonna `submission` è univoca: un retry identico restituisce conferma senza
inserire un secondo risultato; riutilizzare lo stesso identificativo per un
risultato diverso produce HTTP 409. Le iniziali non identificano un account:
due partite con le stesse iniziali devono poter entrare entrambe. A parità di
punti prevale l'ordine di inserimento confermato nel database.

Le preferenze appartengono al profilo del browser e all'origine del sito.
Profili diversi sono indipendenti; schede dello stesso profilo possono
condividere le impostazioni. La classifica viene invece letta dal server,
con il polling esistente di cinque secondi: non è una trasmissione istantanea.

## Prove eseguite e risultati

Ambiente: Ubuntu 22.04/WSL, filesystem locale, Python/SQLite e applicazione
WSGI reale; database temporanei privati. Browser Windows Chrome 157 e Edge
157, automatizzati tramite CDP in modalità headless e profili nuovi.
Esportazione diagnostica Godot 4.7.2 con la correzione gzip già applicata.

| Prova | Risultato |
| --- | --- |
| Due giochi contemporanei, Chrome ed Edge, HTTPS locale, un worker | Un giocatore resta in pausa con 0 punti mentre l'altro raggiunge 50 punti. Partite indipendenti. |
| Due invii dal gioco a circa 70 ms di distanza, risposte gzip | Entrambi HTTP 200; ABC e XYZ, 50 punti ciascuno, presenti in entrambi i browser e dopo il reload. Otto righe complessive: sei fixture e due risultati, senza duplicati. |
| Preferenze separate e reload | Chrome conserva il tasto V, Edge N; impostazioni audio persistenti, nessuna classifica copiata nelle preferenze. |
| 32 client concorrenti, quattro lettori e invii ripetuti | 128 risultati distinti, 256 POST e 836 letture coerenti nell'ultima esecuzione. Nessuna perdita o duplicazione; integrità SQLite `ok`. |
| 32 client HTTP reali, un solo worker | 96 richieste tutte HTTP 200, 32 risultati distinti. Latenza massima locale circa 0,46 s. |
| 32 invii simultanei dello stesso tentativo | Una sola riga, 32 conferme HTTP 200. |
| 16 invii in conflitto sullo stesso identificativo | Una conferma e 15 HTTP 409, una sola riga. |
| Quattro processi indipendenti | 96 risultati distinti, 192 POST includendo i retry; classifica preservata dopo ricreazione dell'applicazione. |
| Parità di punti, iniziali uguali e rollback | Ordine stabile, tentativi distinti preservati e transazione non confermata assente. |
| Database con scrittore bloccante | Riprodotto il timeout della versione attuale; verificata la gestione proposta descritta sotto. |

Le sessioni browser completano anche input, pausa/ripresa, focus, audio,
impostazioni, risultati, ridimensionamento e ritorno HOME. Nessuna eccezione
JavaScript, voce di errore nel log browser o risorsa fallita nelle tracce CDP.
Ispezionate le schermate delle partite indipendenti e della classifica.

Regressioni finali: **131 test GDScript / 126778 verifiche e 41 test Python**
(12 sorgenti/pacchetti, 6 asset, 6 server, 9 distribuzione, 8 multiutenza), tutti
superati. Nessuna nuova prova dell'eseguibile nativo Windows.

## Problema aggiuntivo riprodotto e modifica proposta

Il backend attuale attende un lock SQLite fino a **10 secondi**, mentre il
client Web interrompe la richiesta dopo **8 secondi**. Con un solo worker,
anche le richieste degli altri utenti restano in coda.

Nel test negativo HTTP locale, un'altra connessione trattiene il lock di
scrittura. La versione attuale fa scadere sia il POST sia la lettura di un
secondo utente; dopo il distacco del client il POST può comunque essere
confermato dal server. Il retry era già protetto contro i duplicati.

Modifica locale proposta, oltre alla correzione gzip:

- `tools/leaderboard_server.py`: attesa SQLite **10 → 3 secondi**.
- Backend WSGI e server locale: risposta **503 con `Retry-After: 1`** quando
  il servizio è temporaneamente indisponibile.
- Conservare transazioni, identificativo del tentativo e comando di riprova
  esistenti. L'header non introduce nuovi retry automatici nel gioco.
- Eseguire la suite multiutente anche in `tools/build_web.sh`.

Con la modifica, lo stesso test restituisce 503 in circa **3,1 s**; il secondo
utente riceve GET 200 in circa **2,1 s** anziché il timeout. Nessuna scrittura
è confermata durante il blocco; rilasciato il lock, il retry restituisce 200
e inserisce esattamente una riga. La prova automatica verifica anche la
lettura di uno snapshot confermato durante un lock riservato e il doppio retry.

Il limite riguarda ciascuna attesa SQLite: **non garantisce** una durata
massima dell'intera richiesta sotto code lunghe, rete lenta o sovraccarico.
Il numero di worker, le quote e il filesystem di PythonAnywhere non sono
stati sottoposti a carico. I risultati locali non certificano 32 giocatori
sull'hosting gratuito. Nessun cambio di schema, migrazione, WAL, piano a
pagamento o modifica del gameplay è necessario per questa proposta.

## Riproduzione e artefatti

```bash
python3 -B tests/tooling/test_web_multiuser.py --report /tmp/qbert-multiuser.json
python3 -B tests/tooling/test_web_distribution.py
python3 -B tests/tooling/test_web_server.py
bash tools/test.sh
python3 tests/tooling/check_web_contention.py --report /tmp/qbert-contention.json
```

Per ripetere la prova dei due giochi serve un export diagnostico con la patch
gzip; non utilizzare gli asset pubblicati 1.2.0 per verificare tale correzione.

```bash
python3 tests/tooling/multiuser_https_fixture.py /percorso/site-diagnostico \
  --state /nuova/cartella/privata/multiuser --port 8799
```

Avviare **in parallelo** due PowerShell Windows, con gli stessi `-Url` e
`-SyncDirectory` (cartella nuova), output diversi e browser diversi:

```powershell
& .\tests\tooling\browser_multiuser.ps1 -Browser Chrome `
  -Url 'https://localhost:8799/80_arcade_games/qbert/' `
  -Output 'C:\Temp\qbert-chrome' -SyncDirectory 'C:\Temp\qbert-sync'
# In un secondo terminale usare -Browser Edge e -Output C:\Temp\qbert-edge.
```

La fixture usa certificato autofirmato e database privati, comprimendo le
risposte API. L'eccezione al certificato si applica soltanto ai processi di
test con profilo isolato; non cambiare la sicurezza del browser abituale.
Lo script consente solo localhost e impedisce invii al sito pubblico.

Evidenze della sessione: `.local-state/multiuser-2026-11-17/`, con report JSON
baseline/proposta, tracce API, screenshot e profili browser prima/dopo reload.
Regressione nativa: `.local-state/test.1hW6kh4m/`. File ignorati dal Git;
certificati, database e profili di prova non devono entrare nei pacchetti.

## Fonti ufficiali consultate il 17 novembre 2026

- [SQLite: isolamento fra connessioni](https://www.sqlite.org/isolation.html).
- [SQLite: transazioni e BEGIN IMMEDIATE](https://www.sqlite.org/lang_transaction.html).
- [PythonAnywhere: limiti del piano gratuito](https://help.pythonanywhere.com/pages/FreeAccountsFeatures/).

## Approvazione richiesta

Proposta: includere la correzione gzip e la gestione delle attese SQLite
nella stessa **1.2.1**, ricostruendo poi i pacchetti con la nuova versione.
Prima di release e deployment occorre l'approvazione dell'utente. Conservare
il database e tutti gli asset/tag precedenti. Non aggiornare il sito durante
questa fase di analisi e test.
