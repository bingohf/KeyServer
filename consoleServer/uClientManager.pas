unit uClientManager;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls,uClient,JclSysInfo,iniFiles,ElAES,
  encddecd, ulkJson,PerlRegEx;

type
  TMsgProcedure = procedure(msg:String) of object;
  TMsgFunction = function(msg:String):String of object;
  INotifyChange = interface
    procedure clientAdd(client:TClient; clientList:TStringList);
    procedure messageAdd(msg:String);
    procedure removeClient(Client:TClient);
    procedure LicenseChange;
  end;
  TClientManager = class
  private
    FServerSocket,FAdminSocket :TServerSocket;
    FClientList:TStringList;
    FLicenseCount :integer;
    Fcallback :INotifyChange;
    FCurrentClientId:integer;
    FExpiryDate: TdateTime;
    FRegEx :TPerlRegEx;
    FLicenseError:String;
    function GetCurrentClient:TClient;
    procedure AddClient(Client :TClient);
    procedure RemoveClient(client:TClient);
    procedure ServerSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocketClientRead(Sender: TObject;
                Socket: TCustomWinSocket);
    procedure ServerSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocketClientError(Sender: TObject;  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;  var ErrorCode: Integer);

    procedure AdminSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure AdminSocketClientRead(Sender: TObject;
                Socket: TCustomWinSocket);
    procedure AdminSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure AdminSocketClientError(Sender: TObject;  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;  var ErrorCode: Integer);
    procedure LoadLicense;


    function DecryptLedwayString(source:String):String;
    procedure NotifyAll(msg:String);
    function GetAllclientJson:String;

  public
    procedure NotifyClientList;
    constructor Create(clientServer,adminServer:TServerSocket; callBack:INotifyChange);
    procedure Disconnect(Client:TClient);
    procedure DisconnectAll();
    function GetClient(id:integer):TClient;
    property LicenseCount:integer read FLicenseCount;
    property ExpiryDate :TdateTime read FExpiryDate;
    procedure SetCurrentClient(id:integer);
    procedure CloseCurrent();
  published
    procedure CloseClient(id:string);
    function SetLicenseCount(s:String):String;
    function SetExpiredDate(s:String):String;

  end;

var
  ClientManager:TClientManager;
implementation

{ TClientManager }


procedure TClientManager.AddClient(Client: TClient);
var
  index:integer;
begin
  index := FClientList.IndexOf(client.HandleID);
  if (index > -1) then
  begin
    FClientList.Objects[index].Free;
    FClientList.Delete(index);
  end;
  FClientList.AddObject(client.HandleID, client);
  NotifyAll('License:' + inttostr(FClientList.count) + '/' +inttostr(FLicenseCount));
  if (now +15 > FExpiryDate) then
     NotifyAll('[SetMessageLevel]:W');

  NotifyClientList;
end;

procedure TClientManager.CloseCurrent;
var
  client:Tclient;
  i:integer;
begin
  client :=GetCurrentClient;
  if client <> nil then
  begin
    for i := 0 to FServerSocket.Socket.ActiveConnections -1 do
    begin
      if FServerSocket.Socket.Connections[i].SocketHandle = strtoint(client.HandleID) then
      begin
        FServerSocket.Socket.Connections[i].Close;
      end;
    end;
  end;
end;

constructor TClientManager.Create(clientServer,adminServer: TServerSocket; callBack:INotifyChange);
begin
  Fcallback := callback;
  ClientManager := self;
  FLicenseCount := 0;
  LoadLicense();
  FRegEx := TPerlRegEx.Create;
  FRegEx.RegEx := '\[\w+\]:';
  FRegEx.Options := [preCaseLess];


  FServerSocket := clientServer;
  FClientList := TStringList.Create;
  FServerSocket.OnClientConnect := ServerSocketClientConnect;
  FServerSocket.OnClientRead := ServerSocketClientRead;
  FServerSocket.OnClientDisconnect := ServerSocketClientDisconnect;
  FServerSocket.OnClientError := ServerSocketClientError;

  FServerSocket.Open;

  FAdminSocket := AdminServer;
  FAdminSocket.OnClientConnect := AdminSocketClientConnect;
  FAdminSocket.OnClientRead := AdminSocketClientRead;
  FAdminSocket.OnClientDisconnect := AdminSocketClientDisconnect;
  FAdminSocket.OnClientError := AdminSocketClientError;
  FAdminSocket.Open;



end;

procedure TClientManager.Disconnect(Client: TClient);
begin

end;

function TClientManager.GetClient(id: integer): TClient;
var
  sid:String;
  index:integer;
begin
  sid := inttostr(id);
  index  := FClientList.IndexOf(sid);
  if (index >-1) then
    result := TClient(FClientList.Objects[index])
  else
    result := nil;
end;

function TClientManager.GetCurrentClient: TClient;
begin
  Result := GetClient(FCurrentClientId);
end;

procedure TClientManager.RemoveClient(client: TClient);
var
  i:integer;
begin
   Fcallback.removeClient(client);
  i := FClientList.IndexOf(client.HandleID);
  FClientList.Objects[i].Free;
  FClientList.Delete(i);
  NotifyAll('License:' + inttostr(FClientList.count) + '/' +inttostr(FLicenseCount));
  NotifyClientList;
end;

procedure TClientManager.ServerSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  client:TClient;
begin

  Socket.SendText(#13'[SetServerInfo]:' + 'DeviceID=' +GetVolumeSerialNumber('C') +';LicenseCount=' +  inttostr(FLicenseCount) +';ExpiredDate=' + DateTimeToStr(FExpiryDate));
  if FLicenseError <> '' then
  begin
     Socket.SendText(#13'[SetRefuseMsg]:' + FLicenseError);
     Socket.Disconnect(Socket.SocketHandle);
     exit;
  end;
  if (Now > FExpiryDate)  then
  begin
     Socket.SendText(#13'[SetRefuseMsg]:' + 'Your license is expired(' + DateToStr(FExpiryDate) +')');
     Socket.Disconnect(Socket.SocketHandle);
    exit;
  end;
  if FLicenseCount <= FClientList.Count then
  begin
     Socket.SendText(#13'[SetRefuseMsg]:' + 'Your license count is not enough (' + inttostr(FLicenseCount) +')');
     Socket.Disconnect(Socket.SocketHandle);

    exit;
  end;
  if (now +15 > FExpiryDate) then
     NotifyAll('[showMsg]:Ledway Key Server is about to expire (' + DateToStr(FExpiryDate) +')');
  Socket.SendText(#13'[SetConnectStatus]:OK');
  client := TClient.Create(socket);
  AddClient(client);
  Fcallback.clientAdd(client, FClientList);


end;

procedure TClientManager.ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  client:TClient;
begin
  client := GetClient(socket.SocketHandle);
  if (client <> nil) then
    RemoveClient(client);


end;

procedure TClientManager.ServerSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  client:TClient;
  receiveText:string;

var i:integer;
  action:String;
  stringList:TStringList;
  msg:string;
  param:String;
  m:Tmethod;
begin
  client := GetClient(socket.SocketHandle);
  stringList := TStringList.create;
  stringList.Text := Socket.ReceiveText;
  for i := 0 to stringList.Count -1 do
  begin
    msg := stringList[i];
    if trim(msg) = '' then
      Continue;
    FRegEx.Subject := msg;
    if FRegEx.Match then
    begin
      action := FRegEx.MatchedText;
      param := copy(msg,length(action) +1,length(msg) - length(action));
      action :=  copy(action,2, length(action)-3);
      m.Code := Client.MethodAddress(action);
      m.Data := pointer(client);
      TMsgProcedure(m)(param);
    end else
    begin
      client.addMessage(msg);
      if Socket.SocketHandle = FCurrentClientId then
      begin
        FCallback.messageAdd(msg);
      end;
    end;
  end;


end;

procedure TClientManager.SetCurrentClient(id: integer);
begin
   FCurrentClientId := id;
end;

procedure TClientManager.LoadLicense;
var
  iniFile:TIniFile;
  sCount, sExpiredDate:String;
  FSetting : TFormatSettings;

begin
  try
    FExpiryDate := now;
    FLicenseCount := 0;

    FLicenseError := '';
  //   ShowMessage(GetCurrentDir);
    iniFile := TIniFile.Create(ExtractFilePath( Application.ExeName) +'\license.key');
    sCount := iniFile.ReadString('License','Count','');
    sExpiredDate := iniFile.ReadString('License', 'ExpiredDate','');
    if sExpiredDate = '' then
    begin
      FLicenseError := 'No ''ExpiredDate'' in license.key';
      exit;
    end;
    if sCount = '' then
    begin
      FLicenseError := 'No ''Count'' in license.key';
      exit;
    end;
    try
      sExpiredDate :=  DecryptLedwayString(sExpiredDate);
    except
      on E:Exception do
      begin
       FLicenseError := e.message +'(decrypt expired date)';
       exit;
      end;
    end;
//    FSetting := TFormatSettings.Create(LOCALE_USER_DEFAULT);
    ShortDateFormat:='yyyy-MM-dd';
    LongTimeFormat:='hh:mm:ss';
    DateSeparator:='-';
    TimeSeparator:=':';
    FExpiryDate := StrToDateTime(sExpiredDate);
    try
      FLicenseCount := strtoint(DecryptLedwayString(sCount));
    except
      on E:Exception do
      begin
        FLicenseError := e.message +'(decrypt count)';
        exit;
      end;
    end;
  finally
    iniFile.Free;
  end;
  Fcallback.LicenseChange;
end;

function TClientManager.DecryptLedwayString(source: String): String;
var
    sSource:TmemoryStream;
  sBase64,sDest :TStringStream;
  key:TAESKey256;
  keyString:String;
begin
  try
    keyString := 'qwer1234_' + GetVolumeSerialNumber('C');
    sSource  := TMemoryStream.Create;
    sDest := TStringStream.Create('');
    FillChar(key, sizeOf(key), 0);
    Move(PChar(keyString)^, key, length(keyString));
    sBase64 := TStringStream.Create(source);
    sBase64.Position := 0;
    DecodeStream(sBase64, sSource);
    sSource.Position := 0;
    DecryptAESStreamECB(sSource, sSource.Size, key, sDest);
    Result := sDest.DataString;
  finally
    sSource.Free;
    sBase64.Free;
    sDest.Free;
  end;

end;

procedure TClientManager.NotifyAll(msg: String);
var
  sid:String;
  i:integer;
begin
  for i :=0 to FServerSocket.Socket.ActiveConnections -1 do
  begin
    FServerSocket.Socket.Connections[i].SendText(#13 + msg);
  end;
end;

procedure TClientManager.ServerSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
var
  client:TClient;
begin
  client := GetClient(socket.SocketHandle);
  if (client <> nil) then
    RemoveClient(client);
  ErrorCode := 0;
end;

function TClientManager.GetAllclientJson: String;
var
  i:integer;
  jsList:TlkJSONlist;
  js :TlkJSONobject;
  client:TClient;
begin
  jsList := TlkJSONlist.Create;
  for i := 0 to FClientList.Count -1 do
  begin
    client := TClient(FClientList.Objects[i]);
    js := TlkJSONobject.Create();
    js.add('handleID',client.HandleID);
    js.Add('ip',client.IP);
    js.Add('hostName',client.HostName);
    js.Add('userName',client.UserName);
    if client.LoginDate > 0 then
      js.Add('loginDate', client.LoginDate);
    jsList.Add(js);
  end;
  Result := TlkJSON.GenerateText(jsList);
  jsList.Free;
end;

procedure TClientManager.NotifyClientList;
var
  json:String;
  i:integer;
begin
  json := GetAllclientJson;
  for i :=0 to FClientList.Count -1 do
  begin
    (FClientList.Objects[i] as TClient).Socket.SendText(#13 + '[GetClientList]:' +json);
    //FServerSocket.Socket.Connections[i].SendText(#13 + '[GetClientList]:' +json);
  end;
end;

procedure TClientManager.CloseClient(id: string);
var
  i:integer;
begin
  i := FClientList.IndexOf(id);
  if i >=0 then
  begin
    (FClientList.Objects[i] as TClient).Socket.SendText('[Close]:Winup is closed by admin');
    (FClientList.Objects[i] as TClient).Socket.Close;
  end;
end;

procedure TClientManager.AdminSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
     Socket.SendText('DeviceID=' +GetVolumeSerialNumber('C') +';LicenseCount=' +  inttostr(FLicenseCount) +';ExpiredDate=' + DateTimeToStr(FExpiryDate));
end;

procedure TClientManager.AdminSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin

end;

procedure TClientManager.AdminSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
end;

procedure TClientManager.AdminSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  receiveText:string;

var i:integer;
  action:String;
  stringList:TStringList;
  msg:string;
  param:String;
  m:Tmethod;
  r:String;
begin
  stringList := TStringList.create;
  stringList.Text := Socket.ReceiveText;
  for i := 0 to stringList.Count -1 do
  begin
    msg := stringList[i];
    if trim(msg) = '' then
      Continue;
    FRegEx.Subject := msg;
    if FRegEx.Match then
    begin
      action := FRegEx.MatchedText;
      param := copy(msg,length(action) +1,length(msg) - length(action));
      action :=  copy(action,2, length(action)-3);
      m.Code := self.MethodAddress(action);
      if (m.Code = nil ) then
        continue;
      m.Data := pointer(self);
      r:= TMsgFunction(m)(param);
      Socket.SendText(r);
    end;
  end;
end;
function TClientManager.SetLicenseCount(s: String):String;
var
   iniFile:TIniFile;
begin
   iniFile := TIniFile.Create(ExtractFilePath( Application.ExeName) +'\license.key');
   try
     iniFile.WriteString('License','Count',s);
     LoadLicense;
     if FLicenseError = '' then
       result := 'ok'
     else
       result := FLicenseError;
   finally
     iniFile.Free;
   end;
end;

procedure TClientManager.DisconnectAll;
var
  i:integer;
begin
  for i := 0 to FClientList.Count -1 do
  begin
    TClient(FClientList.Objects[i]).Socket.Close;
  end;

end;

function TClientManager.SetExpiredDate(s: String):String;
var
   iniFile:TIniFile;
begin
   iniFile := TIniFile.Create(ExtractFilePath( Application.ExeName) +'\license.key');
   try
     iniFile.WriteString('License','ExpiredDate',s);
     LoadLicense;
     if FLicenseError = '' then
       result := 'ok'
     else
       result := FLicenseError;
   finally
     iniFile.Free;
   end;
end;

end.
