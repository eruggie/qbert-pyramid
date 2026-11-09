> Release 1.1.0 integrates two owner-authorized supplied assets for Coil deaths.
> The earlier “all supplied images removed” statement describes v1.0.0; the
> current permissions and provenance declaration are recorded below.

> Current update (2026-11-08): unlicensed supplied images removed from the current
> product; qbert.png/qbert.ico are generated from the original in-game sprite,
> GPL-3.0-only. Historical supplied images remain excluded from public upload.
> See [LICENSING.md](LICENSING.md). Entries below retain their historical meaning.

# Catalogo delle risorse

## Stato release 1.1 — 2026-11-09

Il titolare ha confermato l'autorità di redistribuire `qbert_trivia.png` e
`qbert-hello.mp3` nella release 1.1 secondo i termini GPL-3.0-only del progetto.
Dettagli e provenienza dichiarata sono registrati nelle tabelle correnti.
Le dichiarazioni storiche che descrivono la 1.0 restano storiche.

Le sezioni fasi 0–4 sono storiche. Il set attuale 0.5.1 è registrato in fondo;
musica e suono di menu sono rimossi, la grafica degli attori è sostituita.

## Risorse presenti nelle fasi 0–4

| Risorsa | Formato | Uso | Stato |
| --- | --- | --- | --- |
| Icona originale `assets/ui/qbert_pyramid_icon.svg` | SVG | Icona del progetto e schermata iniziale | Presente; geometria isometrica originale, palette blu scuro/turchese/oro. |
| Pannelli e stili del menu | Risorse native `StyleBoxFlat` nella scena | Interfaccia iniziale | Presenti; definiti nel progetto. |
| Vista dei 28 prismi e tre stati | Primitive vettoriali Godot in `scripts/presentation/pyramid_view.gd` | Laboratorio e partita | Originale; stato iniziale a cerchio, intermedio a due punti, obiettivo a spunta. |
| Attore geometrico con visore e ombra | Primitive vettoriali Godot | Prova dei quattro salti diagonali | Originale; arco animato dal progresso della simulazione. |
| HUD e stati della partita | Controlli Godot in scenes/game_screen.tscn | Punti, vite, round, pausa, Game Over e completamento | Presenti nella fase 2; stile originale riusato. |
| Scoria sferica rossa e Stasi sferica verde | Primitive vettoriali in pyramid_view.gd | Partita fase 3, rifiniture 0.3.1 | Volume, riflessi e ombre originali; Stasi con scintilla distintiva. |
| Segugio serpentiforme | Polilinee ed ellissi originali in pyramid_view.gd | Inseguitore esistente | Corpo arrotolato, testa e occhi; sostituisce il cerchio G. Nessuna metamorfosi. |
| Dischi rialzati e mobili | Ellissi, raccordi e traiettoria in pyramid_view.gd | Salvataggio su entrambi i bordi | Primo salto di 18 tick e trasporto di 54 tick, appoggio condiviso con attore/ombra. |
| Ragnetti laterali viola (Scintilla) | Primitive vettoriali in pyramid_view.gd | Famiglia laterale esistente, round secondo calendario Gottlieb | Sagoma originale con arti angolari, occhi e due orientamenti specchiati; sostituisce L. |
| Sverniciatore V e preavviso | Primitive vettoriali Godot | Partita fase 3 | Conservati dall'implementazione precedente. |
| Open Sans SemiBold | Font incorporato nel motore | Testo di Label/Button con fallback Godot | Dipendenza incorporata verificata; nessun font esterno. |

Provenienza e licenze sono registrate separatamente in `ASSET_LICENSES.md`. Nessuna immagine o registrazione del riferimento appartiene a questo inventario.

## Set originale consegnato nella fase 4

- Grafica: mantenuti prismi, attore con visore, dischi rialzati, sfere, serpente e
  ragnetti approvati; Sverniciatore volumetrico con maschera e V, alone verde/oro
  di protezione e bagliore d'atterraggio in `pyramid_view.gd`. Sorgenti vettoriali
  native, senza bitmap aggiunte; risoluzione indipendente.
- Interfaccia: `SettingsPanel`, controlli Godot e tema esistente, focus e scroll;
  record integrato in HUD e menu. Font Godot già registrato nelle notices.
- Audio: `assets/audio/{jump,land,color,fall,contact,rescue,collect,round,extra,menu}.wav`,
  dieci effetti; `menu_music.wav` e `game_music.wav`, due brani di otto secondi.
  Sorgenti PCM mono 16-bit 22050 Hz, generati da `tools/generate_audio.py` (Python
  standard). Hash in `assets/audio/SHA256SUMS.txt`, rigenerazione verificata identica.
- Musica ciclica configurata nel servizio App; il formato di importazione Godot
  è definito nei file .wav.import inclusi. Nessun campione esterno o del riferimento.

Le righe di previsione delle fasi precedenti sopra restano storiche: non indicano
lavoro di asset da anticipare nelle fasi 5–6. Nessun font esterno aggiunto.


## Set attuale — revisione audiovisiva 0.5.1

| Percorso | Contenuto e creazione | Uso |
|---|---|---|
| assets/arcade/actors.png | Atlante RGBA 480×336, 7 famiglie/varianti × 4 direzioni × 3 pose, generato con primitive originali in tools/generate_arcade_art.py | Protagonista, Scoria, Segugio, laterali sinistro/destro, Sverniciatore, Stasi |
| assets/arcade/arcade_font.png e arcade_font.fnt | Griglia di glifi originali 5×7 e descrizione BMFont, stesso generatore, nessun font esterno | Titolo, HUD, campione e scheda fra round |
| scripts/presentation/pyramid_view.gd | Cubi 2:1, facce profonde, dischi multicolore, ombre, posa/volo/caduta e scheda fra round | Presentazione dello stato logico, durate invariate |
| scripts/presentation/arcade_palette.gd | Cinque famiglie cromatiche, RGB stimati visivamente dagli allegati, ciclo dichiarato per round non osservati | Colori separati dalle regole; I/3 sempre grigio |
| assets/audio/*.wav | Dieci effetti mono PCM16 22050 Hz generati da tools/generate_audio.py; jump/land/color/fall/contact/rescue/collect/round/extra/lure | Eventi reali, nessuna musica o suono menu; hash in SHA256SUMS.txt |

Scintilla ha arti asimmetrici viola e occhi chiari; Sverniciatore verde ha
piedi e maschera, distinguendosi dalla sfera Stasi. Il protagonista mantiene
una variante originale con cresta e muso corto; il serpente usa due spire
angolari. Nessuna immagine del riferimento è ricalcata o distribuita.
I PNG sono originali rigenerabili con Python standard, filtro nearest.
Il font Godot con licenza già registrata rimane per testi descrittivi e GUI.


## Aggiornamento 0.5.2 — VID-01

Atlas, font e dieci effetti originali 0.5.1 riutilizzati senza nuovi campioni.
Scala di campo ridotta del 20%, palette I/2 e I/3 invertite correttamente,
bonus sulla piramide e scheda riservata al cambio livello. Matrice temporale
e limiti audio in ARCADE_REVIEW.md. Nessun fotogramma convertito in sprite.


## Revisione soli effetti 0.5.2 — 7 novembre 2026

Rigenerati jump, land, color, collect, contact, rescue, lure e round mediante
oscillatori/inviluppi originali in tools/generate_audio.py. Durate 35–2750 ms;
fall/extra identici al precedente stato locale. Stesso formato PCM16 mono
22050 Hz, nessun loop o brano continuo. Misure prima/dopo in ARCADE_REVIEW.md.
I 13 segmenti del video e il PCM integrale risiedono esclusivamente nella
cartella ignorata .local-state/audio-review/, fuori da asset e distribuzione.


## Risorse correnti 0.5.3

14 WAV originali PCM16 mono 22050 Hz, senza loop. Ai dieci della 0.5.2 si
aggiungono stasis_collect (450 ms), stasis_fall (420 ms), level (2750 ms),
game_over (650 ms), riproducibili con tools/generate_audio.py e identificati
da assets/audio/SHA256SUMS.txt. Lure (1150 ms) è conservato e assegnato alla
caduta del Segugio su una voce autonoma. Nessun nuovo campione o sprite.
GameOverBanner e RecordsPanel sono controlli nativi con font/palette originali
esistenti; HighScores è logica dati indipendente dalla GUI. PDF, video,
segmenti, anteprime e PCM di consultazione sono locali ignorati ed esclusi.


## Revisione 0.5.4

Nome prodotto/font aggiornato a Q*Bert Pyramid; icona rinominata
assets/ui/qbert_pyramid_icon.svg, geometria conservata. Aggiunto glifo *
originale 5×7 al generatore tools/generate_arcade_art.py; atlas attori invariato.
AttractPanel usa testo e primitive/asset esistenti per istruzioni/demo;
RecordsPanel usa una griglia nativa di dieci righe per iniziali/punti/livello/round.
Nessun nuovo WAV: tutti i 14 PCM e hash audio sono quelli approvati nella 0.5.3.
Nessun filmato, PDF, fotogramma o segmento di riferimento appartiene agli asset.


## Identità visiva 0.5.4 approvata dall'utente — 7 novembre 2026

`assets/ui/qbert.ico`: icona Windows fornita dall'utente, ICO 256×256.
`assets/ui/qbert.jpg`: immagine del menu e icona applicazione, JPEG 1024×1024;
byte identici all'allegato chiamato qbert.png, estensione corretta al formato.
Sostituiscono negli usi attivi la precedente icona geometrica SVG, conservata
come risorsa storica inutilizzata. Personaggi e grafica di gioco invariati.
Hash e provenienza in REFERENCE.md; stato dei diritti in ASSET_LICENSES.md.


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
