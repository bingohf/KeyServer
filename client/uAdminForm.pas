unit uAdminForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, SConnect, ScktComp, StdCtrls,iniFiles;

type
  TForm1 = class(TForm)
    ClientSocket1: TClientSocket;
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Connecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  inifile:TIniFile;
  liceseServer:String;
begin
  inifile := TIniFile.Create(GetCurrentDir +'\winup.ini');
  liceseServer := inifile.ReadString('ApControl','LicenseServer','');
  if liceseServer <>'' then
  begin
    ClientSocket1.Host := liceseServer;
  end;
  inifile.free;
  Caption := ClientSocket1.Host +':' + inttostr(ClientSocket1.port);
  ClientSocket1.Open;
end;

procedure TForm1.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Button1.Enabled := false;
end;

procedure TForm1.ClientSocket1Connecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
 Button1.Enabled := false;
end;

procedure TForm1.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Button1.Enabled := true;
end;

procedure TForm1.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
 Button1.Enabled := false;
end;

procedure TForm1.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Memo1.Lines.Add(Socket.ReceiveText);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ClientSocket1.Socket.SendText(Edit1.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ClientSocket1.Open;
end;

end.
