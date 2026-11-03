[Setup]
AppId={{8A9E5C11-4B2F-4E9A-9D1C-7F8B3E2A1C02}
AppName=SBS Remote (Staff Console)
AppVersion=1.5.0
DefaultDirName={autopf}\RustDesk
OutputBaseFilename=SBS-Staff-Remote-Setup-V-150
OutputDir=Output
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern
DisableProgramGroupPage=yes
RestartIfNeededByRun=no
AlwaysRestart=no
UninstallDisplayIcon={code:GetTargetExePath}

[Icons]
Name: "{autodesktop}\SBS Remote (Staff Console)"; Filename: "{code:GetTargetExePath}"; IconFilename: "{code:GetTargetExePath}"
Name: "{autoprograms}\SBS Remote (Staff Console)"; Filename: "{code:GetTargetExePath}"; IconFilename: "{code:GetTargetExePath}"

[Files]
Source: "tailscale-setup.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "SBSRemote-Staff-1.5.0.exe"; DestDir: "{tmp}"; DestName: "rustdesk-host=100.80.200.105,relay=100.80.200.105,key=Ak+YEcbgspcvH0YmWJ478LTevmdjh1VyUUrp+pcfMEo=.exe"; Flags: deleteafterinstall

[Run]
; 1. ติดตั้ง Tailscale แบบเงียบๆ (Silent & Unattended)
Filename: "{tmp}\tailscale-setup.exe"; Parameters: "/quiet /norestart TS_UNATTENDEDMODE=always TS_NOLAUNCH=true"; StatusMsg: "Installing Tailscale Network..."; Flags: runhidden waituntilterminated

; 2. ล็อกอิน Tailscale เข้าวงในฐานะทีมงานบริษัท (autogroup:member)
Filename: "{code:GetTailscaleExePath}"; Parameters: "up --login-server=http://27.254.134.36:8080 --authkey hskey-auth-WViS7_NwwBGg-khd8oc2D3z5CYwFg0-_nKCmzUO5icYfFAI7JO2Ek3WoSO72zyfn-NtKJjQhQTifj --unattended --reset"; StatusMsg: "Connecting to Tailscale Network..."; Flags: runhidden waituntilterminated; BeforeInstall: WaitForTailscale

; 3. ติดตั้ง SBS Remote Staff (สิทธิ์เต็มรูปแบบ สำหรับเป็นฝ่ายควบคุม/รีโมทไปหาลูกค้า)
Filename: "{tmp}\rustdesk-host=100.80.200.105,relay=100.80.200.105,key=Ak+YEcbgspcvH0YmWJ478LTevmdjh1VyUUrp+pcfMEo=.exe"; Parameters: "--silent-install"; StatusMsg: "Installing SBS Remote (Staff Console)..."; Flags: runhidden waituntilterminated; BeforeInstall: PreInstallRemote; AfterInstall: ConfigureRemoteStaff

; 4. เปิดโปรแกรม SBS Remote ขึ้นมาทันทีหลังติดตั้งเสร็จ
Filename: "{code:GetTargetExePath}"; Description: "Launch SBS Remote (Staff Console)"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; 1. ปิดและถอนการติดตั้ง RustDesk Service + โปรแกรม
Filename: "taskkill.exe"; Parameters: "/F /IM rustdesk.exe"; Flags: runhidden; RunOnceId: "KillRustDesk"
Filename: "taskkill.exe"; Parameters: "/F /IM RuntimeBroker_rustdesk.exe"; Flags: runhidden; RunOnceId: "KillRustDeskBroker"
Filename: "{code:GetTargetExePath}"; Parameters: "--uninstall"; Flags: runhidden waituntilterminated; RunOnceId: "UninstallRustDesk"
Filename: "sc.exe"; Parameters: "stop RustDesk"; Flags: runhidden; RunOnceId: "StopRustDeskSvc"
Filename: "sc.exe"; Parameters: "delete RustDesk"; Flags: runhidden; RunOnceId: "DeleteRustDeskSvc"

; 2. ออกจากวงแลนและถอนการติดตั้ง Tailscale
Filename: "{code:GetTailscaleExePath}"; Parameters: "logout"; Flags: runhidden waituntilterminated; RunOnceId: "LogoutTailscale"
Filename: "{code:GetTailscaleExePath}"; Parameters: "down"; Flags: runhidden waituntilterminated; RunOnceId: "DownTailscale"
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""$app = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object {{ $_.DisplayName -like 'Tailscale*' }} | Select-Object -First 1; if ($app -and $app.PSChildName -match '^\{{.*\}}') {{ Start-Process msiexec.exe -ArgumentList ('/x ' + $app.PSChildName + ' /qn /norestart') -Wait -NoNewWindow }} elseif (Test-Path 'C:\ProgramData\Package Cache') {{ Get-ChildItem 'C:\ProgramData\Package Cache' -Filter 'tailscale-setup*.exe' -Recurse -ErrorAction SilentlyContinue | ForEach-Object {{ Start-Process $_.FullName -ArgumentList '/uninstall /quiet /norestart' -Wait -NoNewWindow }} }}"""; Flags: runhidden waituntilterminated; RunOnceId: "UninstallTailscale"

[UninstallDelete]
Type: filesandordirs; Name: "{commonpf64}\RustDesk"
Type: filesandordirs; Name: "{commonpf}\RustDesk"
Type: filesandordirs; Name: "{win}\ServiceProfiles\LocalService\AppData\Roaming\RustDesk"
Type: filesandordirs; Name: "{userappdata}\RustDesk"
Type: filesandordirs; Name: "{localappdata}\RustDesk"
Type: filesandordirs; Name: "{commonappdata}\RustDesk"
Type: files; Name: "{commonstartup}\RustDesk Tray.lnk"
Type: files; Name: "{commondesktop}\SBS Remote (Staff Console).lnk"
Type: files; Name: "{autodesktop}\SBS Remote (Staff Console).lnk"

[Code]
function GetTargetExePath(Param: String): String;
begin
  if FileExists(ExpandConstant('{commonpf64}\RustDesk\rustdesk.exe')) then
    Result := ExpandConstant('{commonpf64}\RustDesk\rustdesk.exe')
  else if FileExists(ExpandConstant('{commonpf}\RustDesk\rustdesk.exe')) then
    Result := ExpandConstant('{commonpf}\RustDesk\rustdesk.exe')
  else
    Result := ExpandConstant('{commonpf64}\RustDesk\rustdesk.exe');
end;

function GetTailscaleExePath(Param: String): String;
begin
  if FileExists(ExpandConstant('{commonpf64}\Tailscale\tailscale.exe')) then
    Result := ExpandConstant('{commonpf64}\Tailscale\tailscale.exe')
  else if FileExists(ExpandConstant('{commonpf}\Tailscale\tailscale.exe')) then
    Result := ExpandConstant('{commonpf}\Tailscale\tailscale.exe')
  else
    Result := ExpandConstant('{commonpf64}\Tailscale\tailscale.exe');
end;

procedure WaitForTailscale();
var
  ResultCode: Integer;
begin
  Exec('net.exe', 'start Tailscale', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(2000);
end;

procedure PreInstallRemote();
var
  ResultCode: Integer;
begin
  Exec('taskkill.exe', '/F /IM rustdesk.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill.exe', '/F /IM sbsremote.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill.exe', '/F /IM SBSRemote.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('net.exe', 'stop RustDesk', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('net.exe', 'stop SBSRemote', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(1000);
end;

procedure SaveBothConfigs(BaseDir: String; Content: String);
begin
  ForceDirectories(BaseDir + '\RustDesk\config');
  SaveStringToFile(BaseDir + '\RustDesk\config\RustDesk2.toml', Content, False);
end;

procedure DeleteRustDeskShortcuts();
begin
  DeleteFile(ExpandConstant('{commondesktop}\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{autodesktop}\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{userdesktop}\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{sd}\Users\Public\Desktop\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{commonprograms}\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{autoprograms}\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{userprograms}\RustDesk.lnk'));
  DelTree(ExpandConstant('{commonprograms}\RustDesk'), True, True, True);
  DelTree(ExpandConstant('{autoprograms}\RustDesk'), True, True, True);

  DeleteFile(ExpandConstant('{commondesktop}\SBS Remote.lnk'));
  DeleteFile(ExpandConstant('{autodesktop}\SBS Remote.lnk'));
  DeleteFile(ExpandConstant('{userdesktop}\SBS Remote.lnk'));
  DeleteFile(ExpandConstant('{sd}\Users\Public\Desktop\SBS Remote.lnk'));
  DeleteFile(ExpandConstant('{commonprograms}\SBS Remote.lnk'));
  DeleteFile(ExpandConstant('{autoprograms}\SBS Remote.lnk'));
end;

procedure HideSubInstallersFromControlPanel();
var
  Names: TArrayOfString;
  I: Integer;
  SubKey, DisplayName: String;
begin
  RegWriteDWordValue(HKLM64, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk', 'SystemComponent', 1);
  RegWriteDWordValue(HKLM32, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk', 'SystemComponent', 1);

  if RegGetSubkeyNames(HKLM64, 'Software\Microsoft\Windows\CurrentVersion\Uninstall', Names) then
  begin
    for I := 0 to GetArrayLength(Names) - 1 do
    begin
      SubKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + Names[I];
      if RegQueryStringValue(HKLM64, SubKey, 'DisplayName', DisplayName) then
      begin
        if Pos('Tailscale', DisplayName) = 1 then
          RegWriteDWordValue(HKLM64, SubKey, 'SystemComponent', 1);
      end;
    end;
  end;

  if RegGetSubkeyNames(HKLM32, 'Software\Microsoft\Windows\CurrentVersion\Uninstall', Names) then
  begin
    for I := 0 to GetArrayLength(Names) - 1 do
    begin
      SubKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + Names[I];
      if RegQueryStringValue(HKLM32, SubKey, 'DisplayName', DisplayName) then
      begin
        if Pos('Tailscale', DisplayName) = 1 then
          RegWriteDWordValue(HKLM32, SubKey, 'SystemComponent', 1);
      end;
    end;
  end;
end;

procedure ConfigureRemoteStaff();
var
  ConfigContent: String;
  FindRec: TFindRec;
  ResultCode: Integer;
  WaitLoops: Integer;
begin
  // รอจนกว่า --silent-install ของ RustDesk จะสร้างไฟล์ rustdesk.exe และลงทะเบียน Service เสร็จสมบูรณ์
  WaitLoops := 0;
  while (not FileExists(GetTargetExePath(''))) and (WaitLoops < 30) do
  begin
    Sleep(1000);
    WaitLoops := WaitLoops + 1;
  end;
  Sleep(2000);

  // 1. หยุด Service ชั่วคราวเพื่อเขียนทับ Config ไม่ให้โดนโปรเซสทับกลับ
  Exec('net.exe', 'stop RustDesk', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill.exe', '/F /IM rustdesk.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(1000);

  ConfigContent := 
    'rendezvous_server = ''100.80.200.105:21116''' + #13#10 +
    'relay_server = ''100.80.200.105:21117''' + #13#10 +
    '' + #13#10 +
    '[options]' + #13#10 +
    'custom-rendezvous-server = ''100.80.200.105''' + #13#10 +
    'relay-server = ''100.80.200.105''' + #13#10 +
    'key = ''Ak+YEcbgspcvH0YmWJ478LTevmdjh1VyUUrp+pcfMEo=''' + #13#10 +
    'app-mode = ''tech''' + #13#10;

  // 2. บันทึก Config ลงใน Windows Service Profile (LocalService)
  SaveBothConfigs(ExpandConstant('{win}\ServiceProfiles\LocalService\AppData\Roaming'), ConfigContent);

  // 3. บันทึก Config ให้ User ปัจจุบัน
  SaveBothConfigs(ExpandConstant('{userappdata}'), ConfigContent);

  // 4. บันทึก Config ให้ User Profiles ทุกคนในเครื่อง
  if FindFirst(ExpandConstant('{sd}\Users\*'), FindRec) then
  begin
    try
      repeat
        if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
           (FindRec.Name <> '.') and (FindRec.Name <> '..') and 
           (FindRec.Name <> 'Public') and (FindRec.Name <> 'All Users') then
        begin
          SaveBothConfigs(ExpandConstant('{sd}\Users\') + FindRec.Name + '\AppData\Roaming', ConfigContent);
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;

  // 5. ลบ Shortcut เดิมของ RustDesk ที่สร้างตอน silent-install ทิ้ง เพื่อให้เหลือเฉพาะ "SBS Remote (Staff Console)"
  DeleteRustDeskShortcuts();

  // 6. ซ่อน RustDesk และ Tailscale จากรายการ Add/Remove Programs ไม่ให้แสดงซ้ำ
  HideSubInstallersFromControlPanel();

  // 7. ตั้งค่า Service ให้เป็น Auto-Start และสั่งเริ่มทำงานทันทีพร้อม Tray
  Exec('sc.exe', 'config RustDesk start= auto', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('net.exe', 'start RustDesk', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec(GetTargetExePath(''), '--tray', '', SW_HIDE, ewNoWait, ResultCode);
  Sleep(1000);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssPostInstall) or (CurStep = ssDone) then
  begin
    DeleteRustDeskShortcuts();
  end;
end;
