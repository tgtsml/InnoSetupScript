; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppVersion              	"1.0"
#define MyAppName                 	"appname"
#define MyAppExeName              	"appname.exe"
#define MyUninstallAppNmae        	"uninstall "+MyAppName
#define MyAppPublisher            	"tgtsml"
#define MyCompanyName             	"tgtsml"
#define MyAppURL                  	"http://www.test.com/"
#define MyAppId                   	"{{FFBFD0C4-2D5D-4742-8AA5-78EFF1D0E653}"
	
#define MyAppWindowName           	"MyAppWindowName"
#define MyAppRunningInstallTips   	"应用软件正在运行，请退出后重试！"
#define MyAppReinstallTips        	"'软件已安装，是否覆盖安装？'#13#13'覆盖安装可能会丢失数据，请先备份数据。'"
#define MyAppRunningUninstallTips 	"应用软件正在运行，请退出后再进行卸载操作！"
#define MyAppExitSetupTips        	"您确定要退出 " + MyAppName + " 安装程序？"
#define MyAppDirChangeEnableTips  	"软件已经安装，不允许更换目录。"
#define MyAppStartupFailedTips    	"软件启动失败！"
#define MyAppSetupTitleTail       	"安装"
	
#define MyAppDir                  	".\app"
#define MyResourceDir             	".\res"
#define MyCoreDir				  	        MyResourceDir+"\core"
#define MyTmpDir                  	MyResourceDir+"\tmp"
#define MyOutputDir               	".\setup"
	
#define MySetupIconFile           	MyCoreDir+"\setup_icon.ico"
#define MyOutputSetupFileName     	"mysetup"

#define x64BuildOnly
;#undef x64BuildOnly

#define MyDefaultInstallDir       	"C:\"+MyCompanyName
#undef  MyDefaultInstallDir

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
OutputDir={#MyOutputDir}
OutputBaseFilename={#MyOutputSetupFileName}
SetupIconFile={#MySetupIconFile}
DisableProgramGroupPage=yes
Compression=lzma
SolidCompression=yes
WizardStyle=modern

#ifdef x64BuildOnly
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={commonpf64}\{#MyCompanyName}\{#MyAppName}
#else
ArchitecturesAllowed=x86 x64
DefaultDirName={commonpf32}\{#MyCompanyName}\{#MyAppName}
#endif

#ifdef MyDefaultInstallDir
DefaultDirName={#MyDefaultInstallDir}\{#MyAppName}
#endif

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#MyTmpDir}\*"; DestDir: "{tmp}"; Flags: dontcopy solidbreak nocompression; Attribs: hidden system
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyCompanyName}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autoprograms}\{#MyCompanyName}\{#MyUninstallAppNmae}"; Filename:{uninstallexe}; WorkingDir: {app};
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
Root: HKLM; Subkey: "SOFTWARE\{#MyCompanyName}"; Flags: uninsdeletekeyifempty
Root: HKLM; Subkey: "SOFTWARE\{#MyCompanyName}\{#MyAppName}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\{#MyCompanyName}\{#MyAppName}"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\{#MyCompanyName}\{#MyAppName}"; ValueType: string; ValueName: "ExecuteName"; ValueData: "{#MyAppExeName}"; Flags: uninsdeletekey

[Code]
#include MyCoreDir + "\coreScript.iss"