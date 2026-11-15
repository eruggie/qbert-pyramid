# Q*Bert Pyramid WEB 1.2 — preparazione della release

**Versione locale:** 1.2.0-rc.3. **Versione stabile proposta:** 1.2.0.
**Stato:** test funzionali rc.2 approvati dall'utente; nuova presentazione,
pacchetti e pubblicazione in attesa di approvazione finale.
Preparazione: 16 novembre 2026. Nessuna data di pubblicazione è dichiarata.

## Contenuto

Port classico Godot 4.7.2 Compatibility per browser desktop. Comportamento,
controlli, asset, regole e correzioni della versione Windows 1.1.0 mantenuti.
Audio Web tramite mixer Stream; punteggi/classifica condivisi su server SQLite,
con conferma, aggiornamento automatico e retry senza duplicati.

Nuova home e cornice Web in stile arcade anni ’80: insegna e pulsanti neon,
cabinato orizzontale con schermata reale del gioco, HOME con icona accessibile. Rimossi i rilanci
ai sorgenti dall'interfaccia. Sorgenti, crediti e licenze restano distribuiti
nei pacchetti e nella documentazione, senza modificare la licenza del progetto.

## Download preparati

| Pacchetto | Contenuto |
|---|---|
| Runtime | Gioco esportato + API/server locale/WSGI + istruzioni; non richiede Godot |
| Complete | Runtime + intero progetto Godot modificabile, asset, strumenti e test |
| Source | Sorgenti esatti con manifest e provenienza |
| WebStatic | Frontend statico per integrazione; richiede backend per la classifica |
| SHA256SUMS | Verifica degli artefatti |

Un eseguibile Web è un insieme HTML/JS/WASM/PCK, non un EXE Windows.
Il servizio Python, anche nel runtime, è codice interpretato necessario alla
classifica. Non è possibile ottenere questa funzione su un host solo statico.
I pacchetti non includono database del giocatore, dati di test o credenziali.

[Download e deployment](docs/DEPLOY_WEB.md) ·
[GitHub Release e Pages](docs/GITHUB_PUBLICATION.md) · [Test](TEST.md).

## Stato dell'accettazione

L'utente dichiara completati con successo i test necessari e sufficienti per
approvare la Web 1.2 basata sulla rc.2. Questa dichiarazione è registrata come
accettazione dell'utente, senza inventare misure o dettagli non forniti.
La nuova veste grafica e gli adattamenti distributivi successivi sono preparati
per una revisione separata. Tag stabile, upload e deploy restano da autorizzare.
Windows v1.1.0, tag e asset pubblicati rimangono distinti e invariati.
Android, smartphone, touch ed Escher sono esclusi.

## Revisione della home richiesta il 16 novembre 2026

Cabinato raddrizzato; piramide decorativa sostituita da una schermata reale
del gioco, mantenendo la cornice arcade. Rimossi il sottotitolo personale e
“nessuna moneta richiesta”. Footer: “Progetto Open Source Indipendente -
Note e Licenze”. Nuova build locale rc.3 identificata dal manifest sorgenti;
nessuna pubblicazione e approvazione della presentazione ancora pendente.
