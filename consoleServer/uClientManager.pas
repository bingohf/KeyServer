unit uClientManager;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls,uClient,JclSysInfo,iniFiles,ElAES,
  encddecd, ulkJson,PerlRegEx,IdBaseComponent,  IdComponent, IdTCPServer,
  IdCustomHTTPServer, IdHTTPServer,TLoggerUnit,TLevelUnit,TFileAppenderUnit,
  ExtCtrls,JclHookExcept,JclDebug,TypInfo,db,adodb,dateUtils;

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
    FTimer:TTimer;
    FtimerMsg:String;
    FLock:Boolean;
    FAdoDataSet: TADODataSet;
    FWListCount :integer;
    FWebOpList:TStringList;
    FWebOpTime:TTimer;
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

    procedure Lock;
    procedure RelaseLock;
    function DecryptLedwayString(source:String):String;
    procedure NotifyAll(msg:String);
    function GetAllclientJson:String;
    procedure HttpServerCommandGet(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HttpServerCommandOther(Thread: TIdPeerThread;  const asCommand, asData, asVersion: String);
    procedure OnQueueMessage(Sender:TObject);
     procedure GlobalExcept(Sender: TObject; E: Exception);
     procedure LogException(ExceptObj: TObject; ExceptAddr: Pointer; IsOS: Boolean);
    procedure loadDBWList;
    procedure refreshWList(Sender:TObject);
    function AvaliableLicenseCount :Integer;
    procedure WebOptimerTimer(Sender:TObject);
  public
    procedure NotifyClientList;
    constructor Create(clientServer,adminServer:TServerSocket;httpServer:TIdHTTPServer; callBack:INotifyChange);
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
  logger : TLogger;
  hMutex:HWnd;
implementation

{ TClientManager }

function EncryptStr(str:String):String;
var
  sDest:TmemoryStream;
  sBase64,sStream :TStringStream;
  key:TAESKey256;
  keyString:String;

begin
  keyString :=  'qwer0987_';
  sStream := TStringStream.Create(str);
  sDest  := TMemoryStream.Create;
  sBase64 := TStringStream.Create('');
  FillChar(key, sizeOf(key), 0);
  Move(PChar(keyString)^, key, length(keyString));
  sStream.Position := 0;
  EncryptAESStreamECB(sStream, sStream.Size, key, sDest);
  sDest.Position := 0;
  EncodeStream(sDest, sBase64);
  result := sBase64.DataString;
end;


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
  NotifyAll('License:' + inttostr(FClientList.count + FWListCount + FWebOpList.Count) + '/' +inttostr(FLicenseCount));
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

constructor TClientManager.Create(clientServer,adminServer: TServerSocket;httpServer:TIdHTTPServer; callBack:INotifyChange);
begin
  FWebOpList := TStringList.Create;
//  Application.OnException := GlobalExcept;
  JclAddExceptNotifier(LogException);
 // exit;
 // hMutex :=  CreateMutex(nil,false,nil);
  FLock := false;
  FTimer := TTimer.Create(clientServer.Owner);
  FTimer.Interval := 200;
  FtimerMsg := '';
  FTimer.OnTimer := OnQueueMessage;
  FTimer.Enabled := false;
  FWebOpTime := TTimer.Create(Application);
  FWebOpTime.OnTimer := WebOptimerTimer;
  FWebOpTime.Enabled := true;
  FWebOpTime.Interval := 60000;


  logger := TLogger.getInstance;
  logger.setLevel(TLevelUnit.INFO);
  logger.addAppender(TFileAppender.Create(ExtractFilePath( Application.ExeName) + '\ledwayKeyService.log'));
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
  httpServer.OnCommandGet :=   HttpServerCommandGet;

  loadDBWList();

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
  s:string;
begin
 
  s :=       'remove :' + client.HandleID + ' ' + inttostr(GetCurrentThread);
    logger.Info(s);
   Fcallback.removeClient(client);
  i := FClientList.IndexOf(client.HandleID);
  FClientList.Objects[i].Free;
  FClientList.Delete(i);
  NotifyAll('License:' + inttostr(FClientList.count + FWListCount + FWebOpList.Count) + '/' +inttostr(FLicenseCount));
  NotifyClientList;
    logger.Info(s +  ' done');
end;

procedure TClientManager.ServerSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  client:TClient;
  s:String;
begin
  s := 'connect:' + inttostr(Socket.Handle);
  logger.Info(s);
  try
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
    if FLicenseCount <= (FClientList.Count + FWListCount + FWebOpList.Count) then
    begin
       Socket.SendText(#13'[SetRefuseMsg]:' + 'Your license count is not enough (' + inttostr(FLicenseCount) +')');
       Socket.Disconnect(Socket.SocketHandle);
      exit;
    end;

    client := TClient.Create(socket);
      AddClient(client);
    if (now +15 > FExpiryDate) then
       NotifyAll('[showAlertMsg]:Ledway Key Server is about to expire (' + DateToStr(FExpiryDate) +')');
    Socket.SendText(#13'[SetConnectStatus]:OK');

    Fcallback.clientAdd(client, FClientList);
  except
       Logger.Error('connect');
  end;
  logger.Info(s + ' done');
end;

procedure TClientManager.ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  client:TClient;
  s:String;
  i:integer;
  j:real;
begin
   s :=      'disconnect :' + inttostr( Socket.SocketHandle);
    logger.Info(s);
  try
    client := GetClient(socket.SocketHandle);
    if (client <> nil) then
      RemoveClient(client);

  except
       Logger.Error('disconnect');
  end;

      logger.Info(s  + ' done');
 //ReleaseMutex(hMutex)
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
  try
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
  Except
    logger.Error('read');
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
  c:TClient;
begin
  try

   FtimerMsg := FtimerMsg +#13  + msg;
   FTimer.Enabled := true;
  except
       Logger.Error('Notifyall');

  end;
end;

procedure TClientManager.ServerSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
var
  client:TClient;
  s:String;
  i:integer;
  j :real;
begin
  try
    try
    Socket.Lock;
    s :=   'clienterror :' +     inttostr( Socket.SocketHandle);
    logger.Info( s);
    client := GetClient(socket.SocketHandle);
    if (client <> nil) then
      RemoveClient(client);
    ErrorCode := 0;
    logger.Info( s + ' done') ;
    except
      logger.Error('clienterror');
    end;
  finally
    Socket.Unlock;
  end;

end;

procedure TClientManager.OnQueueMessage(Sender:TObject);
var
i:integer;
c:TClient;
lid:String;
list:TList;
begin
  try
    try
      if FTimerMsg <> '' then
      begin
        list := TList.Create;
        for i := 0 to FclientList.Count -1 do
        begin
          list.Add((FClientList.Objects[i] as TClient).Socket);
        end;
        while list.Count >0 do
        begin
          TCustomWinSocket(list.Items[0]).SendText(FtimerMsg);
          list.Delete(0);
        end;
        list.Free;
      end;
   except
     Logger.Error('OnQueueMessage');

   end;
 finally

   FtimerMsg := '';
   FTimer.Enabled := false;
 end;


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
  NotifyAll('[GetClientList]:' +json);
{  for i :=0 to FClientList.Count -1 do
  begin
    try
      (FClientList.Objects[i] as TClient).Socket.SendText(#13 + '[GetClientList]:' +json);
    except
    end;
    //FServerSocket.Socket.Connections[i].SendText(#13 + '[GetClientList]:' +json);
  end;
  }
end;

procedure TClientManager.CloseClient(id: string);
var
  i:integer;
begin
  i := FClientList.IndexOf(id);
  if i >=0 then
  begin
    try
      (FClientList.Objects[i] as TClient).Socket.SendText('[Close]:Winup is closed by admin');
      (FClientList.Objects[i] as TClient).Socket.Close;
    except
         Logger.Error('closeclient');
    end;
  end;
end;

procedure TClientManager.AdminSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  try
     Socket.SendText('DeviceID=' +GetVolumeSerialNumber('C') +';LicenseCount=' +  inttostr(FLicenseCount) +';ExpiredDate=' + DateTimeToStr(FExpiryDate));
  except
       Logger.Error('admin clientconeect');
  end;
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
      try
        Socket.SendText(r);
      except
           Logger.Error('admin socket');
      end;
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
  while FClientList.Count >0 do
  begin
    TClient(FClientList.Objects[0]).Socket.Close;
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

procedure TClientManager.HttpServerCommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  key:String;
  expiredDate:TDateTime;
begin
  if ARequestInfo.Document ='/' then
  begin
    key := ARequestInfo.Params.Values['Key'];
    AResponseInfo.ContentText := EncryptStr(key);
  end else if (ARequestInfo.Document = '/license') and (ARequestInfo.Command ='POST') then
  begin
     if AvaliableLicenseCount <= 0 then
     begin
       AResponseInfo.ContentText := 'License overflow';
       AResponseInfo.ResponseNo := 401;
     end else
     begin
       expiredDate := incMinute(now, 1);
       FWebOpList.Values[ARequestInfo.FormParams] := FloatToStr(expiredDate);
       AResponseInfo.ContentText := DateTimeToStr(expiredDate);
     end;

  end;

end;
procedure TClientManager.HttpServerCommandOther(Thread: TIdPeerThread;  const asCommand, asData, asVersion: String);
begin
  ShowMessage(asCommand);
end;
procedure TClientManager.Lock;
begin
  while Flock do
  begin
    Application.ProcessMessages;
  end;
  FLock := true;
end;

procedure TClientManager.RelaseLock;
begin
  FLock := false;

end;

procedure TClientManager.GlobalExcept(Sender: TObject; E: Exception);
begin
  logger.Error(e.Message);
end;

procedure TClientManager.LogException(ExceptObj: TObject;
  ExceptAddr: Pointer; IsOS: Boolean);
var
  TmpS: string;
  ModInfo: TJclLocationInfo;
  I: Integer;
  ExceptionHandled: Boolean;
  HandlerLocation: Pointer;
  ExceptFrame: TJclExceptFrame;
  ss:TStringList;
begin
  ss:= TStringList.Create;
  TmpS := 'Exception ' + ExceptObj.ClassName;
  if ExceptObj is Exception then
    TmpS := TmpS + ': ' + Exception(ExceptObj).Message;
  if IsOS then
    TmpS := TmpS + ' (OS Exception)';
  ss.Add(TmpS);
  ModInfo := GetLocationInfo(ExceptAddr);
  ss.Add(Format(
    '  Exception occured at $%p (Module "%s", Procedure "%s", Unit "%s", Line %d)',
    [ModInfo.Address,
     ModInfo.UnitName,
     ModInfo.ProcedureName,
     ModInfo.SourceName,
     ModInfo.LineNumber]));
  if stExceptFrame in JclStackTrackingOptions then
  begin
    ss.Add('  Except frame-dump:');
    I := 0;
    ExceptionHandled := False;
    while (true or not ExceptionHandled) and
      (I < JclLastExceptFrameList.Count) do
    begin
      ExceptFrame := JclLastExceptFrameList.Items[I];
      ExceptionHandled := ExceptFrame.HandlerInfo(ExceptObj, HandlerLocation);
      if (ExceptFrame.FrameKind = efkFinally) or
          (ExceptFrame.FrameKind = efkUnknown) or
          not ExceptionHandled then
        HandlerLocation := ExceptFrame.CodeLocation;
      ModInfo := GetLocationInfo(HandlerLocation);
      TmpS := Format(
        '    Frame at $%p (type: %s',
        [ExceptFrame.FrameLocation,
         GetEnumName(TypeInfo(TExceptFrameKind), Ord(ExceptFrame.FrameKind))]);
      if ExceptionHandled then
        TmpS := TmpS + ', handles exception)'
      else
        TmpS := TmpS + ')';
      ss.Add(TmpS);
      if ExceptionHandled then
        ss.Add(Format(
          '      Handler at $%p',
          [HandlerLocation]))
      else
        ss.Add(Format(
          '      Code at $%p',
          [HandlerLocation]));
      ss.Add(Format(
        '      Module "%s", Procedure "%s", Unit "%s", Line %d',
        [ModInfo.UnitName,
         ModInfo.ProcedureName,
         ModInfo.SourceName,
         ModInfo.LineNumber]));
      Inc(I);
    end;
  end;
  Logger.Error(ss.Text);
  ss.free;
end;
procedure TClientManager.loadDBWList;
var
  iniFile:TIniFile;
  fileName:String;
  connectStr:String;
begin
  fileName := ExtractFilePath( Application.ExeName) +'\wlist.ini';
  if not FileExists(fileName) then
  begin
    exit;
  end;
  iniFile := TIniFile.Create(fileName);
  connectStr := iniFile.ReadString('DB','ConnectString','');
  if connectStr <>'' then
  begin
    FAdoDataSet := TADODataSet.Create(Application);
    FAdoDataSet.ConnectionString := connectStr;
    FAdoDataSet.CommandText := 'select * from ledwaybasic.vw_wlist where active =''Y''';

    with TTimer.Create(Application) do
    begin
      Interval := 60000;
      OnTimer := refreshWList;
      Enabled := true;
    end;
  end;

end;
procedure TClientManager.refreshWList(Sender:TObject);
begin
  FAdoDataSet.Close;
  FAdoDataSet.Open;
  FWListCount := FAdoDataSet.RecordCount;
  FAdoDataSet.Close;
end;


function TClientManager.AvaliableLicenseCount: integer;
begin
  result := LicenseCount -  (FClientList.Count + FWListCount + FWebOpList.Count)  ;
end;

procedure TClientManager.WebOptimerTimer(Sender: TObject);
var
  i:integer;
  d:TDateTime;
begin
  i := 0;
  while i < FWebOpList.Count do
  begin
    d := StrToFloat( FWebOpList.ValueFromIndex[i]);
    if d < Now then
    begin
      FWebOpList.Delete(i);
    end else
      i := i + 1;

  end;

end;

initialization

  JclStackTrackingOptions := JclStackTrackingOptions + [stExceptFrame];
  JclStartExceptionTracking;
end.
