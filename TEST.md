# Web 1.2.1 — accettazione e verifica

**17 novembre 2026:** l'utente approva entrambe le correzioni (gzip e attesa
SQLite), le modifiche richieste alla pagina, commit, release e deployment.
L'accettazione manuale della 1.2.0 risale al 16 novembre; le prove della patch
qui documentate sono automatizzate e non sono attribuite all'utente.

Suite: **131 test GDScript / 126778 verifiche e 41 test Python**.
La build esegue nuovamente regressioni, export, controlli HTTP/MIME,
sottocartella, licenze, ZIP, sorgenti esatti e Runtime estratto con API.
Il rapporto QA allegato registra gli esiti del commit finale.

## Multiutenza e regressione gzip

Due partite contemporanee in Chrome/Edge Windows (profili isolati, headless)
hanno mantenuto stato e preferenze indipendenti; entrambi i risultati sono
stati salvati nella classifica condivisa e riletti dopo reload, con GET/POST
gzip. Le prove server comprendono 32 client concorrenti, un worker HTTP,
quattro processi, retry, conflitti, ordinamento e rollback. Nessun risultato
perso o duplicato nei casi verificati. Il blocco SQLite forzato riceve 503
prima del timeout client; liberato il lock, il retry salva una sola volta.

Questi test sono locali, su database privati: non certificano la capacità
massima dell'hosting gratuito. Nessuna nuova prova dell'eseguibile Windows.
Le verifiche online successive al deployment e le evidenze browser della
pagina finale sono riportate separatamente nel QA e nel repository del sito.

- [Analisi gzip](docs/incidents/2026-11-17-web-leaderboard-gzip.md)
- [Scenari, risultati e riproduzione multiutenza](docs/incidents/2026-11-17-web-multiuser.md)
- [Release](RELEASE.md) · [Deployment](docs/DEPLOY_WEB.md)

## Registro storico conservato

# Validation record — version 1.0.0

The owner reports successful Windows functional tests, including the checklist
for offline/standard-account operation, paths with spaces, 720p/1080p, DPI,
controls/focus/audio/persistence, 20 minutes and five consecutive new games.
The owner subsequently instructed closure of phase 6, considering performance
and newest-menu checks performed and accepted, and approved the sprite-derived
icons on Windows. No raw frame-time samples or numerical medians/P99 were
supplied to this session; no independent measurement values are invented.

Automated source checks: 126 GDScript tests, 126546 assertions and 17 Python
tests; 153 WSLg captures were checked during final menu/icon work. These are
separate from the owner's Windows acceptance. The release build reruns the
full suite, exports Windows x64, loads PCK scenes/resources and verifies ZIP
CRC, hashes and exact source identity. A fresh public checkout is rebuilt
and public downloads are checked separately before delivery is reported.

Performance targets are 60 FPS at 1080p, median <=16.7 ms and P99 <=33.3 ms.
The owner acceptance is recorded without a universal performance guarantee.
Reference machine: Windows 11 Home x64, Core Ultra 9 275HX, RTX 5070 Laptop.
The executable is unsigned. See INSTALL_WINDOWS for scope and limitations.
