# Pubblicazione proposta: GitHub Release e GitHub Pages

Verifica delle fonti ufficiali: **16 novembre 2026**.
Stato: solo preparazione locale; nessun push, tag, release remota, repository
sito o deployment creato. Il nuovo layout e i pacchetti richiedono approvazione.

## A. Una nuova release Web nello stesso repository

Usare `eruggie/qbert-pyramid`, nuova versione **1.2.0** e nuovo tag **v1.2.0**
sul commit finale approvato. Non aggiungere la Web 1.2 agli asset Windows 1.1.0,
non spostare v1.1.0 e non creare un repository duplicato del gioco.
Le release GitHub identificano un tag e possono contenere binari e note:
[documentazione ufficiale](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).

Le build preparatorie attuali sono **1.2.0-rc.3**: la dichiarazione dell'utente
approva i test funzionali della rc.2, non equivale all'approvazione del nuovo
layout o alla pubblicazione automatica della rc.3.

Dopo l'approvazione finale:

1. Consolidare sorgenti/documentazione nel ramo pubblico, preservando cronologia
   locale e release Windows. Impostare la sola versione Web a 1.2.0.
2. Ricostruire dal commit definitivo, verificare pacchetti e SHA-256; non basta
   rinominare gli ZIP rc.3. Creare il tag v1.2.0 sul commit corrispondente.
3. Su GitHub, Releases → Draft a new release: tag v1.2.0, titolo
   **Q*Bert Pyramid WEB 1.2.0**, descrizione derivata da RELEASE.md.
4. Allegare Runtime, Complete, Source, WebStatic e SHA256SUMS.txt. I primi due
   sono i download principali per il visitatore. Rendere sempre disponibili
   i sorgenti corrispondenti insieme al runtime e conservare le licenze.
5. Verificare i download dall'esterno, hash e avvio dopo estrazione pulita.
6. Pubblicare soltanto dopo autorizzazione esplicita. Tutti questi passaggi
   remoti sono qui istruzioni future: non sono stati eseguiti.

README.md, RELEASE.md e docs/DEPLOY_WEB.md contengono già le istruzioni che
verranno rese visibili su GitHub al successivo push autorizzato. Il testo
“Source code (zip)” generato da GitHub non sostituisce il runtime giocabile.

## B. GitHub Pages e classifica: il vincolo da rispettare

GitHub Pages serve contenuti statici; non esegue il nostro Python/SQLite.
Nome del sito personale proposto: `eruggie/eruggie.github.io`, URL
`https://eruggie.github.io/`. Disponibilità remota non verificata né prenotata.
[Tipi di siti e URL ufficiali](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages).

**Proposta coerente con il gioco già accettato:** Pages ospita la nuova home
personale; 80 Arcade Games apre il gioco completo su un host HTTPS con API e database,
sotto `/80_arcade_games/qbert/`. Gioco e API rimangono sulla stessa origine.

Il sito personale resta il contenitore/ingresso del progetto. Senza un backend
non si deve presentare una copia solo statica come equivalente al gioco completo:
la classifica non funzionerebbe. Ospitare invece il canvas direttamente sul
dominio github.io con API cross-origin richiederebbe un ulteriore adattamento
CORS/client e una scelta separata; non è implementato da questa preparazione.

## C. Procedura Pages, dopo scelta dell'host e approvazione

1. Scegliere e approvare l'host HTTPS del gioco con storage persistente.
   Configurazione documentata in DEPLOY_WEB.md. Nessun host o piano viene
   attivato in questa fase.
2. Preparare **localmente** la sola home Pages. Dalla cartella dei sorgenti:

```bash
python3 tools/prepare_pages.py /percorso/al/pacchetto/site /nuova/cartella/pages-output \
  --game-url https://HOST-APPROVATO/80_arcade_games/qbert/
```

Sostituire HOST-APPROVATO con l'URL reale. Lo strumento scrive in una cartella
nuova, copia personal.css e le risorse/licenze necessarie e imposta il link al gioco; non fa push/deploy.
Non include nel sito Pages database, server Python o un gioco con API inesistente.
Se esiste già un sito personale, integrare solo i file e il collegamento
necessari senza sovrascriverne la home.

3. Dopo approvazione, creare/usare il repository pubblico
   `eruggie/eruggie.github.io`. Copiare il contenuto di pages-output nella
   radice del ramo scelto, compreso `.nojekyll`, quindi effettuare il push.
4. Settings → Pages → Build and deployment → Deploy from a branch; scegliere
   ramo e cartella `/ (root)` e salvare. La selezione può attivare il deploy:
   **non eseguirla prima dell'approvazione**.
5. Sul **sottodominio dedicato al gioco**, configurare il ritorno alla home:
   il simbolo HOME e la voce del menu ritornano alla radice del sito del gioco.
   Se la home è su Pages, quella radice deve rispondere con un redirect verso
   `https://eruggie.github.io/`. Per il percorso standard, nel server Nginx
   dedicato si può aggiungere `location = / { return 302 https://eruggie.github.io/; }`.
   Non applicare questo redirect alla radice di un sito esistente che ospita
   altri contenuti. In localhost la home resta locale e non si configura alcun redirect.
6. Controllare HTTPS, home, pulsanti, risorse e collegamento al gioco completo;
   sul suo host verificare salvataggio e lettura della classifica.

Riferimento: [configurazione della sorgente Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
GitHub Free consente Pages da repository pubblici. Rispettare i
[limiti di Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits).
Un eventuale dominio proprio e l'host del backend hanno valutazioni/costi
separati; non sono coperti automaticamente da Google AI Plus o da GitHub Pages.

## D. Cosa approvare prima di procedere

- Nuova home, cornice del gioco e simbolo HOME.
- Pacchetti runtime/completo e documentazione della distribuzione.
- Commit/tag finale v1.2.0 e pubblicazione su eruggie/qbert-pyramid.
- Destinazione del backend e pubblicazione del sito Pages.

L'approvazione dei test funzionali è registrata; non viene chiesta di nuovo.
La nuova approvazione riguarda precisamente questi elementi preparati dopo
quella dichiarazione. Nessuna fatturazione viene attivata automaticamente.
