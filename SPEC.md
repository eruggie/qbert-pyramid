# Q*Bert Pyramid — specifica approvata

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



## Stato corrente — release pubblica 1.1.0

La versione 1.1.0 è rilasciata e documentata in `docs/releases/v1.1.0.md`. Le
sezioni sottostanti descrivono requisiti e decisioni delle versioni precedenti;
non sostituiscono lo stato o le caratteristiche della release corrente.


## Stato storico — QBERT Rev. 1.0

Prima release 1.0.0 conclusa per richiesta del titolare l'8 novembre 2026.
Windows test 1–3 dichiarati superati; prestazioni test 4 non eseguite,
pendenti e non fallite. Nessuna variazione di regole, codice di gioco,
input, arte, audio o dati rispetto al candidato provato. Aggiornati soltanto
metadati di versione, dicitura delle istruzioni e documentazione. Distribuzione
portabile Windows x64 su disco locale, rete e USB secondo README; salvataggi
sempre nel profilo locale. Fase 7 esclusa. Gli stati sotto sono storici.


## Stato corrente: fase 6 in attesa di verifica

Lo stato corrente supera le indicazioni storiche di fase 6 non avviata nelle
sezioni delle revisioni precedenti. Nessuna nuova funzione è autorizzata.

Versione 0.5.4-corrective-review. Base congelata b6b564f / v0.5.0-phase5. Partita, laboratorio, calendario Gottlieb e controlli
permanenti delle fasi precedenti sono conservati. Aggiunti impostazioni e
record persistenti, rimappatura con tasti aggiuntivi, mixer e audio originale,
completamento della presentazione vettoriale e opzioni video persistenti.
La fase 5 consolida il pacchetto Windows e la copia ricostruibile dei sorgenti;
non modifica le regole della partita. La fase 6 è autorizzata dall’8 novembre 2026 ed è in attesa delle verifiche obbligatorie; fase 7 esclusa.
Il 5 novembre 2026 l’utente riferisce esito positivo delle prove del nuovo
EXE Windows, DPI 125%/150%, audio reale e debugger F5 della fase 4.
Il resoconto è distinto dalle verifiche WSL/WSLg e non certifica scenari
non dichiarati; dettagli in docs/TESTING.md.
Le sezioni 0.3.x in fondo restano storia delle correzioni precedenti.

## Piattaforme e architettura

Godot 4.7.2 standard, GDScript, renderer Compatibility, grafica 2D isometrica.
Sviluppo su Ubuntu 22.04/WSL2 nel filesystem Linux. Prima destinazione:
Windows 11 x86_64, ZIP offline con eseguibile e tutti i dati necessari.
Regole indipendenti da input e grafica; coordinate logiche, InputMap,
configurazioni validate e RNG a seed controllabile. Il rendering rappresenta
lo stato della simulazione, senza deciderne gli esiti. Futuro adattamento Android.

## Funzioni disponibili

- Menu con Nuova partita, laboratorio delle regole, istruzioni, stato e uscita.
- Partita: HUD punti/vite/livello/round/obiettivo, pausa, respawn, bonus,
  Game Over e progressione continua; nuova partita in pausa o a Game Over.
- Quattro ruoli originali: Scoria rossa sferica, Segugio serpentiforme,
  ragnetti laterali viola (Scintilla), Sverniciatore verde con maschera e V; due dischi ellittici rialzati
  e Stasi come sfera verde con riflesso e scintilla.
- Laboratorio di 7 file e 28 celle, quattro diagonali e salto animato
  derivato dallo stato logico; scelta fra tre regole cromatiche.
- InputMap con più associazioni per azione, ripetizione dei mantenuti,
  buffer e arbitraggio simultanei. Rimappatura tramite InputMap;
  pannello e persistenza sono disponibili nella fase 4.
- Reset esplicito del laboratorio e pausa dei tick. La perdita del focus
  sospende il laboratorio; il ritorno richiede una ripresa esplicita.
- Nel laboratorio la caduta resta terminale fino al reset; nella partita
  sottrae una vita e avvia il respawn automatico o il Game Over.
- Finestra 1280×720 ridimensionabile, minimo 960×540; F11 schermo intero.
- Avvio/debug VS Code, test headless e preset Windows Desktop x86_64.
- Verifica grafica Linux opzionale e separata: tools/smoke_linux.sh.

## Piramide e simulazione — fase 1

Simulazione deterministica a 60 tick/s. Celle (r,c), 0 <= r <= 6,
0 <= c <= r: 7 file e 28 celle. NO=(r-1,c-1), NE=(r-1,c),
SO=(r+1,c), SE=(r+1,c+1). Destinazione esterna: caduta salvo
uscita associata a piattaforma disponibile nella partita. Nel laboratorio della fase 1
le piattaforme non esistono: ogni uscita produce una caduta terminale.
Comparsa e reset non colorano. Ogni salto ha un ID e un solo esito;
la fase 1 emette atterraggio o caduta, il salvataggio appartiene alla fase 3.
Il primo step con pressione avvia a tick 1, atterra a tick 19 e consente
la prima nuova partenza a tick 21: 18 tick di salto e 2 di recupero.
Il contatore non avanza durante pausa o caduta terminale.
Il reset è un nuovo esperimento amministrativo: scarta salti pendenti senza
colorare, non riutilizza gli ID e non genera eventi di un esperimento passato.

## Input — requisiti permanenti e rimappatura fase 4

Azioni InputMap per quattro direzioni, rimappabili tramite editor o API.
Persistenza e interfaccia di rimappatura sono disponibili nella fase 4.
Requisito permanente per tutte le fasi: le stesse quattro azioni ricevono
lettere, frecce e tastierino, senza dipendenze dai dispositivi nel nucleo.

| Azione | Direzione | Binding equivalenti |
|---|---|---|
| move_nw | Alto-sinistra | Q, Sinistra, tastierino 7 |
| move_ne | Alto-destra | E, Su, tastierino 9 |
| move_sw | Basso-sinistra | Z, Giù, tastierino 1 |
| move_se | Basso-destra | C, Destra, tastierino 3 |

Una sola freccia produce il salto diagonale indicato. Il secondo tasto
mantenuto della stessa direzione non crea un comando né rinnova il buffer;
la direzione cessa solo al rilascio dell'ultima sorgente attiva. Le priorità
sono definite fra azioni, indipendentemente dal tipo di tasto.
Salto 18 tick (300 ms),
recupero 2 tick: massimo 3 salti/s. Tasto mantenuto: ripetizione al primo
istante utile, ignorando gli eventi echo del sistema operativo.
Buffer di un comando valido mentre età < 12 tick (200 ms) dalla nuova
pressione: all'età esatta di 12 tick il comando è scaduto;
l'ultima pressione sostituisce la precedente, il rilascio non la annulla.
Buffer prima del mantenuto; fra mantenuti vince l'ultima pressione.
Pressioni nello stesso tick: NO, NE, SO, SE. Pausa, morte e cambio
schermata svuotano il buffer; alla ripresa serve una nuova pressione.
Nell'adattatore due tasti associati alla stessa azione mantengono l'azione
finché almeno uno resta premuto. Gli echo del sistema operativo non
creano nuove pressioni. Pausa/reset isolano le pressioni precedenti;
un tasto già mantenuto deve essere rilasciato e premuto nuovamente.
Il pannello aggiunge un tasto per direzione, controlla conflitti e ripristina i predefiniti senza rimuovere i dodici binding permanenti.

Contesto: nella partita e nel laboratorio attivi gli eventi direzionali sono consumati prima
della GUI, anche quando un pulsante ha focus. Nel menu, nella partita e nel laboratorio
in pausa le frecce navigano l'interfaccia senza produrre movimenti o buffer.
Il selettore Regola mette in pausa all'apertura; la chiusura mantiene la pausa
fino a P/Riprendi. I rilasci restano tracciati e alla ripresa serve una pressione
fresca. Tab/Invio e mouse restano disponibili. Il cambio scena con Esc conserva
il viewport prima di rimuovere il laboratorio, per consumare l'evento in sicurezza.
Le fasi successive devono mantenere queste regressioni e la separazione fra
azioni semantiche e dispositivi, inclusi i futuri controlli Android.

## Regole cromatiche — fase 1

| Regola | Transizione | Obiettivo |
|---|---|---|
| Permanente | 0 → 1, poi 1 | Tutte a 1 |
| Due passaggi | 0 → 1 → 2, poi 2 | Tutte a 2 |
| Reversibile | 0 ↔ 1 | Tutte contemporaneamente a 1 |

Il reversibile binario è un adattamento progettuale esplicito.
Le transizioni avvengono soltanto all'atterraggio; spawn, pausa e reset
non simulano atterraggi. Il laboratorio mostra il numero delle celle al
colore obiettivo e il completamento logico, senza avanzare un round.
Il punteggio della partita accredita ogni stato intermedio/finale solo
alla prima occorrenza per cella nel round. Tornare su una cella reversibile
già accreditata non paga di nuovo. Il laboratorio continua a non assegnare punti.
Il sabotaggio non azzera il registro degli accrediti.

## Progressione — fase 3

`data/initial_rounds.tres` configura dodici modalità cromatiche: quattro
permanenti, quattro a due passaggi, quattro reversibili. Il nucleo valida
lunghezza e modalità prima di iniziare una nuova partita, senza distruggere
lo stato esistente in caso di configurazione invalida. I dati sono copiati,
non condivisi mutabilmente con la risorsa o con chi chiama le API.

Round completato: bonus unico, input e danni bloccati, attesa di 180 tick
(3 s, revisione VID-01); poi nuovo round dalla cima, senza colorarla. Si conservano punti,
vite e soglie extra, si azzerano colori e crediti di cella del round nuovo.
Dopo il dodicesimo round inizia il livello 4. La risorsa configura anche il
ciclo successivo, le soglie minime degli intervalli, i cap e i decrementi:
i valori invalidi vengono rifiutati atomicamente prima di azzerare la partita.

La tabella specifica i dodici round iniziali già implementati.

| Livello/round | Regola | Apparizioni | Massimo avversari |
|---|---|---|---|
| 1/1 | Permanente | 5,0 s | 2 |
| 1/2 | Permanente | 4,6 s | 2 |
| 1/3 | Permanente | 4,2 s | 3 |
| 1/4 | Permanente | 3,8 s | 3 |
| 2/1 | Due passaggi | 3,6 s | 3 |
| 2/2 | Due passaggi | 3,3 s | 4 |
| 2/3 | Due passaggi | 3,0 s | 4 |
| 2/4 | Due passaggi | 2,8 s | 4 |
| 3/1 | Reversibile | 2,6 s | 4 |
| 3/2 | Reversibile | 2,4 s | 5 |
| 3/3 | Reversibile | 2,2 s | 5 |
| 3/4 | Reversibile | 2,0 s | 6 |

Dal livello 4, per i valori predefiniti: quattro round per livello, regole cicliche permanente,
due passaggi, reversibile per livello. Intervallo apparizioni:
max(1,2; 2,0 - 0,1*(livello-4) - 0,1*(round-1)) secondi.
Cap avversari min(8; 6 + floor((livello-4)/2)).
Progressione continua configurabile e velocità limitata: adattamento progettuale.

## Avversari — fase 3

Nomi e aspetti originali, provvisori. Tre famiglie pericolose al contatto
più il sabotatore raccoglibile senza danno.

| Famiglia | Ruolo | Disponibilità | Periodo base partenze |
|---|---|---|---|
| Scoria | Discende, scelte tramite RNG, esce dal fondo | Calendario Gottlieb sotto | 1,20 s |
| Segugio prismatico (serpente) | Riduce distanza logica; attirabile fuori con piattaforma | Tutti i round | 1,35 s prima dei fattori |
| Scintilla laterale (ragnetti) | Risale uno dei bordi fino all'apice, senza inseguimento | Calendario Gottlieb sotto | 1,10 s |
| Sverniciatore | Discende e arretra lo stato delle celle; raccoglibile | Da I/3, poi tutti i round | 1,50 s |

Calendario di disponibilità da MAN-01, PDF 7 (stampata 5). I numeri sono
round nel livello, non indici globali. Si applica anche alla Stasi:

| Livello | Scorie / sfere rosse | Segugio / Coily | Ragnetti / Ugg–Wrong-Way | Sverniciatore / Slick–Sam | Stasi / sfera verde |
|---|---|---|---|---|---|
| I | 1, 2, 4 | 1–4 | 3 | 3, 4 | 3, 4 |
| II | 3, 4 | 1–4 | 1, 2, 4 | 1–4 | 1–4 |
| III | 1, 3, 4 | 1–4 | 2, 3, 4 | 1–4 | 1–4 |
| IV | 1–4 | 1–4 | 2, 3, 4 | 1–4 | 1–4 |
| V–IX | 1–4 | 1–4 | 1–4 | 1–4 | 1–4 |

Dal livello X la progressione continua mantiene tutti i ruoli ammessi,
proseguendo il calendario del V–IX; il manuale consultato arriva al IX.
Il calendario governa candidati, preavvisi, spawn e comparsa della sfera verde.
Non impone che tutti i tipi siano contemporaneamente presenti o estratti
prima che il giocatore completi un round: RNG, cap, intervalli e sicurezza
restano attivi. Il cambio round elimina attori, preavvisi e Stasi precedenti.

Salto nemico: 24 tick. Fattore dei periodi da 1,00 a 0,78 nei primi
12 round; dal livello 4 scende di 0,02 per livello fino a 0,60.
Apparizione preannunciata 600 ms; posizioni non sicure rinviano l'evento.
Massimi contemporanei: un inseguitore, un sabotatore, due laterali.
La prima apparizione utile di ogni round è riservata al Segugio, rispettando
cap, preavviso e rinvio per cella non sicura. Dopo il primo Segugio effettivamente
apparso, la scelta torna casuale fra le famiglie ammesse. Una morte non
riapre la priorità del primo Segugio già apparso nello stesso round.
Il Segugio usa anche i fattori 1,00 / 0,94 / 0,88 / 0,82 per round 1–4,
moltiplicati per il fattore di velocità del livello già previsto. Nel primo
livello i periodi fra partenze sono 81 / 75 / 68 / 62 tick; il salto resta
24 tick. Gli altri avversari conservano periodi e comportamento precedenti.
Nel round 1 il preavviso inizia al tick 264 (4,4 s attivi) e l'apparizione
avviene dal tick 300 (5 s) sulla cella logica (6,3), se sicura.
Il Segugio appare sulla cella centrale del fondo senza trasformazione intermedia;
Scoria e Sverniciatore appaiono all'apice, le laterali ai bordi del fondo.
Queste posizioni, gli aspetti provvisori e le scelte degli spareggi sono
adattamenti di Q*Bert Pyramid. L'RNG di partita è inizializzato casualmente;
nei test il seed è impostabile. Gli snapshot includono anche lo stato RNG.
Il sabotatore raccolto è rimosso prima di alterare la cella dell'atterraggio.

## Vite e respawn — fase 2

Tre vite iniziali inclusa quella corrente. Extra a 8.000 e poi ogni 14.000;
cap cinque, soglie consumate anche al cap e attraversamenti multipli gestiti
nello stesso accredito. Ogni caduta sottrae una sola vita: richieste letali
ripetute sono ignorate durante morte, pausa, fine round e stati terminali.
Attesa dopo morte: 90 tick (1,5 s), anche per l'ultima vita; poi respawn
se restano vite, altrimenti Game Over. Respawn all'apice senza colorarla,
conservando colori, punti e crediti del round, e scartando input/salto vecchi.
Gli ID dei salti non vengono riutilizzati nemmeno al respawn.

Protezione contatti dopo respawn: 120 tick (2 s), non protegge dalle cadute.
La protezione è valutata anche contro gli avversari della fase 3.
Pausa esplicita o perdita del focus congela salto, attesa morte/fine round,
protezione e tempo attivo; il ritorno del focus non riprende da solo.
Pausa, morte, cambio round e nuova partita richiedono input fresco.
Nuova partita azzera punti, vite, colori, soglie e registro degli accrediti.
Il tasto R rimane riservato al laboratorio, non azzera la partita attiva.

## Piattaforme, Stasi e respawn avversari — fase 3

Ripresa apparizioni 3 s dopo morte. Piattaforme consumate persistono;
avversari rimossi e potenziamento attivo annullato alla morte.
Due piattaforme per round: sinistra riga 3, destra riga 5. Consumo unico
al decollo, ritorno all'apice in 1,2 s, senza colorare l'apice.
Durante il viaggio avversari attivi e giocatore protetto; il personaggio
non occupa la cella di partenza e non raccoglie oggetti lasciati su di essa.
All'arrivo all'apice il salvataggio si conclude prima delle collisioni.
I numeri di riga logici partono da zero: riga 3 = quarta fila dall'alto,
riga 5 = sesta fila. Gli input del viaggio non vengono conservati.
La vista rialza i dischi rispetto al centro della faccia superiore e li
collega al bordo con un raccordo prospettico, senza modificare le celle
logiche. Il disco consumato rimane visibile nel salvataggio: i primi 18 tick
mostrano il salto dalla cella al disco, i restanti 54 il trasporto all'apice.
Attore, disco e ombra condividono il punto di appoggio durante il trasporto;
i due raccordi sono continui. Consumo e protezione iniziano al decollo logico,
come prima, e il ritorno avviene sempre dopo 72 tick.
Stasi: una nei round ammessi dal calendario, dopo 12 s attivi, durata 5 s; blocca nuove partenze
nemiche e apparizioni, lascia terminare salti già iniziati. Durante l'effetto
protegge da tutti i contatti letali, inclusi nemici immobili, atterraggi e
incroci; non elimina i nemici né assegna punti per il contatto. Il giocatore
può occupare e lasciare le loro celle. Le cadute restano letali.
Il timer parte da 300 alla raccolta; a ogni tick attivo successivo decrementa
prima delle collisioni. Con residuo 1 si è ancora protetti: al successivo
passaggio a 0 i contatti tornano letali immediatamente, anche se si resta
sulla stessa cella. Pausa/focus congelano l'effetto; morte, nuova partita e
nuovo round lo azzerano. Le protezioni di respawn e disco restano indipendenti.
Una raccolta non annulla retroattivamente un contatto letale già risolto
nello stesso tick: l'ordine collisioni/raccolte già approvato rimane invariato.
Pausa, morte e transizioni fermano i timer della simulazione.
Fine round: transizione di 3 s (180 tick).

## Collisioni e priorità — fase 3

Collisioni da coordinate e traiettorie logiche, non dai pixel degli sprite.
Condivisione di cella a terra, inclusi atterraggi simultanei: contatto.
Salti opposti sullo stesso collegamento: collisione all'incontro delle
progressioni anche fra due tick. Archi diversi sovrapposti graficamente:
nessuna collisione.
Eventi per tempo logico; a parità: scadenza effetti, conclusioni di
salvataggi/cadute, collisioni letali, raccolte, modifiche cromatiche,
punti/vite extra, completamento, nuove partenze/apparizioni.
Colore giocatore prima di sabotatori superstiti; vittoria dopo entrambi.
Morte sull'ultima cella prevale sul completamento e annulla raccolte
simultanee. Un episodio letale sottrae una sola vita; stato di morte
ignora eventi successivi dell'episodio. Round completato blocca danni
ed accrediti successivi. La partenza di un nuovo salvataggio viene dopo
le collisioni di quell'istante; un salvataggio già in corso protegge.

## Punteggio — fasi 2–3

Implementati: intermedio 15, finale 25, sabotatore 300, Stasi 100,
inseguitore attirato fuori 500 e piattaforma inutilizzata 50. L'inseguitore
attirato fuori rimuove gli avversari superstiti. Tutti i premi sono deduplicati.
Bonus round min(1000 + 250*(round_globale-1), 5000).
Ogni accredito è identificabile e applicabile una sola volta.

## Esperienza e servizi del giocatore — fase 4

Menu: nuova partita, laboratorio, istruzioni, impostazioni, record/stato e uscita.
La partita offre impostazioni con pausa automatica. Chiudere il pannello non
riprende: serve P/Riprendi e una pressione fresca. Durante il pannello gli eventi
non arrivano all'adattatore di gioco. Esc annulla la cattura, poi chiude il pannello;
non torna al menu della partita nello stesso evento. Il focus perso annulla la
cattura e mantiene la pausa della partita. Scorrimento e Tab raggiungono ogni
controllo a 960×540; interfaccia ridimensionabile, F11 e 16:9 conservati.

Rimappatura: un tasto fisico aggiuntivo per direzione (lettere/cifre), persistente.
Restano Q/←, E/↑, Z/↓, C/→ e tastierino 7/9/1/3. Tasti già assegnati ad altre
direzioni, comandi riservati P/R, modificatori, navigazione e F11 sono rifiutati.
La rimozione riguarda solo il tasto aggiuntivo. Ripristino delle impostazioni
azzera i tasti aggiuntivi e ripristina audio/video, conservando il record.
I dispositivi rimangono separati dalle azioni semantiche anche per Android.

Audio originale: dieci effetti per salto, atterraggio, cambio colore, caduta,
contatto, disco, raccolta, fine round, vita extra e Segugio attirato.
Nessuna musica continua, suono di menu o jingle d'avvio. Sintesi originale
riproducibile con `tools/generate_audio.py`, senza campioni o melodie esterne.
Bus Master/Effects, predefiniti 80%/80%, volume zero e modalità silenziosa.
Un player e una coda massima di tre effetti evitano sovrapposizioni; effetti
uguali in coda sono accorpati. La morte interrompe la coda. Pausa, perdita
focus, cambio scena e nuova partita cancellano i suoni residui; la ripresa
non riproduce eventi vecchi. Il cambio colore sostituisce land; raccolta,
Segugio e fine round hanno precedenza sui normali salti/atterraggi. Vita extra
ha un segnale aggiuntivo anche se assegnata con il bonus. GameAudioCues legge
esiti e accrediti semantici effettivi, senza decidere le regole o basarsi sul
solo incremento dei punti. Nessun suono per apparizioni, respawn o sabotaggio.
Timbri e durata (55–280 ms) sono proposte, non audio arcade ascoltato.

Dati in `user://profile.json`, schema 2: record, livello/round del record,
volumi, mute, schermo intero, dimensioni finestra e tasti aggiuntivi. I profili
schema 1 vengono validati e migrati conservando tutti questi dati e togliendo
soltanto il volume Musica; anche il backup precedente è migrabile. Il record
è aggiornato solo se il punteggio cresce; nuova partita non lo azzera.
Salvataggi differiti di 400 ms e flush alla chiusura delle impostazioni, al ritorno
al menu e all'uscita. Scrittura in .tmp verificata, backup .bak dell'ultimo primario
valido e sostituzione per rename. .tmp incompleti ignorati; primario corrotto
recuperato da backup; copie illeggibili usano i predefiniti. Schema futuro non
sovrascritto. Tipi, limiti e conflitti sono validati prima di applicare i dati.
Errori I/O restano visibili, con dati in memoria e partita utilizzabile.
Non si salva una partita interrotta: la persistenza riguarda record e impostazioni.

Opzioni video: finestra libera con minimo 960×540 e preset 960×540, 1280×720,
1920×1080; dimensioni e schermo intero ricordati. Display headless non ridimensionato
nei test. DPI Windows 125%/150%, ascolto reale e periferiche richiedono collaudo manuale.

## Asset e accettazione

Grafica originale a cubi accostati: faccia superiore 2:1, profondità 0,55
larghezze, lati contrastati. Pixel art generata da Python standard: protagonista
arancio con piedi/cresta e muso corto, quattro direzioni e tre pose; Scorie
rosse, serpente viola a spire, due laterali specchiati, sabotatore verde con
maschera e piedi, Stasi sferica. Dischi multicolore e raccordo 18+54 tick invariato.
HUD con punti/record a sinistra, livello/round a destra, campione obiettivo
cromatico e vite laterali. Il bonus resta sulla piramide fra round; la scheda a quattro cubi compare
soltanto al passaggio di livello. Attesa di 180 tick, congelata in pausa.
Palette separate dalle regole in ArcadePalette: I/1 viola→giallo; I/2 crema→blu;
I/3 grigio chiaro→grigio scuro per tutto il round, anche dopo Stasi, come richiesto;
I/4 blu→oliva; II/1 blu→crema→verde. I round successivi riusano le famiglie
osservate in un ciclo progettuale, non verificato come sequenza arcade.
I/4 resta a cambio permanente: il magenta dello screenshot non introduce
un terzo stato logico. Stati riconoscibili tramite colore e campione HUD;
i vecchi simboli cerchio/spunta non sono più disegnati. Audio solo per eventi.
Font con licenza verificata; sorgenti grafici/audio conservati.
Inventario e licenze: docs/ASSET_LICENSES.md e docs/ASSET_CATALOG.md.
Le fonti e gli adattamenti sono tracciati in docs/REFERENCE.md.
Criteri completi, prove eseguite e pendenti: docs/TESTING.md.

## Limite delle rifiniture della fase 3

La richiesta corrente allinea il calendario di tutti i ruoli esistenti
alla tabella Gottlieb, sostituendo soglie globali e filtro esclusivo round 3.
Nessuna nuova famiglia o metamorfosi. Conservate Stasi protettiva, grafica
approvata, input, timer, punteggi, dischi e progressione. Le prove Windows
riferite dall'utente restano attribuite alle versioni effettivamente provate;
la nuova 0.3.4 richiede un collaudo separato.


## Correzioni circoscritte 0.3.2 — fase 3 (storico; disponibilità aggiornata sotto)

La Stasi protettiva è una modifica richiesta dall'utente: il manuale documenta
congelamento e 100 punti, senza definire questa precisa immunità e la sua
priorità temporale. I ragnetti riusano la Scintilla laterale (tipo 2), con
sagoma originale viola, arti angolari e occhi, specchiata ai due bordi.
Dal livello 1 round 3 sono ammessi nella selezione casuale successiva al
primo Segugio: non viene imposta un'ulteriore prima apparizione. Preavviso
36 tick, intervalli di spawn, cap due, salto 24 tick e periodo base 66 tick
restano invariati. Il manuale descrive i laterali senza inseguimento: il
serpente conserva il ruolo di inseguitore. Nessuna nuova famiglia o metamorfosi.
Nel round 1/3 la prima apparizione resta il Segugio al tick 252, se sicuro;
la seconda può essere un ragnetto dal tick 504 (8,4 s attivi), con preavviso
dal tick 468. Scelta casuale, occupazione e cap possono rinviarne l'arrivo.
La rotta logica esistente risale il bordo fino all'uscita dall'apice; non
implementa una nuova superficie laterale dei cubi. Gli altri scostamenti
progettuali dalla tabella arcade originale restano espliciti e invariati.


## Correzione disponibilità 0.3.3 — fase 3 (storico, sostituita dalla 0.3.4)

I ragnetti (Scintilla laterale, tipo 2) sono candidati di apparizione
esclusivamente quando il round nel livello è 3, in tutti i livelli iniziali
e continui. Con indice globale da zero la condizione è `round_index % 4 == 2`.
Nei round 1, 2 e 4 non sono selezionabili né preannunciati. Ogni cambio
round azzera attori e preavvisi: nessun ragnetto può essere ereditato dal
round 3 al 4 o al livello seguente. La precedente soglia “dal terzo round
globale in poi” è sostituita da questa regola periodica.

Nel terzo round restano la selezione casuale dopo il primo Segugio, cap due,
preavviso 36 tick, rinvii per celle non sicure, rotte, grafica e collisioni
già approvati. Nessuna garanzia di apparizione immediata o su entrambi i
bordi nella stessa partita. Stasi, input, altri avversari, punteggi e timer
restano invariati. La regola esclusiva è richiesta dall'utente per Arcade
Pyramid: la tabella Gottlieb non la applica a tutti i livelli (vedi REFERENCE).


## Allineamento calendario Gottlieb 0.3.4 — fase 3

`PyramidWorld.ROUND_ROSTERS` è l'unica fonte runtime della disponibilità
per le quattro famiglie e la sfera verde. Il filtro è condiviso dalla
selezione dei nemici e dal timer di comparsa della Stasi. I test usano
una trascrizione indipendente dei nomi della tabella per confrontare
preavvisi e apparizioni effettive, oltre alle transizioni e al respawn.

Ugg/Wrong-Way restano le due rappresentazioni specchiate della famiglia
laterale; Slick/Sam corrispondono al ruolo raccoglibile dello Sverniciatore.
Non vengono aggiunti duplicati o trasformazioni. La disponibilità segue il
manuale; numero di attori, prima apparizione riservata al Segugio, velocità,
traiettorie, posizioni, sfera verde statica e protezione durante Stasi
rimangono adattamenti già approvati. Numero/posizione dei dischi e bonus
non sono oggetto di questo allineamento della colonna personaggi.


## Confine della fase 4

Regole, punteggi, timer, avversari e disponibilità Gottlieb della 0.3.4 restano
invariati. Conservate le sagome approvate di dischi, sfere, serpente e ragnetti;
completati Sverniciatore con maschera, orientamento del visore, alone di protezione
e bagliore d'atterraggio, derivati dallo stato logico. Risorse native e audio
originali con provenienza registrata. Nessuna installazione o pubblicazione.
Il pacchetto intermedio usa la pipeline già esistente: non anticipa il lavoro
di consolidamento/distribuzione finale della fase 5 o i collaudi della fase 6.


## Pacchetto consolidato — fase 5

EXE/PCK separati e guida del giocatore sono distribuiti con documenti,
notices, BUILD_INFO.json, manifest sorgenti e checksum. QBertPyramid-source.zip
conserva commit di base tramite bundle Git e sorgenti distribuibili effettivi,
comprese modifiche non committate; PROVENANCE.json elenca eventuali cancellazioni.
La selezione esplicita esclude riferimenti locali, immagini dell'utente,
cache e dati privati; symlink nei sorgenti distribuibili sono rifiutati.
Il manifest corrisponde esattamente allo snapshot distribuibile, non ai
materiali locali esclusi. Identità verificata tra sorgenti, metadati e ZIP.
Procedura di ricostruzione in docs/REBUILD.md; nessuna dipendenza da Codex.
Le prove Windows riferite per la fase 4 non certificano il nuovo archivio.


### Revisione audio 0.5.2 del 7 novembre 2026

Solo sintesi/mix degli eventi: otto WAV originali aggiornati dal confronto
numerico VID-01 documentato in docs/ARCADE_REVIEW.md; caduta ed extra invariati.
Una voce principale, più una voce extra al premio per evitare ritardi dietro
un round di 2,75 s. I segnali lunghi rescue/lure/round cedono al nuovo evento
jump/rescue/collect/round/lure. Pausa, mute, zero volumi, scene e riavvio
cancellano entrambe le voci. Nessun effetto nemico autonomo dedotto dal mix
sovrapposto. Nessuna variazione alle regole/tempi/grafica o avvio della fase 6.


## Revisione correttiva 0.5.3 — requisiti correnti

Questa sezione sostituisce, per i cinque aspetti seguenti, i comportamenti
precedenti descritti nelle sezioni storiche. Base 0.5.2, audio compreso,
funzionalmente accettata su Windows secondo il resoconto dell'utente;
la 0.5.3 non eredita automaticamente quel collaudo. Fase 6 non iniziata.

- **Pillola verde/Stasi:** calendario Gottlieb invariato. Una comparsa per
  round ammesso, al tick attivo 720 (12 s), sulla cella (0,0). Prima partenza
  42 tick dopo la comparsa, poi partenze ogni 42 tick (700 ms), con 24 tick
  di volo e 18 di sosta. A ogni salto RNG sceglie SO/SE con pari probabilità;
  stesso seed, input e stato producono la stessa sequenza. Le celle fino
  alla riga 6 sono valide; il salto successivo arriva alla riga 7 esterna,
  rimuove l'oggetto logico e lascia 24 tick di animazione di caduta. Nessun
  premio per la perdita. Contatto su cella occupata, atterraggio o incrocio
  di traiettorie opposte raccoglie una volta: 100 punti, 300 tick di Stasi,
  cue stasis_collect. Caduta effettiva: stasis_fall una volta. Morte e cambio
  round rimuovono l'oggetto senza falsa raccolta/caduta; la morte non riapre
  una comparsa già consumata. Pausa congela movimento, RNG e timer.
- **Segugio/Coily ("diavolo", identità confermata dall'utente):** conserva
  l'inseguimento normale su celle valide. Quando è sul bordo del disco o
  già in volo verso quella cella durante il trasporto, conserva quel bersaglio
  anche dopo i 72 tick del disco e durante un congelamento. Raggiunta la
  cella del disco salta fuori; soltanto alla fine del salto esterno vengono
  emessi actor_fallen e il cue dedicato lure, accreditati 500 punti una volta
  e rimossi gli avversari. Animazione residua 24 tick, priva di collisioni.
  Un Segugio lontano che non raggiunge il bordo durante il trasporto torna
  a inseguire il protagonista: usare un disco non garantisce 500 punti.
- **Transizioni:** alla prima entrata in ROUND_END, round per i round 1–3,
  level per il quarto, mai entrambi. Attesa logica invariata: 180 tick.
  Raccolta Stasi, caduta del Segugio e vita extra effettivamente coincidenti
  restano eventi distinti, senza essere ritardati dal segnale di transizione.
  Quattro voci: principale, extra, Stasi, Segugio. Mute, volumi zero, pausa,
  focus perso, riavvio e scene arrestano tutte le voci e le code; la ripresa
  non riemette eventi. Nessuna musica continua.
- **Game Over:** appare soltanto allo scadere dei 90 tick dell'ultima morte,
  con vite esaurite. Banner centrale con fondo scuro, font pixel originale,
  contrasto giallo/bianco e variazione cromatica a 1 Hz, HUD lasciato visibile.
  Cue game_over unico da 650 ms. Dopo 1,2 s di tempo di presentazione con
  focus, oppure Invio/"Classifica", apre la classifica. Focus perso sospende
  questa attesa. Menu/Esc a Game Over passano prima dalla classifica;
  il riavvio tramite GUI non la scavalca e le Impostazioni non la sovrappongono.
- **Classifica dopo ogni Game Over:** schermata opaca dedicata con punteggio
  finale, livello/round e massimo cinque risultati. Nessun punteggio fittizio.
  Un punteggio positivo qualifica se ci sono posti liberi o supera l'ultimo;
  a classifica piena il pari all'ultimo non entra. I pari ammessi mantengono
  l'ordine di inserimento. Nome di massimo 8 caratteri A–Z, cifre e spazi,
  normalizzato in maiuscolo; vuoto diventa AAA. LineEdit supporta digitazione,
  correzione, Tab e Invio; "Continua · Menu" ed Esc consentono di proseguire
  anche senza qualificazione. Conferma ripetuta non duplica il risultato.
  Se il disco non è scrivibile il risultato resta in memoria e si può
  riprovare senza un secondo inserimento. Continua senza conferma rinuncia
  al nome/nuova riga; il massimo personale già osservato resta conservato.

Profilo schema 3: aggiunge leaderboard senza perdere record, metadati,
comandi o preferenze. Schemi 1 e 2 migrano il massimo positivo a una riga
STORICO, senza inventare le iniziali del vecchio giocatore; nessuna riga per
record zero. Backup, scrittura atomica, controllo di corruzione e protezione
contro versioni future restano attivi. Ripristinare le impostazioni non
cancella la classifica. Non è prevista retrocompatibilità in scrittura con
la 0.5.2: usare una copia separata dei dati se si desidera tornare indietro.

Fonte delle regole verdi/Coily/punteggi: MAN-01 PDF 6–7 (stampate 4–5).
Timer numerici, collisioni, cinque righe, nomi di otto caratteri e UI sono
scelte originali di Q*Bert Pyramid. Il video non mostra una fine livello
completa: level è una variante originale del ruolo di transizione, non una
trascrizione certificata del riferimento. Nessuna fedeltà percettiva dichiarata.


## Revisione 0.5.4 — comportamento corrente

Questa sezione sostituisce i dettagli 0.5.3 relativi ai sei interventi.
La 0.5.3 è stata approvata funzionalmente su Windows secondo il resoconto
dell'utente; ciò non certifica il nuovo EXE 0.5.4. Fase 6 non avviata.

1. **GAME OVER:** soltanto dopo i 90 tick dell'ultima morte già previsti,
   banner centrale con contrasto elevato e scritta lampeggiante a 1 Hz
   (500 ms visibile, 500 ms spenta). Il pannello/comando resta visibile.
   Durata 30 s di presentazione con focus; perdita focus congela attesa e
   lampeggio. Una nuova pressione Q/E/Z/C, freccia, tastierino o comando
   direzionale rimappato apre i punteggi; echo e tasti già mantenuti non
   saltano l'attesa. Invio e pulsante Classifica sono conferme alternative.
   Esc/Menu non scavalcano l'attesa. Il tasto usato è consumato, senza
   spostare il protagonista o inserire lettere nel nome. Cue game_over
   precedente conservato, una sola volta all'ingresso: non viene ripetuto
   per 30 s né ad ogni lampeggio. HUD e punteggio restano visibili.
2. **Classifica locale:** massimo dieci risultati positivi, ordinati per
   punteggio decrescente, con iniziali esattamente di tre lettere A–Z,
   punteggio, livello e round. Le cinque colonne sono allineate tramite
   GridContainer; i numeri sono allineati a destra. Pari sull'ultimo posto
   pieno non qualificano; altri pari conservano l'ordine di arrivo.
   Il nome è normalizzato in maiuscolo; cifre e nomi incompleti non possono
   essere confermati. Continua/Esc confermano prima l'eventuale risultato
   qualificato valido; non lo scartano silenziosamente. Il retry dopo errore
   di scrittura non reinserisce la riga. Il salvataggio è profile.json in
   user://, con backup, validazione e sostituzione atomica già presenti.
3. **Nome prodotto:** Q*Bert Pyramid in configurazione, finestre, schermate,
   font, documenti e metadati. Eseguibile/PCK QBertPyramid, archivio sorgenti
   QBertPyramid-source.zip. Il percorso del repository richiesto dall'utente
   non viene spostato e la storia Git/build precedenti non viene riscritta.
   Un identificatore di compatibilità ricostruisce esclusivamente il vecchio
   percorso dei dati; non viene usato come nome dell'applicazione.
4. **Totali nelle istruzioni:** seconda riga permanente del menu, del dialogo
   istruzioni, della presentazione e della legenda di partita:
   "Livelli: illimitati · Round/livello: 4 · Round totali: illimitati".
   È il comportamento realmente implementato: dodici round iniziali
   configurati, poi progressione continua senza fine prefissata. Non si
   introduce un limite a nove livelli o dodici round e non si attribuisce
   al manuale un totale finito che il prospetto non dimostra.
5. **Leggibilità e conclusione:** preservati banner centrale, font originale,
   suono conclusivo 650 ms, ultima morte/precedenze e assenza di Game Over
   anticipato. Mute, volumi, pausa, scene e riavvio non riemettono il cue.
   Le regole, palette, collisioni, dischi, Stasi e punteggi della 0.5.3
   restano invariati; cambia solo il tempo di presentazione finale richiesto.
6. **Schermate iniziali:** al primo ingresso nel menu di ogni avvio,
   istruzioni originali progressive (18 s), dimostrazione autonoma (20 s),
   classifica locale in sola lettura (8 s), poi menu operativo. Nuova
   pressione direzionale, Invio, Esc o "Vai al menu" saltano la sequenza.
   "Presentazione" nel menu permette di rivederla; "Classifica" consulta i
   dati locali senza inserimenti. Il rientro al menu dopo una partita non
   ripete automaticamente la sequenza. Focus perso sospende la presentazione.
   La demo usa un modello distinto, seed controllato e gli asset del gioco:
   nessun punteggio della demo viene osservato o salvato nel profilo. I suoi
   effetti provengono dalla mappa degli eventi già esistente e vengono
   fermati al cambio di schermata; istruzioni/classifica restano silenziose.

**Migrazione schema 4 e cambio cartella:** il nuovo user:// è QBertPyramid
(su Windows normalmente %APPDATA%/QBertPyramid). Solo quando mancano sia il
nuovo primario sia il suo backup, il caricatore cerca il precedente profilo
nella cartella sorella della 0.5.3 e il relativo backup. Legge schemi 1–3,
conservando record e preferenze; la successiva scrittura usa il nuovo
percorso e non modifica l'originale. Lo schema 3 conserva tutte le vecchie
righe: le iniziali derivano dalle prime tre lettere, completate con A se
necessario; il nome originale fino a otto caratteri resta in legacy_name e
viene mostrato sotto la tabella. I massimi schema 1/2 diventano STO con
nome precedente STORICO. Nessun punteggio storico viene inventato o perso.
I profili di versioni future restano protetti. Non è prevista lettura dello
schema 4 da parte delle vecchie build: conservare i dati precedenti per rollback.


## Fase 6 — correzione di conformità, 8 novembre 2026

Prodotto 0.5.4 conservato. Corretto il riconoscimento dei vecchi profili
schema 1/2 senza leaderboard dopo parsing JSON: schemi numerici rappresentati
come float sono confrontati numericamente prima della migrazione prevista.
Nessun cambiamento a regole, tempi, controlli, arte o audio. Packaging include
ora TEST.md aggiornato e matrice finale; REBUILD riporta la GPL v3 scelta.
I dodici criteri approvati restano quelli di docs/TESTING.md, con esiti e
prove mancanti in docs/ACCEPTANCE_PHASE6.md. Non si dichiara completata la
fase 6 senza Windows reale, durata e prestazioni. Fase 7 esclusa.


## Menu pubblico Rev. 1.0 — aggiornamento circoscritto

Laboratorio regole nascosto di default; configurazione e spiegazioni solo
nel documento tecnico docs/DEVELOPMENT.md. Informazioni sul gioco sostituisce
Istruzioni, con versione QBERT Rev. 1.0, autore e GPL v3.0 espliciti, mantenendo
l'aiuto di gioco. Navigazione e focus saltano il controllo tecnico nascosto.
Nessuna modifica alle regole, ai salvataggi o all'audio. Amend del solo ultimo
commit di release richiesto dal titolare; precedente commit conservato in
bundle locale ignorato. Release 1.0 conclusa, prestazioni non eseguite ancora
pendenti. Lo stato di preparazione qui riportato è storico; la release corrente è la 1.1.0.

## Release 1.1.0 — 2026-11-09

Released as tag `v1.1.0`. The clean public source, Windows installer, portable
runtime and corresponding source archive are available through the GitHub release.
See `docs/releases/v1.1.0.md` for changes and validation details.
