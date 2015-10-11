object MainForm: TMainForm
  Left = 256
  Top = 140
  Width = 870
  Height = 500
  Caption = 'LedwayKeyServer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 457
    Top = 0
    Height = 423
  end
  object ListView: TListView
    Left = 0
    Top = 0
    Width = 457
    Height = 423
    Align = alLeft
    Columns = <
      item
        Caption = 'id'
      end
      item
        Caption = 'ip'
        Width = 150
      end
      item
        Caption = 'host name'
        Width = 150
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = ListViewSelectItem
  end
  object Panel1: TPanel
    Left = 460
    Top = 0
    Width = 394
    Height = 423
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object memoMsg: TMemo
      Left = 1
      Top = 1
      Width = 392
      Height = 388
      Align = alClient
      Lines.Strings = (
        '')
      ReadOnly = True
      TabOrder = 0
    end
    object Panel2: TPanel
      Left = 1
      Top = 389
      Width = 392
      Height = 33
      Align = alBottom
      Caption = 'Panel2'
      TabOrder = 1
      DesignSize = (
        392
        33)
      object edtSend: TEdit
        Left = 1
        Top = 1
        Width = 384
        Height = 21
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 423
    Width = 854
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object MainMenu: TMainMenu
    Left = 72
    Top = 16
    object About1: TMenuItem
      Caption = 'About'
      object License1: TMenuItem
        Caption = 'License'
      end
    end
  end
  object PopupMenu: TPopupMenu
    Left = 128
    Top = 24
    object closeClient: TMenuItem
      Caption = 'Close'
      OnClick = closeClientClick
    end
  end
  object clientSocket: TServerSocket
    Active = False
    Port = 7100
    ServerType = stNonBlocking
    OnListen = clientSocketListen
    Left = 24
    Top = 32
  end
  object Timer: TTimer
    Interval = 20000
    OnTimer = TimerTimer
    Left = 152
    Top = 72
  end
  object adminSocket: TServerSocket
    Active = False
    Port = 7200
    ServerType = stNonBlocking
    OnListen = clientSocketListen
    Left = 72
    Top = 96
  end
end
