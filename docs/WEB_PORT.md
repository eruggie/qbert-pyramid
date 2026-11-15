> Corrente: **rc.3 per approvazione della nuova veste e distribuzione**.
> Vedere [RELEASE.md](../RELEASE.md), [DEPLOY_WEB.md](DEPLOY_WEB.md)
> e [GITHUB_PUBLICATION.md](GITHUB_PUBLICATION.md). Test funzionali rc.2 approvati.
> Le sezioni seguenti documentano la preparazione precedente e non definiscono il nuovo packaging.

# Port classico Web 1.2 — candidata locale

**Corrente: rc.2, correzioni audio e classifica server.** Vedere
[WEB_RC2_FIXES.md](WEB_RC2_FIXES.md) per avvio, API e persistenza attuali.
Le sezioni sotto registrano la rc.1: le sue indicazioni su classifica IndexedDB
e pubblicazione puramente statica sono superate dal nuovo requisito server.

Rapporto dei risultati e checklist: [WEB_VALIDATION.md](WEB_VALIDATION.md).

## Identità e isolamento

Baseline pubblica Windows: tag annotato `v1.1.0`, oggetto tag
`17eb6df4b4219abdda465903a73d42f1ed423ed8`, commit
`e833fd622596c109997a817afa73c9ea80644622`. Verificati anche con
`git ls-remote origin refs/tags/v1.1.0 'refs/tags/v1.1.0^{}'`.
Ramo locale `web/classic-1.2`, worktree separato `qbert-pyramid-web`.
La versione Web candidata è `1.2.0-rc.1`, non una release stabile collaudata.
La configurazione Windows, i tag e gli asset pubblicati non vengono sostituiti.

Il checkout di sviluppo privato ha cronologia
separata e una trascrizione locale non tracciata, conservata. Confronto dei
file runtime con il checkout pubblico: uno `assets/arcade/qbert_catturato.png`
aggiuntivo nel checkout di sviluppo, assente dalla release pubblica. Gli script,
le scene e i dati classici coincidono. Non sono emerse implementazioni Escher
nei file runtime analizzati: il port usa esclusivamente il tag pubblico e non
incorpora file dal laboratorio privato. Questo evita anche l'importazione di
modifiche future non identificate.

README, BUILD_FROM_SOURCE, PLAYER_GUIDE, TESTING, VALIDATION e release notes
riportano Godot 4.7.2; `tools/common.sh` impone l'identità esatta
`4.7.2.stable.official.ed1daf0bf`. Verificata sull'eseguibile locale. Il doctor
verifica hash del motore e template Windows. Per Web si verificano separatamente
hash dei template `web_nothreads_{debug,release}.zip`, in toolchain.json.
Nessun SDK C#, GDExtension, thread esplicito o dipendenza server nel gioco.
Renderer esistente Compatibility mantenuto; WebGL 2 e WASM richiesti.

## Modifiche limitate alla piattaforma

- Alias Web per le stesse posizioni fisiche KP7/9/1/3: il backend Godot Web
  4.7.2 espone i numeri del tastierino come keycode logici ASCII (o navigazione
  con NumLock spento), mentre le associazioni Windows usano keycode KP.
  L'alias fisico conserva tasto e direzione, non sostituisce alcuna associazione.
  Riscontro: test browser e sorgenti ufficiali
  [dom_keys.inc](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/dom_keys.inc)
  e [display_server_web.cpp](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/display_server_web.cpp).
- Secondo preset Web; thread/estensioni/PWA disabilitati; stesso elenco di
  risorse della release Windows, incluse immagine e voce Coil già pubblicate.
- Web-only DejaVu Sans fallback per le frecce mancanti: font primario e atlas
  bitmap invariati; provenienza e licenza propria in ASSET_LICENSES.md.
- Shell HTML con avvio esplicito, progresso/errori, canvas 1280×720 a proporzioni
  16:9, riduzione CSS alla larghezza e altezza desktop disponibili e fullscreen con
  letterbox. Schermo desktop consigliato almeno 1024×768; viewport più piccoli
  possono ridurre la leggibilità. Nessuna UI touch/mobile.
- Focus del canvas e della finestra/documento inoltrato alle notifiche esistenti.
  La perdita di focus sospende e svuota i comandi secondo la release; il ritorno
  non riprende automaticamente. Nessuna trasformazione di keydown/keyup/repeat.
- Soppressione dei default di scorrimento/navigazione solo sul canvas per i
  tasti del gioco. Il pulsante «Lascia i comandi al sito» libera il focus;
  link e navigazione della pagina restano utilizzabili con tastiera/mouse.
- Ridimensionamento finestra nativo e ripristino fullscreen automatico esclusi
  soltanto nel browser; selettore risoluzione disabilitato sul Web. F11 resta
  assegnato e il pulsante fullscreen offre la stessa azione se il browser lo
  intercetta. Esc può prima chiudere il fullscreen. Nessun tasto rimappato.
- «Esci» diventa «Torna al sito» e risolve `../../` rispetto alla cartella del
  gioco. La pagina indice è un esempio minimo da fondere con il sito futuro.
- Persistenza originale `user://profile.json`, schema e gestione errori invariati.
  Godot usa IndexedDB: origine/browser/profilo differenti hanno dati distinti;
  dati privati, pulizia/evizione e chiusura improvvisa possono perderli. Il flush
  su perdita di focus riduce il rischio ma non garantisce la sincronizzazione
  asincrona su disco. Nessun salvataggio partita o trasferimento da Windows.

## Input effettivo

| Contesto | Associazioni confermate nei sorgenti |
|---|---|
| Gioco | `move_nw`: Q fisico, Sinistra, KP7; `move_ne`: E fisico, Su, KP9; `move_sw`: Z fisico, Giù, KP1; `move_se`: C fisico, Destra, KP3 |
| Pausa | P fisico (`lab_pause`), pulsante Pausa/Riprendi |
| Menu/dialoghi | frecce; Tab; Shift+Tab; Enter e Spazio (`ui_accept`); mouse |
| Uscita/menu | Esc (`ui_cancel`), con vincoli GAME OVER e conferma risultati esistenti |
| Schermo intero | F11 (`toggle_fullscreen`); impostazione esistente e pulsante della pagina |
| Record | tre lettere A–Z, Backspace, Tab/Enter; mantenuto LineEdit e relativo flusso |
| Personalizzazione | una lettera/cifra libera aggiuntiva per direzione nelle impostazioni, senza rimuovere le sorgenti fisse |
| Laboratorio disabilitato | R (`lab_reset`), P; non esposto nella release pubblica |

Le lettere sono associazioni fisiche, esattamente come Windows: il simbolo
scritto può differire su layout non QWERTY. Non reinterpretare le frecce come
coordinate cartesiane della piramide. Gli eventi echo sono ignorati
nell'adattatore; l'hold usa le sorgenti e il buffer della simulazione. Più tasti
per la stessa direzione condividono lo stato; il rilascio dell'ultima sorgente
termina la pressione. Focus/pausa richiedono una pressione nuova. Le combinazioni
con Ctrl/Alt/Meta restano sotto controllo del browser/sistema operativo.

## Build e prova riproducibili

Prerequisiti della release già installati: Bash, Python standard library, Git,
Godot standard e template esatti. Nessuna installazione automatica.

```bash
bash tools/build_web.sh
# Usare la cartella stampata dalla build:
python3 tools/serve_web.py builds/web-1.2.0-rc.1-<identità>/site --port 8765
# Aprire http://localhost:8765/80_arcade_games/qbert/
```

Gli script risolvono il progetto da qualunque cwd. Il build verifica toolchain,
suite completa e log export, confronta snapshot prima/dopo export, crea ZIP del
sito, ZIP sorgenti corrispondenti (anche scaricabile dalla pagina), BUILD_INFO e
SHA256SUMS. Controlla inoltre via HTTP link, MIME e sorgenti con
`python3 tools/verify_web.py <cartella-build>/site` (eseguito anche dalla build).
Nessun pacchetto generato va in Git. Il manifest sorgenti comprende
`web/`, gli strumenti e tutte le risorse necessarie. BUILD_INFO conserva commit,
stato dirty e digest dello snapshot: un commit base non viene spacciato per
sorgenti finali puliti.

Per il controllo browser Windows già installato da PowerShell:

```powershell
.\tools\browser_web.ps1 -Browser Chrome -Url http://localhost:8765/80_arcade_games/qbert/ -Output C:\percorso\qa-chrome
.\tools\browser_web.ps1 -Browser Edge -Url http://localhost:8765/80_arcade_games/qbert/ -Output C:\percorso\qa-edge
```

Usa profili temporanei isolati, CDP e screenshot. Non certifica tasti fisici,
audio udito, prestazioni o comportamento dei browser in primo piano. Le
schermate vanno esaminate: l'invio di un evento non prova il suo effetto.
I profili temporanei vengono conservati nella directory temporanea Windows;
lo script chiude il processo che ha avviato e non tocca il profilo personale.

## Pubblicazione proposta, non eseguita

Scelta e fonti: [WEB_HOSTING.md](WEB_HOSTING.md). Dopo collaudo e accettazione
esplicita, pubblicare sorgenti della linea pubblica su `eruggie/qbert-pyramid`,
nuovo tag `v1.2.0`, release Web con ZIP sito, sorgenti corrispondenti e hash.
Non muovere `v1.1.0` né sostituire i suoi asset Windows. Non riutilizzare il tag
RC per una build diversa.

Per GitHub Pages del sito personale, incorporare la cartella
`site/80_arcade_games/qbert/` alla stessa posizione nell'output del sito e
aggiungere un link alla sua pagina indice. Conservare `.nojekyll` se si pubblica
output statico da branch. Pubblicare il contenuto di `site/`, non la directory
`site/` come ulteriore livello involontario. La pagina radice di esempio non va
sovrascritta a un sito esistente: copiarvi solo il link al gioco.

Percorso proposto: `https://eruggie.github.io/80_arcade_games/qbert/` da un
repository sito personale separato. Nessun workflow di deploy automatico è
abilitato. In seguito si può collegare un branch di output Pages o un workflow
Actions con avvio manuale e approvazione ambiente: solo runner standard,
repository pubblico e nessun servizio a pagamento. Per aggiornare, generare
nuova build dal tag esatto, verificare gli hash, sostituire l'intera cartella
gioco nell'output del sito e collaudare URL, MIME, audio, persistenza e console
su HTTPS. Conservare la build precedente per rollback.

Per Firebase Spark, scegliere soltanto Hosting statico, `public` uguale
all'output completo del sito, senza rewrite SPA. Si possono impostare gli header
MIME in firebase.json. Non collegare fatturazione e non usare App Hosting.
L'integrazione GitHub richiede la configurazione del progetto e dei secret
fuori dal repository. Non è stata attivata.
