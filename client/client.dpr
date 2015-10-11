program client;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uClientSocket in 'uClientSocket.pas',
  uFrmConnect in 'uFrmConnect.pas' {frmConnect},
  ExtCtrls in 'c:\program files (x86)\borland\delphi7\source\vcl\ExtCtrls.pas',
  ScktComp in 'c:\program files (x86)\borland\delphi7\source\vcl\ScktComp.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFrmClientSocket, FrmClientSocket);
  Application.CreateForm(TfrmConnect, frmConnect);
  FrmClientSocket.Connect;
  Application.Run;
end.
