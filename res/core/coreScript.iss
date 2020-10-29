//core setup script

var
  m_isReleased, m_isInitialized, m_isProductInstalledBefore, m_shouldStartupOnSetupFinished : boolean;
  m_labelInstallProgress, m_labelProductAlreadyInstalled : TLabel;
  m_editTargetPath : TEdit;
  m_btnMinimize, m_btnExit, m_btnInstall, m_btnBrowse, m_btnCustomizeSetup, m_btnUncustomizeSetup, m_checkboxStartup : hwnd;
  m_imageCustomizeBackground, m_imageFormBackground, m_progressbarBackground, m_progressbarForeground, PBOldProc : longint;

const
  WM_SYSCOMMAND = $0112;
  ID_BUTTON_ON_CLICK_EVENT = 1;
  WIZARDFORM_WIDTH_NORMAL = 600;
  WIZARDFORM_HEIGHT_NORMAL = 400;
  WIZARDFORM_HEIGHT_MORE = 503;
  
type
  TBtnEventProc = procedure(h : hwnd);
  TPBProc = function(h : hWnd; Msg, wParam, lParam : longint) : longint;
  
function  ImgLoad(h : hwnd; FileName : PAnsiChar; Left, Top, Width, Height : integer; Stretch, IsBkg : boolean) : longint; external 'ImgLoad@files:botva2.dll STDCALL DELAYLOAD';
procedure ImgSetVisibility(img : longint; Visible : boolean); external 'ImgSetVisibility@files:botva2.dll STDCALL DELAYLOAD';
procedure ImgApplyChanges(h : hwnd); external 'ImgApplyChanges@files:botva2.dll STDCALL DELAYLOAD';
procedure ImgSetPosition(img : longint; NewLeft, NewTop, NewWidth, NewHeight : integer); external 'ImgSetPosition@files:botva2.dll STDCALL DELAYLOAD';
procedure ImgRelease(img : longint); external 'ImgRelease@files:botva2.dll STDCALL DELAYLOAD';
procedure CreateFormFromImage(h : hwnd; FileName : PAnsiChar); external 'CreateFormFromImage@files:botva2.dll STDCALL DELAYLOAD';
procedure gdipShutdown();  external 'gdipShutdown@files:botva2.dll STDCALL DELAYLOAD';
function  WrapBtnCallback(Callback : TBtnEventProc; ParamCount : integer) : longword; external 'wrapcallback@files:innocallback.dll STDCALL DELAYLOAD';
function  BtnCreate(hParent : hwnd; Left, Top, Width, Height : integer; FileName : PAnsiChar; ShadowWidth : integer; IsCheckBtn : boolean) : hwnd;  external 'BtnCreate@files:botva2.dll STDCALL DELAYLOAD';
procedure BtnSetVisibility(h : hwnd; Value : boolean); external 'BtnSetVisibility@files:botva2.dll STDCALL DELAYLOAD';
procedure BtnSetEvent(h : hwnd; EventID : integer; Event : longword); external 'BtnSetEvent@files:botva2.dll STDCALL DELAYLOAD';
procedure BtnSetEnabled(h : hwnd; Value : boolean); external 'BtnSetEnabled@files:botva2.dll STDCALL DELAYLOAD';
function  BtnGetChecked(h : hwnd) : boolean; external 'BtnGetChecked@files:botva2.dll STDCALL DELAYLOAD';
procedure BtnSetChecked(h : hwnd; Value : boolean); external 'BtnSetChecked@files:botva2.dll STDCALL DELAYLOAD';
procedure BtnSetPosition(h : hwnd; NewLeft, NewTop, NewWidth, NewHeight : integer);  external 'BtnSetPosition@files:botva2.dll STDCALL DELAYLOAD';
function  SetWindowLong(h : HWnd; Index : integer; NewLong : longint) : longint; external 'SetWindowLongA@user32.dll STDCALL';
function  PBCallBack(P : TPBProc; ParamCount : integer) : longword; external 'wrapcallback@files:innocallback.dll STDCALL DELAYLOAD';
function  CallWindowProc(lpPrevWndFunc : longint; h : hwnd; Msg : uint; wParam, lParam : longint) : longint; external 'CallWindowProcA@user32.dll STDCALL';
procedure ImgSetVisiblePart(img : longint; NewLeft, NewTop, NewWidth, NewHeight : integer); external 'ImgSetVisiblePart@files:botva2.dll STDCALL DELAYLOAD';
function  ReleaseCapture() : longint; external 'ReleaseCapture@user32.dll STDCALL';
function  CreateRoundRectRgn(p1, p2, p3, p4, p5, p6 : integer) : THandle; external 'CreateRoundRectRgn@gdi32.dll STDCALL';
function  SetWindowRgn(h : hwnd; hRgn : THandle; bRedraw : boolean) : integer; external 'SetWindowRgn@user32.dll STDCALL';

procedure MyBtnSetEvent(h : hwnd; Callback : TBtnEventProc);
begin
	BtnSetEvent(h, 1, WrapBtnCallback(Callback, 1));
end;

function ProgressbarProcedure(h : hWnd; Msg, wParam, lParam : longint) : longint;
var
  percent, value, range : EXTendED;
  barWidth : integer;
begin
  Result := CallWindowProc(PBOldProc, h, Msg, wParam, lParam);
  if ((Msg = $402) and (WizardForm.ProgressGauge.Position > WizardForm.ProgressGauge.Min)) then
  begin
    value := WizardForm.ProgressGauge.Position - WizardForm.ProgressGauge.Min;
    range := WizardForm.ProgressGauge.Max - WizardForm.ProgressGauge.Min;
    percent := (value * 100) / range;
    m_labelInstallProgress.Caption := Format('%d', [Round(percent)]) + '%';
    barWidth := Round((560 * percent) / 100);
    ImgSetPosition(m_progressbarForeground, 20, 374, barWidth, 6);
    ImgSetVisiblePart(m_progressbarForeground, 0, 0, barWidth, 6);
    ImgApplyChanges(WizardForm.Handle);
  end;
end;

procedure on_mouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : integer);
begin
  ReleaseCapture();
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, $F012, 0);
end;

procedure on_editTargetPath_changed(Sender : TObject);
begin
  WizardForm.DirEdit.Text := m_editTargetPath.Text;
end;

procedure on_btnExit_clicked(hBtn : hwnd);
begin
  WizardForm.CancelButton.OnClick(WizardForm);
end;

procedure on_btnMinimize_clicked(hBtn : hwnd);
begin
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, 61472, 0);
end;

procedure on_btnInstall_clicked(hBtn : hwnd);
begin
  WizardForm.NextButton.OnClick(WizardForm);
end;

procedure on_btnBrowse_clicked(hBtn : hwnd);
begin
  WizardForm.DirBrowseButton.OnClick(WizardForm);
  m_editTargetPath.Text := WizardForm.DirEdit.Text;
end;

procedure on_btnCustomizeSetup_clicked(hBtn : hwnd);
begin
  if m_editTargetPath.Visible then
  begin
    m_editTargetPath.Hide();
    m_labelProductAlreadyInstalled.Hide();
    BtnSetVisibility(m_btnBrowse, false);
    WizardForm.Height := WIZARDFORM_HEIGHT_NORMAL;
    ImgSetVisibility(m_imageCustomizeBackground, false);
    ImgSetVisibility(m_imageFormBackground, true);
    BtnSetVisibility(m_btnCustomizeSetup, true);
    BtnSetVisibility(m_btnUncustomizeSetup, false);
  end else
  begin
    WizardForm.Height := WIZARDFORM_HEIGHT_MORE;
    ImgSetVisibility(m_imageCustomizeBackground, true);
    ImgSetVisibility(m_imageFormBackground, false);
    m_editTargetPath.Show();
    BtnSetVisibility(m_btnBrowse, true);
    BtnSetVisibility(m_btnCustomizeSetup, false);
    BtnSetVisibility(m_btnUncustomizeSetup, true);
    
    if m_isProductInstalledBefore then
    begin
      m_editTargetPath.Enabled := false;
      BtnSetEnabled(m_btnBrowse, false);
      m_labelProductAlreadyInstalled.Show();
    end;
  end;
  ImgApplyChanges(WizardForm.Handle);
end;

procedure on_checkboxStartup_clicked(hBtn : hwnd);
begin
  m_shouldStartupOnSetupFinished := BtnGetChecked(m_checkboxStartup);
end;

procedure extractTempFiles();
begin
  ExtractTemporaryFile('button_customize_setup.png');
  ExtractTemporaryFile('button_uncustomize_setup.png');
  ExtractTemporaryFile('button_finish.png');
  ExtractTemporaryFile('button_install.png');
  ExtractTemporaryFile('background_welcome.png');
  ExtractTemporaryFile('background_welcome_more.png');
  ExtractTemporaryFile('button_browse.png');
  ExtractTemporaryFile('progressbar_background.png');
  ExtractTemporaryFile('progressbar_foreground.png');
  ExtractTemporaryFile('background_installing.png');
  ExtractTemporaryFile('background_finish.png');
  ExtractTemporaryFile('button_close.png');
  ExtractTemporaryFile('button_minimize.png');
  ExtractTemporaryFile('checkbox_startup.png');
end;

function IsAppRunning(const AppName : string) : Boolean;
begin
  Result := (FindWindowByWindowName(AppName) <> 0);
end;

function IsAppInstalled() : Boolean;
begin
  Result := RegKeyExists(HKLM64, 'SOFTWARE\{#MyCompanyName}\{#MyAppName}');
end;

function InitializeSetup(): Boolean;
begin
  m_isProductInstalledBefore := false;
  Result := true;
  if IsAppRunning('{#MyAppWindowName}') then
  begin
    m_isProductInstalledBefore := TRUE;
    Msgbox('{#MyAppRunningInstallTips}', mbInformation, MB_OK);
    Result := false;
  end;
  if Result and IsAppInstalled() then
  begin
    m_isProductInstalledBefore := TRUE;
    Result := (Msgbox({#MyAppReinstallTips}, mbConfirmation, MB_YESNO) = IDYES);
  end;
end;

function InitializeUninstall(): Boolean;
begin
  Result:= true;
  if  IsAppRunning('{#MyAppWindowName}') then
  begin
    MsgBox('{#MyAppRunningUninstallTips}', mbInformation, MB_OK)
    Result:= false;
  end;
end;

procedure InitializeWizard();
var
  windowTitle,labelToMove : TLabel;
begin
  m_isInitialized := true;
  m_isReleased := false;
  m_shouldStartupOnSetupFinished := true;
  extractTempFiles();
  WizardForm.InnerNotebook.Hide();
  WizardForm.OuterNotebook.Hide();
  WizardForm.Bevel.Hide();
  with WizardForm do
  begin
    BorderStyle := bsNone;
    Width := 600;
    Height := 400;
    Position := poDesktopCenter;
    Color := clWhite;
    NextButton.Width := 0;
    CancelButton.Width := 0;
    BackButton.Visible := false;
  end;
  windowTitle := TLabel.Create(WizardForm);
  with windowTitle do
  begin
    Parent := WizardForm;
    AutoSize := false;
    Left := 10;
    Top := 5;
    Width := 400;
    Height := 20;
    Font.Name := 'Microsoft YaHei';
    Font.Size := 9;
    Font.Color := clWhite;
    Caption := '{#MyAppName} V{#MyAppVersion} {#MyAppSetupTitleTail}';
    Transparent := true;
    OnMouseDown := @on_mouseDown;
  end;
  labelToMove := TLabel.Create(WizardForm);
  with labelToMove do
  begin
    Parent := WizardForm;
    AutoSize := false;
    Left := 0;
    Top := 0;
    Width := WizardForm.Width;
    Height := WizardForm.Height;
    Caption := '';
    Transparent := true;
    OnMouseDown := @on_mouseDown;
  end;
  
  m_btnExit := BtnCreate(WizardForm.Handle, 570, 0, 30, 30, ExpandConstant('{tmp}\button_close.png'), 0, false);
  MyBtnSetEvent(m_btnExit, @on_btnExit_clicked);
  
  m_btnMinimize := BtnCreate(WizardForm.Handle, 540, 0, 30, 30, ExpandConstant('{tmp}\button_minimize.png'), 0, false);
  MyBtnSetEvent(m_btnMinimize, @on_btnMinimize_clicked);
  
  ImgApplyChanges(WizardForm.Handle);
end;

procedure CurPageChanged(CurPageID : integer);
begin
  if (CurPageID = wpWelcome) then
  begin
    m_btnInstall := BtnCreate(WizardForm.Handle, 211, 305, 178, 43, ExpandConstant('{tmp}\button_install.png'), 0, false);
    MyBtnSetEvent(m_btnInstall, @on_btnInstall_clicked);
    
    m_btnCustomizeSetup := BtnCreate(WizardForm.Handle, 511, 374, 78, 16, ExpandConstant('{tmp}\button_customize_setup.png'), 0, false);
    MyBtnSetEvent(m_btnCustomizeSetup, @on_btnCustomizeSetup_clicked);
    
    m_btnUncustomizeSetup := BtnCreate(WizardForm.Handle, 511, 374, 78, 16, ExpandConstant('{tmp}\button_uncustomize_setup.png'), 0, false);
    MyBtnSetEvent(m_btnUncustomizeSetup, @on_btnCustomizeSetup_clicked);
    BtnSetVisibility(m_btnUncustomizeSetup, false);
    
    m_editTargetPath:= TEdit.Create(WizardForm);
    with m_editTargetPath do
    begin
      Parent := WizardForm;
      Text := WizardForm.DirEdit.Text;
      Font.Name := 'Microsoft YaHei';
      Font.Size := 9;
      BorderStyle := bsNone;
      SetBounds(91,423,402,20);
      OnChange := @on_editTargetPath_changed;
      Color := clWhite;
      TabStop := false;
    end;
    m_editTargetPath.Hide();
    
    m_labelProductAlreadyInstalled := TLabel.Create(WizardForm);
    with m_labelProductAlreadyInstalled do
    begin
      Parent := WizardForm;
      AutoSize := false;
      Left := 85;
      Top := 449;
      Width := 200;
      Height := 20;
      Font.Name := 'Microsoft YaHei';
      Font.Size := 9;
      Font.Color := clGray;
      Caption := '{#MyAppDirChangeEnableTips}';
      Transparent := true;
      OnMouseDown := @on_mouseDown;
    end;
    m_labelProductAlreadyInstalled.Hide();
	
    PBOldProc := SetWindowLong(WizardForm.ProgressGauge.Handle, -4, PBCallBack(@ProgressbarProcedure, 4));
    
    m_btnBrowse := BtnCreate(WizardForm.Handle, 506, 420, 75, 24, ExpandConstant('{tmp}\button_browse.png'), 0, false);
    MyBtnSetEvent(m_btnBrowse, @on_btnBrowse_clicked);
    BtnSetVisibility(m_btnBrowse, false);
    
    m_imageFormBackground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_welcome.png'), 0, 0, WIZARDFORM_WIDTH_NORMAL, WIZARDFORM_HEIGHT_NORMAL, false, true);
    m_imageCustomizeBackground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_welcome_more.png'), 0, 0, WIZARDFORM_WIDTH_NORMAL, WIZARDFORM_HEIGHT_MORE, false, true);
    ImgSetVisibility(m_imageCustomizeBackground, false);
    WizardForm.Width := WIZARDFORM_WIDTH_NORMAL;
    WizardForm.Height := WIZARDFORM_HEIGHT_NORMAL;
    ImgApplyChanges(WizardForm.Handle);
  end;
  if (CurPageID = wpInstalling) then
  begin
    m_editTargetPath.Hide();
    BtnSetVisibility(m_btnBrowse, false);
    BtnSetVisibility(m_btnCustomizeSetup, false);
    BtnSetVisibility(m_btnUncustomizeSetup, false);
    WizardForm.Height := WIZARDFORM_HEIGHT_NORMAL;
    
    m_labelInstallProgress := TLabel.Create(WizardForm);
    with m_labelInstallProgress do
    begin
      Parent := WizardForm;
      AutoSize := false;
      Left := 547;
      Top := 349;
      Width := 40;
      Height := 30;
      Font.Name := 'Microsoft YaHei';
      Font.Size := 10;
      Font.Color := clBlack;
      Caption := '';
      Transparent := true;
      Alignment := taRightJustify;
      OnMouseDown := @on_mouseDown;
    end;
    BtnSetEnabled(m_btnExit, false);
    m_imageFormBackground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_installing.png'), 0, 0, WIZARDFORM_WIDTH_NORMAL, WIZARDFORM_HEIGHT_NORMAL, false, true);
    m_progressbarBackground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\progressbar_background.png'), 20, 374, 560, 6, false, true);
    m_progressbarForeground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\progressbar_foreground.png'), 20, 374, 0, 0, true, true);
    BtnSetVisibility(m_btnInstall, false);
    ImgApplyChanges(WizardForm.Handle);
  end;
  if (CurPageID = wpFinished) then
  begin
    ImgSetVisibility(m_imageFormBackground, false);
    ImgSetVisibility(m_progressbarBackground, false);
    ImgSetVisibility(m_progressbarForeground, false);
    m_labelInstallProgress.Hide();
    BtnSetEnabled(m_btnExit, true);
    
    m_checkboxStartup := BtnCreate(WizardForm.Handle, 248, 280, 110, 17, ExpandConstant('{tmp}\checkbox_startup.png'), 0, True);
    MyBtnSetEvent(m_checkboxStartup, @on_checkboxStartup_clicked);
    BtnSetChecked(m_checkboxStartup, True);
    
    m_btnInstall := BtnCreate(WizardForm.Handle, 214, 315, 178, 43, ExpandConstant('{tmp}\button_finish.png'), 0, false);
    
    m_imageFormBackground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_finish.png'), 0, 0, WIZARDFORM_WIDTH_NORMAL, WIZARDFORM_HEIGHT_NORMAL, false, true);
    MyBtnSetEvent(m_btnInstall, @on_btnInstall_clicked);
    MyBtnSetEvent(m_btnExit, @on_btnInstall_clicked);
    
    ImgApplyChanges(m_btnInstall);
    ImgApplyChanges(WizardForm.Handle);
  end;
end;

function ShouldSkipPage(PageID : integer) : boolean;
begin
  if (PageID = wpLicense) then Result := true;
  if (PageID = wpPassword) then Result := true;
  if (PageID = wpInfoBefore) then Result := true;
  if (PageID = wpUserInfo) then Result := true;
  if (PageID = wpSelectDir) then Result := true;
  if (PageID = wpSelectComponents) then Result := true;
  if (PageID = wpSelectProgramGroup) then Result := true;
  if (PageID = wpSelectTasks) then Result := true;
  if (PageID = wpReady) then Result := true;
  if (PageID = wpPreparing) then Result := true;
  if (PageID = wpInfoAfter) then Result := true;
end;

procedure releaseInstallerAfterInit();
begin
  WizardForm.Release();
end;

procedure releaseInstaller();
begin
  gdipShutdown();
  releaseInstallerAfterInit
end;

procedure CancelButtonClick(CurPageID : integer; var Cancel, Confirm: boolean);
begin
  Cancel := false;
  Confirm := false;
  if MsgBox('{#MyAppExitSetupTips}', mbInformation, MB_YESNO) = IDYES then
  begin
    releaseInstaller();
    Cancel := true;
    m_isReleased := true;
  end;
end;

procedure DeinitializeSetup();
begin
  if (m_isReleased = false) then
  begin
    gdipShutdown();
    if m_isInitialized then
    begin
      releaseInstallerAfterInit();
    end;
  end;
end;

procedure CurStepChanged(CurStep : TSetupStep);
var
  ErrorCode : integer;
begin
  if (CurStep = ssDone) then
  begin
    if m_shouldStartupOnSetupFinished then
    begin
      if not ShellExec('', ExpandConstant('{app}\{#MyAppExeName}'), '', '', SW_SHOW, ewNoWait, ErrorCode) then
      begin
        MsgBox('{#MyAppStartupFailedTips}', mbError, MB_OK);
      end;
    end;
    m_isReleased := true;
    releaseInstaller();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usDone then
  begin
    DelTree(ExpandConstant('{app}'), True, True, True);
  end;
end;

