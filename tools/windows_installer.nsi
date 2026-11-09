; GPL-3.0-only. Build via tools/build_windows.sh; payload is an explicit allowlist.
Unicode true
!include "MUI2.nsh"
!include "x64.nsh"
!include "WinVer.nsh"
!ifndef PAYLOAD
!error "PAYLOAD is required"
!endif
!ifndef OUTPUT
!error "OUTPUT is required"
!endif
!ifndef VERSION
!error "VERSION is required"
!endif
Name "QBERT Pyramid"
OutFile "${OUTPUT}"
InstallDir "$LOCALAPPDATA\Programs\QBertPyramid"
RequestExecutionLevel user
SetCompressor /SOLID lzma
VIProductVersion "${VERSION}.0"
VIAddVersionKey /LANG=1033 "ProductName" "QBERT Pyramid Installer"
VIAddVersionKey /LANG=1033 "CompanyName" "Eugenio Ruggieri"
VIAddVersionKey /LANG=1033 "LegalCopyright" "(c) Eugenio Ruggieri 2026"
VIAddVersionKey /LANG=1033 "FileDescription" "QBERT Pyramid Setup"
VIAddVersionKey /LANG=1033 "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=1033 "ProductVersion" "${VERSION}"
!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\QBertPyramid"
!define MUI_ABORTWARNING
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${PAYLOAD}/LICENSE"
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "English"

Function .onInit
  SetShellVarContext current
  SetRegView 64
  ${IfNot} ${IsNativeAMD64}
    MessageBox MB_ICONSTOP "QBERT Pyramid richiede Windows x86_64."
    SetErrorLevel 2
    Abort
  ${EndIf}
  ; Windows 11 starts at build 22000. GetWinVer helpers only distinguish Windows 10+.
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuildNumber"
  ${If} $0 < 22000
    MessageBox MB_ICONSTOP "QBERT Pyramid richiede Windows 11 (build 22000 o successiva)."
    SetErrorLevel 2
    Abort
  ${EndIf}
FunctionEnd

Section "Gioco (obbligatorio)"
  SectionIn RO
  SetShellVarContext current
  SetRegView 64
  SetOutPath "$INSTDIR"
  ; Fail instead of overwriting a running game or continuing with a partial payload.
  ClearErrors
  File /oname=QBertPyramid.exe "${PAYLOAD}/QBertPyramid.exe"
  File /oname=QBertPyramid.pck "${PAYLOAD}/QBertPyramid.pck"
  File "${PAYLOAD}/LICENSE"
  File "${PAYLOAD}/THIRD_PARTY_NOTICES.txt"
  File "${PAYLOAD}/SOURCE_NOTICE.txt"
  File "${PAYLOAD}/BUILD_INFO.json"
  File "${PAYLOAD}/SOURCE_FILES.sha256"
  File "${PAYLOAD}/SHA256SUMS.txt"
  SetOutPath "$INSTDIR\docs"
  File "${PAYLOAD}/docs/INSTALL_WINDOWS.md"
  File "${PAYLOAD}/docs/PLAYER_GUIDE.md"
  File "${PAYLOAD}/docs/LICENSING.md"
  File "${PAYLOAD}/docs/ASSET_LICENSES.md"
  File "${PAYLOAD}/docs/THIRD_PARTY_NOTICES.txt"
  IfErrors 0 +4
    MessageBox MB_ICONSTOP "Installazione incompleta. Chiudere il gioco e riprovare."
    SetErrorLevel 2
    Abort
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateDirectory "$SMPROGRAMS\QBertPyramid"
  CreateShortcut "$SMPROGRAMS\QBertPyramid\QBERT Pyramid.lnk" "$INSTDIR\QBertPyramid.exe"
  CreateShortcut "$SMPROGRAMS\QBertPyramid\Disinstalla.lnk" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\QBertPyramid" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayName" "QBERT Pyramid"
  WriteRegStr HKCU "${REG_UNINSTALL}" "Publisher" "Eugenio Ruggieri"
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${REG_UNINSTALL}" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
  WriteRegStr HKCU "${REG_UNINSTALL}" "QuietUninstallString" '$\"$INSTDIR\Uninstall.exe$\" /S'
  WriteRegStr HKCU "${REG_UNINSTALL}" "URLInfoAbout" "https://github.com/eruggie/qbert-pyramid"
  WriteRegDWORD HKCU "${REG_UNINSTALL}" "NoModify" 1
  WriteRegDWORD HKCU "${REG_UNINSTALL}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetShellVarContext current
  SetRegView 64
  ; Explicit deletion only: preserve saves and any files added by the user.
  Delete "$INSTDIR\QBertPyramid.exe"
  Delete "$INSTDIR\QBertPyramid.pck"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\THIRD_PARTY_NOTICES.txt"
  Delete "$INSTDIR\SOURCE_NOTICE.txt"
  Delete "$INSTDIR\BUILD_INFO.json"
  Delete "$INSTDIR\SOURCE_FILES.sha256"
  Delete "$INSTDIR\SHA256SUMS.txt"
  Delete "$INSTDIR\docs\INSTALL_WINDOWS.md"
  Delete "$INSTDIR\docs\PLAYER_GUIDE.md"
  Delete "$INSTDIR\docs\LICENSING.md"
  Delete "$INSTDIR\docs\ASSET_LICENSES.md"
  Delete "$INSTDIR\docs\THIRD_PARTY_NOTICES.txt"
  RMDir "$INSTDIR\docs"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\QBertPyramid\QBERT Pyramid.lnk"
  Delete "$SMPROGRAMS\QBertPyramid\Disinstalla.lnk"
  RMDir "$SMPROGRAMS\QBertPyramid"
  DeleteRegKey HKCU "${REG_UNINSTALL}"
  DeleteRegKey HKCU "Software\QBertPyramid"
SectionEnd
