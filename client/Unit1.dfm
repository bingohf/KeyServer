object Form1: TForm1
  Left = 192
  Top = 130
  Width = 870
  Height = 500
  Caption = 'Client'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 56
    Top = 16
    Width = 409
    Height = 233
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 443
    Width = 854
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object Button1: TButton
    Left = 488
    Top = 32
    Width = 75
    Height = 25
    Caption = 'ShowAdmin'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 520
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 552
    Top = 328
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 424
    Top = 240
  end
end
