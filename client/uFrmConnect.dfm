object frmConnect: TfrmConnect
  Left = 428
  Top = 277
  Width = 591
  Height = 181
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'Reconnect to Ledway Key Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbServer: TLabel
    Left = 32
    Top = 16
    Width = 60
    Height = 16
    Caption = 'lbServer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbRefuseMsg: TLabel
    Left = 32
    Top = 48
    Width = 62
    Height = 13
    Caption = 'lbRefuseMsg'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lbServerInfo: TLabel
    Left = 32
    Top = 80
    Width = 57
    Height = 13
    Caption = 'lbServerInfo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object btnConnect: TButton
    Left = 378
    Top = 13
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object Button1: TButton
    Left = 479
    Top = 13
    Width = 85
    Height = 25
    Caption = 'Close Application'
    TabOrder = 1
    OnClick = Button1Click
  end
end
