# Changelog

## 1.1.0 — 2026-11-09

- Coil capture now presents the supplied QBERT image in the same 40×48 atlas
  destination frame and feet anchor as the live player; original death timing,
  collisions, score and controls are preserved.
- Coil capture plays the supplied voice cue once; protection, Stasis, volume,
  mute and audio lifecycle retain the existing rules.
- Windows EXE and installer identify `(c) Eugenio Ruggieri 2026` in version
  resources. This product metadata is not an Authenticode signature.
- Add NSIS 3.08 per-user Windows installer with Start menu entry, Windows
  uninstall registration and explicit safe file removal. It preserves saves.
- Provide runtime-only portable ZIP, corresponding source ZIP and SHA-256 sums
  as separate release downloads. The source release uses the public tag/history.
- Owner confirms redistribution authority for the supplied Coil image and voice
  under the documented GPL-3.0-only terms; see ASSET_LICENSES.md.

## Public 1.0.0 — 2026-11-08

Published from clean public commit `45c3b22c2b7a54e5f6afa729ea7535aad384a23b`.
See docs/releases/v1.0.0.md for its release notes.
The following preparation/local-release sections are historical.

## Historical publication preparation

- English user/contributor guides, issue/PR templates, citation and release procedures.
- Publication gates: phase 6 evidence, asset rights, history/privacy review and explicit approval.
- No gameplay, audio, input or artistic changes.

## Local QBERT Rev. 1.0 — 2026-11-08

Existing local product label: 1.0.0; latest local release commit 394b568d69ccb6464501b29ca9a60b9bf96d7d9a.
This is a historical local release, not a published stable GitHub release.
The standard menu hides the technical lab and offers About with author and GPL notices.
The preceding review corrected profile schema 1/2 migration and expanded results to a top ten.
Historical details and test evidence remain in TEST.md, TESTS.md and docs/TESTING.md.
A proposed first public prerelease name is 1.0.0-rc.1; it is not created or applied.

## Historical Windows installer preparation — 2026-11-09

This dated preparation record is superseded by the published release 1.1.0.
See [release notes](docs/releases/v1.1.0.md) for published assets and status.


### Windows candidate follow-up — captured Q*BERT sizing

The Coil capture image now uses the regular player's 40×48 atlas-frame rectangle
and feet anchor. Integration regressions compare both rectangles at every board
cell across three window sizes. The owner reports manual Windows acceptance
passed for release 1.1.0; see its release notes.
