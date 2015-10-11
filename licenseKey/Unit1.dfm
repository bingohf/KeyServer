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
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 31
    Top = 24
    Width = 69
    Height = 13
    Caption = 'Machine Code'
  end
  object Label2: TLabel
    Left = 64
    Top = 104
    Width = 30
    Height = 13
    Caption = 'Result'
  end
  object Label3: TLabel
    Left = 64
    Top = 64
    Width = 27
    Height = 13
    Caption = 'String'
  end
  object edtKey: TEdit
    Left = 104
    Top = 24
    Width = 321
    Height = 21
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 104
    Top = 105
    Width = 321
    Height = 95
    TabOrder = 1
  end
  object btnEncrypt: TButton
    Left = 480
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Encrypt'
    TabOrder = 2
    OnClick = btnEncryptClick
  end
  object edtString: TEdit
    Left = 104
    Top = 64
    Width = 321
    Height = 21
    TabOrder = 3
  end
  object Button1: TButton
    Left = 480
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Decrypt'
    TabOrder = 4
    OnClick = Button1Click
  end
end
