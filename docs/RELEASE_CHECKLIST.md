# Release verification checklist

- Exact clean source commit and tag identify the delivered binary.
- Public history contains only reviewed release snapshots and no private author email.
- No secrets, personal saves, reference media or unlicensed external assets are included.
- GPL-3.0-only, dependency notices and editable asset generators are present.
- Full automatic suite, relevant WSLg checks and actual Windows evidence are distinguished.
- Windows and corresponding-source ZIPs, build metadata and SHA-256 files are downloadable.
- Public download CRC/checksums are verified after download.
- Fresh public tag checkout tests and rebuilds from the English instructions.
- Extracted released EXE is launched on Windows 11 x86_64 without an external Godot installation.
- Catalog links to the game and release; all actual URLs resolve.

See docs/VALIDATION.md and the release validation asset for recorded outcomes.
No numeric frame-time data is invented where the owner supplied acceptance only.
