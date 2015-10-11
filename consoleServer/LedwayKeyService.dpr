program LedwayKeyService;

uses
  SvcMgr,
  uMain in 'uMain.pas' {scMain: TService},
  ElAES in 'ElAES.pas',
  uClient in 'uClient.pas',
  uClientManager in 'uClientManager.pas',
  uLkJSON in 'uLkJSON.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TscMain, scMain);
  Application.Run;
end.
