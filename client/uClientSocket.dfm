object FrmClientSocket: TFrmClientSocket
  Left = 337
  Top = 229
  Width = 596
  Height = 271
  Caption = 'Key Management'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 580
    Height = 233
    Align = alClient
    Columns = <
      item
        Caption = 'HandleId'
        Width = 100
      end
      item
        Caption = 'IP'
        Width = 150
      end
      item
        Caption = 'Host Name'
        Width = 150
      end
      item
        Caption = 'UserName'
        Width = 100
      end
      item
        Caption = 'Login Date'
        Width = 100
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ClientSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 7100
    OnConnecting = ClientSocketConnecting
    OnConnect = ClientSocketConnect
    OnDisconnect = ClientSocketDisconnect
    OnRead = ClientSocketRead
    OnError = ClientSocketError
    Left = 120
    Top = 64
  end
  object PopupMenu1: TPopupMenu
    Left = 160
    Top = 32
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
  object Timer1: TTimer
    Interval = 12000
    OnTimer = Timer1Timer
    Left = 216
    Top = 120
  end
  object IdHTTP1: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 5000
    AllowCookies = False
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 304
    Top = 72
  end
end
