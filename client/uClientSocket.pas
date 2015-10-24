unit uClientSocket;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp,inifiles,PerlRegEx, ComCtrls,ulkJson, Menus, ExtCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TMyThread = class(TThread)
  protected
    procedure Execute; override;
  public
    ProEvent:TThreadMethod;
  end;

  TMsgProcedure = procedure(msg:String) of object;
  ILicenseChange = interface
    procedure StatusChange(msg:String);
    procedure ReceiveMessage(msg:String);
    procedure SetLevel(level:String);
  end;

  TFrmClientSocket = class(TForm)
    ClientSocket: TClientSocket;
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    Close1: TMenuItem;
    Timer1: TTimer;
    IdHTTP1: TIdHTTP;
    procedure FormCreate(Sender: TObject);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Close1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
    FRegEx :TPerlRegEx;
    Flisteners:TList;
    FLastStatus,FLastMsg:String;
    FClientListView: TListView;
    FNeedReconnect: boolean;
    FLevel:string;
    FRefuseMsg: String;
    FServerInfo:String;
    FAutoRetryCount:integer;
    FisFirst:Boolean;
    FActive:Boolean;
    FConnecting:Boolean;
    FMaxRetry:integer;
    procedure NotifyStatusChange(msg:String);
    procedure NotifyMessageChange(msg:String);
    procedure NotifyMessageLevelChange(level:String);
    procedure SetClientListView(const Value: TListView);
    procedure ShowConnectForm;
    procedure CloseConnectForm;
  public
    { Public declarations }

    procedure AddListener(aListener:ILicenseChange);
    procedure RemoveListener(aListener:ILicenseChange);
    procedure Connect;
    procedure AutoConnect;
    property ClientListview:TListView read FClientListView write SetClientListView;
    procedure SetUsername(userName:String);
    property NeedReconnect:boolean read FNeedReconnect write FNeedReconnect default true;
    property RefuseMsg :String read FRefuseMsg;
    property ServerInfo:String read FServerInfo;
  published
    procedure showMsg(msg:String);
    procedure GetClientList(jsondata:String);
    procedure Close(msg:String);
    procedure SetMessageLevel(level:String);
    procedure SetRefuseMsg(msg:String);
    procedure SetServerInfo(Msg:String);
    procedure SetConnectStatus(msg:String);
  end;

var
  FrmClientSocket: TFrmClientSocket;

implementation

uses uFrmConnect;

{$R *.dfm}

procedure TFrmClientSocket.AddListener(aListener: ILicenseChange);
begin
  aListener.StatusChange(FLastStatus);
  aListener.ReceiveMessage(FLastMsg);
  Flisteners.Add(Pointer(aListener));
end;

procedure TFrmClientSocket.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  FActive:=false;
  FConnecting := false;
   FAutoRetryCount:=FAutoRetryCount +1;
   FLastStatus := 'Disconnected' ;
   if (FAutoRetryCount >FMaxRetry) or FisFirst then
     NotifyStatusChange(FLastStatus)
   else
     AutoConnect;


end;

procedure TFrmClientSocket.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  FActive:=false;
  FConnecting := false;
  FLastmsg := 'ErrorCode:' + inttostr(errorCode);
  FLastStatus := 'Disconnected' ;
  FAutoRetryCount:=FAutoRetryCount +1;
  if (FAutoRetryCount > FMaxRetry) or FisFirst then
  begin
    NotifyStatusChange(FLastStatus);
    NotifyMessageChange(FlastMsg);
  end else
  begin
    AutoConnect;
  end;
  ErrorCode := 0;

end;

procedure TFrmClientSocket.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var i:integer;
  action:String;
  stringList:TStringList;
  msg:string;
  param:String;
  m:Tmethod;
begin
  //msg :=  Socket.ReceiveText;
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
      m.Code := Self.MethodAddress(action);
      if m.Code = nil then
        continue;
      m.Data := pointer(self);
      TMsgProcedure(m)(param);
    end else
    begin
      FLastmsg := msg;
      NotifyMessageChange(FlastMsg);
    end;

  end;



end;

procedure TFrmClientSocket.Connect;
begin
//  if ClientSocket.Host <>'' then
  begin
    if (not FActive) and (not FConnecting) then
    begin
      FRefuseMsg := 'Can not connect to Ledway Key Server, please check your network or contact Ledway Key Server Admin.';
      FServerInfo := '';
      FNeedReconnect := true;
      ClientSocket.Active := true;
    end;
  end;
end;

procedure TFrmClientSocket.FormCreate(Sender: TObject);
var
  inifile:TIniFile;
  liceseServer:String;
begin

  FConnecting := false;
  FActive:=false;
  inifile := TIniFile.Create(GetCurrentDir +'\winup.ini');
  liceseServer := inifile.ReadString('ApControl','LicenseServer','');
  FMaxRetry :=  inifile.ReadInteger('ApControl','MaxRetry',4);
  if liceseServer <>'' then
  begin
    ClientSocket.Host := liceseServer;
  end;
  Flisteners := TList.Create;

  FRegEx := TPerlRegEx.Create;
  FRegEx.RegEx := '\[\w+\]:';
  FRegEx.Options := [preCaseLess];
  FClientListView := nil;
  SetClientListView(ListView1);
  FAutoRetryCount := 0;
  FisFirst := true;
 // FRefuseMsg := 'Can not connect to LedwayKeyService';
end;

procedure TFrmClientSocket.NotifyStatusChange(msg: String);
var
  i:integer;
  listener:ILicenseChange;
begin
  for i := 0 to Flisteners.Count -1 do
  begin
    listener := ILicenseChange(Flisteners.Items[i]);
    listener.StatusChange(msg);
  end;
  if (msg <>'Connected') then
  begin
    if FNeedReconnect then
      with TMyThread.Create(true) do
      begin
        ProEvent := ShowConnectForm;
        Resume;
      end;
  end else
  begin
    with TMythread.Create(true) do
    begin
      ProEvent := CloseConnectForm;
      Resume;
    end;
  end;
end;

procedure TFrmClientSocket.RemoveListener(aListener: ILicenseChange);
var
  i:integer;
  listener:ILicenseChange;
begin
  for i := 0 to Flisteners.Count -1 do
  begin
    listener := ILicenseChange(Flisteners.Items[i]);
    if listener = aListener then
    begin
      Flisteners.Delete(i);
      break;
    end;
  end;

end;

procedure TFrmClientSocket.ClientSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  FActive:=true;
  FConnecting :=false;
 //  Socket.SendText('[SetUserName]:Admin');
end;

procedure TFrmClientSocket.ClientSocketConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  FConnecting := true;
end;

procedure TFrmClientSocket.NotifyMessageChange(msg: String);
var
  i:integer;
  listener:ILicenseChange;
begin
  for i := 0 to Flisteners.Count -1 do
  begin
    listener := ILicenseChange(Flisteners.Items[i]);
    listener.ReceiveMessage(msg);
  end;

end;

procedure TFrmClientSocket.showMsg(msg: String);
begin
   ShowMessage(msg);
end;

procedure TFrmClientSocket.SetClientListView(const Value: TListView);
begin
  FClientListView := Value;
end;

procedure TFrmClientSocket.SetConnectStatus(msg: String);
begin
  if msg ='OK' then
  begin
    FAutoRetryCount:=0;
    FisFirst := false;
    Timer1.Enabled := false;
    FLastStatus := 'Connected' ;
    NotifyStatusChange(FLastStatus);
  end;
end;

procedure TFrmClientSocket.SetUsername(userName: String);
begin
   ClientSocket.Socket.SendText('[SetUserName]:' + Username);
end;

procedure TFrmClientSocket.GetClientList(jsondata: String);
var
  jsonList:TlkJSONList;
  i:integer;
  jsonObj:TLkJsonObject;
begin
  jsonList :=  TLKJSON.ParseText(JSONdATA) as  TlkJSONList;
  FClientListView.Items.Clear;
  for i := 0 to   jsonList.Count -1 do
  begin
    jsonObj :=     jsonList.Child[i] as TlkJSONobject;
    with FClientListView.Items.Add() do
    begin
      Caption := jsonObj.getString('handleID');
      SubItems.Add(jsonObj.getString('ip')) ;
      SubItems.Add(JsonObj.getString('hostName'));
      SubItems.Add(jsonObj.getString('userName')) ;
      if jsonObj.Field['loginDate'] <> nil then
        SubItems.Add(DateTimeToStr( jsonObj.getDouble('loginDate'))) ;

    end;
  end;

end;

{ TMyThread }

procedure TMyThread.Execute;
begin
  inherited;
  Synchronize(ProEvent);
end;

procedure TFrmClientSocket.CloseConnectForm;
begin
  if frmConnect.Visible then
    frmConnect.Close;
end;

procedure TFrmClientSocket.ShowConnectForm;
begin
  frmConnect.lbServer.Caption := Format('Server=%s:%d',  [FrmClientSocket.ClientSocket.Host,
  FrmClientSocket.ClientSocket.Port
  ] );
  frmConnect.lbRefuseMsg.Caption := RefuseMsg;
  frmConnect.lbServerInfo.Caption := ServerInfo;
  if not frmConnect.Visible then
    frmConnect.ShowModal;
end;

procedure TFrmClientSocket.Close1Click(Sender: TObject);
var
  id:string;
begin
  if ListView1.Selected <> nil then
  begin
    id :=   ListView1.Selected .caption;
    ClientSocket.Socket.SendText('[Close]:' + id);
  end;


end;

procedure TFrmClientSocket.Close(msg: String);
var ProcessID:Integer;
    ProcessHandleA:THandle;
    ProcessHandle:THandle;
    Code:Cardinal;
begin
  NeedReconnect := false;
  ShowMessage(msg);
  GetWindowThreadProcessID(Handle, @ProcessID);
  ProcessHandle   := OpenProcess(PROCESS_TERMINATE, FALSE, ProcessId);
  ProcessHandleA  := OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, ProcessId);
  if GetExitCodeProcess(ProcessHandleA,Code)then
    TerminateProcess(ProcessHandle,Code);

end;


procedure TFrmClientSocket.SetMessageLevel(level: String);
begin
  FLevel := level;
  NotifyMessageLevelChange(level);
end;

procedure TFrmClientSocket.NotifyMessageLevelChange(level: String);
var
  i:integer;
  listener:ILicenseChange;
begin
  for i := 0 to Flisteners.Count -1 do
  begin
    listener := ILicenseChange(Flisteners.Items[i]);
    listener.SetLevel(level);
  end;

end;

procedure TFrmClientSocket.SetRefuseMsg(msg: String);
begin
  FRefuseMsg := msg;
end;

procedure TFrmClientSocket.SetServerInfo(Msg: String);
begin
  FServerInfo := Msg;
end;

procedure TFrmClientSocket.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  Connect;

  //showmessage('Reconnect');
end;

procedure TFrmClientSocket.AutoConnect;
begin
  Timer1.Enabled := true;
end;

end.
