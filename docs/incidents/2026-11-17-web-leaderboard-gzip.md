# Classifica Web e risposte gzip — analisi del 17 novembre 2026

> Aggiornamento: entrambe le correzioni approvate dall’utente il 17 novembre
> 2026 per la release 1.2.1. Segue il rapporto della fase di proposta;
> stato corrente e autorizzazione in [RELEASE.md](../../RELEASE.md).

**Stato:** correzione proposta, verificata localmente; pubblicazione e deploy
richiedono nuova approvazione dell'utente. Nessuna modifica al servizio online,
al database pubblico, ai tag o agli asset della release v1.2.0.
Ramo locale: `fix/web-leaderboard-gzip-1.2.1`. Versione bugfix proposta: 1.2.1.
I documenti congelati nel tag v1.2.0 restano invariati.

## Evidenza e causa

Screenshot dell'utente: classifica vuota e messaggio “Classifica server non
raggiungibile. Nuovo tentativo automatico.” Il gameplay continua.

Letture diagnostiche pubbliche, senza POST o interventi amministrativi:

- API HTTPS: HTTP 200, JSON valido, inizialmente sei righe e record 33580;
  durante l'analisi le righe sono diventate sette. I dati sono presenti.
- Accept-Encoding identity: corpo JSON non compresso, 443 byte al primo controllo.
- Accept-Encoding gzip: Content-Encoding gzip, corpo compresso di 182 byte.
- Client nativo Godot: accetta la stessa risposta JSON e carica i sei risultati.
- Chrome Windows, profilo isolato: riproduce classifica vuota. La console emette
  errori `core/io/stream_peer_gzip.cpp:117`; un fetch JavaScript indipendente
  nello stesso browser legge correttamente JSON, record e classifica.

Il browser decodifica già la risposta HTTP; HTTPRequest, con accept_gzip=true,
prova a decomprimerla di nuovo perché conserva l'header Content-Encoding.
Non è quindi sufficiente avere HTTP 200: Godot può rifiutare il corpo.
Anche il POST può essere già stato salvato dal server senza che il client riesca
a interpretare la conferma. Non si deduce che ogni risultato non confermato
sia arrivato al server o possa essere recuperato se non è stato registrato.

Documentazione primaria:
[HTTPRequest.accept_gzip](https://docs.godotengine.org/en/stable/classes/class_httprequest.html#class-httprequest-property-accept-gzip).
Con false Godot non esegue la propria decompressione; nel Web resta quella
trasparente del browser. Non si tenta di impostare manualmente Accept-Encoding,
che è controllato dal browser.

## Patch minima proposta

In `scripts/app/web_scores.gd`, alla creazione della richiesta:

```gdscript
_request = HTTPRequest.new()
# Browser Fetch already decodes Content-Encoding; do not decompress twice.
_request.accept_gzip = false
```

Il componente è quello della sola classifica Web. Nessuna modifica a regole,
input, grafica, suoni, database, API, schema dei punteggi o hosting. Sono
preservati conferma, nonce di invio e retry senza duplicati. Non occorre
cambiare motore, attivare un piano a pagamento o svuotare il database.

## Verifica riproducibile

Fixture: `tests/tooling/gzip_leaderboard_fixture.py`, bind 127.0.0.1,
SQLite privato nuovo e sei risultati fittizi. Comprime le risposte JSON di
almeno 200 byte se il browser accetta gzip. La soglia di simulazione riproduce
il caso osservato; la soglia precisa del proxy del provider non è stata misurata.

```bash
python3 tests/tooling/gzip_leaderboard_fixture.py /percorso/site-diagnostico \
  --state /nuova/cartella/privata/gzip-fixture --port 8798
```

Esportazione Web diagnostica locale con la patch, Godot/template 4.7.2.
Non è un pacchetto di release e conserva la versione del progetto di partenza:
non deve essere pubblicata o confusa con gli asset ufficiali v1.2.0.

Chrome: `tools/browser_web.ps1` contro localhost:8798, profilo isolato.
Lettura iniziale di sei righe, UI classifica corretta; POST dal gioco di un
risultato con iniziali, risposta HTTP 200 gzip di 562 byte decodificati, conferma
UI e ritorno al menu. Record ritrovato dopo ricaricamento della pagina.
Le tracce della fixture attestano GET e POST compressi, non solo un header
simulato. Nessun errore stream_peer_gzip nella sessione corretta.
Il test comprende input, pausa, audio/mute e preferenze; la lettura e il
salvataggio della classifica avvengono sul server locale, non nel browser.

Edge: seconda prova Web con dieci posizioni occupate, risposta gzip e
classifica completa visualizzata; nessun errore stream_peer_gzip rilevato.

Regressioni: 131 test GDScript / 126778 verifiche e 32 test Python superati.
Aggiunte verifiche su classifica popolata con punteggi realistici e sul rifiuto
di una falsa conferma HTTP 200 con errore di decompressione. Nessuna nuova
prova nativa Windows dichiarata; la modifica non coinvolge i salvataggi Windows.

Il collaudo della release iniziale non copriva risposte compresse con classifica
popolata: questa lacuna è ora coperta dalla fixture e dalla prova Web reale.
Evidenze locali: `.local-state/leaderboard-incident-2026-11-17/`.

## Rilascio, solo dopo approvazione

Preparare e ricostruire la nuova versione 1.2.1, aggiornare la documentazione
della nuova release, pubblicare tag/asset distinti e aggiornare il frontend
sul backend esistente. Conservare il database; non spostare v1.2.0, non
sostituirne gli asset e non cambiare Windows v1.1.0. Verificare online GET e
conferme, nuova classifica e assenza degli errori gzip dopo il deployment.
