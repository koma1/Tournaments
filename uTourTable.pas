//user to-do: ColorRender; ExcelBeauty
//bugs: rush window don't hide; при построении (до 2х) выдает все равно минимум (3)
//refact: Fast rush;
unit uTourTable;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.Menus, Vcl.ComCtrls,
  ComObj,

  uProgressForm,

  Tournaments.Consts,
  Tournaments.Calculations,
  Tournaments.Alg1,
  Tournaments.AlgCombos,
  Tournaments.AlgCombosExt, Vcl.Buttons;

{$O-}

type
  TStringGridItemType = (itCol, itRow);

  TDrawRule = record
    ItemNumber: Integer;
    ItemType: TStringGridItemType;
    Color: TColor;
    constructor Create(AItemNumber: Integer; AItemType: TStringGridItemType;
      AColor: TColor);
  end;

  TTourTableForm = class(TForm)
    pnlInputParams: TPanel;
    seTeams: TSpinEdit;
    lblTeams: TLabel;
    lblBoats: TLabel;
    seBoats: TSpinEdit;
    pnlControl: TPanel;
    btnGo: TButton;
    pnlResult: TPanel;
    sgSchedule: TStringGrid;
    pnlSummary: TPanel;
    chkUseRandom: TCheckBox;
    chkRestConsider: TCheckBox;
    rbAlg1: TRadioButton;
    rbAlg2: TRadioButton;
    spl1: TSplitter;
    stat: TStatusBar;
    lbl1: TLabel;
    seThreadCount: TSpinEdit;
    lbl2: TLabel;
    seMinTourCount: TSpinEdit;
    btnExcel: TButton;
    seMaxTourCount: TSpinEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    bvl1: TBevel;
    bvl2: TBevel;
    chkAdjustСutoffs: TCheckBox;
    chkAllowSwing: TCheckBox;
    btnReverse: TButton;
    btnSaveToFile: TButton;
    dlgSaveFile: TSaveDialog;
    btnFromFile: TButton;
    dlgOpenFile: TOpenDialog;
    grp1: TGroupBox;
    sgSwimStatCrossTab: TStringGrid;
    spl4: TSplitter;
    grp2: TGroupBox;
    sgSummary: TStringGrid;
    spl3: TSplitter;
    grp3: TGroupBox;
    grp4: TGroupBox;
    spl2: TSplitter;
    sgBoatsDisperse: TStringGrid;
    mmoLog: TMemo;
    procedure CancelRequest(Sender: TObject);
    procedure TourAdded(Sender: TObject);
    procedure TourAddedCombo(Sender: TObject);
    procedure TourProgress(Sender: TTournamentAlghoritm;
      const Current, Max: Integer);
    procedure Cutoff(Sender: TTournamentAlghoritm; CutoffKind: TTourEventKind;
      const Min, Max: Integer);
    procedure Done(Sender: TObject);

    procedure btnGoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgSwimStatCrossTabClick(Sender: TObject);
    procedure btnExcelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnReverseClick(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure btnFromFileClick(Sender: TObject);
    procedure sgScheduleDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgCountersDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    FAlghoritm: TTournamentAlghoritm;
    FProgressForm: TProgressForm;
    FCanceled: Boolean;
    FCutoffs: array of TDrawRule;

    procedure PrepareControls;
    procedure ConstructAlghoritm(AlghoritmClass: TTournamentAlghoritmClass);
  public
    procedure DrawTournament(Tournament: TTournamentAlghoritm);
  end;

var
  TourTableForm: TTourTableForm;

implementation

uses
  KMMath, GenericsUtils, Math.Combinatory,
  {$IFDEF DEBUG} uCrossTabsForm, {$ENDIF}
  Tournaments.Controls;

{$R *.dfm}

const
  ColorBlack = $1f1f1f;
  Color1 = $c1f0c1;
  Color2 = $b3ffff;
  Color3 = $80d4ff;
  Color4 = $b3b3ff;
  Color5 = $8080ff;
  Color6 = $4040bf;
  Color7 = $21215f;

procedure TTourTableForm.FormCreate(Sender: TObject);
begin
  FProgressForm := TProgressForm.Create(Self);
  FProgressForm.OnCancelRequest := CancelRequest;

  seThreadCount.Value := TTournamentAlghoritmCombos.GetOptimalThreadCount;
end;

procedure TTourTableForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAlghoritm);
end;

procedure TTourTableForm.PrepareControls;
begin
  mmoLog.Clear;
  FCutoffs := nil;
end;

procedure TTourTableForm.btnGoClick(Sender: TObject);
begin
  if rbAlg1.Checked then //Выбран алгоритм I
  begin
    ConstructAlghoritm(TTournamentAlghoritmOne);
    with TTournamentAlghoritmOne(FAlghoritm) do
    begin
      Randomization := chkUseRandom.Checked;
      RestConsider  := chkRestConsider.Checked;
    end;
  end
  else if rbAlg2.Checked then //Выбран алгоритм II (комбинаторика)
  begin
    ConstructAlghoritm(TTournamentAlghoritmCombosExt);
    with TTournamentAlghoritmCombosExt(FAlghoritm) do
    begin
      ThreadCount := seThreadCount.Value;
      Randomization := chkUseRandom.Checked;
      AllowSwing := chkAllowSwing.Checked;
      OnProgress := TourProgress;
      OnTourAdded := TourAddedCombo; //у комбинаторики другой метод добавления тура (обновляющий окно прогресса)
      FProgressForm.Show;
    end;
  end
  else
    raise Exception.Create('Unknown alghoritm');

  PrepareControls;
  try
    FAlghoritm.Calculate; //начинаем расчет
    FAlghoritm.DisperseBoats; //рассадим команды по яхтам
    DrawTournament(FAlghoritm);
  finally
    if FProgressForm.Visible then
      FProgressForm.Hide;
  end;
end;

procedure TTourTableForm.btnReverseClick(Sender: TObject);
var
  ReverseCount: Integer;
begin
  ReverseCount := FAlghoritm.TeamCount * FAlghoritm.TeamCount;
  FAlghoritm.ReverseTeams(ReverseCount);
  DrawTournament(FAlghoritm);
end;

procedure TTourTableForm.btnSaveToFileClick(Sender: TObject);
begin
  if dlgSaveFile.Execute then
    FAlghoritm.SaveToFile(dlgSaveFile.FileName);
end;

procedure TTourTableForm.btnExcelClick(Sender: TObject);
const
  xlEdgeBottom = 9;
  xlEdgeRight  = 10;
var
  ExcelApp, Sheet, Cell1, Cell2, Range: Variant;
  Col, Row: Integer;
  I: Integer;
begin
  ExcelApp:= CreateOleObject('Excel.Application');

  Screen.Cursor := crHourGlass;
  try
    ExcelApp.Workbooks.Add;
    Sheet:= ExcelApp.ActiveWorkBook.WorkSheets[1];

    for Col:= 0 to sgSchedule.ColCount -1 do
      for Row:= 0 to sgSchedule.RowCount -1 do
        Sheet.Cells[Row + 1, Col + 1] := sgSchedule.Cells[Col, Row];

    Sheet.Cells[1, 1] := '[X]'; //левый верхний угол

    ExcelApp.Cells.Select;
    ExcelApp.Selection.Columns.AutoFit;
    ExcelApp.Selection.HorizontalAlignment := -4108;
    ExcelApp.Cells[1, 1].Select;

    Cell1 := Sheet.Cells[1, 1];
    Cell2 := Sheet.Cells[sgSchedule.RowCount, sgSchedule.ColCount];
    Range := Sheet.Range[Cell1, Cell2];
    Range.Borders.LineStyle := 1;

    Cell1 := Sheet.Cells[1, 1];
    Cell2 := Sheet.Cells[1, sgSchedule.ColCount];
    Range := Sheet.Range[Cell1, Cell2];
    Range.Interior.Color := RGB(150, 150, 150);
    Range.Font.Bold := True;
    Range.Borders.Item[xlEdgeBottom].LineStyle := 1;
    Range.Borders.Item[xlEdgeBottom].Weight := -4138;

    Cell1 := Sheet.Cells[1, 1];
    Cell2 := Sheet.Cells[sgSchedule.RowCount, 1];
    Range := Sheet.Range[Cell1, Cell2];
    Range.Interior.Color := RGB(150, 150, 150);
    Range.Font.Bold := True;
    Range.Borders.Item[xlEdgeRight].LineStyle := 1;
    Range.Borders.Item[xlEdgeRight].Weight := -4138;

    for I := Low(FCutoffs) to High(FCutoffs) do
      if FCutoffs[I].ItemType = itCol then
      begin
        Cell1 := Sheet.Cells[2, FCutoffs[I].ItemNumber];
        Cell2 := Sheet.Cells[sgSchedule.RowCount, FCutoffs[I].ItemNumber];
        Range := Sheet.Range[Cell1, Cell2];
        Range.Interior.Color := FCutoffs[I].Color;
      end;

    ExcelApp.ActiveWindow.SplitColumn := 1;
    ExcelApp.ActiveWindow.SplitRow := 1;
    ExcelApp.ActiveWindow.FreezePanes := True;

    {ExcelApp.Workbooks.Add;
    Sheet:= ExcelApp.ActiveWorkBook.WorkSheets[1];

    for Col:= 0 to sgSwimStatCrossTab.ColCount -1 do
      for Row:= 0 to sgSwimStatCrossTab.RowCount -1 do
        Sheet.Cells[Row + sgSchedule.RowCount + 2, Col + 1] := sgSwimStatCrossTab.Cells[Col, Row];

    for Col:= 0 to sgSummary.ColCount -1 do
      for Row:= 0 to sgSummary.RowCount -1 do
        Sheet.Cells[Row + sgSchedule.RowCount + sgSwimStatCrossTab.RowCount + 3, Col + 1] := sgSummary.Cells[Col, Row];}
  finally
    ExcelApp.Visible:= True;
    Screen.Cursor := crDefault;
  end;
end;

procedure TTourTableForm.btnFromFileClick(Sender: TObject);
begin
  if dlgOpenFile.Execute then
  begin
    ConstructAlghoritm(TTournamentAlghoritm);
    PrepareControls;
    FAlghoritm.LoadFromFile(dlgOpenFile.FileName);
  end;
end;

procedure TTourTableForm.CancelRequest(Sender: TObject);
begin
  FCanceled := MessageBox(TWinControl(Sender).Handle,
    'Вы действительно хотите остановить текущий расчет?',
    PChar(Application.Title),
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_TOPMOST) = mrYes;
end;

procedure TTourTableForm.ConstructAlghoritm(
  AlghoritmClass: TTournamentAlghoritmClass);
begin
  if Assigned(FAlghoritm) then
    FreeAndNil(FAlghoritm);

  FAlghoritm := AlghoritmClass.Create;

  FAlghoritm.OnTourAdded := TourAdded; //событие добавления тура
  FAlghoritm.OnCutoff := Cutoff;
  FAlghoritm.OnDone   := Done;

  //общие св-ва
  FCanceled := False;
  FAlghoritm.TeamCount := seTeams.Value;
  FAlghoritm.BoatCount := seBoats.Value;
  FAlghoritm.TourMinCount := seMinTourCount.Value;
  FAlghoritm.TourMaxCount := seMaxTourCount.Value;
  FAlghoritm.AdjustСutoffs := chkAdjustСutoffs.Checked;
end;

procedure TTourTableForm.Cutoff(Sender: TTournamentAlghoritm; CutoffKind: TTourEventKind;
  const Min, Max: Integer);
var
  s: string;
  procedure _Add(Color: TColor);
  begin
    SetLength(FCutoffs, Length(FCutoffs) + 1);
    FCutoffs[High(FCutoffs)].Create(Sender.CurrentTourIndex - 1, itCol, Color);
  end;
begin
  case CutoffKind of
    ckEachWithEach:
      begin
        s := 'каждый с каждым';
        _Add(Color1); //зеленый
      end;
    ckCircle:
      begin
        s := 'новый круг';
        if Min <> Max then
          _Add(Color4)
        else
          _Add(Color2)
      end
  else s := 'Неизвестный тип отсечки';
  end;

  mmoLog.Lines.Add(Format('Отсечка (%s) в гонке №%d (мин.: %d; макс.: %d)',
    [s, Sender.CurrentTourIndex - 1, Min, Max]));
end;

procedure TTourTableForm.Done(Sender: TObject);
begin
  DrawTournament(FAlghoritm);

  btnSaveToFile.Enabled := True;
  btnExcel.Enabled := True;
  btnReverse.Enabled := True;
end;

procedure TTourTableForm.DrawTournament(Tournament: TTournamentAlghoritm);
begin
  sgSchedule.DrawChampionship(Tournament.Championship); //таблица встреч
  sgSwimStatCrossTab.DrawCrosstab(Tournament.GetChampCrossTab); //кросс-таб
  sgSummary.DrawSummary(Tournament); //итого
  sgBoatsDisperse.DrawIntArrayTable(FAlghoritm.GetTeamOnBoatTable); //команда+лодка = кол-во

  Application.ProcessMessages;
end;

procedure TTourTableForm.sgCountersDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  DrawColor: TColor;
  RectText: TRect;
  ShiftX, ShiftY, Value: Integer;
begin
  with TStringGrid(Sender), Canvas do
  begin
    if (ACol = 0) or (ARow = 0) then
      DrawColor := FixedColor
    else
      if TryStrToInt(Cells[ACol, ARow], Value) then
      begin
        case Value of
          0: DrawColor := Color1;
          1: DrawColor := Color2;
          2: DrawColor := Color3;
          3: DrawColor := Color4;
          4: DrawColor := Color5;
          5: DrawColor := Color6;
          6: DrawColor := Color7;
        else
          DrawColor := ColorBlack;
        end;
      end
    else
      DrawColor := GradientStartColor;

    Brush.Color := DrawColor;
    FillRect(Rect);

    if (DrawColor = Color6) or (DrawColor = Color7) or (DrawColor = ColorBlack) then
      Font.Color := clWhite;

    with RectText do
    begin
      Left := Rect.Left;
      Top := Rect.Top;
      Height := TextHeight(Cells[ACol, ARow]);
      Width := TextWidth(Cells[ACol, ARow]);
      ShiftX := Rect.CenterPoint.X - CenterPoint.X;
      ShiftY := Rect.CenterPoint.Y - CenterPoint.Y;
    end;

    TextOut(Rect.Left + ShiftX, Rect.Top + ShiftY, Cells[ACol, ARow]);
  end;
end;

procedure TTourTableForm.sgScheduleDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  DrawColor: TColor;
  RectText: TRect;
  ShiftX, ShiftY: Integer;
  I: Integer;
begin
  with sgSchedule, Canvas do
  begin
    if (ACol = 0) or (ARow = 0) then
      DrawColor := FixedColor
    else
    begin
      DrawColor := GradientStartColor;
      for I := Low(FCutoffs) to High(FCutoffs) do
        if
          ((FCutoffs[I].ItemNumber = ACol) and (FCutoffs[I].ItemType = itCol))
            or
          ((FCutoffs[I].ItemNumber = ARow) and (FCutoffs[I].ItemType = itRow))
        then
          DrawColor := FCutoffs[I].Color;
    end;

    Brush.Color := DrawColor;
    FillRect(Rect);

    if (DrawColor = Color6) or (DrawColor = Color7) or (DrawColor = ColorBlack) then
      Font.Color := clWhite;

    with RectText do
    begin
      Left := Rect.Left;
      Top := Rect.Top;
      Height := TextHeight(Cells[ACol, ARow]);
      Width := TextWidth(Cells[ACol, ARow]);
      ShiftX := Rect.CenterPoint.X - CenterPoint.X;
      ShiftY := Rect.CenterPoint.Y - CenterPoint.Y;
    end;

    TextOut(Rect.Left + ShiftX, Rect.Top + ShiftY, Cells[ACol, ARow]);
  end;
end;

procedure TTourTableForm.sgSwimStatCrossTabClick(Sender: TObject);
var
  SwimCount: Integer;
begin
  with sgSwimStatCrossTab, Selection.TopLeft do
  begin
    if TryStrToInt(Cells[X, Y], SwimCount) then
      stat.Panels[0].Text := Format(' <-> ' + sTeamWithNumberFmt + ' = %d', [Y, X, SwimCount])
    else
      stat.Panels[0].Text := '';
  end;
end;

procedure TTourTableForm.TourAdded(Sender: TObject);
begin
  DrawTournament(Sender as TTournamentAlghoritm); //ЗАПОЛНИМ РЕЗУЛЬТАТ
end;

procedure TTourTableForm.TourAddedCombo(Sender: TObject);
begin
  TourAdded(Sender);
  FProgressForm.NewTour(TTournamentAlghoritmCombos(Sender).CurrentTourIndex);
end;

procedure TTourTableForm.TourProgress(Sender: TTournamentAlghoritm;
  const Current, Max: Integer);
begin
  if FCanceled then
  begin
    FCanceled := False;
    FProgressForm.Hide;
    Abort; //прервем расчет
  end;

  FProgressForm.ProgressChanged(Current, Max);
end;

{ TDrawRule }

constructor TDrawRule.Create(AItemNumber: Integer;
  AItemType: TStringGridItemType; AColor: TColor);
begin
  ItemNumber := AItemNumber;
  ItemType := AItemType;
  Color := AColor;
end;

end.
