unit uClient;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls;

type
  TClient = class
  private
    FSocket :TCustomWinSocket;
    FHostName:String;
    FIP:String;
    FHandleID:String;
    FMessage:TStringList;
    FIsAdmin: boolean;
    FUserName: String;
    FLoginDate: TDateTime;

    function GetHostName: String;
    function GetIP: String;
    function GetHandleID: String;
    function GetMsgText: String;
  published
    procedure SetUserName(const Value: String);
    procedure Close(id:String);
  public
    constructor Create(socket:TCustomWinSocket);

    property IP:String read GetIP;
    property HandleID:String read GetHandleID;
    property HostName :String read GetHostName;
    property MsgText :String read GetMsgText;
    property Socket:TCustomWinSocket read FSocket;
    property UserName:String read FUserName write SetUserName;
    property IsAdmin:boolean read FIsAdmin write FIsAdmin;
    property LoginDate :TDateTime read FLoginDate write FLoginDate;
    procedure addMessage(msg:String);

  end;
implementation

uses uClientManager;

{ TClient }

procedure TClient.addMessage(msg: String);
begin
  FMessage.Add(msg);
end;

procedure TClient.Close(id:String);
begin
  ClientManager.CloseClient(id);
end;

constructor TClient.Create(socket:TCustomWinSocket);
begin
  FSocket := socket;
  FHostName := Socket.RemoteHost;
  FIP := socket.RemoteAddress;
  FHandleID := inttostr(socket.SocketHandle);
  FMessage := TStringList.Create;
end;

function TClient.GetHandleID: String;
begin
   result := FHandleID;
end;

function TClient.GetHostName: String;
begin
  Result := FHostName;
end;

function TClient.GetIP: String;
begin
  result := FIP;
end;

function TClient.GetMsgText: String;
begin
  Result := FMessage.Text;
end;

procedure TClient.SetUserName(const Value: String);
begin
  FUserName := Value;
  if Value ='Admin' then
    FIsAdmin := true;
  FLoginDate := now;
   ClientManager.NotifyClientList;
end;

end.
