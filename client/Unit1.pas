unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls,uClientSocket, ExtCtrls,PerlRegEx,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TMyMSG = record
    msg   : Cardinal;
    msgText: string;  //描述消息的类型
  end;
  TMyThread = class(TThread)
  protected
    procedure Execute; override;
  public
    ProEvent:TThreadMethod;
  end;
  TForm1 = class(TForm,ILicenseChange)
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    Button1: TButton;
    Timer1: TTimer;
    Button3: TButton;
    IdHTTP1: TIdHTTP;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations
    }
    procedure AccepterMsg2000(var msg: TMyMSG); message 2000;
        procedure StatusChange(msg:String);
    procedure ReceiveMessage(msg:String);
    procedure SetLevel(level:string);
    procedure showMsg;
  public
    { Public declarations }
    procedure defaultHandler(var message); override;
  end;

var
  Form1: TForm1;

implementation





{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
begin
  FrmClientSocket.AddListener(self);
end;

procedure TForm1.ReceiveMessage(msg: String);
begin
  StatusBar1.Panels[1].Text := msg;
end;

procedure TForm1.StatusChange(msg: String);
begin
   StatusBar1.Panels[0].Text := msg;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  FrmClientSocket.Show;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 Caption := caption + '.';
end;

procedure TForm1.defaultHandler(var message);
begin
  inherited;

end;

procedure TForm1.AccepterMsg2000(var msg: TMyMSG);
begin

end;







{ TMyThread }

procedure TMyThread.Execute;
begin
  inherited;
  Synchronize(ProEvent);
end;

procedure TForm1.showMsg;
begin
  showmessage('1');
end;

procedure TForm1.SetLevel(level: string);
begin

end;

procedure TForm1.Button3Click(Sender: TObject);
var
FRegEx :TPerlRegEx;
begin
   FRegEx := TPerlRegEx.Create;
   FRegEx.Options := [preCaseLess];
   FRegEx.RegEx := '\[\S*\]';
end;

procedure TForm1.Button2Click(Sender: TObject);
var
RespData: TStringStream;
begin
  RespData := TStringStream.Create('');
  IdHTTP1.Get('http://localhost:7300/?Key=123',RespData);
  showmessage(respData.DataString);
end;

end.
