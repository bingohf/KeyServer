object frmAdmin: TfrmAdmin
  Left = 422
  Top = 228
  Width = 603
  Height = 387
  Caption = 'frmAdmin'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 587
    Height = 349
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 100
      end
      item
        Caption = 'IP'
        Width = 150
      end
      item
        Caption = 'Host Name'
        Width = 150
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
end
