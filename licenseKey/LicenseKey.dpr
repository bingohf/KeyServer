program LicenseKey;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  ElAES in 'ElAES.pas',
  EncdDecd in 'c:\program files (x86)\borland\delphi7\source\Internet\encddecd.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
