object scMain: TscMain
  OldCreateOrder = False
  DisplayName = 'LedwayKeyServer'
  Interactive = True
  OnStart = ServiceStart
  Left = 440
  Top = 215
  Height = 228
  Width = 372
  object clientSocket: TServerSocket
    Active = False
    Port = 7100
    ServerType = stNonBlocking
    Left = 24
    Top = 32
  end
  object adminSocket: TServerSocket
    Active = False
    Port = 7200
    ServerType = stNonBlocking
    Left = 112
    Top = 40
  end
  object Timer1: TTimer
    Interval = 60000
    OnTimer = Timer1Timer
    Left = 160
    Top = 80
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 7300
    Greeting.NumericCode = 0
    ListenQueue = 2
    MaxConnectionReply.NumericCode = 0
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 240
    Top = 104
  end
end
