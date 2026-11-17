# Q*Bert Pyramid WEB 1.2.1 — runtime stabile

Versione approvata dall’utente il 17 novembre 2026. Documentazione congelata
con il tag v1.2.1; pacchetti ricostruiti dai sorgenti stabili.

Correzioni: classifica gzip e attese SQLite; pagina aggiornata. Il link Note e
Licenze mostra LICENSE e THIRD_PARTY_NOTICES. La nuova versione conserva il
DB esistente: nessuna migrazione, nessun dato di prova incluso.

## Avvio immediato senza Godot

Estrarre **Runtime.zip** oppure **Complete.zip**, aprire un terminale nella
cartella che contiene `site/` e `server/`, quindi:

```bash
python3 server/serve_web.py site --port 8765 --db ../qbert-data/leaderboard.sqlite3
```

Su Windows con Python installato si può usare:

```powershell
py -3 server/serve_web.py site --port 8765 --db ../qbert-data/leaderboard.sqlite3
```

Aprire http://localhost:8765/80_arcade_games/qbert/ . La pagina presenta
il gioco e il cabinato arcade: premere GIOCA ORA per avviarlo e fare clic
nel canvas. HOME torna alla home personale alla radice del sito; la voce 80 Arcade Games
riapre il gioco.
Per fermare il server: Ctrl+C. Se un vecchio server usa la stessa porta,
arrestarlo prima. Dopo un aggiornamento ricaricare Chrome con Ctrl+F5.

Python >=3.10 con SQLite è il solo prerequisito del server locale; il giocatore
non deve installare Godot. Non aprire index.html tramite file://.
Il database è esterno al sito e al pacchetto: conservarlo fra aggiornamenti.
Le impostazioni restano nel browser; la classifica è condivisa sul server.
Non viene salvata una partita in corso.

## Cosa scaricare

- **Runtime**: gioco esportato HTML/JS/WASM/PCK, server/API e istruzioni.
  Nessun progetto Godot modificabile incluso. I file Python del servizio sono
  necessari all'esecuzione del backend e restano leggibili.
- **Complete**: tutto il runtime più progetto Godot, asset, strumenti, test e
  documentazione in `source/`, con manifest e provenienza dei sorgenti.
- **Source**: soli sorgenti corrispondenti e manifest, per sviluppo/ricostruzione.
- **WebStatic**: soli file statici per integrazioni; non contiene il servizio
  che salva la classifica. Non equivale al gioco completo su un host statico.

Controllare SHA256SUMS.txt. Per ricostruire consultare source/README.md nel
pacchetto completo. Sorgenti corrispondenti disponibili anche nel separato ZIP
Source fornito insieme al runtime: conservare licenze e SOURCE_NOTICE.txt.

## Comandi e distribuzione

Q/Sinistra/KP7 ↖; E/Su/KP9 ↗; Z/Giù/KP1 ↙; C/Destra/KP3 ↘.
P pausa/riprendi; Esc segue il flusso menu/risultati; F11 schermo intero se
consentito dal browser. HOME è il simbolo della casetta nella pagina di gioco.
Dopo perdita di focus riprendere esplicitamente e premere di nuovo i tasti.
Solo browser desktop e tastiera; niente smartphone, Android o touch.

Per web server propri: **DEPLOY_WEB.md**. Per GitHub Release e GitHub Pages:
**GITHUB_PUBLICATION.md**. Il server locale Python è per localhost; il modulo
WSGI incluso serve a integrare la stessa API in un ambiente server adeguato.
Per il piano gratuito predisposto: **PYTHONANYWHERE_DEPLOY.md**.
La configurazione del servizio pubblico è separata dal runtime: non vengono
attivati servizi o fatturazione avviando il gioco in localhost.

Copyright © Eugenio Ruggieri 2026. Codice/asset originali GPL-3.0-only;
dipendenze e font conservano le rispettive licenze. Progetto indipendente,
non ufficiale. Q*bert e marchi di terzi appartengono ai rispettivi titolari.
