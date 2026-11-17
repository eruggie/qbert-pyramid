# Q*Bert Pyramid WEB 1.2.1

**Release stabile approvata dall'utente il 17 novembre 2026.**
Documentazione della versione congelata alla stessa data. Tag: `v1.2.1`.
Repository ufficiale: https://github.com/eruggie/qbert-pyramid.

## Correzioni della 1.2.1

- HTTPRequest Web non decomprime nuovamente le risposte già decodificate dal
  browser: lettura e conferma dei punteggi funzionano anche con gzip.
- Attesa dei lock SQLite ridotta da 10 a 3 secondi, rispetto agli 8 secondi
  del client; risposta 503 con Retry-After e retry senza duplicati preservati.
- Test multiutente: due giochi Chrome/Edge, 32 client e quattro processi;
  nessuna perdita/duplicazione nei casi locali verificati. Nessuna garanzia
  di capacità massima del piano gratuito o di tempi sotto sovraccarico.
- Testi della pagina aggiornati; pulsanti fullscreen/comandi rimossi, indicazione
  “F11 = Schermo Intero”; Note e Licenze apre LICENSE e THIRD_PARTY_NOTICES.

Windows v1.1.0 e Web v1.2.0 mantengono tag e asset originali. Database
conservato senza migrazioni. Gameplay e associazioni dei tasti invariati.

## Contenuto della release

Port Web desktop della versione classica Windows 1.1.0, sviluppato con Godot
4.7.2 standard, GDScript e renderer Compatibility/WebGL 2. Restano invariati
regole, contenuti, grafica di gioco, controlli, progressione e correzioni 1.1.0.

- Audio Web attivato dall'avvio esplicito, con mixer Stream, volume e mute.
- Classifica condivisa sul server tramite API Python/WSGI e SQLite persistente;
  conferma del risultato, aggiornamento automatico e retry senza duplicati.
- Preferenze nel browser; nessun salvataggio della partita in corso.
- Pagina arcade con schermata reale, GIOCA ORA, HOME, gestione focus e pausa.
- Home personale “ruge.” con due soli progetti: EMCRAG Project e 80 Arcade Games.
- INFORMAZIONI aggiornate alla Web 1.2.1 e voce “Torna in Sala Giochi 80 ARCADE GAMES”.

La release Windows `v1.1.0`, il suo tag e i suoi asset sono conservati.
Android, smartphone, layout mobile del gioco, touch ed Escher sono esclusi.

## Asset scaricabili

| Asset | Contenuto |
|---|---|
| QBertPyramid-1.2.1-Runtime.zip | Gioco HTML/JS/WASM/PCK, server/API e istruzioni; Godot non necessario |
| QBertPyramid-1.2.1-Complete.zip | Runtime più progetto completo, asset, strumenti, test e documentazione |
| QBertPyramid-1.2.1-Source.zip | Sorgenti esatti, manifest SHA-256 e provenienza |
| QBertPyramid-1.2.1-WebStatic.zip | Frontend statico; richiede il backend della classifica |
| SHA256SUMS.txt | Hash degli asset della release |

Licenza del materiale originale: GPL-3.0-only. Licenze di terze parti e crediti
inclusi. I pacchetti non contengono credenziali, database o dati del giocatore.

## Avvio e pubblicazione

Estrarre Runtime/Complete e seguire README.md. Serve Python >=3.10 con SQLite
per il server locale; non aprire HTML con file://. La home è alla radice,
il gioco sotto `/80_arcade_games/qbert/`.

GitHub Pages ospita la home personale. Il gioco completo richiede un host
HTTPS con Python/WSGI e storage persistente; Pages non esegue Python/SQLite.
Home: https://eruggie.github.io/ . Gioco e API già attivi su
https://ruge.eu.pythonanywhere.com/80_arcade_games/qbert/ .
Questa documentazione congela il software e la procedura della nuova versione.
Destinazione e verifica del servizio pubblico sono registrate separatamente
nel repository del sito al momento del deployment, senza spostare questo tag.

Backend gratuito predisposto: PythonAnywhere Beginner, con adattatore WSGI
incluso e rinnovo mensile. [Configurazione](docs/PYTHONANYWHERE_DEPLOY.md).
L’attivazione richiede l’account personale; Google Drive non esegue il backend.

## Accettazione e verifiche

L'utente aveva testato e approvato la 1.2.0; il 17 novembre 2026 approva
le due correzioni verificate localmente, le modifiche alla pagina, commit e
pubblicazione della 1.2.1. I test automatici della patch sono distinti dal
collaudo manuale riferito per la versione precedente.
Le build stabili sono ricostruite dalla versione 1.2.1; gli ZIP rc non sono rinominati.
Suite: 131 test GDScript / 126778 verifiche e 41 test Python. Evidenze browser
precedenti su Chrome/Edge desktop e test manuali riferiti dall'utente sono
separati dalle verifiche della build finale e da eventuali prove di hosting.
Nessuna nuova prova nativa Windows è implicita nella pubblicazione Web.

Limiti: F11/Esc possono essere intercettati dal browser; fullscreen dipende
dalle autorizzazioni del browser. Il server accetta punteggi dichiarati dal
client e non implementa anti-cheat. La persistenza dipende dallo storage
del backend, dai backup e dalle quote dell'host.

[Download e deployment](docs/DEPLOY_WEB.md) ·
[GitHub e Pages](docs/GITHUB_PUBLICATION.md) · [Test](TEST.md).
