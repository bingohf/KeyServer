unit uFrmConnect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmConnect = class(TForm)
    btnConnect: TButton;
    lbServer: TLabel;
    procedure btnConnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    function ShowModal: Integer; override;
  end;

var
  frmConnect: TfrmConnect;

implementation

uses uClientSocket, Math;

{$R *.dfm}

procedure TfrmConnect.btnConnectClick(Sender: TObject);
begin
  FrmClientSocket.Connect;
end;

function TfrmConnect.ShowModal: Integer;
begin

  lbServer.Caption := Format('Server=%s:%d',  [FrmClientSocket.ClientSocket.Host,
  FrmClientSocket.ClientSocket.Port
  ] );
  result :=  inherited ShowModal;
end;

procedure TfrmConnect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FrmClientSocket.ClientSocket.Active then
    Action := caHide
  else
    Action := caNone;
end;

end.
