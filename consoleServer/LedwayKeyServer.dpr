program LedwayKeyServer;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  uClient in 'uClient.pas',
  uClientManager in 'uClientManager.pas',
  ElAES in 'ElAES.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  TClientManager.Create(MainForm.clientSocket,MainForm.adminSocket, MainForm);
  Application.Run;
end.