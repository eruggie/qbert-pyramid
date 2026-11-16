> **Registro storico del porting:** candidato e stato di autorizzazione qui
> descritti appartengono alla fase originale. Web 1.2.0, home e pubblicazione
> sono state successivamente approvate dall'utente il 16 novembre 2026.
> Documentazione definitiva congelata: [RELEASE](../RELEASE.md),
> [TEST](../TEST.md), [deployment](DEPLOY_WEB.md), [GitHub/Pages](GITHUB_PUBLICATION.md).

# Hosting Web — verifica 15 novembre 2026 (Europe/Rome)

**Aggiornamento rc.2:** il nuovo requisito dell’utente richiede classifica e
punteggi sul server. L’hosting puramente statico qui valutato per rc.1 non è
sufficiente da solo. Per il test locale è stato aggiunto un backend SQLite:
[WEB_RC2_FIXES.md](WEB_RC2_FIXES.md). Nessun servizio di produzione o deploy
viene selezionato/attivato in questa correzione.

La scelta riguarda il sito personale statico con una sezione
`/80_arcade_games/qbert/`. Nel workspace esistono il catalogo Markdown
`80-arcade-games-public` e il repository profilo `eruggie/eruggie`, senza un
sito HTML da integrare. `web/site-index.html` è soltanto una pagina di prova:
non definisce né sostituisce un sito personale completo.

## Compatibilità

Godot locale e toolchain: `4.7.2.stable.official.ed1daf0bf`, standard,
GDScript, Compatibility/WebGL 2, WebAssembly. La candidata disabilita thread,
GDExtension e PWA: non richiede SharedArrayBuffer, COOP o COEP. HTTPS in
produzione; HTTP localhost per sviluppo. Servire `.wasm` come
`application/wasm`, `.js` come JavaScript e `.pck` come dati binari. Tutte le
risorse del gioco sono relative alla sua pagina. Non usare riscritture SPA
che restituiscano HTML al posto di WASM/PCK mancanti.

La documentazione [Godot Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
spiega requisiti, audio attivato da interazione, persistenza IndexedDB e
restrizioni fullscreen. La compatibilità con gli host sotto è una deduzione
dai loro contratti statici e dalle dimensioni effettive, non un deployment
già provato. Il template installato produce `index.wasm` da **39.514.754 byte**
(37,68 MiB); non va confusa la dimensione ZIP con il limite per asset.

## Confronto dei piani gratuiti continuativi

| Aspetto | GitHub Pages / GitHub Free | Cloudflare Pages Free (cloud) | Firebase Hosting Spark (Google cloud) |
|---|---|---|---|
| Export attuale | Compatibile per requisiti e dimensioni | **Non pubblicabile invariato**: WASM oltre 25 MiB | Compatibile per requisiti e dimensioni |
| HTTPS / WASM / sottocartelle | Sì; verificare MIME dopo deploy | Sì, se rientra nei limiti | Sì; MIME configurabile |
| Header | Nessun file `_headers`/`firebase.json` supportato; non basare il progetto su header personalizzati | `_headers`, anche COOP/COEP | `firebase.json`, anche COOP/COEP |
| Spazio / file | Sito ≤1 GB; Git rifiuta file >100 MiB | 20.000 file, ≤25 MiB ciascuno; limite totale in byte non specificato nella pagina limiti consultata | 10 GB incluse vecchie versioni; singolo file ≤2 GB |
| Traffico | Limite morbido 100 GB/mese | Richieste e banda statiche illimitate dichiarate | 10 GB/mese |
| Build | 10/ora morbido; timeout Pages 10 min; limite frequenza non applicato a workflow Actions personalizzati | 500/mese, una contemporanea, timeout 20 min | Hosting riceve file già pronti; automazione GitHub separata |
| Superamento | Possibili rate limit HTTP 429; eventuali richieste di riduzione/adeguamento, non banda illimitata garantita | Upload/build fuori limite rifiutati o in attesa di quota; nessun aggiramento R2 predisposto | Spazio esaurito: blocco nuovi deploy. Traffico esaurito: dopo tolleranza sito sospeso fino al mese successivo |
| Nome gratuito | `eruggie.github.io` o URL di progetto | `<nome>.pages.dev` | `<id>.web.app` e `<id>.firebaseapp.com` |
| Dominio proprio | Sì, acquisto/rinnovo separati | Sì, acquisto/rinnovo separati | Sì, acquisto/rinnovo separati |
| Carta / fatturazione | Nessuna necessaria per Pages Free pubblico | Nessuna attivata; obbligo carta non esplicitato nelle pagine consultate, da controllare prima dell'iscrizione; soluzione comunque esclusa per dimensione | Spark senza dati di pagamento; non collegare Cloud Billing / Blaze |
| Aggiornamenti GitHub | Nativi da branch o Actions; usare solo runner standard pubblici gratuiti | Integrazione GitHub nativa | Integrazione GitHub ufficiale via Actions, configurazione progetto e credenziale in secret, mai nel codice |

Fonti ufficiali:

- GitHub: [Pages e URL](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages),
  [limiti](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits),
  [HTTPS](https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https),
  [limiti file Git](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github),
  [costi Actions](https://docs.github.com/en/billing/concepts/product-billing/github-actions).
- Cloudflare: [limiti](https://developers.cloudflare.com/pages/platform/limits/),
  [header](https://developers.cloudflare.com/pages/configuration/headers/),
  [piano e banda](https://www.cloudflare.com/products/pages/).
- Firebase: [quote Hosting](https://firebase.google.com/docs/hosting/usage-quotas-pricing),
  [limite singolo file](https://firebase.google.com/docs/hosting/faq-and-troubleshooting),
  [Spark e Blaze](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans),
  [configurazione](https://firebase.google.com/docs/hosting/full-config),
  [GitHub](https://firebase.google.com/docs/hosting/github-integration),
  [HTTPS e nomi](https://firebase.google.com/docs/hosting).

## Raccomandazione e destinazione proposta

**GitHub Pages**: minori passaggi, nessun account cloud aggiuntivo, file
compatibili senza ricompilare il motore. Per un sito personale alla radice,
proposta `https://eruggie.github.io/80_arcade_games/qbert/`, attraverso un
repository sito `eruggie/eruggie.github.io` da scegliere/approvare separatamente.
Non è stata verificata la disponibilità remota di questo repository o URL;
non è stato creato né pubblicato. Sorgenti e futura release Web restano in
`eruggie/qbert-pyramid`, con nuovo tag `v1.2.0` solo dopo collaudo e accettazione.
Un sito di progetto avrebbe invece il prefisso `/nome-repository/`.
I collegamenti relativi predisposti supportano entrambi i casi.

Firebase Spark è la seconda scelta se si preferisce Google e il suo controllo
sugli header; la quota trasferimenti è più stretta. Hosting statico è sufficiente:
non servono Cloud Run, VM, database, Firebase App Hosting o Cloud Storage.
Gli eseguibili Windows rimangono negli asset GitHub della 1.1.0; Spark applica
restrizioni ad alcuni tipi di eseguibili.

## Google AI Plus

La pagina ufficiale [piani Google AI](https://one.google.com/about/google-ai-plans/)
elenca per Plus strumenti AI e spazio per Gmail/Drive/Foto. Non elenca hosting
Web o crediti Cloud per Plus. Quello spazio non è storage Firebase Hosting.
Eventuali crediti di altri piani/programmi o promozioni non sono una gratuità
continuativa e non vengono conteggiati. Spark è gratuito indipendentemente
 dall'abbonamento; Blaze e Google Cloud a consumo richiederebbero una decisione
separata, che questo intervento non attiva. Un dominio proprio ha comunque
un eventuale costo di acquisto e rinnovo, senza necessità tecnica di comprarlo.
