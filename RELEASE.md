# Q*Bert Pyramid WEB 1.2.0

**Release stabile approvata dall'utente il 16 novembre 2026.**
Documentazione della versione congelata alla stessa data. Tag: `v1.2.0`.
Repository ufficiale: https://github.com/eruggie/qbert-pyramid.

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
- INFORMAZIONI aggiornate alla Web 1.2.0 e voce “Torna in Sala Giochi 80 ARCADE GAMES”.

La release Windows `v1.1.0`, il suo tag e i suoi asset sono conservati.
Android, smartphone, layout mobile del gioco, touch ed Escher sono esclusi.

## Asset scaricabili

| Asset | Contenuto |
|---|---|
| QBertPyramid-1.2.0-Runtime.zip | Gioco HTML/JS/WASM/PCK, server/API e istruzioni; Godot non necessario |
| QBertPyramid-1.2.0-Complete.zip | Runtime più progetto completo, asset, strumenti, test e documentazione |
| QBertPyramid-1.2.0-Source.zip | Sorgenti esatti, manifest SHA-256 e provenienza |
| QBertPyramid-1.2.0-WebStatic.zip | Frontend statico; richiede il backend della classifica |
| SHA256SUMS.txt | Hash degli asset della release |

Licenza del materiale originale: GPL-3.0-only. Licenze di terze parti e crediti
inclusi. I pacchetti non contengono credenziali, database o dati del giocatore.

## Avvio e pubblicazione

Estrarre Runtime/Complete e seguire README.md. Serve Python >=3.10 con SQLite
per il server locale; non aprire HTML con file://. La home è alla radice,
il gioco sotto `/80_arcade_games/qbert/`.

GitHub Pages ospita la home personale. Il gioco completo richiede un host
HTTPS con Python/WSGI e storage persistente; Pages non esegue Python/SQLite.
Questa documentazione congela il software e la procedura, non dichiara
collaudato un host o un URL di gioco che non siano stati effettivamente attivati.
Destinazione e verifica del servizio pubblico sono registrate separatamente
nel repository del sito al momento del deployment, senza spostare questo tag.

Backend gratuito predisposto: PythonAnywhere Beginner, con adattatore WSGI
incluso e rinnovo mensile. [Configurazione](docs/PYTHONANYWHERE_DEPLOY.md).
L’attivazione richiede l’account personale; Google Drive non esegue il backend.

## Accettazione e verifiche

L'utente ha testato e approvato l'ultima candidata, compresi home e pacchetti,
e autorizzato completamento, commit, release GitHub e sito il 16 novembre 2026.
Le build stabili sono ricostruite dalla versione 1.2.0; gli ZIP rc non sono rinominati.
Suite: 131 test GDScript / 126776 verifiche e 32 test Python. Evidenze browser
precedenti su Chrome/Edge desktop e test manuali riferiti dall'utente sono
separati dalle verifiche della build finale e da eventuali prove di hosting.
Nessuna nuova prova nativa Windows è implicita nella pubblicazione Web.

Limiti: F11/Esc possono essere intercettati dal browser; fullscreen dipende
dalle autorizzazioni del browser. Il server accetta punteggi dichiarati dal
client e non implementa anti-cheat. La persistenza dipende dallo storage
del backend, dai backup e dalle quote dell'host.

[Download e deployment](docs/DEPLOY_WEB.md) ·
[GitHub e Pages](docs/GITHUB_PUBLICATION.md) · [Test](TEST.md).
