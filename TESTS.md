# Web 1.2.0 — accettazione e verifica della release stabile

**16 novembre 2026:** l'utente dichiara superati i propri test dell'ultima
candidata e approva completamento Web 1.2.0, home personale, pacchetti,
commit e pubblicazione GitHub/Pages. Documentazione congelata per v1.2.0.
Non si attribuiscono all'utente misure, hardware o singole prove non comunicate.

Suite della linea Web: 131 test GDScript / 126776 verifiche e 32 test Python;
la build stabile esegue nuovamente suite, export, controlli HTTP/MIME/sottocartella,
ZIP, identità sorgenti e avvio del Runtime estratto con API e retry.
I risultati finali e l'identità del commit sono nel rapporto QA allegato.

Evidenze precedenti: Chrome 157.0.8103.79 / Edge 157.0.4341.60 desktop,
audio misurato e mute, classifica server, retry, persistenza, focus e comandi.
Ultima home: testi “ruge.”/Progetti Open Source, due riquadri cliccabili,
Tab, percorsi e HOME, nessun errore JS/HTTP rilevato nella sessione finale.
Le prove automatizzate browser non sono test manuali dell'utente né prove
native Windows. Non è implicito un collaudo pubblico di un host non attivato.
Lo stato operativo del deployment è separato dalla verifica del software.

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
