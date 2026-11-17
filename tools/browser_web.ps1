param([ValidateSet('Chrome','Edge')][string]$Browser='Chrome',[string]$Url='http://localhost:8765/80_arcade_games/qbert/',[string]$Output,[switch]$Headed,[switch]$RetryServerSave)
$ErrorActionPreference='Stop'
if (!$Output) { throw 'Pass an absolute Windows output directory in -Output' }
New-Item -ItemType Directory -Force -Path $Output | Out-Null
$exe=if($Browser -eq 'Chrome'){'C:\Program Files\Google\Chrome\Application\chrome.exe'}else{'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'}
$port=if($Browser -eq 'Chrome'){9233}else{9234}
$profile=Join-Path $env:TEMP ('qbert-web-'+[guid]::NewGuid().ToString())
$browserVersion=(Get-Item $exe).VersionInfo.ProductVersion
$browserVersion|Set-Content (Join-Path $Output 'browser-version.txt')
$launch=@("--remote-debugging-port=$port",(' --user-data-dir="'+$profile+'"'),'--no-first-run','--no-default-browser-check','--window-size=1440,1100','about:blank')
if(!$Headed){$launch+= '--headless=new'}
$process=Start-Process -FilePath $exe -ArgumentList $launch -PassThru
$script:seq=0;$script:events=[System.Collections.Generic.List[object]]::new()
function Cdp([string]$Method,$Params=@{}) {
 $script:seq++;$id=$script:seq
 $message=@{id=$id;method=$Method;params=$Params}|ConvertTo-Json -Depth 20 -Compress
 $bytes=[Text.Encoding]::UTF8.GetBytes($message)
 $script:socket.SendAsync([ArraySegment[byte]]::new($bytes),[Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).GetAwaiter().GetResult()|Out-Null
 do {
  $buffer=New-Object byte[] 4194304;$stream=[IO.MemoryStream]::new()
  do {$cancel=[Threading.CancellationTokenSource]::new(30000);$received=$script:socket.ReceiveAsync([ArraySegment[byte]]::new($buffer),$cancel.Token).GetAwaiter().GetResult();$stream.Write($buffer,0,$received.Count)} while(!$received.EndOfMessage)
  $reply=[Text.Encoding]::UTF8.GetString($stream.ToArray())|ConvertFrom-Json
  if($reply.method){$script:events.Add($reply)}
 }while($reply.id -ne $id)
 if($reply.error){throw ($reply.error|ConvertTo-Json)}
 return $reply.result
}
function Js([string]$Code) {$r=Cdp 'Runtime.evaluate' @{expression=$Code;returnByValue=$true;awaitPromise=$true};if($r.exceptionDetails){throw ($r.exceptionDetails|ConvertTo-Json -Depth 8)};return $r.result.value}
function Shot([string]$Name) {
 Start-Sleep -Milliseconds 180
 $r=Cdp 'Page.captureScreenshot' @{format='png'}
 [IO.File]::WriteAllBytes((Join-Path $Output ($Name+'.png')),[Convert]::FromBase64String($r.data))
}
function ClickCanvas([double]$X,[double]$Y) {
 $point=Js "(()=>{const r=canvas.getBoundingClientRect();return {x:r.x+r.width*$X/1280,y:r.y+r.height*$Y/720}})()"
 Cdp 'Input.dispatchMouseEvent' @{type='mousePressed';x=$point.x;y=$point.y;button='left';clickCount=1}|Out-Null
 Cdp 'Input.dispatchMouseEvent' @{type='mouseReleased';x=$point.x;y=$point.y;button='left';clickCount=1}|Out-Null
}
function Key([string]$Code,[string]$Key,[int]$Vk,[int]$Hold=80) {
  $parameters=@{type='keyDown';code=$Code;key=$Key;windowsVirtualKeyCode=$Vk;nativeVirtualKeyCode=$Vk}
 if($Key.Length -eq 1){$parameters.text=$Key}
 Cdp 'Input.dispatchKeyEvent' $parameters|Out-Null
 Start-Sleep -Milliseconds $Hold
 Cdp 'Input.dispatchKeyEvent' @{type='keyUp';code=$Code;key=$Key;windowsVirtualKeyCode=$Vk;nativeVirtualKeyCode=$Vk}|Out-Null
}
try {
 for($i=0;$i -lt 40;$i++){try{$targets=Invoke-RestMethod "http://localhost:$port/json/list";break}catch{Start-Sleep -Milliseconds 250}}
 $target=$targets|Where-Object {$_.type -eq 'page' -and $_.url -eq 'about:blank'}|Select-Object -First 1
 if(!$target){$target=$targets|Where-Object {$_.type -eq 'page'}|Select-Object -First 1}
 if(!$target){throw 'No browser page target available'}
 $script:socket=[Net.WebSockets.ClientWebSocket]::new();$script:socket.ConnectAsync([Uri]$target.webSocketDebuggerUrl,[Threading.CancellationToken]::None).GetAwaiter().GetResult()
 Cdp 'Page.enable'|Out-Null;Cdp 'Runtime.enable'|Out-Null;Cdp 'Log.enable'|Out-Null;Cdp 'Network.enable'|Out-Null;Cdp 'WebAudio.enable'|Out-Null
 Cdp 'Page.addScriptToEvaluateOnNewDocument' @{source=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'web_audio_probe.js'))}|Out-Null
 Cdp 'Page.navigate' @{url=$Url}|Out-Null;Start-Sleep -Seconds 1
 Shot '01-page'
 $start=Js '(()=>{const r=document.getElementById("start").getBoundingClientRect();return {x:r.x+r.width/2,y:r.y+r.height/2}})()'
 Cdp 'Input.dispatchMouseEvent' @{type='mousePressed';x=$start.x;y=$start.y;button='left';clickCount=1}|Out-Null
 Cdp 'Input.dispatchMouseEvent' @{type='mouseReleased';x=$start.x;y=$start.y;button='left';clickCount=1}|Out-Null
 for($i=0;$i -lt 100;$i++){Start-Sleep -Milliseconds 300;if(Js 'started') {break}}
 if(!(Js 'started')){throw ('Game did not start: '+(Js 'notice.textContent'))}
 Key 'Enter' 'Enter' 13
 Shot '02-menu'
 Key 'Enter' 'Enter' 13
 Start-Sleep -Milliseconds 400
 Shot '03-game'
 # Preserve full down/up events, including the numpad location.
 foreach($entry in @(@('KeyC','c',67),@('KeyQ','q',81),@('KeyZ','z',90),@('KeyE','e',69),@('ArrowRight','ArrowRight',39),@('ArrowLeft','ArrowLeft',37),@('ArrowDown','ArrowDown',40),@('ArrowUp','ArrowUp',38),@('Numpad3','3',99),@('Numpad7','7',103),@('Numpad1','1',97),@('Numpad9','9',105))){
  if($entry[0] -like 'Numpad*'){
   Cdp 'Input.dispatchKeyEvent' @{type='keyDown';code=$entry[0];key=$entry[1];windowsVirtualKeyCode=$entry[2];location=3;isKeypad=$true}|Out-Null
   Start-Sleep -Milliseconds 80
   Cdp 'Input.dispatchKeyEvent' @{type='keyUp';code=$entry[0];key=$entry[1];windowsVirtualKeyCode=$entry[2];location=3;isKeypad=$true}|Out-Null
  }else{Key $entry[0] $entry[1] $entry[2]}
  Start-Sleep -Milliseconds 300;Shot ('key-'+$entry[0])
 }
 Key 'KeyP' 'p' 80;Shot '04-pause';Key 'KeyP' 'p' 80
 Key 'KeyC' 'c' 67 1200;Shot '05-hold'
 Cdp 'Input.dispatchKeyEvent' @{type='keyDown';code='KeyC';key='c';text='c';windowsVirtualKeyCode=67}|Out-Null
 Js 'canvas.blur();document.querySelector(".home-link").focus();true'|Out-Null
 Cdp 'Input.dispatchKeyEvent' @{type='keyUp';code='KeyC';key='c';windowsVirtualKeyCode=67}|Out-Null
 Shot '06-focus-out'
 Js 'canvas.focus();true'|Out-Null;Shot '07-focus-return'
 Key 'KeyP' 'p' 80;Key 'KeyC' 'c' 67;Shot '08-resume'
 $before=Js 'scrollY';Key 'ArrowDown' 'ArrowDown' 40;Key 'Tab' 'Tab' 9
 $after=Js 'scrollY';if($before -ne $after){throw 'Page scrolled with focused gameplay keys'}
 Key 'Escape' 'Escape' 27;Shot '09-menu-return'
 Key 'Tab' 'Tab' 9;Key 'Tab' 'Tab' 9;Key 'Enter' 'Enter' 13;Shot '10-records'
 Key 'Enter' 'Enter' 13
 ClickCanvas 470 462
 Shot '11-settings'
 $audio=Js '({peak:audioProbe.peak,samples:audioProbe.samples,contexts:audioProbe.contexts.map(c=>c.state)})'
 $audio|ConvertTo-Json -Depth 5|Set-Content (Join-Path $Output 'audio-before-mute.json')
 if($audio.peak -le 0.00001){throw 'No outgoing audio waveform before mute'}
 # Settings remain local; ranking must come from the HTTP server.
 ClickCanvas 1210 210
 ClickCanvas 700 120
 ClickCanvas 900 158
 ClickCanvas 800 565;Key 'KeyV' 'v' 86
 Shot '12-mute'
 Key 'Escape' 'Escape' 27
 Js 'audioProbe.peak=0;true'|Out-Null
 # Start a fresh run and deliberately lose lives after earning positive points.
 ClickCanvas 640 364
 Start-Sleep -Milliseconds 250
 Key 'KeyV' 'v' 86;Start-Sleep -Milliseconds 500;Key 'KeyQ' 'q' 81;Start-Sleep -Milliseconds 500
 for($i=0;$i -lt 3;$i++){Key 'KeyQ' 'q' 81;Start-Sleep -Seconds 8}
 $mutedAudio=Js '({peak:audioProbe.peak,samples:audioProbe.samples})'
 $mutedAudio|ConvertTo-Json|Set-Content (Join-Path $Output 'audio-muted.json')
 if($mutedAudio.peak -gt 0.000001){throw 'Audio output was not silent while muted'}
 Shot '13-game-over'
 Key 'Enter' 'Enter' 13;Start-Sleep -Milliseconds 400;Shot '14-result-input'
 Key 'KeyA' 'a' 65;Key 'KeyB' 'b' 66;Key 'KeyX' 'x' 88;Key 'Backspace' 'Backspace' 8;Key 'KeyC' 'c' 67;Shot '15-initials'
 Key 'Enter' 'Enter' 13;Shot '16-saved'
 if($RetryServerSave){
  Start-Sleep -Seconds 1;Shot '16a-server-not-confirmed'
  Key 'Tab' 'Tab' 9;Key 'Enter' 'Enter' 13
  Start-Sleep -Seconds 1;Shot '16b-server-retried'
 }
 Key 'Enter' 'Enter' 13;Key 'Escape' 'Escape' 27
 Start-Sleep -Seconds 2
 $profileReadCode='(async()=>{const dbs=await indexedDB.databases();const found=[];for(const info of dbs){const db=await new Promise((ok,bad)=>{const r=indexedDB.open(info.name);r.onsuccess=()=>ok(r.result);r.onerror=()=>bad(r.error)});for(const name of db.objectStoreNames){const values=await new Promise((ok,bad)=>{const r=db.transaction(name).objectStore(name).getAll();r.onsuccess=()=>ok(r.result);r.onerror=()=>bad(r.error)});for(const v of values){if(v.contents){try{const p=JSON.parse(new TextDecoder().decode(v.contents));if(p.schema)found.push(p)}catch{}}}}db.close()}return found})()'
 $profileBefore=Js $profileReadCode
 $serverReadCode='(async()=>{const r=await fetch(new URL("api/leaderboard",location.href),{cache:"no-store"});if(!r.ok)throw new Error("API unavailable");return await r.json()})()'
 $serverBefore=Js $serverReadCode
 $serverBefore|ConvertTo-Json -Depth 15|Set-Content (Join-Path $Output 'server-before-reload.json')
 if(!($serverBefore.leaderboard|Where-Object {$_.name -eq 'ABC' -and $_.points -gt 0})){throw 'Initials ABC were not saved on the server'}
 if($profileBefore|Where-Object {$_.leaderboard.Count -gt 0 -or $_.record -ne 0}){throw 'Server ranking leaked into local preferences'}
 if(!($profileBefore|Where-Object {$_.muted -and $_.bindings[3] -eq 86 -and $_.master -lt 0.8 -and $_.effects -lt 0.8})){throw 'Changed settings were not persisted'}
 $profileBefore|ConvertTo-Json -Depth 15|Set-Content (Join-Path $Output 'profiles-before-reload.json')
 Key 'F11' 'F11' 122;Shot '17-f11'
 # F11 is the only page hint; the browser may handle it outside the document.
 $full=Js '({element:Boolean(document.fullscreenElement),enabled:document.fullscreenEnabled,notice:document.getElementById("browser-notice").textContent})'
 $full|ConvertTo-Json|Set-Content (Join-Path $Output 'fullscreen.json')
 Key 'F11' 'F11' 122
 Js 'if(document.fullscreenElement)document.exitFullscreen();true'|Out-Null
 Cdp 'Emulation.setDeviceMetricsOverride' @{width=1024;height=900;deviceScaleFactor=1;mobile=$false}|Out-Null;Shot '18-resize-1024'
 Cdp 'Emulation.setDeviceMetricsOverride' @{width=1024;height=768;deviceScaleFactor=1;mobile=$false}|Out-Null
 Shot '18-resize-1024x768'
 $layout=Js '(()=>{const r=document.getElementById("stage").getBoundingClientRect();return {width:r.width,height:r.height,bottom:r.bottom,viewport:innerHeight}})()'
 $layout|ConvertTo-Json|Set-Content (Join-Path $Output 'layout-1024x768.json')
 if($layout.bottom -gt $layout.viewport+1){throw 'Game surface extends below desktop viewport'}
 Cdp 'Emulation.clearDeviceMetricsOverride'|Out-Null
 # Reload on the same origin and temporary profile, then revisit the leaderboard.
 Cdp 'Page.reload' @{ignoreCache=$true}|Out-Null;Start-Sleep -Seconds 1
 $start=Js '(()=>{const r=document.getElementById("start").getBoundingClientRect();return {x:r.x+r.width/2,y:r.y+r.height/2}})()'
 Cdp 'Input.dispatchMouseEvent' @{type='mousePressed';x=$start.x;y=$start.y;button='left';clickCount=1}|Out-Null
 Cdp 'Input.dispatchMouseEvent' @{type='mouseReleased';x=$start.x;y=$start.y;button='left';clickCount=1}|Out-Null
 for($i=0;$i -lt 100;$i++){Start-Sleep -Milliseconds 300;if(Js 'started'){break}}
 Key 'Enter' 'Enter' 13;Shot '19-reloaded-menu'
 ClickCanvas 640 462;Shot '20-persistent-leaderboard'
 $profileAfter=Js $profileReadCode
 $profileAfter|ConvertTo-Json -Depth 15|Set-Content (Join-Path $Output 'profiles-after-reload.json')
 if(!($profileAfter|Where-Object {$_.muted -and $_.bindings[3] -eq 86})){throw 'Preferences did not survive page reload'}
 $serverAfter=Js $serverReadCode
 $serverAfter|ConvertTo-Json -Depth 15|Set-Content (Join-Path $Output 'server-after-reload.json')
 if(!($serverAfter.leaderboard|Where-Object {$_.name -eq 'ABC' -and $_.points -gt 0})){throw 'Server ranking did not survive page reload'}
 # The return link and game exit resolve relative to a nested site root.
 Key 'Enter' 'Enter' 13
 ClickCanvas 640 512;Start-Sleep -Milliseconds 400;Shot '21-back-to-site'
 if((Js 'location.pathname') -ne '/'){throw 'Return to site did not resolve to site root'}
 $state=Js '({url:location.href,started:typeof started==="undefined"?null:started,canvas:typeof canvas==="undefined"?null:[canvas.width,canvas.height],focused:document.activeElement.id,isolated:crossOriginIsolated,userAgent:navigator.userAgent})'
 $state|ConvertTo-Json -Depth 10|Set-Content (Join-Path $Output 'state.json')
 $script:events|ConvertTo-Json -Depth 30|Set-Content (Join-Path $Output 'events.json')
 Write-Output ($state|ConvertTo-Json -Compress)
} finally {
 if($script:events.Count){$script:events|ConvertTo-Json -Depth 30|Set-Content (Join-Path $Output 'events.json')}
 if($script:socket){$script:socket.Dispose()}
 if($process -and !$process.HasExited){Stop-Process -Id $process.Id -Force}
}
