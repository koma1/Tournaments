object ProgressForm: TProgressForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1056#1072#1089#1095#1077#1090' '#1090#1091#1088#1085#1080#1088#1072
  ClientHeight = 103
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    490
    103)
  PixelsPerInch = 120
  TextHeight = 17
  object lblTourNumber: TLabel
    Left = 10
    Top = 10
    Width = 93
    Height = 27
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1058#1091#1088' '#8470' 5'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object pb: TProgressBar
    Left = 10
    Top = 48
    Width = 470
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
  end
  object statsb: TStatusBar
    Left = 0
    Top = 84
    Width = 490
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <
      item
        Text = '00:00:00'
        Width = 70
      end
      item
        Width = 170
      end
      item
        Alignment = taRightJustify
        Text = '00:00:00      '
        Width = 50
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object tmrTime: TTimer
    Interval = 100
    OnTimer = tmrTimeTimer
    Left = 320
  end
end
