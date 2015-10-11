object Form1: TForm1
  Left = 192
  Top = 130
  Width = 870
  Height = 500
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 552
    Top = 24
    Width = 97
    Height = 25
    Caption = 'Send Command'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 144
    Top = 72
    Width = 361
    Height = 209
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 144
    Top = 32
    Width = 353
    Height = 21
    TabOrder = 2
  end
  object Button2: TButton
    Left = 664
    Top = 24
    Width = 75
    Height = 25
    Caption = 'connect'
    TabOrder = 3
    OnClick = Button2Click
  end
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 7200
    OnConnecting = ClientSocket1Connecting
    OnConnect = ClientSocket1Connect
    OnDisconnect = ClientSocket1Disconnect
    OnRead = ClientSocket1Read
    OnError = ClientSocket1Error
    Left = 96
    Top = 24
  end
end
