## Release 1.1.0 — verifiche correnti

La suite `bash tools/test.sh` include la regressione COIL, i controlli di
packaging/sorgenti e la rigenerazione degli asset. Il riepilogo e i limiti
dell'evidenza sono in [release 1.1.0](releases/v1.1.0.md). L'accettazione
manuale Windows è riferita dal titolare (2026-11-09).

# Test e accettazione

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



## Publication status — release 1.1.0

Release 1.1.0 is published from the clean public source lineage. This heading
replaces the preparation status that applied on 2026-11-08; the dated records
below remain historical evidence for their stated snapshots.


## Aggiornamento corrente — 8 novembre 2026, prima release

**QBERT Rev. 1.0: prima release conclusa per richiesta del titolare.**
L'utente riferisce superati i test Windows 1–3 della checklist sul candidato
fase 6 SHA-256 `3bc86ef6c78176f2df67070744b7149316c53c2c92134310b1897f8ce26225c6`.
Il test 4 prestazionale è **non eseguito, pendente**, per mancanza dello
strumento; non è fallito. Dettaglio e limiti della dichiarazione in TESTS.md.
Questo aggiornamento supera soltanto gli stati «Windows non eseguito» sotto:
le registrazioni e gli esiti diretti precedenti restano storici. Non si
inventa una misura di durata o prestazioni. La fase 6 non è integralmente
certificata completata; la fase 7 non è iniziata.
La release 1.0.0 cambia soltanto metadati, dicitura nelle istruzioni e
 documentazione; non è dichiarato un nuovo collaudo Windows della nuova etichetta.

## Registro precedente — conservato


## Stato corrente — fase 6, 8 novembre 2026

**In attesa di verifica**, fase 7 esclusa. La matrice operativa dei dodici
criteri è [ACCEPTANCE_PHASE6.md](ACCEPTANCE_PHASE6.md); esiti, difetti e log
correnti sono in [TEST.md](../TEST.md). Le sezioni sotto sono storiche:
non estendono accettazioni Windows a build diverse o misure non eseguite.
Base corrente 0.5.4 / 98bbc6397f4a; stato/identità del candidato nel suo
BUILD_INFO.json e nel manifest sorgenti. Suite corretta: 124 test GDScript,
126535 verifiche e 15 test Python; smoke WSLg 153 catture senza errori.
Correzioni: migrazione JSON schema 1/2 senza classifica, report TEST nel
pacchetto/snapshot, istruzioni GPL di ricostruzione. Windows, durata e
prestazioni sono ancora non eseguiti sul candidato.


## Stato delle fasi 0–3

La fase 0 ha predisposto il progetto e la catena test/export. La fase 1
aggiunge regole fondamentali e laboratorio: verifiche automatiche completate.
La fase 2 aggiunge partita essenziale con vite, punteggio e dodici round.
La fase 3 aggiunge avversari, collisioni, dischi, Stasi e progressione continua.
Le evidenze di ciascuna fase sono separate sotto.

## Esecuzione

```bash
bash tools/doctor.sh
bash tools/test.sh
bash tools/build_windows.sh
```

Richiamabili da qualunque cwd usando il percorso dello script.
Le modalità negative del runner sono:

```bash
bash tools/test.sh --self-test-empty
bash tools/test.sh --self-test-failure
```

Entrambe devono restituire errore. I log restano disponibili in .local-state/.

GODOT_BIN seleziona esplicitamente il motore; versione diversa, eseguibile
non valido e modelli mancanti devono produrre un errore chiaro.
Il test importa risorse e avvia un runner GDScript SceneTree effettivo.
Il runner conta test e asserzioni, produce un report e restituisce errore
per fallimenti o zero test. Il wrapper controlla il processo, gli errori
del motore e la conclusione del runner; timeout e report incompleto falliscono.
Dati, cache, impostazioni e log dei test sono in .local-state/.

## Integrazione e suite obbligatorie

Caricamento e istanziazione della scena principale reale, presenza dei
controlli essenziali, indicazione della fase, renderer Compatibility,
apertura e chiusura dei dialoghi. Le suite della fase 2 verificano anche la partita.
Il runner esegue inoltre le suite obbligatorie
`tests/unit/test_foundation_rules.gd`, `tests/integration/test_rules_lab.gd`,
`tests/unit/test_game_rules.gd`, `tests/integration/test_game_screen.gd`
e `tests/unit/test_world_rules.gd`.
Una suite obbligatoria che non registra test o asserzioni fallisce anche
se i test precedenti erano passati. Le modalità negative verificano suite
vuota e asserzione deliberatamente errata, oltre ai controlli del motore
e del fallimento della build.
Le prove negative devono fallire: il loro exit code non zero è il risultato atteso.

## Criteri del gioco completo e stato corrente

Il requisito del runner (8) è già verificato. La fase 1 copre la logica
di celle/salti/colori e input; la fase 2 verifica vite, punti, stati e dodici round.
I collaudi manuali della build fase 3 e del gioco finale restano pendenti. Questa matrice non dichiara completata l'accettazione finale.

| ID | Criterio e prova |
|---|---|
| 1 | ZIP avviabile su Windows 11, account standard, offline, senza Godot installato; anche percorso con spazi |
| 2 | Tutte le 28 celle, quattro direzioni, confini e un esito per salto |
| 3 | Tre regole cromatiche e quattro ruoli verificati con seed riproducibili |
| 4 | Un evento letale sottrae una vita; pausa, respawn e timer corretti |
| 5 | Raggiungibilità dei 12 round e progressione continua valida e limitata |
| 6 | Punti, bonus e vite extra non duplicati; soglie multiple e limite vite |
| 7 | Record e impostazioni persistenti; dati mancanti, corrotti e scrittura negata non bloccano l'avvio |
| 8 | Test falliti restituiscono errore; suite vuota non superata |
| 9 | Menu e partita a 1280×720/1920×1080, ridimensionamento e scala Windows 125%/150% |
| 10 | Almeno 20 minuti di gioco e cinque nuove partite consecutive senza arresti o errori non gestiti |
| 11 | Obiettivo 60 FPS a 1080p sul PC di riferimento con hardware, tempi frame e misurazioni documentati |
| 12 | Sorgenti, licenze, istruzioni, versioni e identificativo Git della build consegnati |

## Strategia per le fasi successive

Test unitari sulle regole, test di integrazione delle transizioni e scenari
riproducibili da seed e comandi. Casi obbligatori: pressioni simultanee,
buffer alla scadenza, mantenuti dopo pausa, incroci sfalsati, atterraggi
simultanei, collisione sull'ultima cella, sabotaggio contemporaneo,
più cause letali, eventi di punteggio ripetuti, soglie multiple,
reset/preservazione al respawn, soluzioni riproducibili dei round.
Test automatici senza interfaccia non verificano resa grafica, audio,
scalatura DPI o comportamento effettivo del pacchetto Windows.

## Prestazioni e macchina di riferimento

Inventario iniziale: Windows 11 Home x64, build 26300.9818;
Intel Core Ultra 9 275HX; NVIDIA GeForce RTX 5070 Laptop GPU circa 8 GiB;
RAM visibile Windows circa 31,5 GiB, WSL circa 15,3 GiB.
Da riconfermare sul sistema di collaudo. Nessuna misurazione prestazionale eseguita.
Obiettivo approvato: 60 FPS release a 1080p; dopo riscaldamento mediana
entro 16,7 ms e 99º percentile entro 33,3 ms. Documentare durata,
risoluzione, driver, sincronizzazione, seed/scenario e picchi separati
di caricamento. La misura in WSL non sostituisce la misura Windows.

## Prove manuali pendenti

- Verifica manuale di editor, menu e laboratorio in WSLg; navigazione fisica della tastiera, testo, layout e icona.
- Navigazione mouse/tastiera, focus, dialoghi, F11, ridimensionamento e uscita.
- F5 in VS Code: connessione debugger, breakpoint e passo; LSP su 6005.
- Estrarre lo ZIP su Windows 11 con account standard, offline e senza Godot.
- Provare menu a 720p/1080p e scala 125%/150%, percorso con spazi e uscita.
- Collaudo di gioco, audio, persistenza, 20 minuti/cinque partite e prestazioni:
  pendenti fino alle fasi che ne realizzano le funzioni.

## Evidenze automatiche della fase 0

- Doctor eseguito anche da /tmp: Ubuntu/WSL2 x86_64, motore e modelli
  Windows x86_64 conformi a versione e SHA-256 registrati.
- Integrazione headless: 10 test, 95 verifiche, zero fallimenti. Include
  configurazione, InputMap/F11, isolamento user://, menu/istruzioni/stato,
  focus e geometria dell'interfaccia a 960×540, 1280×720, 1920×1080.
- Sintassi Bash/Python e JSON delle configurazioni verificati.
- I controlli geometrici non sono un collaudo visivo o DPI di Windows.
- Suite vuota: exit 1, zero test; assertion intenzionalmente falsa: exit 1.
- Test eseguiti da /tmp con copia del progetto in un percorso contenente spazi:
  superati (10 test/95 verifiche). Anche GODOT_BIN con spazi è accettato.
- Motore mancante, versione errata e timeout non valido: exit 1.
- In una copia isolata del repository, test deliberatamente fallito ed export
  con preset non valido interrompono entrambi la build con exit 1, senza ZIP.
- Verificatore ZIP: fixture valida accettata; manifesti vuoti, incompleti,
  duplicati, malformati e hash errati rifiutati. Controllo sorgenti: cambiamenti
  simulati al contenuto, a HEAD e allo stato dirty rifiutati.
- Prima esportazione Windows release x86_64 completata dal commit
  61b78ddb6418dd81840bc0cce3a7ac70dc3d82ff con working tree pulito.
  EXE riconosciuto PE x86_64, PCK separato non vuoto, ZIP/CRC/SHA-256 conformi,
  documenti e notices inclusi. Le build successive identificano il proprio
  commit e stato nel rispettivo BUILD_INFO.json.
- Il PCK esportato è stato avviato con Godot Linux --headless --main-pack
  e arrestato dopo 10 iterazioni, senza errori nei log. Questo verifica il
  caricamento del contenuto esportato, non l'eseguibile Windows.

Log locali delle prove iniziali (ignorati da Git):

- .local-state/test.fXHFaj7t/: suite della prima build.
- .local-state/build.aIsS7j5v/: prima esportazione e controllo ZIP.
- .local-state/package-smoke.0SO2Mdoh/: avvio PCK con motore Linux.
- .local-state/negative build with spaces.3lsuxive/: prove negative e summary.json.

Lo ZIP finale della fase include documentazione aggiornata e un nuovo commit;
consultare BUILD_INFO.json e il file .zip.sha256 per l'identità dell'artefatto.

## Fase 1 — logica e integrazione in WSL senza interfaccia

Comando: `bash tools/test.sh`. La suite mantiene i controlli del menu e
aggiunge coordinate esaustive, vicini/confini, tre regole cromatiche,
percorsi effettivi sulle 28 celle, salto 18 tick/recupero 2 tick,
TTL del buffer a 11 e 12 tick, 24 permutazioni simultanee,
ultima pressione e precedenza buffer, tap fra due tick, input invalidi
atomici, pausa/reset, caduta terminale e copie indipendenti degli snapshot.
I replay con seed sono confrontati con un riferimento cromatico indipendente.

L'integrazione copre i binding reali InputMap, più tasti per azione,
echo, dispatch di Godot con GUI in focus, rimappatura runtime e ripristino,
selettore/regole/reset, ritorno al menu e rientro nel laboratorio.
Pausa e focus vengono controllati senza trasformarli in una partita con vite.
Il reset è amministrativo: termina l'esperimento senza colorare e senza
riutilizzare ID di salti; nessun evento ritardato del vecchio esperimento.

Risultato alla chiusura iniziale: **44 test, 50.438 verifiche, zero fallimenti**. Evidenze salvate
in .local-state/test.5y0adD8w/report.json e confermate dalla build corretta
in .local-state/test.vEM1FJwx/report.json. Il wrapper verifica il report.
Comprende anche il rilascio di un tasto fuori dalla finestra e il ritorno
con un tasto ancora mantenuto: nessuna ripresa involontaria o prima pressione persa.

Prova negativa aggiuntiva: suite unitaria obbligatoria sostituita con una
suite vuota in una copia isolata (percorso con spazi), exit 1 atteso;
29 test/213 verifiche e un fallimento esplicito del contratto della suite.
Evidenza: .local-state/phase1-resume-negative/summary.json e relativo log.
I sorgenti del progetto non sono stati alterati per questa prova.

## Fase 1 — esecuzione grafica Linux tramite WSLg

Comando opzionale: `bash tools/smoke_linux.sh`. Richiede un display reale e usa audio Dummy (audio del gioco non implementato);
verifica DisplayServer diverso da headless, esegue menu e laboratorio e
salva screenshot a tre risoluzioni e con salto in corso/atterrato.
Report con piattaforma, display, renderer e GPU in
.local-state/linux-graphics.*/graphics-report.json.

Eseguita: .local-state/linux-graphics.3xSVw5t7/graphics-report.json,
otto screenshot e zero fallimenti. Display X11, gl_compatibility,
Mesa llvmpipe LLVM 15 (rendering software). Avviso del driver sulla mancata
possibilità di cambiare V-Sync; nessun errore del motore. Non è una misura FPS.
La prima esecuzione rilevava errori audio dell'ambiente WSL: il controllo
corretto usa esplicitamente Dummy, senza installazioni o modifiche globali.
Gli eventi automatici non equivalgono a una prova manuale di tastiera/periferiche;
questa esecuzione resta distinta da Windows.

## Fase 1 — esportazione ed eseguibile Windows 11

Comando: `bash tools/build_windows.sh`. I metadati del pacchetto riportano
fase 1 e versione 0.1.0-phase1. Il pacchetto è il laboratorio delle regole,
non il gioco completo né la consegna finale delle fasi 5–6.

Esportazione di regressione superata: .local-state/build.L7z0YKtj/.
Doctor, 44 test/50.438 verifiche, export release x86_64 e controlli
ZIP/CRC/SHA-256 superati. Menu e laboratorio del PCK caricati con Godot
Linux headless, senza errori. La pipeline ripete questi controlli per ogni build.

Il primo PCK della fase ometteva le dipendenze GDScript delle regole/input:
la sola esportazione riusciva, ma il caricamento del laboratorio falliva.
Il preset ora include esplicitamente gli script; il controllo di entrambe
le scene è obbligatorio prima della generazione dello ZIP. Il pacchetto
errato è stato spostato in .local-state/rejected-phase1-export/.

Le build fase 1 qui documentate precedono il commit locale e riportano
fase/versione, commit di base e dirty=true. Il manifest dei sorgenti
identifica il contenuto effettivo; BUILD_INFO.json e .zip.sha256 identificano
ciascun pacchetto, inclusa la rigenerazione con questa documentazione.

Avvio dell'EXE su Windows 11:
**non eseguito**. Nessuna prova Linux, nemmeno con un PCK esportato,
verifica l'eseguibile PE Windows, l'account standard, l'offline o i DPI.

## Regressione fase 1 — Esc durante il cambio scena

Causa: `handle_input_event()` chiama `change_scene_to_file()`, che rimuove
subito il laboratorio dall'albero. Il successivo `get_viewport()` in `_input()`
restituiva null. `_input()` ora conserva il viewport prima del dispatch e lo
usa per consumare l'evento dopo il ritorno, senza interrogare il nodo rimosso.

Il test `rules_lab_escape_consumed_across_scene_change` invia il tasto Esc
tramite `Viewport.push_input()`, attraversando `_input()` e il vero cambio scena.
Verifica l'evento consumato, la rimozione immediata del laboratorio, il menu
caricato, il rilascio del tasto senza altri cambi scena e il focus del pulsante
Laboratorio; ripete tre cicli. La prova preesistente del pulsante Indietro resta.

- Prima della correzione: .local-state/test.tVWDGthR/, exit 1, tre errori null
  e tre asserzioni fallite sull'evento non consumato; bug riprodotto.
- Dopo la correzione: `bash tools/test.sh`, .local-state/test.hvelKMsj/report.json,
  **45 test, 50.456 verifiche, zero fallimenti**, senza errori Godot.
- Queste prove sono automatiche in WSL headless. Non è stata ripetuta
  l'esecuzione grafica WSLg, né eseguito il collaudo Windows della correzione.
- In quel solo intervento gli ZIP precedenti non furono rigenerati.
  Il successivo consolidamento lettere/frecce include la correzione Esc nel nuovo ZIP.
  Nessun commit creato.

Prova manuale pendente: aprire il laboratorio, premere e rilasciare Esc,
verificare menu e focus senza errori; rientrare e ripetere, anche durante un
salto e in pausa. Ripetere in WSLg e, dopo una nuova build, su Windows 11.

## Consolidamento fase 1 — lettere/frecce (3 novembre 2026)

Requisito permanente: Q/Sinistra → move_nw, E/Su → move_ne,
Z/Giù → move_sw, C/Destra → move_se; tastierino 7/9/1/3 conservato.
Le fasi successive devono mantenere le azioni semantiche e questi test.

Copertura aggiunta in tests/integration/test_rules_lab.gd:

- Configurazione e atterraggi di tutti i dodici binding; eventi InputEventKey
  con keycode e physical_keycode, invio al viewport per attraversare `_input()`.
- Tutte le quattro coppie lettera/freccia, entrambi gli ordini di pressione
  e di rilascio (16 combinazioni); ripetizione mantenuta fino all'ultimo
  rilascio, echo ignorato, nessun buffer introdotto dal secondo equivalente.
- Buffer di una direzione diversa non sovrascritto dall'equivalente;
  duplicato tardivo non rinnova il TTL; priorità simultanee e ultima
  direzione mantenuta indipendenti dal dispositivo.
- Frecce di gioco senza spostamento del focus; frecce UI durante pausa
  senza salti o comandi residui. Popup Regola: pausa automatica e navigazione
  tramite Input.parse_input_event indirizzato alla finestra del popup.
  Il test osserva id_focused, evitando di dipendere dal successivo hover del mouse.
- Reset, pausa e focus con sorgenti miste; rilascio fuori finestra e tasto
  ancora mantenuto provati anche con freccia. Navigazione del menu con Su/Giù.
- Tre uscite con Esc durante input misto, evento consumato e rientro senza
  comandi ereditati: la correzione del viewport resta coperta.

Evidenze automatiche WSL headless: .local-state/test.HZpo55QP/report.json,
**54 test, 50.606 verifiche, zero fallimenti**. La build finale ripete la suite.
I test durante lo sviluppo hanno segnalato un percorso di iniezione errato
per il popup: usare push_input sulla finestra o emettere il suo segnale non
riproduce il dispatch nativo; la verifica finale usa il percorso del motore.

Evidenze grafiche WSLg, distinte dal collaudo Windows:

- `bash tools/smoke_linux.sh`: .local-state/linux-graphics.CswferMW/,
  otto screenshot, zero fallimenti, freccia destra tramite viewport e
  atterraggio verificato. X11, gl_compatibility, Mesa llvmpipe LLVM 15,
  audio Dummy. Immagine 960×540 ispezionata: legenda completa e leggibile.
- Suite con display e `--single-window --audio-driver Dummy`:
  .local-state/arrows-graphics-embedded.GVgqiMgI/report.json,
  54 test/50.606 verifiche superati. Popup incorporati nella finestra Linux;
  eventi sintetici, nessuna prova manuale della tastiera.
- Tentativo aggiuntivo senza --single-window:
  .local-state/arrows-graphics.VsHHsGva/, prova NON superata: asserzione del
  popup fallita e processo non terminato entro 120 s (exit 124). Questa prova
  usava il controllo del focus prima della sua stabilizzazione tramite segnale.
  Le finestre native WSLg restano da verificare manualmente; il risultato con
  popup incorporati non certifica quel percorso. Nessuna modifica globale.

Nuovo ZIP Windows: prodotto dalla pipeline tools/build_windows.sh, con EXE,
PCK, documenti, licenze, BUILD_INFO.json, manifest sorgenti, SHA256SUMS.txt
interno e .zip.sha256 esterno. Il nome univoco include fase, HEAD, dirty e data.
Il controllo PCK carica menu e laboratorio con Godot Linux e non esegue l'EXE.
Al momento di quella build HEAD era quello precedente; dirty=true identifica la presenza
anche delle modifiche conservate dalle richieste precedenti. Windows non collaudato.

Checklist manuale ancora pendente in WSLg e Windows 11:

1. Dal menu usare Su/Giù e Invio; verificare anche il dialogo Istruzioni.
2. Nel laboratorio provare Q/E/Z/C e Sinistra/Su/Giù/Destra, una alla volta;
   verificare le diagonali e che il focus UI non si sposti insieme all'attore.
3. Mantenere Z, aggiungere Giù, rilasciare Z e poi Giù; invertire gli ordini.
   Nessun salto extra alla seconda pressione, stop dopo l'ultimo rilascio.
4. Durante un salto mescolare lettere e frecce di altre direzioni; verificare
   buffer, pressioni simultanee e nessuna ripetizione dopo tutti i rilasci.
5. Provare P, R, perdita/ritorno del focus e selettore Regola con tasti mantenuti.
   In pausa le frecce navigano l'interfaccia; riprendere con una pressione fresca.
6. Uscire con Esc durante un salto, rientrare tre volte: nessun errore null
   né comando ereditato. Verificare anche l'uscita tramite pulsante.
7. Sul nuovo ZIP: avvio Windows offline, frecce/menu/popup, 720p/1080p e DPI
   125%/150%. Le prove precedenti non certificano questo eseguibile aggiornato.

Registrazione Git successiva: confrontato il contenuto dei sorgenti con il
manifest della build o3zkUPYR, senza differenze prima dell'aggiornamento di
queste annotazioni e di PLAN.md. Confermato il report finale
.local-state/test.GfWghCRN/report.json: 54 test, 50.606 verifiche, zero fallimenti.
Nessuna modifica al codice richiede di ripetere la suite per il solo commit.
Gli artefatti preesistenti conservano i metadati della loro build; il commit
non equivale a una nuova esportazione o a un collaudo Windows.

## Fase 2 — stato verificato alla ripresa

Prima della ripresa: nucleo, scena, configurazione, test unitari e aggiornamenti
export parzialmente scritti, ma mai verificati; documenti ancora riferiti alla
fase 1. Completati test d'integrazione, correzioni di compilazione degli array
GDScript, documentazione, smoke grafico ed esportazione. Le suite precedenti
non sono state eliminate o indebolite.

### Logica e integrazione WSL senza interfaccia

`bash tools/test.sh`: **68 test, 50.836 verifiche, zero fallimenti**.
Evidenza prima della build finale: .local-state/test.KWjXFtmQ/report.json.
La build finale ripete l'intera suite e conserva un nuovo report in .local-state/.

Copertura delle nuove regole:

- Configurazione di dodici round, validazione atomica e copia indipendente.
- Un solo addebito di vita per episodio letale; caduta reale, 90 tick esatti
  prima del respawn/Game Over; colori e punti preservati, apice non colorato.
- Protezione contatti fino al tick 119, scadenza al 120, cadute non protette.
  L'API contatto è verificata senza introdurre avversari o collisioni della fase 3.
- Pausa congela salto, respawn, protezione, fine round e tempo attivo.
- Punti 15/25 una sola volta per cella/stato/round, ripetizioni reversibili,
  crediti duplicati respinti; soglie esatte, multiple e consumate al cap cinque.
- Tutti i dodici round risolti con eventi semantici e salti effettivi, senza
  impostare i colori nei test di raggiungibilità. Il percorso su albero
  assegna un numero dispari di atterraggi a ciascuna cella per il reversibile;
  la modalità a due passaggi ripete la visita quando necessario.
- Per round: colori completati, bonus esatto e unico, attesa 90 tick,
  nuovo stato pulito. Totale della campagna senza morti: 38.580 punti,
  cinque vite, prossima soglia extra a 50.000. Dopo il round 12 nessun
  avanzamento, danno, timer o punto aggiuntivo fino alla nuova partita.

Integrazione effettiva menu → game_screen → menu:

- Dodici binding lettere/frecce/tastierino: atterraggio e punti, non soltanto
  presenza nell'InputMap. Sorgenti equivalenti senza buffer aggiuntivo.
- HUD aggiornato, geometria a 960×540, 1280×720 e 1920×1080.
- Pausa, navigazione UI senza salto, rilascio fuori finestra, input fresco,
  tre cadute reali con tasti mantenuti, Game Over e pulsante Nuova partita.
- Ultima cella → bonus visibile → round seguente; completamento e restart.
  Questi test UI usano fixture quasi complete: non sono la prova di
  raggiungibilità, che è invece coperta dai percorsi unitari precedenti.
- Esc durante un salto: evento consumato dopo il cambio scena, menu
  e rientro senza punti o comandi residui.

### Grafica Linux tramite WSLg

`bash tools/smoke_linux.sh`: .local-state/linux-graphics.AV59W3LF/,
20 catture e zero fallimenti. Display X11, renderer gl_compatibility,
Mesa llvmpipe LLVM 15 (software), audio Dummy. Nessuna misura FPS.
Sono visibili menu, laboratorio, partita alle tre risoluzioni, salto,
atterraggio con 25 punti, caduta, pausa, respawn, Game Over, bonus round,
round successivo e completamento. Ispezionate le immagini del menu,
della partita a 960×540 e del completamento: testo e controlli leggibili.

Le schermate di fine round/completamento usano fixture esplicite per la
copertura visiva, non una partita manuale di dodici round. Sono eventi
scriptati su display reale, non collaudo fisico della tastiera né Windows.
Il precedente limite dei popup nativi WSLg resta documentato nella fase 1;
questa fase non lo dichiara risolto e non modifica configurazioni globali.

### Pacchetto Windows e limiti

`bash tools/build_windows.sh` verifica doctor, suite completa, export release,
caricamento di menu/laboratorio/partita dal PCK tramite Godot Linux headless,
EXE/PCK non vuoti, ZIP/CRC/SHA-256 e immutabilità dei sorgenti durante la build.
Il nuovo ZIP fase 2 include README, specifica, piano, test, licenze,
BUILD_INFO.json, SOURCE_FILES.sha256, SHA256SUMS.txt e checksum esterno.
È un pacchetto intermedio giocabile, non la consegna finale delle fasi 5–6.
HEAD di base 42477d58ef294c7655bec273a18a85121b9b6ad1, modifiche fase 2
non committate e dirty=true; il manifest identifica il contenuto effettivo.

Al momento di quella esportazione l'EXE Windows non era stato eseguito;
in seguito l'utente ha annotato una prova Windows della fase 2 nella checklist.
L'export e il caricamento del PCK
con Godot Linux non verificano il binario PE, account standard, offline o DPI.
Nessun software installato e nessun servizio remoto usato.

### Checklist manuale ancora pendente

1. Avvio dal menu e da F5, breakpoint nel controller; dialoghi e navigazione.
Testato e funzionante.03/11/2026 ore 12
2. Nuova partita: provare lettere/frecce/tastierino e pressioni miste, salto
   durante pausa/focus, rilascio dei tasti prima della ripresa.
   Testato e funzionante.03/11/2026 ore 14
3. Cadere da un bordo: una vita persa, ritorno dopo 1,5 s, colori/punti
   conservati. Tre cadute portano a Game Over; Nuova partita azzera tutto.
   Testato e funzionante.03/11/2026 ore 14.45
4. Completare i round nelle tre modalità: bonus unico, transizione, input
   fresco. Dopo i dodici round compare il completamento, non il livello 4.
   Testato e funzionante fino al livello 2 Round 4
   03/11/2026 15.00
5. Esc durante salto, morte e pausa, poi rientro: niente errori né input residui.
Testato e funzionante. 3/11/2026 ore 15:02
6. Eseguire lo ZIP su Windows 11 offline con account standard senza Godot;
   720p/1080p, DPI 125%/150%, percorso con spazi. Testato e funzionante alla fase 2. 3/11/2026 ore 15:02
7. Collaudo finale di prestazioni/durata, audio, record e persistenza soltanto
   dopo le fasi che realizzano tali funzioni. La fase 3 non è iniziata.

Esportazione fase 2 effettivamente eseguita: .local-state/build.aBkdWlVh/;
suite associata .local-state/test.4c41HbGB/report.json (68 test/50.836 verifiche).
Doctor, export, tutte e tre le scene dal PCK, ZIP/CRC/SHA-256 e controllo
sorgenti superati. La rigenerazione conclusiva include anche questa evidenza
e la chiarificazione dei riepiloghi storici nel piano, senza modifiche al codice.


## Fase 3 — verifiche ed evidenze

### Prove manuali fase 2 riferite dall'utente

L'utente riferisce eseguita la checklist, escluso il punto finale sul gioco
completo, e ha annotato nella checklist precedente il funzionamento di F5,
input, cadute, Esc e ZIP fase 2 su Windows. La nota del punto 4 specifica
«fino al livello 2 Round 4»: non assumiamo verificati manualmente il livello 3
o il completamento del dodicesimo round. Nessuna prova manuale della build
fase 3 è stata eseguita per il solo fatto che la fase 2 è stata collaudata.
Le annotazioni e l'immagine non tracciata docs/image.png appartengono
all'utente e sono conservate.

### Logica WSL, senza interfaccia

`bash tools/test.sh`: **83 test, 52.716 verifiche, zero fallimenti**;
.local-state/test.lOqFjNCG/report.json. Le suite fondamentali e le
regressioni lettere/frecce sono mantenute. Copertura nuova:

- Dodici valori iniziali e progressione continua ai livelli successivi;
  limiti predefiniti, personalizzazione, validazione atomica e copia dati.
- Replay di 1800 tick con seed identici e confronto stato RNG/attori;
  preavviso di 36 tick, posizione occupata e ripresa dell'apparizione.
- Prima apparizione tramite la partita effettiva, pausa durante il preavviso;
  quattro ruoli, direzioni dei bordi e inseguimento logico. Verificati cap
  per famiglia e rinvio quando la destinazione è occupata o in arrivo.
- Collisione sull'ultima cella e raccolte simultanee: una sola morte e nessun
  punto/colore/bonus; incrocio di salti opposti di 18 e 24 tick anche fra
  tick; nessuna collisione su archi diversi.
- Raccolta del sabotatore prima della sua modifica cromatica; sabotaggio
  simultaneo all'ultima cella che impedisce vittoria/bonus; persistenza del
  registro di punteggio quando il sabotatore sopravvive.
- Stasi di 300 tick, completamento di un salto già in corso, blocco partenze,
  pausa, scadenza e successiva ripartenza.
- Disco consumato al decollo, 72 tick e pausa, ritorno senza colorare;
  collisione prima della partenza; caduta successiva a disco esaurito;
  nessuna raccolta dalla cella lasciata durante il viaggio.
- Segugio attirato fuori, anche quando la sua caduta termina dopo il ritorno,
  500 punti unici e rimozione degli altri avversari; caduta prioritaria sulle
  raccolte e tempo attivo fermo durante la morte. Collisione al decollo o
  all'atterraggio simultaneo impedisce l'emissione della partenza.
- I dodici round della regressione sono risolti con salti effettivi e spawn
  disabilitati per isolare colori/punteggio; dopo il dodicesimo parte il
  livello 4. La prova non equivale a completare manualmente la campagna
  con tutti gli avversari attivi.

### WSLg

`bash tools/smoke_linux.sh`: .local-state/linux-graphics.0hwInqpt/,
23 schermate, zero fallimenti, X11/Compatibility/llvmpipe, audio Dummy.
Controllati visivamente quattro ruoli, dischi, Stasi e viaggio; verificata
una prima apparizione nella partita effettiva. La schermata con tutti i ruoli
usa una fixture, non dimostra che compaiano tutti nello stesso round.
Eventi scriptati; nessuna nuova prova manuale con tastiera o misura FPS.

### Windows e controlli ancora pendenti

La pipeline di fase 3 verifica doctor, suite, export, caricamento PCK in
Linux di menu/laboratorio/partita, ZIP/CRC/checksum e identità dei sorgenti.
Questi controlli non eseguono l'EXE Windows. L'utente ha collaudato la fase 2,
ma il pacchetto fase 3 deve ancora essere avviato su Windows 11.

Prove manuali fase 3: verificare i quattro ruoli, avviso e spawn, contatto,
incroci, raccolta/sabotaggio, entrambi i dischi (quarta fila sinistra e sesta
destra contando dall'alto), richiamo Segugio, Stasi, pausa e respawn; arrivare
oltre il round 12. Ripetere con tastiera fisica in WSLg e su Windows offline,
account standard, percorso con spazi, 720p/1080p e DPI 125%/150%.
Restano future le prove finali 20 minuti/cinque partite, prestazioni a 60 FPS,
audio e persistenza; la fase 4 non è iniziata.

La prova negativa mirata .local-state/test.ne7yhjgU/ ha inizialmente rilevato
un evento di partenza emesso nonostante una collisione simultanea. La partenza
ora rimane provvisoria fino alla risoluzione della collisione; le verifiche
successive controllano sia il contatto a terra sia l'atterraggio avversario.


## Rifiniture circoscritte della fase 3 — verifica conclusiva

### Stato alla ripresa e prove riferite dall'utente

Alla ripresa erano già implementati e verificati dischi rialzati, raccordo
visivo del salvataggio, sfere originali Scoria/Stasi, Segugio serpentiforme
dal primo round e ritmo crescente nei quattro round. Restavano documentazione
e pacchetto aggiornato: non sono state ripetute le implementazioni concluse.
L'utente riferisce prove funzionali della fase 3 in Godot senza bug osservati,
prima di queste rifiniture. Non ne sono dedotti scenari specifici, prove della
versione rifinita o collaudi Windows. Le evidenze precedenti restano storiche.

### Verifiche automatiche WSL

`bash tools/test.sh`: **86 test, 53.514 verifiche, zero fallimenti**.
Report già verificato: `.local-state/test.vZJgwYow/report.json`.
La pipeline `bash tools/build_windows.sh` ripete la suite completa prima
dell'export e conserva il proprio nuovo report, senza alterare queste evidenze.

Regressioni aggiunte o estese:

- Segugio ammesso dal primo round, prima apparizione utile riservata,
  preavviso di 36 tick, rinvio sulla cella non sicura e cap esistenti.
- Periodi effettivi 81/75/68/62 tick nel primo livello, fattori nei livelli
  seguenti e limiti; gli altri avversari mantengono il proprio ritmo.
- Partita normale: prima apparizione al tick 300, prima partenza al 381,
  inseguimento, collisione che sottrae una sola vita, respawn e protezione.
  La morte non riapre la priorità del primo Segugio nello stesso round.
- Entrambi i dischi attraverso input reale dell'adattatore: consumo,
  continuità della posizione rappresentata lungo i 72 tick, arrivo sul
  disco al tick 18, trasporto e ritorno esatto all'apice al tick 72,
  nelle tre risoluzioni previste.
- Conservate le prove su richiamo del Segugio con il disco, pausa, Stasi,
  collisioni, punteggi e progressione, oltre a sorgenti equivalenti,
  lettere/frecce/tastierino, buffer e cambio scena con Esc.

### Grafica Linux WSLg effettivamente eseguita

`GODOT_TIMEOUT_SECONDS=180 bash tools/smoke_linux.sh`:
`.local-state/linux-graphics.NWgj2Ffb/graphics-report.json`,
**62 catture, zero fallimenti**, X11, Compatibility, llvmpipe LLVM 15,
audio Dummy. Si tratta di rendering reale con eventi scriptati, non di
prove manuali di tastiera, finestre native aggiuntive o prestazioni a 60 FPS.

Le immagini `refinement_actors_*` mostrano dischi, sfere e serpente a
960×540, 1280×720 e 1920×1080. Le sequenze
`refinement_<risoluzione>_<left|right>_t<tick>.png` acquisiscono entrambi i
salvataggi ai tick 0, 9, 18, 45, 71 e 72: partenza, volo, appoggio sul disco,
trasporto, avvicinamento e ritorno. `game_phase3_spawn.png` mostra anche la
prima apparizione nella partita normale; la panoramica con tutti i ruoli
usa una fixture, non una comparsa simultanea nel primo round.

Ispezionate le panoramiche alle tre risoluzioni, la sequenza sinistra a
1280×720, le fasi iniziali/trasporto della destra a 1280×720 e campioni di
appoggio/trasporto di entrambi i lati a 960×540 e 1920×1080. Dischi rialzati
con raccordi leggibili, sfere volumetriche e serpente riconoscibile; nei
campioni non osservati scatti o sovrapposizioni fuorvianti. Il controllo
numerico della continuità integra l'ispezione delle immagini, senza
sostituire una valutazione manuale del movimento in partita.

### Pacchetto e verifiche ancora pendenti

Versione delle rifiniture: **0.3.1-phase3**, sempre fase 3. La pipeline
Windows esegue doctor, suite completa, esportazione EXE/PCK, caricamento
Linux headless delle tre scene dal PCK, verifica ZIP/CRC/checksum e sorgenti.
`BUILD_INFO.json` registra versione motore, HEAD e dirty=true; il manifest
identifica anche le modifiche non committate. Nessun commit autorizzato.
L'esportazione e il caricamento Linux del PCK non eseguono l'EXE Windows.

Checklist manuale della versione aggiornata:

1. Nuova partita: attendere cinque secondi attivi, osservare preavviso e
   serpente al centro del fondo; controllare inseguimento e accelerazione
   dal round 1 al 4. Verificare contatto, singola vita persa e respawn.
2. Usare il disco sinistro dalla quarta fila verso alto-sinistra e quello
   destro dalla sesta verso alto-destra. Osservare salto, appoggio, trasporto,
   ombre e ritorno; provare anche richiamo del Segugio, pausa e Stasi.
3. Provare lettere, frecce e tastierino, pressioni equivalenti e miste,
   pausa, perdita del focus ed Esc: nessun comando residuo o errore.
4. Ripetere sulla nuova build in Windows 11, account standard offline,
   senza Godot, percorso con spazi, 720p/1080p e DPI 125%/150%.
   Il precedente collaudo Windows della fase 2 non vale per questo EXE.

Queste prove manuali sono pendenti. LSP e finestre native WSLg non sono
certificati dallo smoke. Durata finale, prestazioni, audio e persistenza
restano nelle fasi successive. Nessuna attività della fase 4 è iniziata.


## Correzioni Stasi/ragnetti 0.3.2 — fase 3

### Evidenza dell'utente e confine

L'utente riferisce test funzionali in Windows delle precedenti rifiniture
0.3.1, senza bug osservati, e approva la grafica. Nel seguito della richiesta
è ripetuta la formula delle prove in Godot: registriamo il resoconto senza
trasformarlo in un nostro collaudo o dedurre DPI, hardware, durata o scenari
non dichiarati. La nuova 0.3.2 deve ancora essere collaudata manualmente.
Restano conservati tutti i resoconti e le immagini locali precedenti.

### Regressioni automatiche WSL senza interfaccia

`bash tools/test.sh`: **92 test, 53.628 verifiche, zero fallimenti**.
Evidenza di sviluppo: `.local-state/test.bbYDOp5w/report.json`.
La pipeline finale riesegue l'intera suite prima di esportare; i report
sono isolati in .local-state/, senza dati del giocatore condivisi.

Nuove verifiche sugli esiti, non sui dettagli interni del disegno:

- Raccolta tramite salto effettivo della sfera verde, 100 punti una sola
  volta e 300 tick. Atterraggi su Scoria, Segugio e ragnetto senza morte,
  possibilità di lasciare la cella, nemico non consumato e nessun premio
  extra. Anche il contratto di morte rifiuta un contatto durante Stasi.
- Incrocio con un serpente già in volo protetto; caduta reale ancora letale
  e annullamento dell'energia. I salti nemici già iniziati terminano.
- Pausa ferma l'energia: residuo 1 ancora protetto, successivo passaggio a
  zero ripristina subito la letalità. Contatti multipli sottraggono una sola
  vita; respawn rimuove avversari senza ripristinare Stasi. La protezione
  indipendente del respawn resta valida se Stasi scade prima di essa.
- Nuova partita e nuovo round azzerano l'energia. Test d'integrazione con
  freccia Giù e lettera C: raccolta, perdita del focus, ripresa, contatto
  protetto su ragnetto e HUD aggiornato; scadenza e singola vita persa.
- Nessun ragnetto nei primi due round. Il vero scheduler della partita,
  con seed controllati e round 1/3 selezionato dalla fixture, genera le
  varianti su entrambi i bordi. Preavviso 36 tick, nessun anticipo e rinvio
  se la posizione è occupata; cap e selezione casuale conservati.
- Rotte su entrambi i bordi senza inseguimento; il manuale attribuisce
  l'inseguimento al serpente. Salto, pausa, contatto letale, singola vita
  persa e respawn verificati per entrambe le varianti.
- Dischi su entrambi i lati con ragnetto sulla cella e Stasi: consumo,
  viaggio 72 tick, ritorno all'apice, timer energia e nessun premio da
  inseguimento. Conservate le suite dei dischi, del Segugio, dei punteggi,
  della progressione, degli input equivalenti e del buffer.

Il primo tentativo di sviluppo `.local-state/test.bYeMSKrS/` ha rilevato
errori nelle nuove fixture (mancato recupero tra salti e tick di preavviso
anticipato). Corretti gli scenari, senza allentare le regole del nucleo;
la suite successiva sopra è superata.

### Rendering WSLg realmente eseguito e immagini ispezionate

`GODOT_TIMEOUT_SECONDS=180 bash tools/smoke_linux.sh`:
`.local-state/linux-graphics.riVHH88V/graphics-report.json`,
**72 catture, zero fallimenti**; X11, Compatibility, llvmpipe LLVM 15,
audio Dummy. Nessuna misura prestazionale o prova fisica di tastiera.

Ispezionate `spiders_both_960x540.png`, `spiders_both_1280x720.png`,
`spiders_both_1920x1080.png`: sagome originali viola specchiate, arti e occhi
leggibili, variante destra anche in salto. Controllate
`stasis_safe_contact_960x540.png` e `stasis_expired_1920x1080.png`:
sovrapposizione consentita con HUD “Contatti innocui”, poi energia zero
e una sola vita persa. La panoramica degli avversari e le sequenze dei
dischi delle rifiniture precedenti restano nella stessa esecuzione.

`spider_round3_actual_spawn.png` è ispezionata e mostra un ragnetto prodotto
dallo scheduler effettivo nel round 1/3 con seed 3. Il round e la posizione
del giocatore sono preparati dalla fixture, con protezione estesa per
osservare lo spawn: non è una partita manuale né una campagna raggiunta
senza aiuti. Le panoramiche con due varianti sono fixture grafiche esplicite.

Il tentativo `.local-state/linux-graphics.QCHiodka/` NON è superato: la
precedente fixture dei dischi lasciava lo spawn disabilitato. Ripristinata
esplicitamente l'abilitazione nella fixture del nuovo scenario e ripetuto
l'intero smoke con esito positivo; nessuna correzione alle regole richiesta.
L'avviso V-Sync del driver software non costituisce errore Godot.

### Pacchetto Windows e checklist manuale pendente

La build 0.3.2-phase3 esegue doctor, suite completa, export EXE/PCK, avvio
Linux headless delle tre scene dal PCK, ZIP/CRC/SHA-256 e controllo identità
sorgenti. BUILD_INFO.json e SOURCE_FILES.sha256 identificano HEAD e tutte
le modifiche non committate. Nessun commit creato. Questi controlli non
eseguono l'EXE Windows: la prova Windows riferita per la 0.3.1 resta storica.

Sul nuovo ZIP, e separatamente con tastiera fisica WSLg:

1. Raccogliere la sfera verde, disponibile dopo 12 secondi attivi nella
   cella (3,1): HUD “Contatti innocui” e conto alla rovescia di cinque secondi.
   Saltare su sfere rosse, serpente e ragnetti; allontanarsi prima dello zero.
2. Verificare ritorno alla vulnerabilità allo zero, singola vita persa,
   respawn, pausa e perdita del focus durante l'effetto. Le cadute restano letali.
3. Raggiungere livello 1 round 3: osservare preavviso e ragnetti viola ai
   bordi (ammessi dalla seconda apparizione, da 8,4 s attivi; RNG, cap e
   posizione possono rinviarli). Risalgono senza inseguire; il serpente insegue.
4. Provare entrambi i dischi, Stasi e contatti dei ragnetti; conservare
   il controllo con lettere, frecce e tastierino, anche equivalenti e misti.
5. Windows 11: estrazione completa, account standard offline, percorso con
   spazi, 720p/1080p e DPI 125%/150%. Non si deduce l'esito dalla build.

Non sono certificate nuove sessioni interattive F5, LSP o finestre native
WSLg; configurazioni di avvio/debug conservate. La fase 4 non è iniziata.


## Ragnetti solo nel terzo round — fase 3, versione 0.3.3

### Prova riferita dall'utente e origine della correzione

L'utente riferisce prove funzionali Windows della precedente 0.3.2 senza
bug osservati e approva le modifiche grafiche. Richiede ora che i ragnetti
appaiano esclusivamente nel terzo round di ogni livello. Questo resoconto
non certifica il nuovo EXE, DPI, durata o scenari non dichiarati; le evidenze
precedenti restano storiche e le modifiche locali dell'utente sono conservate.

La selezione usava solo una soglia minima del round globale: dopo il terzo
round i ragnetti restavano sempre candidati. Aggiunto il vincolo sul round
nel livello, anche nella progressione continua. Grafica, Stasi, punteggi,
rotte, cap, preavvisi e tempi restano quelli approvati. La regola esclusiva
è un adattamento richiesto, non la tabella Gottlieb completa (vedi REFERENCE).

### Logica automatica WSL senza interfaccia

`bash tools/test.sh`: **94 test, 56.397 verifiche, zero fallimenti**;
`.local-state/test.oLIvoQcI/report.json`. La build finale ripete la suite.

- Selezione, preavviso e apparizione effettiva con 24 seed per ogni round
  dei primi otto livelli e per livelli continui lontani, fino al livello
  100001: nessun ragnetto nei round 1, 2 o 4; candidati e apparizioni
  possibili nel solo terzo. Gli altri tipi continuano a essere selezionati.
- Transizioni effettive tramite completamento e attesa di 90 tick: 2→3,
  3→4 e cambio livello, anche oltre i dodici round e in livelli lontani.
  Attori e preavvisi pendenti vengono cancellati, senza eredità nel round
  seguente o riabilitazione fuori dal terzo.
- Conservate tutte le regressioni su Stasi, collisioni, dischi, input
  lettere/frecce/tastierino, buffer, punteggi, respawn e progressione.

### Grafica e pacchetto

La pipeline grafica esistente viene eseguita con display reale WSLg e audio
Dummy, mantenendo le catture dei ragnetti e dei salvataggi alle tre risoluzioni.
Non vengono modificati i disegni originali già approvati dall'utente.
La build 0.3.3-phase3 verifica doctor, suite completa, export Windows,
caricamento Linux headless delle tre scene dal PCK, ZIP/CRC/SHA-256 e identità
sorgenti; il pacchetto registra HEAD e dirty=true, senza creare commit.
Queste prove non eseguono il binario Windows.

### Prove manuali pendenti sulla 0.3.3

1. Nei round 1, 2 e 4 di più livelli verificare l'assenza dei ragnetti;
   nel terzo attenderne la selezione casuale dopo il primo Segugio, con
   preavviso e rinvii per occupazione/cap. Non è garantita la presenza
   immediata a ogni partita o di entrambe le varianti contemporaneamente.
2. Completare il terzo round con un ragnetto o preavviso presente: nel
   quarto non deve essere ereditato. Ripetere oltre il livello 3.
3. Avviare lo ZIP aggiornato su Windows 11 e ripetere i controlli di Stasi,
   dischi, pausa/focus e input misto già approvati per la versione precedente.
   I test automatici non sostituiscono tastiera fisica o DPI 125%/150%.

Nessuna nuova prova interattiva F5/LSP. Nessun avvio della fase 4.


Evidenza grafica 0.3.3 effettivamente eseguita:
`GODOT_TIMEOUT_SECONDS=180 bash tools/smoke_linux.sh`,
`.local-state/linux-graphics.L9cbTqBV/graphics-report.json`:
**72 catture, zero fallimenti**, X11/Compatibility, llvmpipe LLVM 15, audio
Dummy. Ispezionate `spider_round3_actual_spawn.png` e
`spiders_both_960x540.png`: grafica conservata e leggibile. La prima usa
lo scheduler del round 1/3 con seed 3, round/posizione e protezione preparati
dalla fixture; la seconda è una panoramica controllata dei due lati.
Nessuna partita manuale, misura FPS o esecuzione Windows dedotta dallo smoke.


## Calendario Gottlieb completo — fase 3, versione 0.3.4

### Ambito e fonte

La richiesta corrente sostituisce la regola 0.3.3 “ragnetti solo nel terzo
round” con l'intera colonna personaggi di MAN-01, PDF 7 (stampata 5).
Il calendario vale per Scoria, Segugio, laterali, Sverniciatore e sfera verde,
riusando i ruoli esistenti senza nemici duplicati o metamorfosi. La tabella
trascritta è in SPEC.md, README.md e REFERENCE.md; tutti i ruoli dal livello V,
prosecuzione oltre IX come adattamento della progressione continua.
Le vecchie evidenze e i resoconti dell'utente restano storici. Non viene
aggiunta una prova Windows della 0.3.3 o della 0.3.4 non dichiarata dall'utente.

### Logica automatica WSL

`bash tools/test.sh`: **95 test, 118.614 verifiche, zero fallimenti**;
`.local-state/test.eoACL93X/report.json`. La build finale ripete la suite.
La prima suite intermedia, prima dell'estensione alla partita/respawn,
aveva superato 94 test/62.528 verifiche in `.local-state/test.vmy4xRLg/`.

- Sostituite le regressioni della regola superata con un oracolo indipendente
  trascritto per nomi dal manuale, distinto dalle maschere runtime.
- Quarantotto seed per ciascun round dei livelli I–IX e per livelli continui
  lontani (fino al 100001): tutti e soli i tipi documentati possono essere
  preannunciati e apparire effettivamente, con il normale intervallo/preavviso.
- Sfera verde: assente prima del tick 720, presente al 720 e al 721 solo
  nei round ammessi; assente anche oltre la soglia nei primi due round.
  La regressione della durata/congelamento usa ora un round ammesso.
- Partita effettiva per i venti round I–V, 1000 tick ciascuno e un seed
  controllato: avversari/preavvisi e sfera verde conformi al calendario;
  morte provocata, respawn e ulteriori 150 tick non riabilitano tipi esclusi.
  La protezione contatti è estesa nella fixture per osservare lo scheduler:
  non è una campagna manuale superata né un bilanciamento della difficoltà.
- Trentasei transizioni di round effettive tramite completamento e attesa
  90 tick: nessuna eredità di attori, preavvisi o Stasi; il nuovo calendario
  si applica subito, anche nei cambi di livello e oltre i primi dodici round.
- Conservate regressioni su inseguimento, contatti/incroci, singola vita
  persa, Stasi protettiva, pausa/focus, dischi, punteggi, input equivalenti,
  buffer e cambio scena. Grafica e tempi non sono modificati.

### Smoke grafico e pacchetto

Lo smoke aggiunge scenari I/1, I/3, II/1 e V/1 con seed 3, 800 tick della
partita per scenario, controllo dei tipi realmente presenti e della sfera
verde. Round, posizione e protezione sono preparati per osservare lo spawn;
non è una partita manuale. Le panoramiche complete usano II/4 e i ragnetti/
contatti protetti usano I/3, così le fixture visive rispettano la disponibilità.
Restano le sequenze dei dischi e le tre risoluzioni 960×540/1280×720/1920×1080.

La build 0.3.4-phase3 esegue doctor, suite completa, export Windows x86_64,
caricamento Linux headless di menu/laboratorio/partita dal PCK, ZIP/CRC,
SHA-256 e verifica di identità dei sorgenti durante l'esportazione.
BUILD_INFO.json e SOURCE_FILES.sha256 registrano HEAD e modifiche locali.
Il successo non esegue l'EXE Windows; nessun commit creato.

### Collaudi manuali ancora pendenti

Sul nuovo ZIP Windows, e separatamente con tastiera fisica WSLg:

1. Livello I/1–2: soltanto Scorie e Segugio; niente sfera verde dopo 12 s.
   I/3: Segugio, ragnetti e Sverniciatore ammessi, Stasi dopo 12 s, nessuna
   Scoria. I/4: tornano le Scorie, non sono ammessi i ragnetti.
2. Livello II/1–2: niente Scorie, ragnetti ammessi; II/3: Scorie ammesse,
   ragnetti assenti; II/4: tutti i ruoli ammessi. Stasi/Sverniciatore ammessi
   in tutti i round del livello II.
3. Livelli III/1 e IV/1 senza ragnetti; III/2 senza Scorie. Dal V tutti i
   tipi ammessi in ogni round. Controllare anche i confini di round/livello.
4. Attendere le apparizioni casuali: cap, sicurezza e completamento rapido
   possono impedire di vedere tutti i tipi in una singola partita.
5. Ripetere Stasi, dischi, pausa/focus, input misto e prova Windows offline,
   account standard, percorso con spazi e DPI 125%/150%. Nessun risultato
   manuale viene dedotto dalle prove automatiche o dalla sola esportazione.

Nessuna nuova prova interattiva F5/LSP; configurazioni conservate. Nessuna
installazione, modifica globale, pubblicazione o attività della fase 4.


Evidenza grafica 0.3.4 effettivamente eseguita:
`GODOT_TIMEOUT_SECONDS=180 bash tools/smoke_linux.sh`,
`.local-state/linux-graphics.oGick0DQ/graphics-report.json`:
**76 catture, zero fallimenti**, X11/Compatibility, llvmpipe LLVM 15, audio
Dummy. Ispezionate `gottlieb_level1_round1.png`, `gottlieb_level1_round3.png`,
`gottlieb_level2_round1.png`, `gottlieb_level5_round1.png`: HUD e attori
leggibili, sfera verde assente in I/1 e presente negli altri scenari dopo
il timer. Le immagini sono istanti campione: l'assenza dei tipi vietati
è controllata automaticamente lungo tutti gli 800 tick dello scenario,
non dedotta da una sola immagine. Nessuna misura FPS o prova Windows.


## Fase 4 — esperienza e asset, versione 0.4.0

### Stato e copertura automatica WSL

Base: commit finale fase 3 `12c5808`, sorgenti inizialmente puliti; conservati
`docs/image.png` e relativo import locali dell'utente. Implementata soltanto
la fase 4. Fasi 5–6 non iniziate, nessun commit o software installato.

`bash tools/test.sh`: **102 test, 118.699 verifiche, zero fallimenti**;
report `.local-state/test.RcOm11RO/report.json`. La pipeline finale ripete la suite.
Copertura nuova, oltre a tutte le regressioni delle fasi 1–3:

- Profilo assente, roundtrip con nuova istanza, backup valido, primario corrotto,
  entrambe le copie corrotte, temporaneo incompleto ignorato e riparazione che
  non sostituisce un backup valido con corruzione. Tipi, limiti, duplicati e
  comandi riservati rifiutati. Schema futuro non sovrascritto.
- Directory non scrivibile/temporaneo non apribile: save restituisce falso,
  messaggio visibile e dati precedenti/in memoria conservati. Nessun errore
  del motore nascosto dal runner e nessun blocco del nucleo della partita.
- Dieci effetti e due brani WAV caricabili e non vuoti; player reali con
  driver Dummy, musica ciclica, pausa/ripresa, mixer Master/Music/Effects,
  mute e volume musica zero. Non costituisce una prova di ascolto.
- Pannello tramite la partita: pausa automatica, cattura di un InputEventKey
  reale, conflitto respinto, P riservato non riprende il gioco, Esc annulla
  prima la cattura e poi chiude senza tornare al menu. Navigazione UI non
  muta timer, movimento o buffer. Slider UI aggiorna profilo e mixer.
- Ogni tasto aggiuntivo produce l'atterraggio semantico previsto. Tasto
  personalizzato/freccia equivalenti non aggiungono buffer o salti duplicati.
  Restano le regressioni permanenti lettere/frecce/tastierino, focus ed Esc.
- Punteggio reale aggiorna record, punteggio minore/nuova partita non lo
  azzera; ricaricamento da disco conserva record e tasti. Ripristino conserva
  record e rimuove solo binding aggiuntivi. Nuova partita dalla pausa
  riprende la musica. Cinque cicli apertura/ripristino/chiusura del pannello
  non accumulano connessioni ai servizi.

Prove negative ripetute: `bash tools/test.sh --self-test-empty` e
`bash tools/test.sh --self-test-failure`, entrambe exit 1 atteso. Log in
`.local-state/phase4-negative-empty.log` e `phase4-negative-failure.log`.
Il runner continua a rifiutare suite obbligatorie vuote e errori Godot.

### Riproducibilità e difetti risolti durante lo sviluppo

Importazione senza cache riuscita nella copia isolata
`.local-state/phase4-cold-import.tGEBqSYx/source`, nessuna .godot copiata,
log `import.log` e `engine.log` nella directory padre. La prima importazione
aveva rivelato preload audio nell'autoload prima dell'importazione dei WAV:
ora il servizio carica i file quando serve, dopo l'importazione. I WAV sono
inclusi esplicitamente nel preset per evitare dipendenze omesse dal PCK.

La prima prova grafica `.local-state/linux-graphics.dbQXdRtD/` NON è superata:
compilazione anticipata del controller prima del nome globale App disponibile
nel runner SceneTree. I controller ora ottengono il nodo del servizio in _ready.
Le esecuzioni successive WSLg sotto sono riuscite.

Inizialmente suite con asserzioni superate ma errore di risorse audio residue
all'uscita: la pipeline le ha correttamente rifiutate. App ora arresta i player,
rilascia gli stream e lascia drenare il buffer audio per 60 ms prima della
chiusura del motore, anche con --quit-after. Le suite finali non riportano
errori Godot o risorse audio residue.

`python3 tools/generate_audio.py`: rigenerazione dei dodici WAV verificata
identica byte per byte, PCM mono 16-bit 22050 Hz, valori senza saturazione.
Hash sorgenti in `assets/audio/SHA256SUMS.txt`. Sintassi Python/Bash degli
strumenti modificati verificata. Nessuna dipendenza installata.

### Grafica Linux WSLg effettivamente eseguita

`GODOT_TIMEOUT_SECONDS=180 bash tools/smoke_linux.sh`:
`.local-state/linux-graphics.WMPUwBej/graphics-report.json`,
**82 catture, zero fallimenti**, X11, Compatibility, llvmpipe LLVM 15,
audio Dummy. La precedente esecuzione positiva jOl4l2HX precedeva gli ultimi
aggiustamenti di opacità/scorrimento; HhRXuGWI precedeva la cattura dal menu.

Ispezionati menu, partita con record, Sverniciatore completato e impostazioni
960×540/1280×720/1920×1080. Pannello opaco, testo leggibile; a dimensione minima
lo scroll/focus mostra correttamente i pulsanti Ripristina e Salva/chiudi.
Immagini chiave: `phase4_menu_settings_960x540.png`, `phase4_settings_1280x720.png`,
`phase4_settings_1920x1080.png`, `phase4_settings_bindings_960x540.png`,
`phase4_game_record.png`, `refinement_actors_1280x720.png`.
Le sequenze visive delle fasi precedenti e gli scenari Gottlieb restano eseguiti.
Nessuna misura FPS, ascolto reale, tastiera fisica o certificazione DPI Windows.

### Pacchetto intermedio Windows e limiti

La pipeline esistente produce la versione 0.4.0-phase4: doctor, suite completa,
export release x86_64, caricamento delle tre scene dal PCK su Linux headless,
ZIP/CRC/SHA-256 e identità sorgenti invariata durante la build. Inclusi EXE/PCK,
guida del giocatore, documenti, notices/licenze, BUILD_INFO.json, manifest
sorgenti e checksum. Il manifest registra base Git 12c5808 e dirty=true.
È un pacchetto intermedio della fase 4, non l'avvio della fase 5.

Alla consegna automatica il nuovo eseguibile non era stato eseguito su Windows
e la nuova prova interattiva F5 era pendente. Il successivo resoconto
dell'utente del 5 novembre 2026, registrato sotto, aggiorna questo stato;
le precedenti evidenze restano storiche.

### Checklist manuale della fase 4

1. Avvio da Godot/F5: provare breakpoint, ripresa, uscita senza errori; LSP
   separato. Avviare senza --audio-driver Dummy per ascoltare musica ed effetti.
2. Dal menu aprire Impostazioni e Record; in partita aprire Impostazioni:
   pausa, navigazione frecce/Tab, Esc, focus perso, ripresa con input fresco.
   Ripetere a 960×540, 1280×720 e 1920×1080 e in schermo intero.
3. Variare tutti i volumi, portare a zero, attivare/disattivare Silenzioso;
   ascoltare suoni di salto, raccolta, morte, disco, bonus e vita extra.
4. Assegnare A/D/S/F, provare conflitti e tasti riservati, annullare con Esc;
   riprendere e mescolare tasti personalizzati, lettere e frecce equivalenti.
   Ripristinare: restano i dodici comandi permanenti e il record.
5. Chiudere/riaprire l'app: record, volumi, mute, tasti e video persistono.
   Su una COPIA del profilo provare JSON corrotto, backup e percorso non
   scrivibile; il gioco deve avviarsi con messaggio e poter continuare.
6. Sul nuovo ZIP Windows 11: estrazione completa, offline/account standard,
   percorso con spazi, assenza di Godot, audio e riavvio, DPI 125%/150%.
   Per le prove Windows, DPI e audio riferite successivamente dall'utente,
   vedere la registrazione sotto. Non estendere il resoconto a condizioni
   non dichiarate. Durata finale 20 minuti/cinque partite e prestazioni
   a 60 FPS rimangono nel collaudo finale, non eseguito qui.

Implementazione della fase 4 completata nel proprio ambito. Il resoconto
manuale successivo è distinto dalle verifiche automatiche; nessuna attività
di implementazione delle fasi 5–6 è documentata in questa sezione.


### Prove manuali della fase 4 riferite dall'utente — 5 novembre 2026

L'utente dichiara di aver eseguito con successo le prove prima indicate come
pendenti: nuovo EXE Windows della fase 4, DPI 125% e 150%, audio reale e
debugger F5. Queste quattro voci sono quindi registrate come superate
secondo il resoconto dell'utente, non come prove eseguite dall'agente.

Non sono stati forniti nome/checksum dello ZIP effettivamente provato,
hardware, misurazioni o log della sessione manuale. Non si attribuisce
il risultato a uno specifico archivio e non si deducono ulteriori scenari:
LSP, finestre native WSLg, tutte le combinazioni della checklist, account
standard/offline, assenza di Godot e percorso con spazi restano non
attestati da questo resoconto. Restano da documentare nel collaudo finale
le prove di durata di almeno 20 minuti, cinque nuove partite consecutive
e le prestazioni sul PC di riferimento.

La fase 4 è completata per l'ambito previsto, con le prove manuali
Windows/DPI/audio/F5 sopra riferite. La fase 5 è il prossimo passo del
piano; questa registrazione documentale non ne avvia l'implementazione.


## Fase 5 — consolidamento del pacchetto, versione 0.5.0

Ambito: sorgenti ricostruibili inclusi, base Git, identità/manifest, istruzioni
e regressioni della pipeline. Nessuna nuova regola di gioco, fase 6 o commit.
Le prove Windows/DPI/audio/F5 della fase 4 restano resoconti dell'utente e non
sono estese al nuovo ZIP. Il riferimento della nuova build è il suo checksum.

La pipeline test esegue dieci regressioni Python prima della suite GDScript:
clone Git reale dal bundle, overlay non committato e cancellazioni, manifest
identico dopo recupero, esclusione di materiali locali e credenziali,
symlink rifiutati, contenuti mancanti/alterati, duplicati e percorsi insicuri,
commit/identità errati e ZIP completo con copertura checksum esatta.
Il test positivo usa una fixture PE minima per verificare il formato del
pacchetto; non è una prova di esecuzione Windows. L'export reale usa i template
ufficiali e la pipeline continua a caricare le tre scene del PCK in Linux.

Comandi: bash tools/test.sh, bash tools/smoke_linux.sh,
bash tools/build_windows.sh; tutti utilizzabili anche da altra cwd tramite
percorso assoluto. Ricostruzione dal materiale consegnato: docs/REBUILD.md.
Le prove della fase 6 (durata, cinque partite, prestazioni e accettazione
Windows del nuovo ZIP) restano pendenti e non sono avviate qui.


### Evidenze effettivamente eseguite per la fase 5

- Suite WSL: `.local-state/test.h9oLngRI/report.json`, **102 test GDScript,
  118.699 verifiche, zero fallimenti**, oltre alle nove regressioni Python
  iniziali. Aggiunta in seguito la decima regressione sul blocco della build
  se i sorgenti cambiano: tutte e dieci superate; la pipeline finale le
  ripete insieme alla suite GDScript. Il runner Python rifiuta suite vuote.
- Modalità negative: `.local-state/phase5-negative-empty.log` e
  `.local-state/phase5-negative-failure.log`, entrambe exit 1 atteso.
- Ricostruzione reale dallo ZIP sorgenti, base Git e overlay in una cartella
  con spazi, nessuna cache .godot iniziale: identità sorgenti uguale prima
  dei test; doctor, import, suite, export e caricamento delle tre scene PCK
  superati da /tmp. Log `.local-state/phase5-rebuild.lo1b4ckp/rebuild.log`;
  report nella copia `project with spaces/.local-state/test.jIRpTljB/`.
  La copia precede soltanto gli ultimi aggiornamenti documentali, la regola
  di esclusione delle cache Python e la decima regressione della pipeline.
  Nessuna modifica alle regole di gioco dopo tale ricostruzione.
- Smoke WSLg `.local-state/linux-graphics.BW7yjIDx/graphics-report.json`:
  **82 catture, zero fallimenti**, X11/Compatibility, llvmpipe LLVM 15,
  audio Dummy. Ispezionata `phase4_settings_1280x720.png`: leggibilità e
  pannello impostazioni conservati. Successiva esecuzione per l'etichetta
  di stato fase 5: `.local-state/linux-graphics.OTSmZ5ch/`, anch’essa
  82 catture e zero fallimenti; ispezionati menu e partita a 1280×720.
  I nomi phase4 delle catture identificano gli scenari conservati, non la
  versione del pacchetto. Nessuna nuova prova fisica di tastiera o audio.

La build conclusiva riesegue doctor, dieci test Python e suite GDScript,
export release, caricamento PCK Linux, verifica archivio sorgenti, ZIP/CRC,
checksum e sorgenti invariati. Log sotto `.local-state/build.*`; nome e
checksum puntuali sono consegnati in chat e nel file `.zip.sha256`.
Il manifest mantiene Windows validation pending: nessuna esecuzione del
nuovo EXE della fase 5 è stata effettuata. Le prove riferite dall'utente
per la fase 4 restano valide soltanto nel loro ambito dichiarato.


## Revisione audiovisiva fra fasi 5 e 6 — 0.5.1

Checkpoint invariato: b6b564f / v0.5.0-phase5. Completati atlante originale,
font pixel, geometria dei cubi, palette indipendenti, pose e HUD/scheda round,
dischi multicolore, dieci effetti originali senza musica o suoni di menu,
migrazione profili schema 1→2. La palette I/3 resta grigia anche dopo Stasi
su indicazione dell'utente; durata nel riferimento non verificata.
Matrice e limiti: ARCADE_REVIEW.md. Non iniziata la fase 6.

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
la checklist in ARCADE_REVIEW.md. Durata e prestazioni finali escluse.


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

Le attese di 90 tick nei verbali storici di fine round sono superate:
ora 180 tick; morte/respawn restano 90. Test dei dodici round con pausa e
controllo al tick 179/180, bonus unico e input fresco; calendario su 36
transizioni senza attori/preavvisi/Stasi residui. Palette I/2 crema→blu,
I/3 chiaro→scuro anche dopo Stasi; scheda solo al cambio livello.
Una prima esecuzione ha rilevato 72 errori nelle fixture di calendario
ancora ferme a 90 tick; aggiornate per attendere ROUND_END_TICKS.
Il controllo immagini ha rilevato bonus duplicato sulla base dei cubi:
rimosso, conservato il messaggio sotto il campo.

Prova manuale Windows richiesta per questa build:
1. Completare I/1–I/3: bonus sulla piramide, attesa 3 s, pausa durante attesa,
   nessun salto residuo e cambio palette corretto; I/4→II/1 mostra la scheda.
2. Controllare sagome, quattro direzioni e dischi a 960×540, 1280×720, 1920×1080.
3. Verificare record e comandi esistenti dopo aggiornamento, lettere/frecce/
   tastierino misti, pausa e ritorno menu.
4. Ascoltare salto/colore/raccolta/morte/caduta/disco/bonus/vita extra/lure;
   volume e mute persistenti, nessuna musica o suono menu dopo riavvio.
5. Confrontare con VID-01 e annotare timestamp e descrizione dei suoni diversi.

Dummy e decodifica AAC non sono prove d'ascolto. Nessuna prova Windows
eseguita da questo agente; nessun collaudo finale di durata/prestazioni.


Verifica automatica 0.5.2: `bash tools/test.sh` riuscito, 108 test GDScript
e 118803 verifiche, oltre alle regressioni Python di packaging e asset.
Log `.local-state/test.UxUHO8Oj/`. Incluse migrazione profili schema 1→2,
record/preferenze, input equivalente, buffer, audio-eventi e assenza musica.
Smoke WSLg riuscito su X11/Compatibility/llvmpipe, audio Dummy; nessuna
prova d'ascolto. Acquisizione finale `.local-state/linux-graphics.bV71ZUXQ/`.


## Revisione soli effetti 0.5.2 — 7 novembre 2026

Analizzata numericamente tutta la traccia AAC VID-01 (168,448 s), decodificata
con ffmpeg 4.4.2: RMS 5 ms, STFT 2048/4096, quantili spettrali, traiettorie
delle dominanti e sincronizzazione visuale. 327 regioni automatiche;
attribuzione individuale dei suoni sovrapposti non sempre possibile.
Nessun ascolto percettivo e nessun campione distribuito.

Suite definitiva `.local-state/test.Vs5jHFGe/`: 109 test GDScript,
118829 verifiche, 10 test release Python + 3 asset/PCM superati.
Il primo passaggio falliva sui precedenti limiti di durata 40–300 ms,
aggiornati per i nuovi segnali finiti; nessun cambio alle regole del gioco.
Test aggiunti: durata entro i tempi delle azioni, bilanciamento relativo,
componente continua PCM, avvio singolo degli effetti e vita extra simultanea,
prelazione segnali lunghi, pausa/ripresa, zero/ripristino Master/Effetti.
Regressioni esistenti: cue semantici, mute, focus, scene, riavvio e assenza
di musica. Il nuovo mix consente due voci solo per la vita extra.

`bash tools/smoke_audio.sh` fallito, log `.local-state/audio-review/device-final.log`,
report `.local-state/audio-device.Hgp5aj53/audio-report.json`: PulseAudio/ALSA
non disponibili, fallback Dummy. Non è un problema di codec né prova di ascolto.
Non ripetuto lo smoke grafico: nessuna grafica modificata in questo task.
Matrice numerica, limiti e timestamp Windows in ARCADE_REVIEW.md.


Pipeline Windows di verifica riuscita (`.local-state/build.tMcOMkLB/`):
doctor, export EXE/PCK, tre scene del PCK isolate, risorse, archivio sorgenti,
ZIP CRC/checksum e identità sorgenti. La pipeline di consegna ripete tutti
i controlli con gli ultimi test. Controllo hash dello snapshot iniziale:
core, input, scene e grafica invariati; modificati soltanto sintesi/mix,
WAV originali, test audio e documentazione. `git diff --check` riuscito.
Nessuna prova del nuovo EXE su Windows o ascolto percettivo effettuati.


Un tentativo di build è fallito su errore Godot di risorse audio ancora in
uso all'uscita dopo i test rapidi, pur con 0 asserzioni fallite. Teardown del
test audio aggiornato: stop e attesa 200 ms del thread audio prima del quit,
senza introdurre attese nel gioco. Suite successiva `.local-state/test.Vs5jHFGe/`
riuscita senza errori (109 / 118829). Aggiunta la regressione del salto durante
collect, che ora parte subito interrompendo la voce principale.


## Revisione correttiva 0.5.3 — ripresa e verifica

La 0.5.2, comprese le modifiche audio, è stata dichiarata funzionalmente
accettabile su Windows dall'utente. È un resoconto dell'utente, distinto
dalle prove della nuova 0.5.3. Nessuna fase 6, commit/tag, installazione o
pubblicazione. Snapshot iniziale e di ripresa in .local-state/review-053/;
modifiche locali precedenti, cancellazioni e materiali dell'utente conservati.

Prima dell'interruzione: suite `.local-state/test.D3rYWItm/`, 117 test / 126402
verifiche, e smoke `.local-state/linux-graphics.E93D58I7/`, 135 catture senza
fallimenti. Quei risultati erano salvati; mancavano documenti e ZIP 0.5.3.

Dopo l'audit della ripresa: suite `.local-state/test.mQlKidwt/`, **118 test
GDScript / 126411 verifiche**, zero fallimenti; 10 test Python di rilascio e
3 test Python di asset/PCM. La pipeline Windows ripete la suite sullo snapshot
di consegna. Copertura aggiunta e regressioni mantenute:

- 12 seed e coppie equivalenti: più percorsi verdi, riproducibilità dello
  stato completo, origine all'apice, salti validi, una sola perdita al fondo,
  nessun punto/vita persi alla perdita, raccolta e incrocio, pausa, pulizia.
- Segugio su entrambi i dischi con partenza dopo il termine del viaggio,
  anche congelato: caduta e animazione, rimozione, 500 punti/cue unico.
  Un nemico lontano non conserva un richiamo permanente; niente caduta
  casuale nel normale inseguimento.
- Tutti i 12 round: round/level esclusivi, nessun replay durante 180 tick,
  pausa o nuovo round. Fine livello + Stasi + extra: tre eventi reali,
  senza doppio segnale round/livello. Game Over assente prima dell'ultima
  morte terminata, poi cue singolo.
- Quattro voci audio: avvii immediati e conteggi, precedenza al salto senza
  troncare Stasi/Segugio, mute, Master/Effetti zero, pausa, focus, nuova partita,
  scene e ripristino senza residui. PCM originali rigenerabili, brevi/limitati,
  senza loop, clipping o offset eccessivo.
- Classifica qualificata/non qualificata dopo Game Over, ritorno al menu,
  input reale del viewport per digitare/correggere, Tab e Invio; lettere dei
  comandi non generano movimento. Conferma ripetuta non duplica. Errore
  di scrittura e retry con una sola riga, reload da nuova istanza, reset
  impostazioni conserva massimo/classifica. Migrazione schemi 1 e 2 a 3,
  pari, dimensione, ordine e dati malformati.
- Restano nella suite: calendario, progressione, palette indipendenti,
  Q/E/Z/C, frecce e tastierino, sorgenti equivalenti, buffer, salti, collisioni,
  dischi, punteggi, pausa, focus, preferenze e protezione profili futuri.

Smoke definitivo dopo la ripresa: `.local-state/linux-graphics.xAvnJtQF/`,
**135 catture, zero fallimenti**, X11, Compatibility, llvmpipe, audio Dummy.
Include nuovi scenari a 960×540, 1280×720 e 1920×1080: pillola in cima/in
volo/in caduta, Segugio fuori bordo, banner Game Over, classifica prima/dopo
salvataggio e senza qualificazione. Controlli automatici di contenimento e
focus. Ispezionate visivamente catture di Game Over e record, Segugio e
pillola in movimento/caduta. Input sintetici, non tastiera fisica o EXE Windows.

I primi test della sessione d'implementazione hanno rilevato assunzioni
obsolete (pillola immobile, riavvio diretto senza classifica) e un fixture
cromatico errato per il reversibile; aggiornati ai requisiti 0.5.3. Un primo
smoke non attivava la pillola nel fixture di prova, che ereditava un flag
stasis_enabled=false: corretto il solo fixture e ripetuto con esito positivo.
Gli errori di compilazione del nuovo test sono stati corretti prima degli
esiti riusciti sopra. Nessun fallimento è stato considerato una verifica valida.

Analisi audio esclusivamente numerica, dettagli in ARCADE_REVIEW.md; quattro
WAV nuovi sintetici, dieci precedenti conservati identici allo snapshot
0.5.2. Nessun video/PDF/estratto nel codice, negli asset o nella distribuzione.
Il dispositivo Linux viene verificato separatamente: l'eventuale ripiego
Dummy non certifica né uscita fisica né ascolto percettivo. Il collaudo del
nuovo EXE e la somiglianza percepita restano da eseguire su Windows.


### Esito di build e ricostruzione 0.5.3

Build di verifica riuscita `.local-state/build.doBr7MKv/`: suite completa
118 / 126411 e 13 test Python, doctor/toolchain, export release EXE/PCK,
caricamento di tre scene dal PCK isolato su Linux, verifica di tutti i 14
WAV e delle nuove dipendenze della classifica, assenza vecchie risorse
menu/musica, CRC ZIP, checksum e identità sorgenti invariata.

Ricostruzione reale da QBertPyramid-source.zip della build doBr7MKv:
`.local-state/review-053/rebuild from source/work/`, percorso con spazi,
clone locale del BASE.bundle, overlay completo, cancellazioni del manifest
applicate e ogni SHA-256 sorgente verificata. Nessuna cache .godot iniziale.
Ripetuti doctor, tutti i test, import, export e controlli PCK/ZIP/sorgenti
con esito positivo; log `.local-state/review-053/rebuild.log`.
Lo snapshot ricostruito precede soltanto queste evidenze documentali finali;
nessun cambiamento al codice/asset dopo quella ricostruzione. La consegna
ripete l'intera pipeline per includere le evidenze aggiornate. ZIP/checksum
esatti sono nel resoconto e nel file .zip.sha256 accanto all'archivio.

Smoke dispositivo ripetuto: `.local-state/audio-device.NVelgveg/`,
**non superato**, PulseAudio/ALSA indisponibili e fallback Dummy. Non è
mancanza di codec né ascolto. Non sono stati installati driver o modifiche
globali. Il nuovo EXE non è stato eseguito su Windows. `git diff --check`
superato; tutte le modifiche restano non committate, HEAD b6b564f invariato.

## Revisione 0.5.4 — sei miglioramenti e nuova identità

Base 0.5.3 approvata funzionalmente dall'utente su Windows; nessuna nuova
esecuzione Windows attribuita ai controlli Linux. Backup dello stato locale
in .local-state/review-054/before.tar.gz e before.json. Nessun commit/tag,
installazione, pubblicazione o fase 6. Storia e build precedenti conservate;
identità aggiornata nel working tree e nella nuova distribuzione.

Suite finale prima del pacchetto: `.local-state/test.B3YibF1H/`, **123 test
GDScript / 126533 verifiche**, zero fallimenti. 10 test Python di rilascio e
4 test Python asset/branding. La pipeline di build ripete la suite sullo
snapshot esatto. Nuove verifiche:

- Game Over: on/off 500/500 ms, assenza passaggio a 29,99 s e apertura dopo
  30 s, focus che congela il tempo, dodici binding permanenti, echo ignorato,
  tasto consumato senza movimento o input nel nome. Esc non anticipa il
  passaggio; banner e cue restano successivi alla morte effettiva.
- Top ten: 12 inserimenti conservano soltanto i dieci massimi, pari e cutoff,
  nomi esattamente di tre lettere, maiuscolo, livello/round e salvataggio
  completo riletto da una nuova istanza. Migrazione schema 3 e cartella dati,
  vecchio nome conservato, originale non modificato, schemi 1/2 già coperti.
  Continuazione con iniziali invalide rifiutata; iniziali valide confermate
  e salvate prima di proseguire. Retry, backup, profili futuri e reset
  preferenze continuano a essere coperti dalle regressioni precedenti.
- Nome: titolo configurato Q*Bert Pyramid e scansione case-insensitive di
  tutti i file di testo correnti selezionati da Git, inclusi documenti e
  sorgenti, per escludere titolo/identificatore precedenti. La storia Git
  e gli artefatti locali precedenti non vengono riscritti. Il solo accesso
  alla vecchia cartella è un identificatore ricostruito per compatibilità.
- Totali: confronto della seconda riga del menu, del dialogo istruzioni e
  della legenda con livelli/round illimitati, quattro round per livello.
  La progressione continua effettiva e il calendario restano invariati.
- Presentazione: primo ingresso, istruzioni progressive, demo, classifica
  read-only e fine automatica sul menu; skip via tasto, nessun dato della
  demo osservato/persistito nel profilo. AttractPanel usa un modello autonomo.
- Allineamento delle cinque colonne su tutte le dieci righe della classifica,
  separazione dell'input GUI da Q/E/Z/C e navigazione/conferma/correzione.

Smoke WSLg finale `.local-state/linux-graphics.SCxaLTFJ/`: **153 catture,
zero fallimenti**, X11, Compatibility, llvmpipe, audio Dummy. Tre risoluzioni:
960×540, 1280×720, 1920×1080. Incluse istruzioni, demo, top ten, Game Over
on/off e classifica piena con inserimento; caso punti 2147483647 e livello
1000000, righe/colonne e comandi contenuti nel viewport. Ispezionate le
catture della nuova presentazione, menu rinominato, tabella e Game Over.
Non è un test fisico della tastiera né del nuovo EXE Windows.

I primi passaggi hanno correttamente segnalato aspettative obsolete dei test
(cinque righe, nomi lunghi, schema 3 e attesa 1,2 s), poi aggiornate ai nuovi
requisiti. Uno smoke ha inoltre rilevato in modo intermittente il primo
input del laboratorio non consegnato correttamente quando iniettato dal
callback post-draw. La preparazione del test rimuove l'eventuale scena di
avvio implicita, attende process_frame prima di inviare gli eventi del
viewport e verifica esplicitamente jump_started prima dei tick successivi.
Log diagnostico intermedio: coda vuota prima e press direction=3 dopo la
consegna, seguito da atterraggio corretto. Nessuna modifica ai controlli,
InputAdapter o modello di salto per aggirare l'errore del test. Ripetuto
lo smoke con esito positivo; i tentativi falliti non sono contati come successi.

Entrambe le tracce AAC sono state decodificate integralmente e rimisurate;
RMS 5 ms, STFT e quantili di frequenza, confronto con tutti i 14 WAV.
Misure, differenze non risolte e decisione di conservare i WAV approvati in
ARCADE_REVIEW.md. Audio PCM e hash identici alla 0.5.3. Tentativo dispositivo
`.local-state/audio-device.M6d4CfFa/` **non superato**: PulseAudio/ALSA non
utilizzabili, fallback Dummy. Nessun ascolto percettivo o problema di codec
asserito. Volume fisico, timbro e somiglianza richiedono collaudo Windows.
`git diff --check` superato; simulazione, nemici, buffer, controlli e palette
confrontati tramite SHA-256 con lo snapshot iniziale e trovati invariati.

### Build e ricostruzione 0.5.4

Pipeline di verifica riuscita `.local-state/build.s86cpYzp/`: doctor e
impronte del motore/template, 123 test / 126533 verifiche e 14 test Python,
export release QBertPyramid.exe/.pck, tre scene isolate dal PCK, quattordici
WAV e nuove dipendenze GameIdentity/AttractPanel/classifica, assenza musica,
archivio sorgenti, CRC ZIP, SHA-256 e identità dello snapshot invariata.

Ricostruzione effettiva da QBertPyramid-source.zip della build s86cpYzp in
`.local-state/review-054/rebuild from source/work/`: clone del BASE.bundle,
overlay, cancellazioni esplicite applicate, ogni hash del manifest verificato,
nessuna cache .godot iniziale. Suite/import/export/PCK/ZIP nuovamente riusciti;
log `.local-state/review-054/rebuild.log`. Si è verificato anche il nuovo nome
dell'eseguibile e dei sorgenti nella pipeline ricostruita. Questa verifica
precede soltanto l'aggiunta delle presenti evidenze: codice/asset invariati.
La consegna ripete la pipeline per includerle nello snapshot finale; ZIP e
checksum esatti sono nel resoconto e nel relativo file .zip.sha256.

Confronto con prima della 0.5.4: nessuna modifica al nucleo di partita,
PyramidWorld, simulazione, buffer, InputAdapter o palette; tutti i WAV e i
relativi hash sono identici. I soli percorsi originali rimossi sono quelli
dell'icona rinominata, conservata con il nuovo nome. Lavoro non committato,
materiali e altri file preesistenti preservati. HEAD b6b564f invariato;
nessun nuovo commit/tag o fase 6. Nessun ascolto percettivo e nessuna
esecuzione del nuovo EXE su Windows dichiarati.


## Chiusura 0.5.4: conformità riferita e aggiornamento icona/licenza

Collaudo completo Windows e accettazione riferiti dall'utente il 7 novembre
2026; attestazione circostanziata in `TEST.md` nella radice dei sorgenti.
Nuova icona fornita dall'utente verificata anche nelle risorse PE dell'EXE.
GNU GPL v3.0 scelta dal titolare, testo in LICENSE e riga nelle Istruzioni.
Suite ripetuta: 123 test, 126533 verifiche, 14 test Python; smoke WSLg
153 catture senza errori, riga di licenza leggibile anche a 960×540.
Queste modifiche non alterano script di gioco, audio o strumenti approvati.
Non equivalgono a un nuovo collaudo manuale dell'EXE su Windows.


## Aggiornamento menu/About della Rev. 1.0 — 8 novembre 2026

Richiesta circoscritta: laboratorio rimosso dal menu standard, configurabile
solo per manutenzione; documentazione tecnica in docs/DEVELOPMENT.md e nessuna
indicazione del laboratorio nell'aiuto pubblico. L'utente ha confermato
esplicitamente l'interpretazione «solo documentazione tecnica».
Informazioni sul gioco sostituisce Istruzioni con presentazione About,
QBERT Rev. 1.0, autore Eugenio Ruggieri e licenza GNU GPL v3.0 espliciti;
contenuti operativi preesistenti conservati, riga del laboratorio visibile
soltanto nella configurazione tecnica. Regole, audio e dati invariati.

La nuova regressione verifica default nascosto/disabilitato/non focalizzabile,
blocco dell'handler, collegamento diretto Giù/Su fra Nuova partita e About,
titolo/contenuti/attribuzioni, attivazione tecnica e ritorno dei contenuti
riservati. Le prove storiche del laboratorio richiedono ora esplicitamente
il flag tecnico in memoria, ripristinato alla fine: non si riabilita la voce
nella distribuzione per soddisfare i vecchi test.

Suite: 126 test GDScript, 126546 verifiche, zero fallimenti; 15 test Python.
Report test.Z4PbhklH. Smoke WSLg e build verificano anche geometria e risorse.
Le prove Windows 1–3 precedenti restano riferite al candidato originario;
nuovo menu non ancora collaudato manualmente su Windows. Test 4 prestazioni
non eseguito e pendente, non fallito. Prima release conclusa su richiesta
del titolare con tale verifica residua; fase 7 non avviata.


Smoke grafico menu/About superato: 153 catture, zero fallimenti,
`.local-state/linux-graphics.XO5iiiDg/`. Ispezionati menu 1280×720 senza
laboratorio e About 960×540, senza tagli e con autore/licenza leggibili.
La pipeline Windows completa viene ripetuta prima dell'amend e sul commit
sostitutivo per legare archivio e sorgenti; esito e checksum nel rapporto
esterno del pacchetto. Vecchio commit salvato in bundle locale ignorato;
nessuna cancellazione dei precedenti ZIP o materiali dell'utente.


## Historical phase 7 preparation — 2026-11-08

The local preparation notes below were superseded by the published 1.0.0 and
1.1.0 releases. Current release contents and test evidence are summarized in
`docs/releases/v1.1.0.md`.


## Sprite-derived application identity — 2026-11-08

Owner-requested replacement of the unlicensed supplied icon/JPEG: current
application PNG and six-size Windows ICO are generated from the existing
original in-game player sprite, without changing that sprite or gameplay.
The JPEG and its import descriptor are removed; supplied ICO bytes are replaced.
Editable derivation: tools/generate_app_icon.py, Python standard library only.

Regression: generated sprite bytes equal the actual actor-atlas region
(kind 0, direction 3, pose 0); PNG is transparent RGBA 256×256; every output
color comes from the original sprite; ICO has 16/32/48/64/128/256 frames;
the 256 frame equals the application PNG; isolated regeneration is byte-identical.
Initial suite passed: 126 GDScript tests, 126546 assertions, 17 Python tests,
report test.QHhRaHVX. WSLg: 153 captures, zero failures,
linux-graphics.U8uvLgl5. Final pipeline runs on the updated assets/docs before
requesting owner acceptance. No new Windows runtime or independent performance
measurement is claimed by the assistant. Phase 6 closure is owner-directed as
recorded above; this subsequent icon change awaits owner acceptance.

Only the two empty repositories were created after explicit confirmation;
no source upload, commit/tag, push or release is authorized or performed.
Historical Git/source bundles and older deliveries still contain the original
unlicensed supplied images: no history rewrite or deletion of old packages
has been performed. Those historical blobs must not be published unchanged.

## Release 1.1.0 verification — 2026-11-09

- 129 GDScript tests / 126766 assertions, 12 packaging/source tests and 6 asset tests passed.
- Windows x86_64 export, PCK scenes and new dynamic COIL assets passed isolated checks.
- Linux X11/Compatibility graphical smoke and PulseAudio device-delivery checks passed. Audio-device output is not human listening.
- Owner reports manual Windows testing completed successfully. No hardware/session details beyond that report are asserted.
- Installer logic and payload are covered by its Windows test harness; a pre-existing per-user install prevented the harness from repeating its install/update/uninstall cycle on this workstation.
- Windows EXE and installer contain requested author metadata but are not Authenticode-signed.
See [release notes](releases/v1.1.0.md) and [release assets](https://github.com/eruggie/qbert-pyramid/releases/tag/v1.1.0).
