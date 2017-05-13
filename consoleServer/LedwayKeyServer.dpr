program LedwayKeyServer;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  uClient in 'uClient.pas',
  uClientManager in 'uClientManager.pas',
  ElAES in 'ElAES.pas',
  TConfiguratorUnit in '..\log4delphi-0.8\src\delphi\TConfiguratorUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;

  Application.CreateForm(TMainForm, MainForm);
  TClientManager.Create(MainForm.clientSocket,MainForm.adminSocket,MainForm.IdHTTPServer1, MainForm);
  Application.Run;
end.
