unit Tournaments.AlgCombos;

interface

uses
  System.SysUtils,
  System.Classes,
  Generics.Collections,

  Math.Combinatory,
  Tournaments.Calculations,

  System.RTLConsts;

type
  TChampPoints = record
    Positive : Integer; //������������� ����
    Negative : Integer; //������������� ����
    Together : Integer; //���-�� ������� "������"
    Rest: Integer; //���-�� ������� "������"

    procedure InitComparate;
    procedure Reset;
    function CompareWith(const ACompareTo: TChampPoints;
      AllowSwing: Boolean): Boolean; //True - ���� Self (������������) ����� ��� CompareTo; False - � ���������
  end;

  TTournamentAlghoritmCombos = class(TTournamentAlghoritm) //27 sec/tour - 25%; 7 sec
  private
    FCombinations: TBool2D;
    type
      TCalcThread = class(TThread)
    private
      FParent: TTournamentAlghoritmCombos;
      FFromPos, FToPos, FCurrentIndex: Integer;
      FBetterIndex: Integer; //������ ������� ���� � ������� FAlghoritm.FCombinations
      FBetterResult: TChampPoints;
      {$IFDEF FAST_RUSH}
        FVPoints: TChampPoints;
      {$ELSE}
        CTTemp: TTeamCrossTab;
      {$ENDIF}
      FVCTMaster: TTeamCrossTab;
      procedure PointsCalculatorPrepare;
      function PointsCalculatorGet(const Tour: array of Boolean): TChampPoints;
      const ThreadNotifyStep = 123456; //���-�� "�����������" ����������, ����� ������� Thread ������������� ����� ������������� ���� ��������
    protected
      procedure Execute; override;
    public
      constructor Create(const AParent: TTournamentAlghoritmCombos;
        FromPos, ToPos: Integer);
      procedure GetProgress(var Current, Total: Integer);
      property BetterResult: TChampPoints read FBetterResult;
      property BetterIndex: Integer read FBetterIndex;
    end;
  private
    FThreadList: TObjectList<TCalcThread>;
    FThreadCount: Integer;
    FComboCountPerThread: Integer; //���-�� ���������� �� Thread

    FAllowSwing: Boolean;

    function MakeTourFromCombo(ComboIndex: Integer): TTour;
  protected
    procedure PrepareCalculation; override;
    function CalculateTour: TTour; override;
  public
    class function GetOptimalThreadCount: Integer;
    constructor Create; override;
    destructor Destroy; override;

    property AllowSwing: Boolean read FAllowSwing write FAllowSwing;
    property ThreadCount: Integer read FThreadCount write FThreadCount;

    property OnProgress;
  end;

implementation

function GetNegativeCount(const SwimCount: Integer): Integer; {$IFNDEF DEBUG}inline;{$ENDIF} //���������� ���������� "������" �����
begin //X = (n - 1) * n; X - ��������� (������ �����); n - ���-�� ������� ����� ����� ��������� (SwimsCount)
  if SwimCount > 1 then
    Result := (SwimCount - 1) * SwimCount
  else
    Result := 0;
end;

{ TCalcThread }

// ��������, ���� (���������� ������ / ���-�� ����. �������) = 2, �� ��������� ��������� ������, �.�. ����� ������ �� ��������, �������� ����� � ����������� ����
function GetAllowSwing(const AllowSwing: Boolean;
  const TeamCount, RoundCount: Integer): Boolean; inline;
begin
  Result := (AllowSwing) or (TeamCount div RoundCount = 2);
end;

constructor TTournamentAlghoritmCombos.TCalcThread.Create(const AParent: TTournamentAlghoritmCombos;
  FromPos, ToPos: Integer);
begin
  FParent := AParent;
  FFromPos := FromPos;
  FToPos := ToPos;

  FCurrentIndex := FromPos;
  FBetterIndex := -1;

  PointsCalculatorPrepare;

  inherited Create(False);
end;

procedure TTournamentAlghoritmCombos.TCalcThread.Execute;
var
  I: Integer;
  Current, Better: TChampPoints;
  _BetterIndex: Integer;
  AllowSwing: Boolean;
begin
  Better.InitComparate;

  for I := FFromPos to FToPos do
  begin
    if I mod ThreadNotifyStep = 0 then
    begin
      Synchronize(procedure
      begin
        FCurrentIndex := I;
      end);

      if Terminated then Break;
    end;

    AllowSwing := GetAllowSwing( //inline function
      FParent.AllowSwing,
      FParent.TeamCount,
      FParent.RoundCount);

    Current := PointsCalculatorGet(FParent.FCombinations[I]); //������� ���� ������� ����
    if Current.CompareWith(Better, AllowSwing) then //������� �� � ������ �����������
    begin //���� �������, ����� ��� ������, "��������" ������� ��� ������
      Better := Current;
      _BetterIndex := I;
    end;
  end;

  Synchronize(procedure
    begin
      FBetterResult := Better;
      FBetterIndex  := _BetterIndex;
    end);
end;

procedure TTournamentAlghoritmCombos.TCalcThread.GetProgress(var Current, Total: Integer);
begin
  Current := FCurrentIndex - FFromPos;
  Total := FToPos - FFromPos;
end;

{$IFNDEF FAST_RUSH}
  procedure TTournamentAlghoritmCombos.TCalcThread.PointsCalculatorPrepare;
  begin
    FVCTMaster := FParent.GetChampCrossTab;
    SetLength(CTTemp, Length(FVCTMaster[0]), Length(FVCTMaster[0]));
  end;

  function TTournamentAlghoritmCombos.TCalcThread.PointsCalculatorGet(const Tour: array of Boolean): TChampPoints;
    function CalcRestPoints(Points: Integer): Integer;
    begin
      if Points > 2 then
        Result := (Points - 1) * Points
      else
        Result := Points;
    end;
  var
    I, J, Val: Integer;
  begin
    Result.Reset;

    for I := Low(FVCTMaster) to High(FVCTMaster) do
      Move(
        Pointer(FVCTMaster[I])^,
        Pointer(CTTemp[I])^,
        Length(CTTemp[I]) * SizeOf(CTTemp[I][0]));

    //������� ����������� ��� � ����c�...
    for I := Low(Tour) to High(Tour) do
      if Tour[I] then
      begin
        Inc(Result.Together, FParent.GetTogetherSwimCount(I + 1));
        Inc(Result.Rest, CalcRestPoints(FParent.GetTogetherRestCount(I + 1)));
        for J := I + 1 to High(Tour) do
          if Tour[J] then //then...i + 1 �������� � j + 1
            Inc(CTTemp[i, j]); //��������� � ����������� �����-���
      end;

    for I := Low(CTTemp) to High(CTTemp) do
      for J := Low(CTTemp[I]) to High(CTTemp[I]) do
      begin
        Val := CTTemp[I][J];
        if Val > -1 then
          if Val = 1 then //���� ��������� ���������� ���� � ������� - ����������...
            Inc(Result.Positive) //...������� ��� � ����������
          else if (Val > 1) then
            Inc(Result.Negative, GetNegativeCount(Val));
      end;
  end;
{$ELSE}
  procedure TTournamentAlghoritmCombos.TCalcThread.PointsCalculatorPrepare;
  var
    I, J: Integer;
  begin
    FVPoints.Reset;

    FVCTMaster := FParent.GetChampCrossTab;

    for I := Low(FVCTMaster) to High(FVCTMaster) do
      for J := Low(FVCTMaster[I]) to High(FVCTMaster[I]) do
        Inc(FVPoints.Negative, GetNegativeCount(FVCTMaster[I][J]));
  end;

  function TTournamentAlghoritmCombos.TCalcThread.PointsCalculatorGet(const Tour: array of Boolean): TChampPoints;
  var
    I, J: Integer;
  begin
    //�������� ���-�� ����� �����-����
    Result.Negative := FVPoints.Negative;

    //������� ����������� ��� � ������...
    for I := Low(Tour) to High(Tour) do
      if Tour[I] then
        for J := I + 1 to High(Tour) do
          if Tour[J] then //...i �������� � j
            Inc(Result.Negative, GetNegativeCount(FVCTMaster[I, J] + 1));
  end;
{$ENDIF}

{ TTournamentAlghoritmCombos }

procedure TTournamentAlghoritmCombos.PrepareCalculation;
begin
  FCombinations := GetCombinations(TeamCount, RoundCount); //������� ����������
  FComboCountPerThread := (Length(FCombinations) div FThreadCount); //���������� �� �����
end;

function TTournamentAlghoritmCombos.CalculateTour: TTour;
const
  ProgressUpdateInterval = 10;
var
  I: Integer;
  FromPos, ToPos: Integer;
  Thr: TCalcThread;
  AllDone: Boolean;
  Current, Total, ThrCurrent, ThrTotal: Integer;
  BetterIndex: Integer;
  BetterResult: TChampPoints;
  _Canceled: Boolean;
  AllowSwing: Boolean;
begin
  //������� ��������� ���������� ������� (�������)
  BetterIndex := -1;

  try
    for I := 1 to ThreadCount do
    begin
      FromPos := (I - 1) * FComboCountPerThread;
      ToPos := FromPos + FComboCountPerThread - 1;
      if I = ThreadCount then //���� ��������� �����...
        ToPos := High(FCombinations); //..."�������" ��� ���� ��������� �������

      Thr := TCalcThread.Create(Self, FromPos, ToPos);
      Thr.Priority := tpTimeCritical;
      FThreadList.Add(Thr);
    end;

    repeat
      AllDone := True;

      Current := 0;
      Total := 0;

      _Canceled := Canceled;

      for Thr in FThreadList do //������� ��� ������, �������� ��������
      begin
        if _Canceled then Thr.Terminate; //��������� ������ ���� ��������� �������� ������

        if not Thr.Finished then //���� � ������ ���� ������������� �����...
          AllDone := False; //...�������� �������, ��� ������ �� �������

        Thr.GetProgress(ThrCurrent, ThrTotal); //������� �������� �������� ������ � ������� �� � ����� ����������
          Inc(Current, ThrCurrent);
          Inc(Total, ThrTotal);
      end;

      DoProgress(Current, Total); //�������� "�������"
      Sleep(ProgressUpdateInterval);

    until AllDone; //��������, ����� ��� ������ ������������� � ���������� �������

    BetterResult.InitComparate;

    AllowSwing := GetAllowSwing( //inline function
      FAllowSwing,
      TeamCount,
      RoundCount);

    //������� ���������...
    for Thr in FThreadList do
      if Thr.BetterResult.CompareWith(BetterResult, AllowSwing) then
        begin
          BetterIndex := Thr.BetterIndex;
          BetterResult := Thr.BetterResult;
        end;
  finally
    FThreadList.Clear; //������� ��������� ������ ��� ����� ��������� ��� ����������
  end;

  Result := MakeTourFromCombo(BetterIndex); //������� ������ ����������� ��� � �������� �������
end;

constructor TTournamentAlghoritmCombos.Create;
begin
  inherited;

  FThreadList := TObjectList<TCalcThread>.Create(True); //��������� thread'���
  FThreadCount := 1;
end;

destructor TTournamentAlghoritmCombos.Destroy;
begin
  FThreadList.Free;

  inherited;
end;

class function TTournamentAlghoritmCombos.GetOptimalThreadCount: Integer;
begin
  Result := Round(TThread.ProcessorCount * 1.6);
end;

function TTournamentAlghoritmCombos.MakeTourFromCombo(
  ComboIndex: Integer): TTour;
var
  I : Integer;
  Combo: TBoolArr;
begin
  if (ComboIndex < Low(FCombinations)) or (ComboIndex > High(FCombinations)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  Result := CreateTour;
  Combo := FCombinations[ComboIndex];
  for I := Low(Combo) to High(Combo) do
    if Combo[I] then
      Result[I] := 0;
end;

{ TChampPoints }

procedure TChampPoints.InitComparate;
begin
  Positive := Low(Integer);
  Negative := High(Integer);
  Together := High(Integer);
  Rest     := Low(Integer);
end;

procedure TChampPoints.Reset;
begin
  Negative := 0;
  Positive := 0;
  Together := 0;
  Rest := 0;
end;

function TChampPoints.CompareWith(const ACompareTo: TChampPoints;
  AllowSwing: Boolean): Boolean;
begin
  {$IFNDEF FAST_RUSH}
    if not AllowSwing then
      Result := (
        ( ACompareTo.Together > Together )
          or
        ( (ACompareTo.Together = Together) and ((Positive - Negative) > (ACompareTo.Positive - ACompareTo.Negative)) )
          or
        ( (ACompareTo.Together = Together) and ((Positive - Negative) = (ACompareTo.Positive - ACompareTo.Negative)) and (ACompareTo.Rest < Rest) )
      )
    else
      Result :=
        ( (Positive - Negative) > (ACompareTo.Positive - ACompareTo.Negative) )
          or
        ( (ACompareTo.Positive = Low(ACompareTo.Positive)) and (ACompareTo.Negative = High(ACompareTo.Negative)) );
  {$ELSE}
    Result :=
      ( (Negative) < (ACompareTo.Negative) )
        or
      ( (ACompareTo.Positive = Low(ACompareTo.Positive)) and (ACompareTo.Negative = High(ACompareTo.Negative)) );
  {$ENDIF}
end;

end.
