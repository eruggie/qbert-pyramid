# Q*Bert Pyramid — piano di progetto e release

## Current release — QBERT Rev. 1.1 / version 1.1.0

Released 2026-11-09 from the clean public source lineage. Coil captures match the
live player's 40×48 atlas frame and feet anchor; the existing death duration,
scoring, collision, input and protection rules are retained. A per-user NSIS
installer and portable edition are available for Windows 11 x86_64. The owner
reports manual Windows acceptance. See docs/releases/v1.1.0.md and docs/TESTING.md.

## Phase 7 completed — 2026-11-08

Published the clean 1.0.0 snapshot at https://github.com/eruggie/qbert-pyramid,
tag v1.0.0, and catalog https://github.com/eruggie/80-arcade-games. Public source
commit: 45c3b22c2b7a54e5f6afa729ea7535aad384a23b. Release and validation assets:
https://github.com/eruggie/qbert-pyramid/releases/tag/v1.0.0.
The public Git history starts with this snapshot only, using noreply identity;
private history and historical archives/reference media are kept separately.
Anonymous download hashes/CRC, fresh public tag rebuild and actual Windows
headless/graphical EXE startup passed. Windows smoke used isolated profiles,
Dummy audio and 120 graphical frames, not a new manual play/performance dataset.
The owner’s prior acceptance is distinguished in RELEASE_VALIDATION.md/json.
Previous preparation statements below are historical and superseded by this status.



## Owner-directed phase 6 closure — 2026-11-08

The owner requests complete phase 6 closure and instructs us to consider the
performance test and the latest menu verification on Windows performed and
accepted. Status: **phase 6 closed on the owner's declaration**, superseding the
previous pending status. No raw frame-time samples, medians/P99, timing log or
new executed ZIP hash were supplied with this declaration; none is invented or
represented as measured by the assistant. Historical reports remain unchanged.
The newly generated icon build is a subsequent change: its automated checks
and the owner's acceptance must precede any source upload/release publication.
Only creation of the two empty personal repositories is separately authorized.



## Stato corrente — release 1.1.0

La release pubblica 1.1.0 è disponibile dal tag `v1.1.0`. La pipeline e le
verifiche sono documentate in `docs/releases/v1.1.0.md` e `docs/RELEASING.md`.
Le descrizioni e le evidenze delle fasi 0–6 qui sotto restano registrazioni
storiche e non descrivono lo stato attuale della pubblicazione.


## Stato corrente e descrizione delle fasi 1–7

8 novembre 2026: **prima release QBERT Rev. 1.0 conclusa**, commit locale
autorizzato dal titolare. Windows test 1–3 superati secondo il suo resoconto;
test 4 prestazioni non eseguito e pendente. Il rilascio non certifica il
superamento di tale misura né la chiusura integrale della fase 6.
La descrizione della fase 6 è intenzionalmente vuota in questo prospetto.
La fase 7 deve ancora essere definita dall'utente e non viene iniziata.

| Fase | Descrizione |
|---|---|
| 1 | Regole fondamentali: piramide di 28 celle, salti, quattro direzioni, input e tre regole cromatiche |
| 2 | Partita completa: vite, punteggi, respawn, stati e dodici round iniziali |
| 3 | Avversari e progressione: quattro ruoli, calendario, collisioni, dischi, Stasi e progressione continua |
| 4 | Esperienza e asset: grafica/audio, menu, impostazioni, rimappatura e persistenza |
| 5 | Pacchetto Windows: esportazione x64, ZIP, licenze, sorgenti corrispondenti e ricostruzione |
| 6 | |
| 7 | Pubblicazione open source e rilascio su GitHub — preparazione locale, pubblicazione non autorizzata |

## Piano ed evidenze precedenti — registro storico


## Regola di avanzamento

La specifica è approvata. Base attuale: 0.5.4, commit 98bbc6397f4a.
L'8 novembre 2026 è autorizzata soltanto la fase 6: collaudo, correzioni
necessarie e consegna locale. Stato: **in attesa di verifica**; Windows,
durata e prestazioni richiedono evidenze specifiche della build consegnata.
La fase 7 è esclusa. Nessun commit/tag, installazione, configurazione globale,
repository remoto, push o pubblicazione è autorizzato.
I registri sotto restano storici, inclusi i precedenti divieti di fase 6.
SPEC.md distingue le funzioni effettive da quelle pianificate.
Le prove manuali ancora pendenti sono riportate separatamente sotto.

| Fase | Ambito | Criterio di uscita | Stato |
|---|---|---|---|
| 0 — Fondamenta | Istruzioni/configurazioni; documenti; Godot Compatibility; menu minimo; configurazioni di avvio/debug; runner e integrazione iniziale; toolchain; prima esportazione Windows | Doctor, suite non vuota, prove negative, ZIP completo con versione e Git; limiti e collaudi manuali pendenti documentati | Completata per l'ambito autorizzato; collaudi manuali pendenti |
| 1 — Regole fondamentali | Coordinate, salti, input, colori e simulazione deterministica | 28 celle, quattro direzioni, buffer, tre regole verificati | Completata; collaudi manuali pendenti |
| 2 — Partita completa | Stati, cadute, vite, respawn, punti, bonus e dodici round | Partita completa con presentazione essenziale | Completata; collaudo Windows fase 2 riferito dall’utente |
| 3 — Avversari e progressione | Quattro famiglie, collisioni, piattaforme, Stasi e progressione continua | Scenari riproducibili per comportamenti e simultaneità | Completata per l’ambito autorizzato; Windows 0.3.1/0.3.2 riferito dall’utente, 0.3.4 da collaudare |
| 4 — Esperienza e asset | Grafica/audio originali, menu completi, rimappatura, persistenza, display | Funzioni complete e provenienza asset registrata | Completata; EXE Windows, DPI 125%/150%, audio e F5 superati secondo il resoconto dell’utente del 5 novembre 2026 |
| 5 — Pacchetto Windows | Consolidamento del pacchetto del gioco completo sulla pipeline già predisposta nella fase 0 | Pacchetto finale del gioco legato a commit e ricostruibile | Consolidata; sorgenti, base Git e istruzioni di ricostruzione inclusi; verifiche nella sezione fase 5 |
| 6 — Collaudo e consegna | Prove reali Windows, prestazioni, durata, correzioni e regressioni | Tutti i criteri di accettazione del gioco soddisfatti con evidenze | In attesa di verifica: autorizzata 8 novembre 2026; matrice corrente in docs/ACCEPTANCE_PHASE6.md |

## Fase 0 — realizzato

- Istruzioni canoniche AGENTS.md, configurazione locale Codex e configurazioni
  VS Code per ambiente, attività, avvio e debug. Percorso del motore risolto
  come godot nel PATH; nessuna configurazione globale modificata.
- Documentazione: README.md, SPEC.md, PLAN.md, docs/TESTING.md,
  docs/REFERENCE.md, docs/ASSET_LICENSES.md e docs/ASSET_CATALOG.md.
- Progetto Godot 4.7.2 standard con renderer Compatibility, scena principale
  e menu minimo con Istruzioni, Stato del progetto ed Esci; navigazione,
  dialoghi, schermo intero e gestione iniziale del focus.
- Icona SVG originale e notices delle dipendenze in
  docs/THIRD_PARTY_NOTICES.txt. Nessun asset del riferimento riutilizzato.
- tools/doctor.sh, tools/test.sh e tools/build_windows.sh, relativi helper
  e tools/toolchain.json con versioni e impronte della toolchain.
- Runner GDScript effettivo con integrazione iniziale del menu; dati,
  configurazioni, cache e log di verifica isolati in .local-state/.
- Preset Windows Desktop x86_64 e pipeline di esportazione release che
  prepara EXE e PCK separati, documenti, licenze, metadati e checksum.
- Due commit locali della consegna iniziale; nessun repository remoto usato.

Il solo riferimento online del gioco è
https://www.classicgamesarcade.com/italiano/game/21652/q-bert.html,
consultato congiuntamente al manuale Gottlieb fornito dall'utente.
Accessibilità, pagine effettivamente lette e limiti della verifica del
contenuto Flash sono registrati in docs/REFERENCE.md.

## Fase 0 — verifiche automatiche eseguite

- Doctor: ambiente, versione esatta del motore e modelli Windows x86_64
  verificati, comprese le impronte SHA-256 registrate.
- Suite iniziale: **10 test, 95 verifiche, zero fallimenti**. Copre
  configurazione, InputMap del menu, isolamento user://, caricamento,
  dialoghi, focus e geometria a 960×540, 1280×720 e 1920×1080.
- Suite vuota e asserzione intenzionalmente fallita: entrambe restituiscono
  errore. Verificati anche motore mancante/errato e timeout non valido.
- Script eseguiti da una cartella diversa dalla radice e con percorsi
  contenenti spazi, incluso il percorso esplicito del motore.
- In una copia isolata, un test fallito e un errore di esportazione
  interrompono la build con codice non zero e senza produrre ZIP.
- ZIP, CRC, copertura dei checksum e controllo dei sorgenti invariati
  durante la build verificati; fixture errate correttamente rifiutate.
- Prima esportazione Windows e build finale della fase 0 completate.
- PCK esportato caricato senza errori con Godot Linux in modalità headless.
  Questa prova non esegue il binario Windows.

Queste evidenze riguardano l'infrastruttura della fase 0, non le future
meccaniche di gioco. Il requisito trasversale del runner non vuoto e capace
di fallire è già verificato; l'accettazione complessiva del gioco resta aperta.
Dettagli delle prove e riferimenti ai log locali: docs/TESTING.md.

## Build consegnata alla chiusura della fase 0

- Commit: 19c0f0805abdb732b48bde76f9cfc58670643116.
- Sorgenti puliti al momento della build: git.dirty=false.
- Motore: 4.7.2.stable.official.ed1daf0bf.
- Archivio locale in builds/:
  QBertPyramid-phase0-Windows-x86_64-19c0f0805abd-20261102T221653Z-ElzimUxf.zip.
- BUILD_INFO.json registra versione/hash del motore, modello di esportazione,
  commit e identità dei sorgenti; SHA256SUMS.txt e il file .zip.sha256
  registrano le impronte del pacchetto.
- Il manifest dichiara il collaudo Windows ancora pending.

Il commit precedente, 61b78ddb6418dd81840bc0cce3a7ac70dc3d82ff,
identifica la prima esportazione; la build sopra include la documentazione
aggiornata della consegna. Questi riferimenti identificano gli artefatti
consegnati, non eventuali aggiornamenti documentali successivi del piano.
Gli artefatti in builds/ e i log in .local-state/ sono esclusi da Git.

## Prove manuali pendenti e confine delle fasi successive

- Apertura dell'editor e del menu in WSL; controllo visivo di testo, icona,
  layout, navigazione, dialoghi, focus, ridimensionamento, F11 e uscita.
- F5 in VS Code, aggancio del debugger, breakpoint e passo; connessione
  LSP sulla porta 6005. Le configurazioni sono predisposte, non collaudate
  interattivamente.
- Estrazione e avvio effettivo dello ZIP su Windows 11 con account standard,
  offline e senza Godot installato; prova anche da percorso con spazi.
- Verifica visiva a 1280×720 e 1920×1080 con scala Windows 125% e 150%.

Lo ZIP della fase 0 contiene soltanto il menu minimo. L'esportazione e il caricamento
headless del PCK non dimostrano il funzionamento dell'EXE su Windows,
la resa visiva o la completezza del gioco. Nessuna prova manuale di
questo elenco risulta eseguita.

Il laboratorio della fase 1 realizza coordinate, salti, input e colori.
Vite, respawn, partita e punteggi sono ora disponibili nella fase 2, descritta
sotto; avversari, audio e persistenza restano futuri. Il collaudo di almeno
20 minuti, le cinque nuove partite e le misure dei 60 FPS richiedono prima
il gioco completo.

## Fase 1 — regole fondamentali

Implementati il nucleo GDScript indipendente da scene/dispositivi e il
laboratorio interattivo collegato al menu. Le verifiche automatiche della fase
sono completate; i collaudi manuali restano separati.

- Board di 7 file/28 celle, vicini diagonali, confini e tre regole cromatiche.
- Simulazione a tick interi 60 Hz, salti di 18 tick e recupero di 2 tick;
  atterraggio e caduta terminale, senza vite o respawn automatico.
- Input semantico separato dai dispositivi: mantenuti, buffer di 12 tick,
  priorità simultanee e pausa/reset; adapter InputMap con più tasti per azione.
- Rimappatura tramite InputMap/editor/API. Il pannello con persistenza resta
  nella fase 4; non è anticipato dal laboratorio.
- Vista originale vettoriale dei 28 prismi e attore, animata dallo stato
  logico. Tre modalità selezionabili, reset e pausa espliciti.
- Suite unitarie e integrazione obbligatorie, oltre alle prove del menu.
- tools/smoke_linux.sh distingue esecuzione grafica Linux/WSLg dai test
  senza interfaccia e dall'eseguibile Windows.

Il solo laboratorio non implementa vite, punteggio, respawn, round o avversari.
Pausa/reset del laboratorio sono controlli delle regole fondamentali,
non la macchina a stati della partita prevista nella fase 2.
Il reset chiude l'esperimento corrente, scarta il salto eventualmente in
corso e avvia un nuovo stato senza colorare celle né riutilizzare gli ID.
Ogni salto concluso durante un esperimento emette un solo esito terminale.

Risultati e collaudi distinti per piattaforma: docs/TESTING.md.

## Fase 1 — chiusura e attività pendenti

- Logica/integrazione WSL: 54 test, 50.606 verifiche, zero fallimenti
  dopo il consolidamento lettere/frecce (44 test/50.438 verifiche iniziali).
- Suite obbligatoria vuota: prova in copia isolata con percorso contenente
  spazi, correttamente rifiutata con exit 1.
- Esecuzione grafica Linux/WSLg: X11, Compatibility, llvmpipe; otto
  screenshot, zero errori, audio Dummy. Eventi automatici, non prova manuale
  di tastiera né misura delle prestazioni Windows.
- Export Windows x86_64 verificato, ZIP/CRC/SHA-256 conformi. Corrette le
  dipendenze esplicite del preset dopo aver rilevato script mancanti nel PCK.
  La build ora carica menu e laboratorio dal PCK in Linux headless prima
  di pubblicare localmente il pacchetto; errori Godot interrompono la build.
- La build consegnata prima del commit registra HEAD di base, stato dirty
  e manifest dei sorgenti effettivi della fase 1.

Non rimangono attività di implementazione della fase 1. Restano pendenti
le prove manuali con tastiera/editor/debugger, il collaudo dell'EXE su
Windows 11 e i DPI Windows. Non sono requisiti dichiarati superati.
Il pacchetto fase 1 è un laboratorio, non il gioco completo.
Alla chiusura della fase 1 la fase 2 non era iniziata; la successiva
autorizzazione e il suo completamento sono registrati nella sezione fase 2.

### Correzione fase 1 — uscita con Esc

Corretto l'accesso al viewport dopo la rimozione del laboratorio dall'albero:
il riferimento viene conservato prima della gestione dell'evento. Esc viene
consumato anche quando cambia la scena. Test di regressione sul dispatch reale
nel viewport: tre uscite/rientri, rilascio di Esc e focus del menu.
Riprodotto l'errore prima della correzione; suite completa superata dopo.
Nessun commit creato e nessuna funzionalità della fase 2 introdotta.
Al termine di quel solo intervento la correzione era nei sorgenti; il nuovo
pacchetto del consolidamento lettere/frecce include anche la correzione Esc.
Prova manuale aggiornata in WSLg e Windows ancora pendente; docs/TESTING.md.

### Consolidamento fase 1 — lettere e frecce

Completate le associazioni permanenti Q/Sinistra, E/Su, Z/Giù, C/Destra
alle azioni move_nw/ne/sw/se; conservato il tastierino. Nessun controllo dei
tasti nel nucleo logico e nessuna modifica alle regole di salto o del buffer.
Più sorgenti equivalenti mantengono una sola azione senza comandi duplicati.
Il laboratorio attivo consuma i tasti di movimento; menu, pausa e selettore
Regola mantengono la navigazione UI senza saltare. Il selettore mette in
pausa all'apertura e richiede una ripresa esplicita. Istruzioni visibili aggiornate.

Regressioni permanenti: tutte le associazioni, ordini delle coppie equivalenti,
atterraggi, echo, buffer misti e scadenza, priorità, focus, pausa/reset,
menu e tre ritorni tramite Esc. Le fasi successive devono mantenerle.

- Suite WSL headless: 54 test, 50.606 verifiche, zero fallimenti.
- Smoke WSLg: otto immagini e atterraggio con freccia destra verificati.
- Suite grafica WSLg con popup incorporati: stessi 54 test superati.
- Prova aggiuntiva con finestre native WSLg non superata (popup/timeout):
  resta da collaudare manualmente; non equiparata alla prova incorporata.
- Nuovo pacchetto Windows con checksum e identità dei sorgenti, comprensivo
  della correzione Esc. La pipeline esegue suite, export e caricamento PCK.
  Identità puntuale nel BUILD_INFO.json e nel file .zip.sha256 accanto allo ZIP.
- Nessun collaudo dell'EXE Windows; nessun commit, installazione o fase 2.

Evidenze e checklist manuale in docs/TESTING.md; uso in README.md.

### Registrazione della fase 1 in Git

La successiva richiesta autorizza il commit locale del lavoro consolidato:
regole, laboratorio, controlli lettere/frecce, correzione Esc, test, strumenti
ed evidenze documentali. Il commit non avvia la fase 2.
I sorgenti sono stati confrontati con il manifest della build verificata
(54 test, 50.606 verifiche); per la registrazione cambiano soltanto queste
annotazioni sullo stato Git. Build e log restano esclusi dal repository.
Lo ZIP già consegnato conserva la propria identità precedente al commit
(19c0f0805abd, dirty=true): non viene rigenerato né rietichettato.

## Fase 2 — partita essenziale completata

Ripresa dal commit fase 1 `42477d58ef294c7655bec273a18a85121b9b6ad1`.
All'interruzione erano già scritti nucleo della sessione, punteggio, risorsa
round, scena partita, collegamento menu, predisposizione export e test unitari.
Non esistevano ancora risultati di test della fase 2. La ripresa ha completato
integrazione, correzioni, verifiche e documentazione senza rifare la fase 1.

- Stati playing/dying/round_end/game_over/completed, con pausa separata.
- Tre vite, perdita singola per episodio, attesa di 90 tick e respawn che
  conserva colori, punti e crediti. Protezione contatti di 120 tick;
  cadute sempre letali, nessun avversario o collisione fra attori introdotto.
- Punti idempotenti 15/25 per stato/cella/round, bonus 1000/+250,
  extra a 8000 e ogni 14000; cap cinque con soglie consumate al cap.
- Dodici round configurabili in data/initial_rounds.tres; quattro per regola,
  tre livelli. Dopo l'ultimo: completamento, Nuova partita o Menu. La
  progressione continua non è anticipata e resta nella fase 3.
- Nuova scena game_screen con HUD e controlli pausa/menu/nuova partita,
  collegata al menu principale. Laboratorio e regressioni della fase 1 conservati.
- Stesse azioni lettere/frecce/tastierino, nessun comando residuo dopo pausa,
  respawn, transizioni, nuova partita e cambio scena; Esc consuma l'evento
  sul viewport conservato prima della rimozione del nodo.
- Runner esteso con due suite obbligatorie; export include configurazione e
  script della partita, e carica anche game_screen dal PCK prima dello ZIP.
- Versione 0.2.0-phase2; istruzioni del giocatore nel README e nel programma.

Verifiche: suite completa WSL **68 test, 50.836 verifiche, zero fallimenti**;
include una soluzione con salti reali per tutti i dodici round, anche
reversibili, con totale atteso di 38.580 punti. Smoke WSLg superato: 20
screenshot, partita a 960×540/1280×720/1920×1080, caduta, pausa, respawn,
Game Over e fine round/completamento. Export Windows tramite la pipeline
verificata, con EXE/PCK, documenti, metadati e checksum; consultare il
BUILD_INFO.json del pacchetto fase 2 per la sua identità.

Le attività di implementazione della fase 2 sono concluse. Restano pendenti
prove manuali tastiera/GUI/F5, finestre native WSLg, esecuzione dell'EXE su
Windows 11 e DPI. Non vengono dichiarate superate. Prestazioni, durata di
20 minuti e cinque partite del gioco completo restano al collaudo finale.
Nessun nuovo commit, software installato, pubblicazione o upload.
**La fase 3 non è iniziata.** Evidenze dettagliate: docs/TESTING.md.


## Fase 3 — avversari e progressione continua

Implementati quattro ruoli originali (Scoria, Segugio, Laterale e
Sverniciatore), salti da 24 tick, apparizioni preannunciate e rinviate se
la destinazione è occupata o in arrivo, ruoli/cap per round e RNG impostabile.
Il Segugio appare direttamente al centro del fondo: adattamento progettuale
distinto dal comportamento di trasformazione del riferimento.

Il mondo usa celle logiche, rileva condivisione di cella e incroci di salti
opposti anche tra tick, e risolve morte prima di raccolte/colori/bonus.
Il sabotatore raccolto non altera la cella; quello superstite arretra il
colore senza azzerare i crediti. Una morte annulla Stasi, rimuove attori e
rinvia apparizioni a tre secondi dall'evento; restano colori, punti e dischi.

Due dischi consumabili (sinistra riga logica 3, destra riga logica 5),
viaggio protetto di 72 tick e ritorno senza colorare. Stasi compare dopo
720 tick attivi, dura 300 tick, blocca partenze e spawn lasciando terminare
salti in corso; nella prima versione non proteggeva dai contatti
(comportamento aggiornato dalla correzione 0.3.2 sotto). Punteggi 300/100/500/50 secondo SPEC.md.
Dopo il round 12 inizia il livello 4: ciclo cromatico, intervallo di spawn,
cap e limite di velocità sono configurabili in data/initial_rounds.tres.
Rappresentazione vettoriale originale e HUD con dischi/Stasi; nessun asset
del riferimento estratto. Audio e persistenza restano alla fase 4.

Logica WSL: 83 test, 52.716 verifiche, zero fallimenti (report in
.local-state/test.lOqFjNCG/). Lo smoke WSLg in
.local-state/linux-graphics.0hwInqpt/ ha prodotto 23 screenshot, inclusa
una prima apparizione effettiva e fixture visive per i quattro ruoli.
I test finali e la build Windows sono ripetuti dalla pipeline; l'esportazione
non equivale a esecuzione dell'EXE. Nessun collaudo Windows della fase 3 è
stato eseguito. Dettagli, priorità, limiti e prove pendenti: docs/TESTING.md.

L'utente ha riferito test manuali della fase 2, incluso lo ZIP Windows; la
checklist conservata specifica prova dei round fino a livello 2 round 4.
Non attribuiamo a tali prove la verifica manuale del livello 3 o della fase 3.
Il collaudo finale di durata, prestazioni, audio e persistenza resta futuro.
La fase 4 non è stata iniziata.


## Rifiniture circoscritte della fase 3 — chiusura

Alla ripresa il codice era già implementato e verificato: dischi rialzati
con raccordo e trasporto visivo in due tratti, Scorie/Stasi volumetriche,
Segugio serpentiforme dal primo round, ritmo 81/75/68/62 tick nel primo
livello. Restavano da completare l'allineamento dei documenti e la nuova
esportazione Windows; il lavoro verificato non è stato reimplementato.

- Grafica vettoriale originale e ombre coerenti; attivazione, consumo,
  protezione e durata logica dei dischi (72 tick) conservati.
- Prima apparizione utile di ogni round riservata al Segugio, cap uno,
  preavviso e rinvio per cella non sicura. Nessuna metamorfosi o nuovo nemico.
- Fattori del Segugio 1,00/0,94/0,88/0,82 nei quattro round; gli altri
  avversari mantengono le proprie regole. Controlli e buffer conservati.
- Suite salvata: 86 test, 53.514 verifiche, zero fallimenti. Smoke WSLg
  salvato: 62 catture, inclusi entrambi i dischi nelle tre risoluzioni.
- Documenti, istruzioni e fonti aggiornati; versione pacchetto 0.3.1-phase3.
  La pipeline finale riesegue la suite ed esporta EXE/PCK con metadati e checksum.

L'utente riferisce prove funzionali in Godot senza bug osservati prima di
queste rifiniture. Non sono estese a scenari non dichiarati o a Windows.
Le evidenze precedenti restano storiche. Nessuna attività di implementazione
delle rifiniture rimane aperta; restano il collaudo manuale della versione
aggiornata e l'avvio Windows. Non sono stati creati commit né avviata la fase 4.


## Correzioni Stasi e ragnetti — fase 3, versione 0.3.2

Ambito esclusivo della nuova richiesta: protezione contatti durante Stasi,
ritorno alla vulnerabilità allo zero e riuso dei laterali come ragnetti viola
dal round 1/3. Nessuna fase 4, nuovo nemico, metamorfosi o commit.

- Corretta la risoluzione dei contatti: Stasi attiva protegge da tutte le
  famiglie letali e dagli incroci; cadute ancora letali, durata 300 tick,
  scadenza prima delle collisioni, protezioni disco/respawn indipendenti.
- Scintilla laterale disponibile dal terzo round anziché dal quinto;
  sostituito il cerchio L con due sagome originali specchiate. Rotta laterale
  senza inseguimento, tempi, cap, RNG e priorità del primo Segugio conservati.
- Aggiornati istruzioni visibili, specifica, fonti, inventario/licenze e test.
  I precedenti dischi, sfere e serpente approvati sono conservati.
- La nuova pipeline verifica regressioni, smoke WSLg con immagini ispezionate
  e pacchetto Windows con metadati/checksum; evidenze in docs/TESTING.md.

L'utente riferisce test funzionali Windows delle precedenti rifiniture senza
bug e approva la grafica. Il resoconto non certifica DPI, durata o scenari
non dichiarati, né la nuova 0.3.2: questa richiede un nuovo collaudo manuale.
Le vecchie evidenze restano storiche; nessuna fase successiva è autorizzata.


## Ragnetti soltanto nel terzo round — fase 3, versione 0.3.3

Correzione circoscritta della selezione: tipo 2 ammesso soltanto nel terzo
round di ciascun livello, inclusi quelli successivi ai dodici round iniziali.
La vecchia soglia minima globale lasciava i ragnetti disponibili anche negli
altri round. Ora viene applicato anche il filtro periodico del round nel livello.
Il cambio round già azzerava attori e preavvisi: tale comportamento è conservato
e coperto dalle regressioni. Nessuna modifica alla grafica o alle altre regole.

Test estesi su tutti i round dei primi otto livelli e livelli continui lontani,
selezione/preavviso/apparizione effettiva e confini 2→3, 3→4 e cambio livello.
Documenti e istruzioni aggiornati, nuova build con metadati/checksum; esiti
e prove ancora pendenti in docs/TESTING.md. L'esclusività richiesta è un
adattamento di Q*Bert Pyramid, distinto dalla tabella del manuale Gottlieb.

L'utente riferisce test funzionali Windows della 0.3.2 senza bug osservati e
approva la grafica. La 0.3.3 richiede un nuovo collaudo Windows; non si deducono
DPI o scenari non dichiarati. Nessun commit, nuova famiglia o fase 4.


## Calendario Gottlieb di tutti i personaggi — fase 3, versione 0.3.4

La nuova autorizzazione sostituisce il precedente filtro “solo terzo round”.
Allineata l'intera colonna personaggi della tabella PDF 7, pagina stampata 5:
Scorie, Segugio, laterali, Sverniciatore e sfera verde. Calendario unico per
candidati/preavvisi/spawn e Stasi, con livelli I–IV distinti, tutti i ruoli
dal V e prosecuzione oltre il IX nella progressione continua.

Sverniciatore e Stasi iniziano da I/3; Scorie assenti in I/3, II/1–2 e III/2;
ragnetti I/3, II/1–2–4, III–IV/2–3–4, tutti i round dal V. Il Segugio resta
sempre ammesso. Conservati prima apparizione, RNG, cap, tempi, input, punti,
collisioni, Stasi protettiva, dischi e grafica. Nessun nemico duplicato o
metamorfosi. Non si estende l'intervento a bonus o numero dei dischi originali.

Regressioni: matrice indipendente del manuale per tutti i ruoli, apparizioni
reali con seed, sfera verde ai tick 719/720/721, livelli I–IX e continui
lontani, transizioni e ripresa dopo morte. Smoke WSLg con scenari I/1, I/3,
II/1 e V/1 e build aggiornata; evidenze in docs/TESTING.md.
I risultati precedenti restano storici. Windows 0.3.4 da provare; nessun
commit, installazione, pubblicazione o avvio della fase 4.


## Fase 4 — esperienza e asset, 0.4.0

Implementati servizi separati dal nucleo: `PlayerProfile` (schema/validazione/I/O),
`App` (InputMap, audio, display, record) e `SettingsPanel` (interfaccia/cattura).
Menu con impostazioni e record; pannello dalla partita con pausa, contesto UI
isolato e pressione fresca alla ripresa. Comandi aggiuntivi persistenti senza
rimuovere lettere/frecce/tastierino, conflitti rifiutati e ripristino disponibile.

Record e impostazioni in user://, scrittura verificata con rename e backup,
recupero da dati assenti/corrotti, schema futuro protetto e fallimenti I/O non
bloccanti. Audio originale: dieci effetti e due brani con mixer, mute e pausa;
sorgente di sintesi e file WAV inclusi. Presentazione vettoriale completata
con Sverniciatore, visore, indicatori di protezione/atterraggio; conservata
la grafica approvata. Opzioni finestra/fullscreen persistenti, interfaccia
scorrevole alla dimensione minima. Regole della fase 3 conservate.

Verifiche, prove negative, importazione senza cache, smoke WSLg e pacchetto
intermedio sono registrati in docs/TESTING.md. I risultati automatici non
certificano ascolto reale, tastiera fisica, F5/LSP o esecuzione Windows/DPI.
Alla consegna queste prove erano pendenti. Il 5 novembre 2026 l’utente
riferisce esito positivo per il nuovo EXE Windows, DPI 125%/150%, audio
reale e debugger F5: fase 4 completata nel proprio ambito. Dettagli e
limiti del resoconto in docs/TESTING.md; durata, prestazioni e scenari non
dichiarati non sono certificati. La fase 5 è il prossimo passo del piano;
le fasi 5 e 6 non sono ancora iniziate.
Nessun commit creato. Le immagini locali dell'utente sono conservate.


## Fase 5 — pacchetto Windows ricostruibile, 0.5.0

Consolidata la pipeline esistente senza nuove meccaniche o modifiche ai
controlli. Il pacchetto comprende EXE/PCK, guida del giocatore, licenze/notices,
metadati, checksum e QBertPyramid-source.zip. L'archivio sorgenti contiene
il bundle del commit di base e lo snapshot completo delle modifiche non
committate distribuibili, inclusi eventuali file cancellati nel manifest
PROVENANCE.json. docs/REBUILD.md descrive recupero, verifica e ricostruzione
anche senza Codex. Manuale e immagini locali non sono redistribuiti.

Le modifiche della fase 4 e dell'utente sono conservate. Non viene creato
un nuovo commit: la build è collegata alla base 12c5808 e identificata
esattamente dal manifest SHA-256 dello snapshot (dirty=true). Non viene
promessa identità binaria di build effettuate in momenti diversi.

Dieci regressioni Python nella pipeline verificano clone reale da bundle,
overlay con nuovi file/cancellazioni, integrità e identità dei sorgenti,
archivi incompleti/alterati, percorsi insicuri, duplicati e symlink.
La suite GDScript delle fasi precedenti rimane obbligatoria e invariata.
Evidenze di esecuzione in docs/TESTING.md. La fase 6 non è iniziata:
collaudo del nuovo EXE, durata, cinque partite e misure FPS restano separati.


## Revisione audiovisiva fra fasi 5 e 6 — 0.5.1

Checkpoint invariato: b6b564f / v0.5.0-phase5. Completati atlante originale,
font pixel, geometria dei cubi, palette indipendenti, pose e HUD/scheda round,
dischi multicolore, dieci effetti originali senza musica o suoni di menu,
migrazione profili schema 1→2. La palette I/3 resta grigia anche dopo Stasi
su indicazione dell'utente; durata nel riferimento non verificata.
Matrice e limiti: docs/ARCADE_REVIEW.md. Non iniziata la fase 6.

- Suite WSL: `.local-state/test.Jo0YXfwe/report.json`, **108 test GDScript,
  118.790 verifiche, zero fallimenti**. Dieci test Python di packaging e due
  di rigenerazione asset/PCM superati nella stessa pipeline. Comprendono
  eventi audio effettivi, precedenze, assenza di musica/coda residua,
  migrazione record/livello/round, preferenze e backup precedenti, controlli
  equivalenti/buffer e tutte le regressioni del nucleo.
- WSLg: `.local-state/linux-graphics.Pzeq5yN8/graphics-report.json`, **109
  catture, zero fallimenti**, X11/Compatibility/llvmpipe, audio Dummy.
  Ispezionati menu, personaggi alle tre dimensioni, palette I/3, salto,
  arrivo sui dischi e trasporto, scheda fra round. Catture statiche e input
  programmati: nessuna prova fisica di tastiera o misura delle prestazioni.
- Primo smoke `.local-state/linux-graphics.3IaRQj3Y` rifiutato per stream
  audio ancora in uso all'uscita, sebbene le catture fossero riuscite.
  Il servizio ora rilascia lo stream quando arresta gli effetti; lo smoke
  attende lo svuotamento del buffer prima di terminare. Ripetizioni bp2rdq2V
  e Pzeq5yN8 superate senza errori del motore.
- Audio reale tentato con `bash tools/smoke_audio.sh`:
  `.local-state/audio-device.4b1nNKeC/audio-report.json`, **non superato**.
  libpulse.so.0 assente e ALSA senza dispositivo; ripiego Dummy rilevato e
  rifiutato. Nessuna installazione; nessun ascolto umano o Windows dichiarato.
  Integrità, durata e assenza di clipping PCM sono verifiche numeriche.
- I test di migrazione usano profili precedenti sintetici validi e backup
  isolati, non modificano il profilo personale dell'utente.
- La prima build 6xHAm5V1 è stata rifiutata dal controllo PCK: mancavano
  i nuovi script nel preset selettivo. Aggiunte le dipendenze esplicite.
  L'ispezione delle istruzioni ha rilevato testo fuori finestra: testo
  abbreviato e nuove catture/asserzioni di contenimento alle tre risoluzioni.

Il nuovo ZIP viene prodotto dalla pipeline completa con metadati versione
0.5.1-arcade-review, base Git e dirty=true, sorgenti e checksum. Il riferimento
puntuale è il file .zip.sha256 consegnato in chat, non lo ZIP della fase 5
congelata. Esportare e caricare il PCK su Linux non esegue l'EXE Windows.
Il collaudo audiovisivo Windows di questa revisione resta pendente; usare
la checklist in docs/ARCADE_REVIEW.md. Durata e prestazioni finali escluse.


### Chiusura della revisione

Smoke definitivo: `.local-state/linux-graphics.IJuP85it/graphics-report.json`,
**111 catture, zero fallimenti**. Istruzioni ispezionate a 960×540 e 1280×720,
contenimento verificato anche a 1920×1080. Il primo nuovo controllo di
contenimento confrontava coordinate logiche con pixel fisici: corretto per
le finestre incorporate; il testo e il pulsante restano visibili.

Build di verifica DHoumJR8 riuscita: tre scene PCK caricate su Linux,
ZIP/CRC/checksum e archivio sorgenti validi. Ricostruzione effettiva dal
suo QBertPyramid-source.zip in una cartella con spazi senza .godot:
`.local-state/arcade-rebuild.f6fw5yye/rebuild.log`. Clone del bundle, overlay,
cancellazioni esplicite del manifest, SHA-256 sorgenti, doctor, 108 test
GDScript/118.790 verifiche, 12 test Python, export e PCK superati da /tmp.
Questo snapshot precede solo la correzione delle coordinate dell'asserzione
WSLg, il controllo esplicito aggiuntivo degli asset PCK e queste evidenze.
Nessun cambiamento al comportamento del gioco successivo a tale ricostruzione.

La pipeline definitiva controlla inoltre i dieci WAV non ciclici, atlante,
font e nuovi script dentro il PCK isolato; rifiuta i vecchi file musica/menu.
Il pacchetto finale ripete l'intera pipeline e contiene questa documentazione.
Versione 0.5.1-arcade-review, Git b6b564f dirty; nome/checksum nel resoconto
in chat e file .zip.sha256. Nessun commit/tag, installazione o fase 6.
L'ascolto reale e il collaudo audiovisivo del nuovo EXE Windows restano pendenti.


## Seconda revisione video 0.5.2 — 6 novembre 2026

Implementati: correzione palette I/2–I/3, scala attori −20%, bonus sulla
piramide e scheda solo al cambio livello, attesa fine round 180 tick.
Regressioni dei confini temporali, pausa, bonus unico, input fresco e calendario
aggiornate. Materiali locali conservati, MP4 escluso da Git/pacchetto.
Analisi del video: decodifica completa, campioni sull'intera durata e segmenti
con PTS; nessun ascolto. Residui e matrice in ARCADE_REVIEW.md.
Il confronto sonoro percettivo resta pendente: non dichiarare completata una
fedeltà audiovisiva integrale. Fase 6 e relativo collaudo finale non avviati.


Verifica automatica 0.5.2: `bash tools/test.sh` riuscito, 108 test GDScript
e 118803 verifiche, oltre alle regressioni Python di packaging e asset.
Log `.local-state/test.UxUHO8Oj/`. Incluse migrazione profili schema 1→2,
record/preferenze, input equivalente, buffer, audio-eventi e assenza musica.
Smoke WSLg riuscito su X11/Compatibility/llvmpipe, audio Dummy; nessuna
prova d'ascolto. Acquisizione finale `.local-state/linux-graphics.bV71ZUXQ/`.


### Revisione soli effetti 0.5.2 — 7 novembre 2026

Analisi numerica integrale VID-01 e confronto con i dieci WAV; otto rivisti
con sintesi originale, due conservati per mancanza di evidenza separabile.
Misure, ambiguità, segmenti locali ignorati e confronto Windows in
docs/ARCADE_REVIEW.md. Regressioni audio e pacchetto aggiornati; ascolto
percettivo e nuovo EXE sul PC Windows restano da collaudare. Nessun commit/tag
o fase 6; regressioni funzionali separate da questo intervento.


## Chiusura correttiva 0.5.3, fra fasi 5 e 6

Implementati i cinque punti autorizzati: Stasi discendente deterministica,
Segugio/Coily che conserva il bersaglio del disco quando arrivato al bordo,
cue round/livello esclusivi, Game Over centrale e classifica dopo ogni fine
partita. Migrazione schema 1/2→3 con STORICO e preferenze conservate. Quattro
nuovi effetti sintetici, nessun materiale estratto negli asset. Specifiche
correnti in SPEC.md, matrice/fonti/limiti e procedura Windows in ARCADE_REVIEW.md.
Il lavoro interrotto è stato ripreso dai log, non rifatto; risultati di suite,
smoke, build e ricostruzione in TESTING.md. Nuovo EXE Windows e confronto
percettivo restano da provare; nessun commit/tag o attività della fase 6.


## Revisione 0.5.4 — sei miglioramenti autorizzati

Game Over da 30 s/pressione fresca con lampeggio; top ten locale a tre lettere
con livello/round e migrazione schema 4/cartella; identità Q*Bert Pyramid;
totali permanenti coerenti con progressione continua; conclusione centrale
con cue unico conservata; istruzioni/demo/classifica/menu da VID-02.
Sono implementati come presentazione, dati e compatibilità: nessuna nuova
regola di salto, avversari, dischi o progressione. I quattordici WAV approvati
restano invariati dopo il confronto numerico; fedeltà percepita non certificata.
Suite, WSLg, export Windows, controlli ZIP/PCK e sorgenti in TESTING.md.
Nessun commit/tag o fase 6; collaudo Windows della nuova build da eseguire.


## Fase 6 — collaudo locale, 8 novembre 2026

Base verificata 0.5.4 / 98bbc6397f4a; due immagini locali conservate.
Matrice dei dodici criteri in docs/ACCEPTANCE_PHASE6.md, prove in TEST.md.
Corretti D6-01 (report TEST assente dal pacchetto/overlay), D6-02 (licenza
obsoleta in REBUILD), D6-03 (schema 1/2 JSON senza leaderboard rifiutato).
Regressione iniziale fallita e poi superata: 124 test / 126535 verifiche,
15 test Python; WSLg 153 catture senza errori. Il solo codice prodotto
modificato è il confronto numerico iniziale nella validazione del profilo.
Restano prove Windows sul candidato, 20 minuti e cinque partite reali,
DPI/ascolto/persistenza e misure mediana/P99. **In attesa di verifica**.
Nessun commit/tag, installazione o fase 7; consegna locale con pipeline
esistente e sorgenti corrispondenti.


## Menu pubblico Rev. 1.0 — aggiornamento circoscritto

Laboratorio regole nascosto di default; configurazione e spiegazioni solo
nel documento tecnico docs/DEVELOPMENT.md. Informazioni sul gioco sostituisce
Istruzioni, con versione QBERT Rev. 1.0, autore e GPL v3.0 espliciti, mantenendo
l'aiuto di gioco. Navigazione e focus saltano il controllo tecnico nascosto.
Nessuna modifica alle regole, ai salvataggi o all'audio. Amend del solo ultimo
commit di release richiesto dal titolare; precedente commit conservato in
bundle locale ignorato. Release 1.0 conclusa, prestazioni non eseguite ancora
pendenti. Fase 7 esclusa; la sua pianificazione non viene anticipata.


## Fase 7 — Pubblicazione open source e rilascio su GitHub

Stato: **release 1.1.0 pubblicata**. La release usa un checkout pubblico
pulito, un tag stabile e sorgenti corrispondenti scaricabili; processo e
checklist sono registrati in `docs/RELEASING.md` e `docs/RELEASE_CHECKLIST.md`.

La prima release pubblica 1.0 resta disponibile come tag immutabile; la 1.1
aggiunge il comportamento COIL corretto e i pacchetti di distribuzione descritti
nelle release notes. Le note 1.1 riportano i limiti delle verifiche svolte.
Le frasi precedenti di preparazione sono registrazioni storiche superate dalla
release 1.1.0; le note correnti descrivono il contenuto e le verifiche pubblicate.

## Release 1.1.0 — 2026-11-09

Released as tag `v1.1.0`. The clean public source, Windows installer, portable
runtime and corresponding source archive are available through the GitHub release.
See `docs/releases/v1.1.0.md` for changes and validation details.
