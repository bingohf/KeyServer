unit uFrmConnect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmConnect = class(TForm)
    btnConnect: TButton;
    lbServer: TLabel;
    Button1: TButton;
    lbRefuseMsg: TLabel;
    lbServerInfo: TLabel;
    procedure btnConnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
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


  result :=  inherited ShowModal;
end;

procedure TfrmConnect.Button1Click(Sender: TObject);
var ProcessID:Integer;
    ProcessHandleA:THandle;
    ProcessHandle:THandle;
    Code:Cardinal;
begin
  GetWindowThreadProcessID(Handle, @ProcessID);
  ProcessHandle   := OpenProcess(PROCESS_TERMINATE, FALSE, ProcessId);
  ProcessHandleA  := OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, ProcessId);
  if GetExitCodeProcess(ProcessHandleA,Code)then
    TerminateProcess(ProcessHandle,Code);

end;

procedure TfrmConnect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FrmClientSocket.ClientSocket.Active then
    Action := caHide
  else
    Action := caNone;
end;

end.
