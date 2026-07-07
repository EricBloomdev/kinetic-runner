#ifndef MyAppVersion
  #define MyAppVersion "1.1.0"
#endif

#define MyAppName "Kinetic"
#define MyAppPublisher "Kinetic"
#define MyAppExeName "Kinetic.exe"

[Setup]
AppId={{D81C0A38-8A83-4D74-BE2D-3C3B7AE29CC8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=dist
OutputBaseFilename=Kinetic-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=assets\kinetic.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Dirs]
Name: "{localappdata}\Kinetic"

[Files]
Source: "dist\Kinetic\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[INI]
Filename: "{localappdata}\Kinetic\runner_installed.ini"; Section: "runner"; Key: "app_dir"; String: "{app}"
Filename: "{localappdata}\Kinetic\runner_installed.ini"; Section: "runner"; Key: "exe_path"; String: "{app}\{#MyAppExeName}"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[UninstallDelete]
Type: files; Name: "{localappdata}\Kinetic\runner_installed.ini"
Type: files; Name: "{localappdata}\Kinetic\runner_installing.flag"

[Run]
Filename: "{app}\{#MyAppExeName}"; Parameters: "--initialize-only"; StatusMsg: "Initializing Kinetic..."; Flags: waituntilterminated skipifsilent

[Code]
procedure WriteRunnerInstallingFlag();
begin
  ForceDirectories(ExpandConstant('{localappdata}\Kinetic'));
  SaveStringToFile(
    ExpandConstant('{localappdata}\Kinetic\runner_installing.flag'),
    GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':'),
    False
  );
end;

procedure ClearRunnerInstallingFlag();
var
  FlagPath: string;
begin
  FlagPath := ExpandConstant('{localappdata}\Kinetic\runner_installing.flag');
  if FileExists(FlagPath) then begin
    DeleteFile(FlagPath);
  end;
end;

function InitializeSetup(): Boolean;
begin
  WriteRunnerInstallingFlag();
  Result := True;
end;

procedure DeinitializeSetup();
begin
  ClearRunnerInstallingFlag();
end;