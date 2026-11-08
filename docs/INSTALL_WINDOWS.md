# Install and play on Windows

## Availability

[Release 1.0.0](https://github.com/eruggie/qbert-pyramid/releases/tag/v1.0.0)
provides the Windows binary and matching SHA-256 files. Choose the Windows ZIP
under Assets, not GitHub's automatic source archive.

## Requirements

Windows 11 x86_64, Compatibility renderer with an OpenGL 3.3-capable graphics
driver. Godot's [engine requirements](https://docs.godotengine.org/en/stable/about/system_requirements.html)
are informative, not proof of this game's minimum hardware. The observed Windows
reference PC is Core Ultra 9 275HX / RTX 5070 Laptop, driver 32.0.15.9608;
no performance floor has been measured. No Windows 10 or ARM support is claimed.
Players do not install development tools or a separate Godot runtime.

## Download, verify and extract

Choose the Windows x86_64
binary ZIP attached under release **Assets**, plus its matching .zip.sha256.
GitHub's “Source code” ZIP/tar.gz and QBertPyramid-source.zip are source packages,
not the playable Windows download. Use the exact pair of files from the same release.

In PowerShell, replace both file paths with the exact downloaded names:

```powershell
$archive = Get-Item -LiteralPath '.\QBertPyramid-1.0.0-Windows-x86_64.zip'
$checksumFile = Get-Item -LiteralPath '.\QBertPyramid-1.0.0-Windows-x86_64.zip.sha256'
$expected = ((Get-Content -LiteralPath $checksumFile.FullName -Raw).Trim() -split '\s+')[0]
if ($expected -notmatch '^[0-9a-fA-F]{64}$') { throw 'Invalid SHA-256 file' }
$actual = (Get-FileHash -LiteralPath $archive.FullName -Algorithm SHA256).Hash
if ($actual -ine $expected) { throw 'SHA-256 mismatch: do not run this file' }
$destination = Join-Path $env:LOCALAPPDATA 'QBertPyramid Game'
if (Test-Path -LiteralPath $destination) { throw 'Choose a new empty destination for this version' }
Expand-Archive -LiteralPath $archive.FullName -DestinationPath $destination
Start-Process -FilePath (Join-Path $destination 'QBertPyramid.exe') -WorkingDirectory $destination
```

The names above identify the 1.0.0 release assets.
Keep the EXE, PCK, licenses, notices and other extracted files together. Do not
run from inside an archive. Distribution works by copying the entire folder to
local disk, USB or a network share where Windows permits execution; no installer
is provided. Network/USB policies and disconnections can prevent execution.
Those paths have not received a distinct reported transport test.

## First run and saves

Use Nuova partita (New game), Informazioni sul gioco (About/instructions) and
Impostazioni (Settings). See [PLAYER_GUIDE](PLAYER_GUIDE.md). Test sound, focus,
controls and results. The top ten and settings are stored in
`%APPDATA%\QBertPyramid\profile.json`, with a .bak backup. They are local to
the current Windows user, including when running from USB or a share.
Do not modify personal profiles for corruption or write-denial testing.

For an update, close the game, retain a protected copy of that profile folder,
and extract the new version to a separate program directory. Existing supported
profiles are migrated; older builds may not understand a new schema. Removing
the program folder uninstalls the game. Saves remain until the user separately
chooses to remove them; do not delete them as part of an ordinary update.

## Warnings and known limits

The EXE is not digitally signed. Windows reputation checks may display a warning.
Inspect the source, checksum and provenance; stop if uncertain. Do not disable
antivirus, SmartScreen or other protection. A missing PCK usually means incomplete
extraction; a graphics startup error may indicate an unsupported driver. Do not
promise a fix by changing global driver or security settings.
Phase 6, including performance targets, is accepted on the owner’s declaration.
No frame-time values were provided to this session; the assistant has not measured them. See [VALIDATION](VALIDATION.md) for owner-reported acceptance and its scope.
