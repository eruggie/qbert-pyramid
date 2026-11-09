> Release 1.1.0 integrates two owner-authorized supplied assets for Coil deaths.
> The earlier “all supplied images removed” statement describes v1.0.0; the
> current permissions and provenance declaration are recorded below.

> Current update (2026-11-08): unlicensed supplied images removed from the current
> product; qbert.png/qbert.ico are generated from the original in-game sprite,
> GPL-3.0-only. Historical supplied images remain excluded from public upload.
> See [LICENSING.md](LICENSING.md). Entries below retain their historical meaning.

# Provenienza e licenze delle risorse

## Stato release 1.1 — 2026-11-09

Il titolare ha confermato l'autorità di redistribuire `qbert_trivia.png` e
`qbert-hello.mp3` nella release 1.1 secondo i termini GPL-3.0-only del progetto.
Dettagli e provenienza dichiarata sono registrati nelle tabelle correnti.
Le dichiarazioni storiche che descrivono la 1.0 restano storiche.

Le sezioni fasi 0–4 sono storiche. Il set attuale 0.5.1 è registrato in fondo;
musica e suono di menu sono rimossi, la grafica degli attori è sostituita.

## Licenza corrente — scelta del titolare per la 0.5.4

(c) Eugenio Ruggieri 2026 GNU GPL v3.0.

Il titolare ha scelto esplicitamente **GNU General Public License versione 3**
per il progetto. I sorgenti e le risorse originali sono distribuiti sotto
GPL-3.0-only; testo integrale in `LICENSE`, copiato senza modifiche dal testo
GNU GPL versione 3 presente nel sistema (`/usr/share/common-licenses/GPL-3`).
Questa scelta supera le indicazioni storiche «licenza da decidere» riportate
nelle sezioni precedenti. Le dipendenze Godot/Open Sans mantengono MIT/OFL e
le rispettive notices. Gli allegati dell'utente restano documentati nella
sezione dedicata: non si attribuiscono diritti di terzi non documentati.

## Stato delle fasi 0–4

Il progetto non riutilizza asset del gioco di riferimento. Non sono stati estratti codice, ROM, file Flash, sprite, immagini o audio. Le risorse originali comprendono il menu della fase 0 e la vista vettoriale del laboratorio della fase 1, riusata dalla partita e dall’HUD essenziale della fase 2; la fase 4 completa il set vettoriale originale e aggiunge audio originale.

Non viene assegnata una licenza generale ai sorgenti o alle risorse originali dell'utente. Fino alla scelta del titolare non viene concessa con questo registro una licenza di riutilizzo a terzi; restano riservati i diritti applicabili. Le licenze delle dipendenze rimangono indipendenti.

| Risorsa/componente | Provenienza e uso | Licenza/stato | Attribuzione o azione |
| --- | --- | --- | --- |
| `assets/ui/qbert_pyramid_icon.svg` | Icona geometrica originale del progetto, creata con assistenza durante la fase 0; rombi e superfici isometriche. Icona applicazione e immagine del menu. | Risorsa originale; licenza di distribuzione dei sorgenti da decidere dal titolare. | Progetto Q*Bert Pyramid. Nessun materiale del riferimento usato nella creazione. |
| Stili `StyleBoxFlat` nella scena del menu | Colori, bordi e pannelli definiti come risorse native Godot del progetto. | Risorse originali; medesimo stato dei sorgenti di progetto. | Progetto Q*Bert Pyramid. |
| Grafica procedurale `scripts/presentation/pyramid_view.gd` | Prismi, simboli di stato, attore geometrico con visore e ombra originali, disegnati con primitive native Godot; nessun file bitmap aggiunto. | Risorsa originale del progetto; licenza pubblica da decidere dal titolare. | Progetto Q*Bert Pyramid. Animazione derivata dal progresso logico dei salti. |
| Avversari, dischi e Stasi | Primitive vettoriali originali in `pyramid_view.gd`; rifiniture 0.3.1 con sfere volumetriche, serpente stilizzato ed ellissi dei dischi; 0.3.2 aggiunge la sagoma originale dei ragnetti laterali specchiati al posto di L. Nessuna bitmap o codice del riferimento riutilizzato. | Risorsa originale del progetto; licenza pubblica da decidere dal titolare. | Nessun materiale grafico o audio del riferimento riutilizzato. |
| Font di fallback dell'interfaccia | Font incorporato nel motore, nessun file font esterno aggiunto al progetto. Verifica runtime del motore installato: `ThemeDB.fallback_font.get_font_name()` restituisce **Open Sans SemiBold**. | **SIL Open Font License 1.1 (OFL-1.1)**, secondo le notices del motore. | Open Sans Project Authors; notice completa in `THIRD_PARTY_NOTICES.txt`. |
| Godot Engine e componenti incorporati | Motore standard usato per eseguire ed esportare il progetto; versione e hash sono registrati in `tools/toolchain.json`. | Godot: **MIT/Expat**; componenti terzi con proprie licenze compatibili. | Testo e attribuzioni estratti dalle API del motore installato in `THIRD_PARTY_NOTICES.txt`. |
| Manuale Q*bert fornito dall'utente | Documento di consultazione locale identificato in `REFERENCE.md`. | Nessuna autorizzazione di redistribuzione verificata. | Escluso dal pacchetto Windows; non trasformato in asset di produzione. |
| Pagina Classic Games Arcade | Consultazione documentale descritta in `REFERENCE.md`. | Nessuna licenza per il riutilizzo dei suoi asset verificata. | Nessun contenuto del sito incluso nella build. |

## Verifica delle dipendenze

Le API `Engine.get_license_text()`, `Engine.get_license_info()` ed `Engine.get_copyright_info()` del motore installato sono state eseguite in un progetto temporaneo isolato sotto `.local-state/license-snapshot/`. Il font di fallback è stato interrogato nello stesso processo. Lo script temporaneo è stato rimosso; lo snapshot locale rimane fuori Git.

`THIRD_PARTY_NOTICES.txt` conserva il testo MIT di Godot, le attribuzioni dei componenti dichiarati dal binario e tutti i testi di licenza restituiti dal motore, compreso OFL-1.1. Conservare l'intero file insieme a eseguibile/PCK nel pacchetto Windows. La raccolta comprende anche componenti opzionali/editor dichiarati dal motore; la loro presenza nel registro non afferma che siano tutti attivi nel gioco.

Fonti primarie per la verifica:

- [Godot Engine — License](https://godotengine.org/license/).
- [Godot Engine — Engine API: informazioni di licenza](https://docs.godotengine.org/en/stable/classes/class_engine.html).
- [Godot Engine — copyright dei componenti](https://github.com/godotengine/godot/blob/master/COPYRIGHT.txt), riscontro supplementare; lo snapshot locale del binario identifica le notices conservate.

## Aggiunta di risorse nelle fasi successive

Prima dell'inclusione registrare percorso, autore, origine, URL se presente, versione/hash, licenza completa, modifiche e attribuzione richiesta. Non usare risorse prive di provenienza o con termini non verificati. Il set originale della fase 4 è registrato sotto; nessun font esterno è stato aggiunto; il catalogo è in `ASSET_CATALOG.md`.


## Risorse originali della fase 4

| Risorsa | Origine e sorgente modificabile | Diritti e attribuzione |
|---|---|---|
| Dodici WAV in `assets/audio/` | Sintesi matematica e due sequenze musicali originali create per Q*Bert Pyramid con assistenza; sorgente `tools/generate_audio.py`, Python standard, nessuna libreria/campione esterno. Dieci effetti e due brani, 22050 Hz mono PCM 16-bit. Hash in `assets/audio/SHA256SUMS.txt`. | Risorse originali del progetto, medesimo stato dei sorgenti: licenza pubblica da decidere dal titolare. Nessuna attribuzione di composizioni o registrazioni terze. |
| Completamento vettoriale e pannello impostazioni | Geometria e controlli nativi in `pyramid_view.gd` e `settings_panel.gd`; maschera Sverniciatore, alone di protezione, bagliore d'atterraggio, focus e layout originali. | Risorse originali del progetto; nessuna copia del riferimento. Dipendenze Godot/font conservano le proprie notices già incluse. |

Non vengono modificati diritti o licenze di terzi. Le dodici registrazioni
sono prodotte dalla sintesi del repository, senza estrazione di sprite, suoni,
ROM o codice del riferimento. Il manuale locale resta escluso dal pacchetto.


## Risorse attuali — revisione audiovisiva 0.5.1

| Risorsa | Origine/metodo/autore | Stato dei diritti |
|---|---|---|
| assets/arcade/actors.png | Disegni originali per Q*Bert Pyramid creati con assistenza, primitive e pose nel sorgente tools/generate_arcade_art.py; nessun campione o ricalco | Diritti applicabili riservati; licenza pubblica non assegnata |
| assets/arcade/arcade_font.png, arcade_font.fnt | Glifi a griglia disegnati nel medesimo generatore; nessun font di terzi copiato | Risorsa originale del progetto, stesso stato |
| Cubi, palette, dischi e animazioni | Codice originale PyramidView/ArcadePalette; rapporti e colori stimati dagli screenshot consultati | Risorse originali, stesso stato; screenshot esclusi |
| Dieci WAV attuali, compreso lure.wav | Sintesi matematica originale di oscillatori, rumore deterministico e inviluppi, tools/generate_audio.py; zero registrazioni/composizioni esterne | Risorse originali, stesso stato; SHA256SUMS.txt identifica i file |

menu.wav, menu_music.wav e game_music.wav sono rimossi dai sorgenti attuali
e dal PCK. Il bundle Git del checkpoint conserva la storia della fase 5;
non è una dipendenza audio della nuova partita. Il font di fallback Godot
mantiene le notices OFL già distribuite. I materiali locali dell’utente,
PDF e screenshot di consultazione non entrano nello snapshot o nel pacchetto.


## Revisione 0.5.2

Nessun nuovo asset di terzi. Modifiche originali al codice di presentazione
(scala, selezione palette, transizione); origine: confronto visivo VID-01.
Restano validi autori/provenienza e stato dei diritti degli asset 0.5.1.
Video e anteprime sono soltanto consultazione locale, esclusi dalla consegna.
Nessuna sintesi nuova dichiarata basata su un ascolto non effettuato.


## Revisione soli effetti 0.5.2 — 7 novembre 2026

Otto WAV risintetizzati con oscillatori, armoniche, rumore deterministico e
inviluppi originali del progetto. Misure temporali/spettrali di VID-01 usate
come confronto tecnico; nessun campione, voce, melodia o registrazione terza
incorporata negli asset. Segmenti di consultazione soltanto locali e ignorati.
Caduta/vita extra e diritti già registrati conservati. Nessun ascolto
percettivo dichiarato: metodo e limiti in ARCADE_REVIEW.md.


## Risorse originali aggiunte nella 0.5.3

stasis_collect.wav, stasis_fall.wav, level.wav e game_over.wav: sintesi
matematica originale del progetto, tools/generate_audio.py, oscillatori,
armoniche, gate e inviluppi. Nessuna registrazione, voce, melodia o campione
estratto dal gioco incorporato. Misure di VID-01 usate per confrontare ruolo,
ritmo, durata e banda; limiti dichiarati in ARCADE_REVIEW.md. Stesso stato
dei diritti degli asset originali già registrati, nessuna nuova licenza
pubblica assegnata. Banner e classifica usano controlli nativi e font originali
esistenti; nessuna copia di impaginazione pixel, sprite o testo decorativo.


## Risorse 0.5.4

Glifo * originale 5×7, costruito nel generatore del font del progetto;
nessun font o logo del riferimento estratto. Presentazione iniziale originale
con controlli e asset propri; nessuna copia pixel di schermate o classifica.
Icona rinominata con geometria esistente. Tutti i 14 WAV conservati, senza
campioni di terzi o nuove sintesi non verificabili. Restano invariati autori,
provenienza e stato dei diritti già registrati. Consultazioni locali ignorate.


## Allegati dell'utente per l'identità visiva 0.5.4 — 7 novembre 2026

ICO e immagine qbert forniti dall'utente e autorizzati esplicitamente per
l'inclusione nel gioco e nell'EXE: `assets/ui/qbert.ico` e `assets/ui/qbert.jpg`.
Copiati senza modifica dei byte; hash in REFERENCE.md. Origine della creazione
e titolarità di eventuali elementi di terzi non documentate: la richiesta
di inclusione non costituisce certificazione di esclusività o trasferimento
di diritti di terzi. Non sono estratti dal PDF o dai video di consultazione.


## Original player-sprite application icon — 2026-11-08

Current files: assets/ui/qbert.png and assets/ui/qbert.ico. Source:
tools/generate_app_icon.py, using sprite kind 0 / direction 3 / pose 0 from
tools/generate_arcade_art.py, the same atlas cell rendered by PyramidView.
The PNG is 256×256 RGBA; ICO contains 16/32/48/64/128/256 PNG frames.
Only cropping, centered transparent padding and nearest-neighbor resizing
are applied; no new drawing, external image, model or font is introduced.
Regenerate with `python3 tools/generate_app_icon.py` (Python standard library).
These replacements inherit GPL-3.0-only from the project-original sprite.
Previous supplied JPEG and icon bytes remain only in local historical backups,
old commits/packages, not as current production assets. Do not upload that history.

Current generated SHA-256:

- `qbert.png`: `42eea3f83383702c62f4382bcfb2d6a7360c1dce6c5586ee0fbaef470904c2f6`
- `qbert.ico`: `8e946f07176a0f642ffbacbf3fd18941d76e8aba020a983452323287d86abbe4`


## Release 1.1.0 — supplied Coil capture assets, 2026-11-09

| Resource | Provenance / format | Usage / rights |
|---|---|---|
| `assets/arcade/qbert_trivia.png` | User-supplied `qbert_trivia.png`; byte-identical copy, PNG 1254×1254 RGBA, alpha range 0–255, nonzero-alpha bounds (0,38)–(1224,1230) | Replaces normal player and impact only during a real Coil death. Drawn in the same 40×48 atlas-frame rectangle and player feet anchor as live Q*BERT. Owner confirmed authority to redistribute under GPL-3.0-only for release 1.1 (2026-11-09). |
| `assets/audio/qbert_hello.mp3` | User-supplied `qbert-hello.mp3`, renamed only. MPEG-1 Layer III, mono, 48000 Hz, 320 kb/s; 63 frames = 1.512 s encoded, Godot decoder/playback length 1.45416665 s | One non-looping cue through existing Effects bus; replaces contact, respects mute/volumes/lifecycle. Owner confirmed authority to redistribute under GPL-3.0-only for release 1.1 (2026-11-09); recording creator/source attribution was not separately provided. |

Originals were copied from the user's supplied QBERT folder without modification
or movement; no existing target trivia PNG was present. No asset regeneration,
extraction from reference media or new license attribution. SHA-256:

- PNG: `380f413aee3c7aeb9f71dbfe021e4a5ced82d294c303068ae6d6125faed6f6ec`
- MP3: `258eee9203a40b86c7dfd0a045974459badeff1ea863adc9e763debe632c42cb`

On 2026-11-09 the owner explicitly confirmed authority to redistribute both supplied files in release 1.1 under the project's documented GPL-3.0-only terms. The owner's authorization is recorded here; author/source attribution beyond that confirmation was not supplied. GPL-3.0-only applies to these files for this distribution.
