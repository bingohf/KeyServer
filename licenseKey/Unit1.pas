unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, encddecd;

type
  TForm1 = class(TForm)
    edtKey: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Label2: TLabel;
    btnEncrypt: TButton;
    Label3: TLabel;
    edtString: TEdit;
    Button1: TButton;
    procedure btnEncryptClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses ElAES;

{$R *.dfm}

procedure TForm1.btnEncryptClick(Sender: TObject);
var
  sDest:TmemoryStream;
  sBase64,sStream :TStringStream;
  key:TAESKey256;
  keyString:String;

begin
  keyString :=  'qwer1234_' + edtKey.Text;
  sStream := TStringStream.Create(edtString.Text);
  sDest  := TMemoryStream.Create;
  sBase64 := TStringStream.Create('');
  FillChar(key, sizeOf(key), 0);
  Move(PChar(keyString)^, key, length(keyString));
  sStream.Position := 0;
  EncryptAESStreamECB(sStream, sStream.Size, key, sDest);
  sDest.Position := 0;
  EncodeStream(sDest, sBase64);
  Memo1.Lines.Add(sBase64.DataString);

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  sSource:TmemoryStream;
  sBase64,sDest :TStringStream;
  key:TAESKey256;
  keyString:String;
begin
  keyString :=  'qwer1234_' + edtKey.Text;
  FillChar(key, sizeOf(key), 0);
  Move(PChar(keyString)^, key, length(keyString));

  sBase64 := TStringStream.Create(edtString.Text);
  sBase64.Position := 0;
  sSource  := TMemoryStream.Create;
  DecodeStream(sBase64, sSource);
  sSource.Position := 0;
  sDest := TStringStream.Create('');
  DecryptAESStreamECB(sSource, sSource.Size, key, sDest);
  Memo1.Lines.Add(sDest.DataString);

end;

end.
