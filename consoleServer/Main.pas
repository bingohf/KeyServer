unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, StdCtrls, ExtCtrls, ScktComp,uClientManager,uClient,JclSysInfo;

type
  TMainForm = class(TForm,INotifyChange)
    MainMenu: TMainMenu;
    About1: TMenuItem;
    License1: TMenuItem;
    ListView: TListView;
    PopupMenu: TPopupMenu;
    Splitter1: TSplitter;
    Panel1: TPanel;
    memoMsg: TMemo;
    Panel2: TPanel;
    edtSend: TEdit;
    clientSocket: TServerSocket;
    StatusBar: TStatusBar;
    closeClient: TMenuItem;
    Timer: TTimer;
    adminSocket: TServerSocket;
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure closeClientClick(Sender: TObject);
    procedure removeClient(Client:TClient);
    procedure clientSocketListen(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    procedure clientAdd(client:TClient; clientList:TStringList);
    procedure messageAdd(msg:String);

  public
    { Public declarations }
     procedure SetStatusBar;
     procedure LicenseChange;
  end;

var
  MainForm: TMainForm;

implementation




{$R *.dfm}

{ TMainForm }

procedure TMainForm.clientAdd(client: TClient; clientList: TStringList);
var
  i:integer;
  aclient:Tclient;
begin
  ListView.Items.Clear;
  for i := 0 to clientList.count-1 do
  begin
    aclient := TClient(clientList.Objects[i]);
    with ListView.Items.Add do
    begin
      Caption := aclient.HandleID;
      SubItems.Add(aclient.IP);
      SubItems.Add(aclient.HostName);
    end;
  end;
  SetStatusBar;
end;

procedure TMainForm.messageAdd(msg: String);
begin
  memoMsg.Lines.Add(msg);
end;

procedure TMainForm.ListViewSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  client:Tclient;
begin
  ClientManager.SetCurrentClient(0);
  if Selected then
  begin
    ClientManager.SetCurrentClient(strtoint( Item.Caption));
    client := ClientManager.GetClient(strtoint( Item.Caption));
    memoMsg.Text := client.msgText;

  end;
end;

procedure TMainForm.closeClientClick(Sender: TObject);
begin
  ClientManager.CloseCurrent();
end;

procedure TMainForm.removeClient(Client: TClient);
var i:integer;
begin
  i := 0;
  while i < ListView.Items.Count  do
  begin
    if ListView.Items[i].Caption = Client.HandleID then
    begin
      ListView.Items.Delete(i);
    end else
      inc(i);
  end;
  SetStatusBar;
end;

procedure TMainForm.SetStatusBar;
begin
  StatusBar.Panels[0].Text := Format('License: %d/%d', [Listview.Items.Count , ClientManager.LicenseCount]) ;
end;

procedure TMainForm.clientSocketListen(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  SetStatusBar;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
 // ShowMessage(DateTimeToStr(now));
//  ShowMessage(DateTimeToStr(ClientManager.ExpiryDate));
  if Now > ClientManager.ExpiryDate then
  begin
   // clientSocket.Close;
    ClientManager.DisconnectAll;

  end;
end;

procedure TMainForm.LicenseChange;
begin
  StatusBar.Panels[1].Text := GetVolumeSerialNumber('C');
  StatusBar.Panels[2].Text := 'Expried Date:' + DateTimeToStr(ClientManager.ExpiryDate);
  StatusBar.Panels[0].Text := Format('License: %d/%d', [Listview.Items.Count , ClientManager.LicenseCount]) ;
end;

end.
