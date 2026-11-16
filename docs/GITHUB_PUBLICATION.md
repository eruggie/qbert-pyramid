# GitHub Release e GitHub Pages — Web 1.2.0

Documentazione congelata il **16 novembre 2026**. L'utente ha approvato
l'ultima candidata, la home personale “ruge.”, i pacchetti e la pubblicazione.
Non serve ripetere tale approvazione per i passaggi qui descritti.
Stato operativo e URL effettivamente verificati sono registrati separatamente
nel repository del sito e nel rapporto di pubblicazione, senza cambiare il tag.

## Release ufficiale

Repository: `eruggie/qbert-pyramid`; tag stabile **v1.2.0** sul commit definitivo.
Windows v1.1.0 mantiene tag e asset originali. La versione 1.2.0 è ricostruita
con Godot e template 4.7.2: non si rinominano gli ZIP delle candidate.
Le release GitHub identificano un tag e possono allegare binari e note:
[documentazione ufficiale](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).

Asset principali: Runtime, Complete, Source, WebStatic e SHA256SUMS.txt.
Rapporto QA, evidenze e BUILD_INFO possono essere allegati separatamente.
Runtime serve a giocare senza Godot; Complete aggiunge tutti i sorgenti.
I download “Source code” automatici di GitHub sono sorgenti, non il runtime.

Prima di rendere pubblica la release verificare suite, export, ZIP, manifest,
identità commit/tag, avvio dopo estrazione e checksum. Dopo l'upload scaricare
nuovamente gli asset pubblici e confrontarne gli hash.

## Architettura del sito approvata

Home personale su **https://eruggie.github.io/**, repository
**eruggie/eruggie.github.io**, con due sole voci:

- EMCRAG Project: https://github.com/eruggie/EMCRAG/blob/main/README.md
- 80 Arcade Games: gioco completo sotto `/80_arcade_games/qbert/` sull'host HTTPS.

GitHub Pages serve contenuti statici e non esegue Python/SQLite.
[Tipi di siti e URL](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages).
Gioco e API classifica devono restare sulla stessa origine, su un host con
Python/WSGI e storage persistente. Nessuna chiave di servizio va inserita
nell'HTML, in JavaScript o nei repository.

L'autorizzazione alla pubblicazione non fornisce automaticamente un account
backend: prima di attivare la home occorrono host, accesso autenticato e URL
reale del gioco verificato. Non usare URL inventati o pubblicare un link
alla classifica inesistente. Non attivare fatturazione o piani a pagamento.

Soluzione gratuita predisposta: [PythonAnywhere Beginner](PYTHONANYWHERE_DEPLOY.md),
con account personale e rinnovo mensile. Non usa Google Drive come server.

## Preparazione e attivazione Pages

Dopo il deployment del gioco e dell'API sul backend scelto, usare il suo URL:

```bash
python3 tools/prepare_pages.py /percorso/al/runtime/site /nuova/cartella/pages-output \
  --game-url https://HOST-REALE/80_arcade_games/qbert/
```

HOST-REALE è un segnaposto da sostituire. Lo strumento scrive localmente
home approvata, personal.css e risorse/licenze, imposta il link Arcade e
conserva il link EMCRAG; non pubblica un gioco privo di API su Pages.

1. Creare/usare il repository pubblico eruggie/eruggie.github.io.
2. Copiare i file generati nella radice del ramo main, inclusa `.nojekyll`;
   conservare un README con origine dei file, versione, URL e verifica del sito.
3. Eseguire commit e push. In Settings → Pages scegliere Deploy from a branch,
   ramo main e cartella `/ (root)`; oppure usare l'equivalente API GitHub Pages.
4. Attivare HTTPS e attendere l'esito della build Pages. Controllare home e link
   dall'esterno e con un browser desktop.
5. Sul sottodominio dedicato al gioco configurare la radice `/` come redirect
   verso https://eruggie.github.io/: HOME e la voce di menu continueranno a
   usare il percorso relativo `../../`. Non cambiare la radice di un sito che
   ospita altri contenuti. In localhost HOME torna alla home locale.
6. Verificare gioco/API HTTPS, MIME WASM/PCK, audio, focus, classifica condivisa,
   salvataggio e lettura da un altro profilo, quindi persistenza al riavvio.

Fonti ufficiali verificate il 16 novembre 2026:
[sorgente Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site),
[API Pages](https://docs.github.com/en/rest/pages/pages),
[limiti Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits).
GitHub Free supporta Pages da repository pubblici. Eventuali dominio proprio
e hosting backend hanno condizioni separate; Google AI Plus non li include
automaticamente.
