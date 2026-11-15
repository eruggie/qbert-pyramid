# Web 1.2.0-rc.2 — audio e classifica server (test localhost)

Ambito autorizzato: correggere esclusivamente audio Web e persistenza condivisa
di punteggi/classifica. Gameplay, contenuti, controlli, fullscreen e layout non
vengono modificati. Windows 1.1.0 mantiene il salvataggio locale e il playback
nativo. Nessuna pubblicazione, attivazione cloud o deploy.

## Correzioni

- Audio: nella rc.1 il contesto WebAudio era running e i buffer contenevano dati,
  ma la misura del segnale finale in Chrome era zero. I quattro player Web
  usano ora `AudioServer.PLAYBACK_TYPE_STREAM`, il mixer Godot, invece del
  percorso Sample predefinito. Asset, cue, volume e mute non cambiano.
  Questa modalità può avere più latenza nel template senza thread:
  https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#audio-playback.
- Punteggi: HTTP GET/POST `api/leaderboard`, relativo alla cartella del gioco.
  Il server salva le iniziali, i punti, il livello e il round in SQLite;
  restituisce la top ten e il record, con pareggi ordinati per primo invio.
  Classifica aggiornata all'apertura e ogni cinque secondi, anche fra browser
  con profili diversi. Il record Web è quello confermato sul server; il solo
  punteggio della partita in corso non è ancora un record pubblicato.
- Il salvataggio è dichiarato riuscito soltanto dopo risposta del server.
  In caso di errore la schermata consente Riprova e conserva in memoria lo
  stesso identificativo: ripetere un invio non duplica il risultato. Il
  risultato qualificato non viene chiuso come «salvato» durante attesa/errore.
- Le sole impostazioni restano nel browser. Il vecchio profilo rc.1 viene
  conservato per rollback, senza caricare automaticamente i suoi punteggi nel
  server. Nessun punteggio fittizio o di test nel database della prova manuale.

## Avvio dal workspace WSL

1. Arrestare con Ctrl+C il vecchio server rc.1 nel suo terminale.
2. Dalla radice `qbert-pyramid-web`, eseguire:

```bash
python3 tools/serve_web.py builds/<cartella-rc.2-stampata-dalla-build>/site --port 8765
```

Aprire Chrome Windows su http://localhost:8765/80_arcade_games/qbert/ .
Ricaricare la pagina per non continuare la precedente sessione rc.1.
Avviare il gioco e fare clic nel canvas. Per ricostruire: `bash tools/build_web.sh`.

Il database predefinito è `.local-state/web-server/leaderboard.sqlite3`, fuori
 dai file pubblici. È indipendente dalla cartella/versione della build e
rimane fra riavvii del server. Non cancellarlo per aggiornare il gioco.
Per prove isolate usare `--db /percorso/esterno/al/sito/prova.sqlite3`.
Fare backup del database a server fermo. Nessun salvataggio partita in corso.

## Uso del pacchetto senza checkout

Estrarre lo ZIP Web in una directory `site/` ed estrarre lo ZIP LocalServer
accanto ad essa (directory `server/`). Con Python >=3.10:

```bash
python3 server/serve_web.py site --port 8765 --db state/leaderboard.sqlite3
```

Non mettere il database dentro `site/`. Il server ascolta soltanto su localhost.
La standard library Python e SQLite non richiedono installazioni aggiuntive.

## Test manuale richiesto

1. Da un profilo Chrome normale nuovo/non silenziato ascoltare salti, atterraggi,
   cadute, demo e Coil; provare Master, Effetti e mute. Nessuna musica continua
   è prevista. Confermare anche la latenza percepita.
2. Concludere una partita con punti, inserire tre iniziali e attendere
   «Punteggio salvato sul server».
3. Aprire la classifica in un secondo browser o profilo: lo stesso punteggio
   deve comparire senza condividere IndexedDB. Tenere aperte due classifiche:
   i nuovi risultati devono comparire entro circa cinque secondi.
4. Arrestare e riavviare il server usando lo stesso database, quindi ricaricare:
   classifica e record devono restare. Non confondere un database `--db`
   differente con una perdita di dati.
5. Simulare server irraggiungibile durante un invio; ripristinarlo e premere
   Riprova. Verificare conferma e assenza di duplicati.

I dati restano sul computer che esegue il server di prova, non nel disco del
browser. Una futura classifica pubblica richiede API e storage server persistenti:
GitHub Pages o altro hosting puramente statico da soli non soddisfano più il
requisito. Nessuna scelta o attivazione di produzione viene effettuata ora.
Questo server locale accetta punteggi dichiarati dal client, non implementa
anti-cheat né certifica l'infrastruttura per l'esposizione pubblica.

Esiti automatici/browser ed eventuali limiti sono consegnati con il pacchetto;
l'ascolto umano e l'accettazione dell'utente restano separati. La rc.2 non è
una release pubblicata.

## Verifiche della correzione

- Suite GDScript: 131 test, 126.776 verifiche, compreso JSON remoto con numeri
  decimali normalizzati e UI che non conferma scritture fallite.
- 18 regressioni Python esistenti e 6 nuovi test HTTP/SQLite: validazione,
  concorrenza, pareggi, persistenza, idempotenza, isolamento della directory.
- Chrome ed Edge Windows: segnale audio di picco circa 0,07474 prima di mute,
  zero dopo mute; classifica letta dal server, preferenze locali senza
  punteggi/classifica. Demo naturale con segnale non nullo.
- HTTP 503 iniettato dopo il commit SQLite: UI «non confermato», retry con
  stesso identificativo, conferma successiva e una sola riga nel database.
- Browser/profilo nuovo vede i risultati preesistenti; un invio HTTP da un
  altro client aggiorna una classifica già aperta senza ricaricare la pagina.
- Riavviato il server QA: identici revisione, classifica e record riletti dal
  database. Dati QA isolati dal database predefinito della prova manuale.

L'ascolto reale dell'utente e la latenza restano da accettare. Il controllo
«contesto running» della rc.1 è stato sostituito dalla misura del segnale in
uscita. Queste correzioni non risolvono né modificano il fullscreen pendente.
Nessuna nuova accettazione manuale Windows o pubblicazione viene dichiarata.
