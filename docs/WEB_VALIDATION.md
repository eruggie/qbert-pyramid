> Registro storico: l’utente ha successivamente approvato i test funzionali Web 1.2.
> La nuova presentazione/distribuzione rc.3 richiede approvazione separata.
> Stato attuale: [RELEASE.md](../RELEASE.md).

# Verifica Web 1.2.0-rc.1 — 15 novembre 2026

Questo è il rapporto storico rc.1. La segnalazione dell’utente di audio
assente ne supera l’indicazione di solo contesto running: quel controllo non
provava l’uscita sonora. Per audio misurato e classifica server della rc.2,
vedere [WEB_RC2_FIXES.md](WEB_RC2_FIXES.md) e il rapporto della nuova build.

**Stato: candidata locale, non accettata per pubblicazione stabile.**
Windows 1.1.0 resta una release distinta. La sua precedente accettazione
manuale non viene estesa al Web. Nessun push, tag o release remota eseguiti.

## Riscontri eseguiti

| Livello | Risultato e limite |
|---|---|
| Baseline | Tag v1.1.0 e commit e833fd622596c109997a817afa73c9ea80644622 verificati localmente e su origin. Worktree separato, modifiche originali conservate |
| Toolchain | Godot standard 4.7.2.stable.official.ed1daf0bf; doctor e hash motore/template Windows conformi; hash template Web senza thread conformi |
| Suite automatica | 129 test GDScript, 126.766 verifiche; 12 test packaging/sorgenti e 6 test asset superati. Copertura include equivalenza input, hold/buffer misti, pausa, progressione, punteggi, persistenza, risultati e correzioni Coil 1.1.0 |
| Runner negativo | `--self-test-empty` termina con 0 test, 0 verifiche, 1 fallimento e codice 1, come richiesto |
| Grafica nativa Linux | Smoke X11/WSLg, Compatibility llvmpipe: 177 catture, 0 fallimenti. Comprende i casi Coil e le risoluzioni della suite; non è una prova browser né Windows |
| Export Web | Riuscito con GDScript, WebGL 2, WASM, senza thread/estensioni/PWA. Avvio con crossOriginIsolated=false |
| HTTP e sottocartella | `/80_arcade_games/qbert/` provato da server locale raggiunto da Windows; controllo automatico anche sotto `/site/80_arcade_games/qbert/`. Link relativi, risorse, licenze, ZIP sorgenti e MIME WASM/JS/PCK verificati |
| Chrome desktop | 157.0.8103.79 Windows, automazione CDP con profilo temporaneo; ciclo conclusivo headless, 35 screenshot. Eseguito anche ciclo con finestra visibile, distinto dalla prova manuale |
| Edge desktop | 157.0.4341.60 Windows, CDP headless, profilo temporaneo, 35 screenshot |
| Input browser | Osservati Q/E/Z/C, quattro frecce e KP7/9/1/3 con alias fisici; hold, P, Esc, Tab/Enter e mouse. Rilascio fuori canvas, focus perso/ritrovato, ripresa esplicita e nuova pressione. Scorrimento pagina invariato con frecce/Tab nel gioco |
| UI browser | Intro, menu, partita, pausa, impostazioni, Game Over, risultati, classifica e ritorno al sito osservati; ridimensionamento a viewport desktop 1024×900 e 1024×768; canvas interamente nel viewport
  anche dopo il messaggio di rifiuto fullscreen. Fallback frecce verificato nelle schermate |
| Iniziali e dati | Inseriti ABX, corretto X con Backspace e C: ABC, 50 punti. Master 0,48, effetti 0,67, mute=true, tasto V aggiuntivo per basso-destra. Asserzioni su IndexedDB prima/dopo reload e classifica visibile, in entrambi i browser |
| Audio browser | Contesto WebAudio passa da suspended a running, risorse caricate. Nessuna registrazione o ascolto umano certificato; la modifica dei volumi è confermata nei dati |
| Console browser | Nei cicli conclusivi: 0 eccezioni JS, 0 richieste fallite e nessun HTTP >=400. Warning fullscreen «not granted» registrati e distinti dagli errori di caricamento |
| Regressione Windows nativa | EXE esportato da questi adattamenti, profili APPDATA/LOCALAPPDATA isolati: 20 frame headless e 120 frame grafici, codici 0, audio Dummy. Non è un nuovo collaudo manuale Windows, prestazionale o dell'installer |

## Problemi trovati e risolti

1. KP numerici non riconosciuti dal mapping logico Windows nel backend Web:
   aggiunti alias per le stesse posizioni fisiche, direzioni invariate.
2. Frecce UI senza fallback di sistema nel browser: incluso DejaVu Sans come
   fallback dei soli glifi mancanti, con licenza e provenienza.
3. Risoluzione finestra/ripristino fullscreen nativi non appropriati al browser:
   dimensioni gestite dalla shell; richiesta fullscreen solo esplicita.
4. Primo tentativo Edge non valido: il driver aveva selezionato una pagina di
   estensione integrata. Selezione corretta e ciclo ripetuto con successo.
5. Le prime sequenze di test risultati erano troppo rapide o non generavano
   testo nativo. Corrette temporizzazione/eventi e aggiunte asserzioni su ABC e
   persistenza: i tentativi inconcludenti non sono stati dichiarati superati.
6. Un riferimento documentale al vecchio nome ha fatto fallire il controllo
   branding; riferimento rimosso e suite completa rieseguita con successo.

## Limiti che impediscono l'etichetta «stabile collaudata»

- F11 e pulsante fullscreen sono richiesti e il rifiuto è gestito, ma il browser
  risponde «not granted». Riprodotto anche su una pagina HTML minima senza
  Godot e con chiamata diretta: fullscreenEnabled=true, gesto trusted e
  userActivation=true all'ingresso. Verificato anche nel ciclo Chrome visibile.
  Non è quindi attribuito al gameplay, né dichiarato funzionante. Non sono
  state cambiate policy, associazioni o configurazioni globali. Serve una prova
  interattiva in un ambiente che consenta Fullscreen API e del vero F11 browser.
- Tasti fisici, NumLock attivo/spento, Shift+Tab/Spazio in tutte le schermate,
  combinazioni trattenute e ritorno da altra scheda richiedono il passaggio
  manuale completo: gli eventi CDP non equivalgono a hardware reale.
- Ascolto audio/Coil, bilanciamento e latenza richiedono ascolto umano. Coil e
  progressione sono coperti dalle regressioni native, non da un nuovo
  playthrough browser completo con collisioni naturali e tutti i round.
- Nessuna misura di frame time/P99 o endurance Web, né test Safari/Firefox:
  browser di questi tipi non disponibili nel percorso di prova adottato.
- Nessun deploy HTTPS eseguito: verificare MIME, caricamento, focus, audio,
  persistenza e console sull'URL definitivo dopo approvazione.

## Accettazione prima della release 1.2

Usare la build identificata nel BUILD_INFO e nei suoi SHA256SUMS, servita via
HTTP locale. Registrare browser, layout tastiera, sistema e build esatta.

1. Confermare tutte le sorgenti Q/E/Z/C, frecce e tastierino (NumLock on/off),
   hold, tasti equivalenti simultanei, rilascio fuori gioco e ripresa con P.
2. Provare menu con frecce/Tab/Shift+Tab, Enter/Spazio/mouse; impostazioni,
   schermata informazioni, intro, Game Over, Esc, iniziali e classifica.
3. Consentire fullscreen e verificare pulsante, F11, Esc e ritorno alla pagina,
   proporzioni/leggibilità; ascoltare cue e impostazioni mute/volumi.
4. Giocare una sessione estesa, verificare Coil 1.1.0, vite, dischi, Stasi,
   collisioni/progressione; cambiare scheda/finestra durante input mantenuto.
5. Riaprire lo stesso browser/profilo/origine: classifica e impostazioni devono
   restare; documentare che dati privati/puliti/evicti non sono garantiti.

Dopo esito positivo, presentare identità della build e destinazione proposta
all'utente e ottenere consenso esplicito per `eruggie/qbert-pyramid` v1.2.0 e
per il sito. Nessuna sostituzione di tag/asset Windows 1.1.0.
