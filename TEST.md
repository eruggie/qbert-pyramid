# Web 1.2 — accettazione e preparazione finale

L'utente dichiara superati i test necessari e sufficienti e approva il
funzionamento Web della rc.2. Non vengono attribuiti all'utente numeri,
hardware, misure o singole prove non comunicati.

La nuova veste arcade e i pacchetti rc.3, preparati il 16 novembre 2026,
richiedono ulteriore approvazione. Nessun tag finale, push o deploy autorizzato.
Regressioni precedenti rc.2: 131 test GDScript / 126.776 verifiche, 24 test Python;
audio misurato, classifica server, retry e persistenza documentati nel rapporto rc.2.
Controlli rc.3: 131 test GDScript / 126.776 verifiche e 28 test Python;
verifica del Runtime estratto in percorso con spazi, HTTP/MIME, API e retry.
Chrome 157.0.8103.79 ed Edge 157.0.4341.60, profili isolati: nuova home,
avvio, menu, focus, HOME e viewport desktop 1024×768; nessuna eccezione
JavaScript, risposta HTTP >=400 o richiesta fallita rilevata nelle sessioni.
Queste prove automatizzate browser non sono test manuali dell'utente.
Nessuna nuova prova nativa Windows o di hosting pubblico è dichiarata.
Il rapporto della build rc.3 conserva i risultati e distingue le verifiche.

[Release](RELEASE.md) · [Deployment](docs/DEPLOY_WEB.md) · [Pubblicazione](docs/GITHUB_PUBLICATION.md).

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
