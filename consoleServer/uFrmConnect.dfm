object frmConnect: TfrmConnect
  Left = 428
  Top = 277
  Width = 439
  Height = 156
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
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbServer: TLabel
    Left = 40
    Top = 40
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
  object btnConnect: TButton
    Left = 296
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
end
