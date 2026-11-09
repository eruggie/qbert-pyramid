# Install and play on Windows

## Release 1.1.0

The current release is [QBERT Rev. 1.1](https://github.com/eruggie/qbert-pyramid/releases/tag/v1.1.0)
for Windows 11 x86_64. The release includes the installer, portable runtime,
corresponding sources, build metadata and checksums as separate GitHub release
assets. Windows 1.0.0 remains available at its original tag.

| Download | Use |
|---|---|
| `QBertPyramid-1.1.0-Setup.exe` | Guided current-user setup and Windows uninstall entry |
| `QBertPyramid-1.1.0-Windows-x86_64.zip` | Portable game; extract the full ZIP |
| `QBertPyramid-1.1.0-source.zip` | Corresponding source snapshot and public source history |
| `QBertPyramid-1.1.0-SHA256SUMS.txt` | SHA-256 checks for release downloads |
| GitHub Source code ZIP/tar.gz | Exact sources for tag `v1.1.0` |

## Verify and install

In PowerShell calculate the hash for each downloaded file and compare it to the
matching release checksum:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath '.\QBertPyramid-1.1.0-Setup.exe'
```

Open Setup, review the GPL license, and follow the installer. It installs for
the current Windows user under `%LOCALAPPDATA%\Programs\QBertPyramid`, adds
Start menu shortcuts and a Windows installed-app entry, and does not require
administrator rights or extra runtime downloads. To update, close the game and
run the newer installer into the existing application directory. To remove it,
use Windows Settings > Apps or `Uninstall.exe`.

For the portable edition verify the ZIP, extract it in full and launch
`QBertPyramid.exe`. Keep its PCK and notices together. Delete the portable folder
to remove the application.

## Saves and platform requirements

Settings and scores stay in `%APPDATA%\QBertPyramid\profile.json` (and backup).
Updates and uninstall preserve these saves and files added by the user. Back up
your profile before changing releases. Windows 11 x86_64 and an OpenGL 3.3-capable
driver are required. Windows 10 and ARM are not supported targets.

Players do not need Godot, Python, Git, WSL, VS Code or Codex.
See [PLAYER_GUIDE.md](PLAYER_GUIDE.md) for controls and settings.

## Publisher and security

The EXE and installer include author metadata and `(c) Eugenio Ruggieri 2026`.
Neither binary is digitally signed with Authenticode. File metadata does not
verify the publisher, and SmartScreen can still warn about a new download. Keep
Windows security protections enabled.

The owner reports manual Windows acceptance passed on 2026-11-09. See
[release-specific validation](releases/v1.1.0.md).
