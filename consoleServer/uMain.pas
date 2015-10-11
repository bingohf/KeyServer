unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ScktComp, uClientManager, uClient,Forms, ExtCtrls;

type
  TscMain = class(TService,INotifyChange)
    clientSocket: TServerSocket;
    adminSocket: TServerSocket;
    Timer1: TTimer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
        procedure clientAdd(client:TClient; clientList:TStringList);
    procedure messageAdd(msg:String);
    procedure removeClient(Client:TClient);
    procedure LicenseChange;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  scMain: TscMain;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  scMain.Controller(CtrlCode);
end;

procedure TscMain.clientAdd(client: TClient; clientList: TStringList);
begin

end;

function TscMain.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TscMain.LicenseChange;
begin

end;

procedure TscMain.messageAdd(msg: String);
begin

end;

procedure TscMain.removeClient(Client: TClient);
begin

end;

procedure TscMain.ServiceStart(Sender: TService; var Started: Boolean);
begin
  TClientManager.Create(scMain.clientSocket,scMain.adminSocket,scMain);
end;

procedure TscMain.Timer1Timer(Sender: TObject);
begin
//  if now > ClientManager.ExpiryDate then
    ClientManager.DisconnectAll;
end;

end.