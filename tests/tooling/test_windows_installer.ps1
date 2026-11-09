param([Parameter(Mandatory=$true)][string]$Delivery)
$ErrorActionPreference = 'Stop'
function Check($Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
    Write-Output "PASS: $Message"
}
$Delivery = (Resolve-Path -LiteralPath $Delivery).ProviderPath
$setup = @(Get-ChildItem -LiteralPath $Delivery -Filter '*-Setup.exe')
Check ($setup.Count -eq 1) 'One setup executable'
$reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\QBertPyramid'
$appReg = 'HKCU:\Software\QBertPyramid'
$shortcutDir = Join-Path ([Environment]::GetFolderPath('Programs')) 'QBertPyramid'
Check ((-not (Test-Path $reg)) -and (-not (Test-Path $appReg)) -and (-not (Test-Path $shortcutDir))) 'No pre-existing installation registration or shortcuts'
$work = Join-Path $env:TEMP ('QBertInstallerTest-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$localSetup = Join-Path $work 'Setup.exe'
Copy-Item -LiteralPath $setup[0].FullName -Destination $localSetup
$install = Join-Path $work 'installed game'
$profileDir = Join-Path $env:APPDATA 'QBertPyramid'
function ProfileHashes {
    if (Test-Path -LiteralPath $profileDir) {
        return ((Get-ChildItem -LiteralPath $profileDir -Recurse -File | Sort-Object FullName | ForEach-Object {
            $_.FullName + ':' + (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }) -join "`n")
    }
    return ''
}
$profilesBefore = ProfileHashes
foreach ($file in @($localSetup, (Join-Path $Delivery 'runtime\QBertPyramid.exe'))) {
    $v = [Diagnostics.FileVersionInfo]::GetVersionInfo($file)
    Check ($v.CompanyName -eq 'Eugenio Ruggieri') "Publisher metadata: $([IO.Path]::GetFileName($file))"
    Check ($v.LegalCopyright -eq '(c) Eugenio Ruggieri 2026') 'Exact author copyright'
    Write-Output ('SIGNATURE: ' + (Get-AuthenticodeSignature -LiteralPath $file).Status)
}
try {
    $proc = Start-Process -FilePath $localSetup -ArgumentList @('/S', ('/D=' + $install)) -Wait -PassThru
    Check ($proc.ExitCode -eq 0) 'Silent installation exit code'
    $payload = @(Get-ChildItem -LiteralPath (Join-Path $Delivery 'runtime') -Recurse -File)
    foreach ($file in $payload) {
        $relative = $file.FullName.Substring((Join-Path $Delivery 'runtime').Length).TrimStart('\')
        $target = Join-Path $install $relative
        Check ((Test-Path -LiteralPath $target) -and ((Get-FileHash -LiteralPath $target).Hash -eq (Get-FileHash -LiteralPath $file.FullName).Hash)) "Installed payload: $relative"
    }
    Check (@(Get-ChildItem -LiteralPath $install -Recurse -File).Count -eq ($payload.Count + 1)) 'Only allowlisted runtime files and uninstaller installed'
    Check ((Get-ItemProperty -LiteralPath $reg).Publisher -eq 'Eugenio Ruggieri') 'Windows installed-app publisher'
    Check (Test-Path -LiteralPath (Join-Path $shortcutDir 'QBERT Pyramid.lnk')) 'Start menu shortcut'
    $sentinel = Join-Path $install 'user-file.keep'
    Set-Content -LiteralPath $sentinel -Value 'preserve this file'
    $proc = Start-Process -FilePath $localSetup -ArgumentList @('/S', ('/D=' + $install)) -Wait -PassThru
    Check ($proc.ExitCode -eq 0) 'Update in place exit code'
    Check (Test-Path -LiteralPath $sentinel) 'Update preserves user-added files'
    $uninstaller = Join-Path $install 'Uninstall.exe'
    $proc = Start-Process -FilePath $uninstaller -ArgumentList '/S' -Wait -PassThru
    Check ($proc.ExitCode -eq 0) 'Uninstall launcher exit code'
    for ($i = 0; $i -lt 100; $i++) {
        if ((-not (Test-Path $reg)) -and (-not (Test-Path -LiteralPath $uninstaller))) { break }
        Start-Sleep -Milliseconds 100
    }
    Check (-not (Test-Path $reg)) 'Installed-app registration removed'
    Check (-not (Test-Path $appReg)) 'Application registration removed'
    Check (-not (Test-Path -LiteralPath $shortcutDir)) 'Start menu shortcuts removed'
    Check ((Test-Path -LiteralPath $sentinel) -and ((Get-Content -LiteralPath $sentinel -Raw).Trim() -eq 'preserve this file')) 'Uninstall preserves user-added file'
    Check (@(Get-ChildItem -LiteralPath $install -Recurse -File).Count -eq 1) 'All installed runtime files removed'
    Check ((ProfileHashes) -ceq $profilesBefore) 'Existing player saves unchanged'
    Write-Output 'AP_WINDOWS_INSTALLER_COMPLETE (automated lifecycle only; gameplay/SmartScreen pending)'
} finally {
    if (Test-Path -LiteralPath (Join-Path $install 'Uninstall.exe')) {
        Write-Output "Test artifacts retained for inspection: $work"
    } else {
        Remove-Item -LiteralPath $work -Recurse -Force
    }
}
