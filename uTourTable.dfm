object TourTableForm: TTourTableForm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1090#1091#1088#1085#1080#1088#1086#1074
  ClientHeight = 535
  ClientWidth = 1091
  Color = clBtnFace
  Constraints.MinHeight = 540
  Constraints.MinWidth = 1040
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 17
  object spl1: TSplitter
    Left = 0
    Top = 267
    Width = 1091
    Height = 4
    Cursor = crVSplit
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    ExplicitTop = 222
    ExplicitWidth = 1023
  end
  object pnlInputParams: TPanel
    Left = 0
    Top = 0
    Width = 1091
    Height = 89
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      1091
      89)
    object lblTeams: TLabel
      Left = 10
      Top = 5
      Width = 48
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1050#1086#1084#1072#1085#1076
    end
    object lblBoats: TLabel
      Left = 82
      Top = 5
      Width = 25
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1071#1093#1090
    end
    object lbl1: TLabel
      Left = 887
      Top = 35
      Width = 69
      Height = 17
      Hint = #1042#1083#1080#1103#1077#1090' '#1090#1086#1083#1100#1082#1086' '#1085#1072' '#1089#1082#1086#1088#1086#1089#1090#1100' '#1088#1072#1089#1095#1077#1090#1072', '#1085#1086' '#1085#1077' '#1085#1072' '#1080#1090#1086#1075#1086#1074#1099#1081' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = #1055#1072#1088#1072#1083#1077#1083#1077#1081
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 819
    end
    object lbl2: TLabel
      Left = 154
      Top = 5
      Width = 38
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1043#1086#1085#1086#1082
    end
    object lbl3: TLabel
      Left = 241
      Top = 33
      Width = 16
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1076#1086
    end
    object lbl4: TLabel
      Left = 162
      Top = 34
      Width = 16
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1086#1090
    end
    object bvl1: TBevel
      Left = 612
      Top = 8
      Width = 1
      Height = 74
      Anchors = [akTop, akRight]
      Shape = bsLeftLine
      ExplicitLeft = 544
    end
    object bvl2: TBevel
      Left = 844
      Top = 8
      Width = 1
      Height = 74
      Anchors = [akTop, akRight]
      Shape = bsLeftLine
      ExplicitLeft = 776
    end
    object seTeams: TSpinEdit
      Left = 10
      Top = 30
      Width = 65
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 1000
      MinValue = 2
      TabOrder = 0
      Value = 27
    end
    object seBoats: TSpinEdit
      Left = 82
      Top = 30
      Width = 64
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 1000
      MinValue = 1
      TabOrder = 1
      Value = 9
    end
    object chkUseRandom: TCheckBox
      Left = 322
      Top = 7
      Width = 202
      Height = 22
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1055#1089#1077#1074#1076#1086#1089#1083#1091#1095#1072#1081#1085#1099#1081' '#1088#1072#1079#1073#1088#1086#1089
      TabOrder = 4
    end
    object chkRestConsider: TCheckBox
      Left = 656
      Top = 34
      Width = 117
      Height = 22
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1059#1095#1077#1090' '#1086#1090#1076#1099#1093#1072
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object rbAlg1: TRadioButton
      Left = 637
      Top = 3
      Width = 169
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084' '#1073#1099#1089#1090#1088#1099#1081
      TabOrder = 5
    end
    object rbAlg2: TRadioButton
      Left = 870
      Top = 3
      Width = 198
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084' '#1082#1086#1084#1073#1080#1085#1072#1090#1086#1088#1080#1082#1080
      Checked = True
      TabOrder = 7
      TabStop = True
    end
    object seThreadCount: TSpinEdit
      Left = 965
      Top = 31
      Width = 65
      Height = 27
      Hint = #1042#1083#1080#1103#1077#1090' '#1090#1086#1083#1100#1082#1086' '#1085#1072' '#1089#1082#1086#1088#1086#1089#1090#1100' '#1088#1072#1089#1095#1077#1090#1072', '#1085#1086' '#1085#1077' '#1085#1072' '#1080#1090#1086#1075#1086#1074#1099#1081' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      MaxValue = 999
      MinValue = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      Value = 1
    end
    object seMinTourCount: TSpinEdit
      Left = 184
      Top = 30
      Width = 55
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 1000
      MinValue = 1
      TabOrder = 2
      Value = 1
    end
    object seMaxTourCount: TSpinEdit
      Left = 259
      Top = 30
      Width = 55
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 1000
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object chkAdjustСutoffs: TCheckBox
      Left = 322
      Top = 34
      Width = 215
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1042#1099#1088#1086#1074#1085#1103#1090#1100' '#1082#1088#1091#1075#1086#1074#1099#1077' '#1079#1072#1077#1079#1076#1099
      Checked = True
      State = cbChecked
      TabOrder = 9
    end
    object chkAllowSwing: TCheckBox
      Left = 870
      Top = 63
      Width = 215
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1056#1072#1079#1088#1077#1096#1080#1090#1100' '#1075#1088#1091#1087#1087#1086#1074#1099#1077' '#1079#1072#1077#1079#1076#1099
      TabOrder = 10
    end
  end
  object pnlControl: TPanel
    Left = 0
    Top = 462
    Width = 1091
    Height = 54
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 467
    DesignSize = (
      1091
      54)
    object btnGo: TButton
      Left = 768
      Top = 8
      Width = 187
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100' >>>'
      TabOrder = 0
      OnClick = btnGoClick
    end
    object btnExcel: TButton
      Left = 588
      Top = 8
      Width = 172
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = '> Excel'
      Enabled = False
      TabOrder = 1
      OnClick = btnExcelClick
    end
    object btnReverse: TButton
      Left = 2
      Top = 7
      Width = 150
      Height = 33
      Caption = #1056#1077#1074#1077#1088#1089#1080#1103' '#1082#1086#1084#1072#1085#1076
      Enabled = False
      TabOrder = 2
      OnClick = btnReverseClick
    end
    object btnSaveToFile: TButton
      Left = 456
      Top = 7
      Width = 123
      Height = 33
      Anchors = [akRight, akBottom]
      Caption = '> '#1060#1072#1081#1083
      Enabled = False
      TabOrder = 3
      OnClick = btnSaveToFileClick
    end
    object btnFromFile: TButton
      Left = 962
      Top = 7
      Width = 123
      Height = 33
      Anchors = [akRight, akBottom]
      Caption = #1048#1079' '#1092#1072#1081#1083#1072' >>>'
      TabOrder = 4
      OnClick = btnFromFileClick
    end
  end
  object pnlResult: TPanel
    Left = 0
    Top = 89
    Width = 1091
    Height = 178
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitHeight = 139
    object sgSchedule: TStringGrid
      Left = 0
      Top = 0
      Width = 1091
      Height = 178
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ColCount = 1
      DefaultColWidth = 30
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing]
      TabOrder = 0
      OnDrawCell = sgScheduleDrawCell
      ExplicitHeight = 139
    end
  end
  object pnlSummary: TPanel
    Left = 0
    Top = 271
    Width = 1091
    Height = 191
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitTop = 232
    object spl4: TSplitter
      Left = 308
      Top = 0
      Width = 4
      Height = 191
      Align = alRight
      ExplicitLeft = 456
    end
    object spl3: TSplitter
      Left = 119
      Top = 0
      Width = 4
      Height = 191
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      ExplicitLeft = 0
      ExplicitTop = 22
    end
    object spl2: TSplitter
      Left = 596
      Top = 0
      Width = 4
      Height = 191
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      ExplicitLeft = 791
    end
    object grp1: TGroupBox
      Left = 0
      Top = 0
      Width = 119
      Height = 191
      Align = alClient
      Caption = #1042#1089#1090#1088#1077#1095#1080' '#1084#1077#1078#1076#1091' '#1091#1095#1072#1089#1090#1085#1080#1082#1072#1084#1080
      TabOrder = 0
      object sgSwimStatCrossTab: TStringGrid
        Left = 2
        Top = 19
        Width = 115
        Height = 170
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        DefaultColWidth = 24
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnDrawCell = sgCountersDrawCell
        ExplicitLeft = 0
        ExplicitTop = 21
      end
    end
    object grp2: TGroupBox
      Left = 123
      Top = 0
      Width = 185
      Height = 191
      Align = alRight
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1079#1072#1077#1079#1076#1086#1074
      TabOrder = 1
      ExplicitLeft = 281
      ExplicitTop = 2
      object sgSummary: TStringGrid
        Left = 2
        Top = 19
        Width = 181
        Height = 170
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 0
        ExplicitLeft = 22
        ExplicitTop = 21
        ExplicitWidth = 160
      end
    end
    object grp3: TGroupBox
      Left = 312
      Top = 0
      Width = 284
      Height = 191
      Align = alRight
      Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1084#1099#1077' '#1103#1093#1090#1099
      TabOrder = 2
      ExplicitLeft = 496
      object sgBoatsDisperse: TStringGrid
        Left = 2
        Top = 19
        Width = 280
        Height = 170
        Align = alClient
        ColCount = 10
        DefaultColWidth = 24
        RowCount = 28
        TabOrder = 0
        OnDrawCell = sgCountersDrawCell
        ExplicitTop = 18
        RowHeights = (
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24)
      end
    end
    object grp4: TGroupBox
      Left = 600
      Top = 0
      Width = 491
      Height = 191
      Align = alRight
      Caption = #1054#1090#1089#1077#1095#1082#1080
      TabOrder = 3
      object mmoLog: TMemo
        Left = 2
        Top = 19
        Width = 487
        Height = 170
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitLeft = 760
        ExplicitTop = 0
        ExplicitWidth = 331
        ExplicitHeight = 191
      end
    end
  end
  object stat: TStatusBar
    Left = 0
    Top = 516
    Width = 1091
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <
      item
        Width = 150
      end
      item
        Alignment = taRightJustify
        Width = 130
      end>
    ExplicitTop = 477
  end
  object dlgSaveFile: TSaveDialog
    DefaultExt = 'ctbl'
    Filter = 'Tournament Table Format (*.ctbl)|*.ctbl'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 656
    Top = 168
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = 'ctbl'
    Filter = 'Tournament Table Format (*.ctbl)|*.ctbl'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 592
    Top = 312
  end
end
