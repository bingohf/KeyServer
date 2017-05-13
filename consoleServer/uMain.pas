unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ScktComp, uClientManager, uClient,Forms, ExtCtrls, IdBaseComponent,
  IdComponent, IdTCPServer, IdCustomHTTPServer, IdHTTPServer,TConfiguratorUnit;

type
  TscMain = class(TService,INotifyChange)
    clientSocket: TServerSocket;
    adminSocket: TServerSocket;
    Timer1: TTimer;
    IdHTTPServer1: TIdHTTPServer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
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

uses ElAES;

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
  TConfiguratorUnit.doBasicConfiguration;
  TClientManager.Create(scMain.clientSocket,scMain.adminSocket,IdHTTPServer1, scMain);
end;

procedure TscMain.Timer1Timer(Sender: TObject);
begin
  if now > ClientManager.ExpiryDate then
    ClientManager.DisconnectAll;
end;

procedure TscMain.IdHTTPServer1CommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  //
end;

end.
