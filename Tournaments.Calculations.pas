unit Tournaments.Calculations;

interface

uses
  System.SysUtils,
  System.Classes,
  KMMath,
  Generics.Collections,
  Generics.Defaults, {$IFDEF DEBUG} Dialogs,{$ENDIF}

  Tournaments.Consts;

const
  BinarySign: AnsiString = 'CTbl'; //сигнатура файла (данных)
  BinaryVer: Cardinal = $1;

type
  TTourEventKind = (ckEachWithEach, ckCircle);

  TBoat = type Integer; //Лодка (порядковый №)
  TTeam = type Integer; //Команда (порядковый №)
  TTeamArray = array of TTeam; //массив комманд, индекс элемента - порядковый № команды - 1 - значение №
  TTour = TTeamArray; //Тур (заплыв)  - (i + 1) - порядковый № команды; [I] - лодка
  TChampionship = array of TTour;
  TTeamCrossTab = array of array of TTeam;
  TIntArrayTable = array of array of Integer; //Кросс - Команда+Лодка=кол-во

  TSortedInfo = record //информация о сортируемой сущности (команда или лодка)
    SortableNo: TTeam; //№ сортируемого (команды; лодки и т.д.)
    SwimCount: Integer; //кол-во заездов
    RestCount: Integer; //кол-во отдыха
    constructor Create(ASortableNo: Integer;
      ASwimCount, ARestCount: Integer); overload;
  end;

  TSortedComparer = class(TComparer<TSortedInfo>)
  private
    FRandMax: Integer;
  public
    constructor Create(ARandMax: Integer);
    function Compare(const Left, Right: TSortedInfo): Integer; override;
  end;

  TSortedDetailedComparer = class(TSortedComparer)
  private
    FRandMax: Integer; //0 - не "разбрасываем" при каждом пересчете в случайном порядке; иначе кол-во сортируемых * 2
    FRestConsider: Boolean; //с учетом отдыха
  public
    constructor Create(ARandMax: Integer; ARestConsider: Boolean);
    function Compare(const Left, Right: TSortedInfo): Integer; override;
  end;

  TTournamentAlghoritm = class; //Forwarded declaration

  TCutoffEvent = procedure(Sender: TTournamentAlghoritm; CutoffKind: TTourEventKind;
    const Min, Max: Integer) of object;

  TProgressEvent = procedure(Sender: TTournamentAlghoritm;
    const Current, Max: Integer) of object;

  TTournamentAlghoritm = class abstract //Custom-Abstract алгоритм
  strict private
    FStartedAt, FCompletedAt: TDateTime; //время начала и окончания расчета
    FCanceled: Boolean;
    FLastGameCut, FLastTourCut: Integer;
  private
    FTeamCount: Integer;
    FTourMinCount: Integer;
    FTourMaxCount: Integer;
    FBoatCount: Integer;
    FOnTourAdded: TNotifyEvent;
    FOnProgress: TProgressEvent;
    FRandomization: Boolean;
    FOnCutoff: TCutoffEvent;
    FAdjustСutoffs: Boolean;
    FOnDone: TNotifyEvent;
    function GetChampionship: TChampionship;
    function GetTourCount: Integer;
    function GetRoundCount: Integer;
    function GetCurrentTourIndex: Integer;
    //процедуры проверяющие индекс на вхождение в границы массива
    procedure TeamBoundsCheckRaise(Team: TTeam; APIName: string);
    procedure BoatBoundsCheckRaise(Boat: TTeam; APIName: string);
  protected
    FChampionship: TChampionship;
    procedure AddTour(const Tour: TTour); //добавить тур к таблице
    procedure DoProgress(const Current, Max: Integer); virtual;
    procedure DoTourAdded; virtual; //вызывается после добавления нового расчитаного тура в итоговую таблицу
    procedure DoCutoff(CutoffKind: TTourEventKind; const Min, Max: Integer); virtual;
    procedure DoDone; virtual; //расчет завершен или остановлен; загрузка результата завершена
      (*методы переопределяемые конечными алгоритмами*)
    procedure PrepareCalculation; virtual; //инициализация алгоритма (вызывается перед началом расчета)
    function CalculateTour: TTour; virtual; abstract; //расчитывает и возврашает расчитанный тур (который автоматически добавляется в итог)
    function IsChampDone: Boolean; virtual; //возвращает True если турнир отвечает минимальным требованиям и можно начинать другие упорядочивания (напр. "выравнивание" команд) (в данном случае, когда каждый встретится с каждым хотя бы один раз)
    procedure AdjustTeamRaces; virtual; //"подтягивает" отсечки до ровного кол-ва

    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property Randomization: Boolean read FRandomization write FRandomization;
    property Canceled: Boolean read FCanceled;
    function CreateTour: TTour; //создание тура
    class function GetTourTeamCount(Tour: TTour): Integer; static; //вернет кол-во команд усаженных в туре
  public
    class constructor CreateClass;
    constructor Create; virtual;
    function GetTeamOnBoatRaceCount(const Team: TTeam; const Boat: TBoat): Integer; //вернет количество заездов команды на лодке
    function GetChampCrossTab: TTeamCrossTab;
    function GetTeamOnBoatTable: TIntArrayTable; //получить кросс-таблицу - Лодка (ось X) + Команда (ось Y) = кол-во заездов
    function GetSwimCount(const Team: TTeam): Integer;
    function GetSwimsCountBetweenTwoTeams(const Team1, Team2: TTeam): Integer;
    function GetTogetherSwimCount(const Team: TTeam): Integer; //вернет количество заездов "подряд" (начиная с последнего тура) для команды Team
    function GetTogetherRestCount(const Team: TTeam): Integer; //вернет количество отдыхов "подряд" (начиная с последнего тура) для команды Team
    procedure GetEachWithEachMinMax(var Min, Max: Integer);
    procedure GetRacesMinMax(var Min, Max: Integer); //возвращает общие для всех команд показатели (мин и макс) количества заездов
    procedure Calculate; //запуск расчета
    procedure ReverseTeams(Count: Integer); //перемещает команды местами N-кол-во раз
    procedure CleanDisperse; //сброисить рассадку команд по лодкам
    procedure DisperseBoats; //распределяет участников по яхтам (ToDo: вынести в отдельный класс)
    procedure CorrectDisperse; //Исправить рассадку команд по лодкам
    procedure SaveToFile(Filename: TFilename);
    procedure LoadFromFile(Filename: TFilename);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    // Properties
    property TeamCount: Integer read FTeamCount write FTeamCount;
    property BoatCount: Integer read FBoatCount write FBoatCount;
    property RoundCount: Integer read GetRoundCount;
    property TourMinCount: Integer read FTourMinCount write FTourMinCount;
    property TourMaxCount: Integer read FTourMaxCount write FTourMaxCount;
    property AdjustСutoffs: Boolean read FAdjustСutoffs write FAdjustСutoffs; //True - после "круговой отсечки" корректируется количество гонок для каждой команды до равного кол-ва у всех
    property TourCount: Integer read GetTourCount;
    property CurrentTourIndex: Integer read GetCurrentTourIndex; //текущий расчитываемый тур
    property Championship: TChampionship read GetChampionship; //создает и возвращает копию расчета (итоговой таблицы) который имеется в данный момент времени
    // Events
    property OnTourAdded: TNotifyEvent read FOnTourAdded write FOnTourAdded; //событие генерируется при добавлении алгоритмом нового тура
    property OnCutoff: TCutoffEvent read FOnCutoff write FOnCutoff; //достигнута игровая "отсечка" (определенный результат который нужно зафиксировать клиенту)
    property OnDone: TNotifyEvent read FOnDone write FOnDone;
  end;
  TTournamentAlghoritmClass = class of TTournamentAlghoritm;

implementation

{ TTournamentAlghoritm }

function TTournamentAlghoritm.GetTeamOnBoatRaceCount(const Team: TTeam;
  const Boat: TBoat): Integer;
var
  I: Integer;
begin
  TeamBoundsCheckRaise(Team, 'GetTeamOnBoatTable()');
  BoatBoundsCheckRaise(Boat, 'GetTeamOnBoatTable()');

  Result := 0;
  for I := Low(FChampionship) to High(FChampionship) do
    if FChampionship[I, Team - 1] = Boat then
      Inc(Result);
end;

function TTournamentAlghoritm.GetTeamOnBoatTable: TIntArrayTable;
var
  I, J: Integer;
begin
  SetLength(Result, BoatCount, FTeamCount);
  for I := Low(Result) to High(Result) do
    for J := Low(Result[I]) to High(Result[I]) do
      Result[I][J] := GetTeamOnBoatRaceCount(J + 1, I + 1); //(I + 1, J + 1) //I + 1 - №лодки; J + 1 - №команды
end;

function TTournamentAlghoritm.GetTogetherRestCount(const Team: TTeam): Integer;
var
  I: Integer;
begin
  TeamBoundsCheckRaise(Team, 'GetTogetherRestCount()');

  Result := 0;
  for I := High(FChampionship) downto Low(FChampionship) do
  begin
      if FChampionship[I][Team - 1] >= 0 then
        Exit(Result);

    Inc(Result);
  end;
end;

function TTournamentAlghoritm.GetTogetherSwimCount(const Team: TTeam): Integer;
var
  I: Integer;
begin
  TeamBoundsCheckRaise(Team, 'GetTogetherSwimCount()');

  Result := 0;
  for I := High(FChampionship) downto Low(FChampionship) do
  begin
    if FChampionship[I][Team - 1] >= 0 then
      Inc(Result)
    else
      Exit(Result);
  end;
end;

function TTournamentAlghoritm.GetSwimCount(const Team: TTeam): Integer;
var
  I: Integer;
begin
  TeamBoundsCheckRaise(Team, 'GetSwimCount()');

  Result := 0;
  for I := Low(FChampionship) to High(FChampionship) do
    if FChampionship[I][Team - 1] >= 0 then
      Inc(Result);
end;

function TTournamentAlghoritm.GetSwimsCountBetweenTwoTeams(
  const Team1, Team2: TTeam): Integer;
var
  I: Integer;
begin
  TeamBoundsCheckRaise(Team1, 'GetSwimsCountBetweenTwoTeams(Team1)');
  TeamBoundsCheckRaise(Team2, 'GetSwimsCountBetweenTwoTeams(Team2)');

  Result := 0;
  for I := Low(FChampionship) to High(FChampionship) do
    if (FChampionship[I][Team1 - 1] >= 0)
         and
       (FChampionship[I][Team2 - 1] >= 0)
    then
      Inc(Result);
end;

function TTournamentAlghoritm.GetTourCount: Integer;
begin
  Result := Length(FChampionship);
end;

class function TTournamentAlghoritm.GetTourTeamCount(Tour: TTour): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(Tour) to High(Tour) do
    if Tour[I] >= 0 then Inc(Result);
end;

function TTournamentAlghoritm.GetCurrentTourIndex: Integer;
begin
  Result := Length(FChampionship) + 1;
end;

procedure TTournamentAlghoritm.GetEachWithEachMinMax(var Min, Max: Integer);
var
  I, J: Integer;
  CrossTab: TTeamCrossTab;
begin
  Min := High(Min);
  Max := Low(Max);

  CrossTab := GetChampCrossTab;
    for I := Low(CrossTab) to High(CrossTab) do
      for J := Low(CrossTab[I]) to High(CrossTab[I]) do
        if CrossTab[I][J] > -1 then
          begin
            Min := KMMath.Min([Min, CrossTab[I][J]]);
            Max := KMMath.Max([Max, CrossTab[I][J]]);
          end;
end;

procedure TTournamentAlghoritm.GetRacesMinMax(var Min, Max: Integer);
var
  I, Sw: Integer;
begin
  Min := High(Min);
  Max := Low(Max);

  for I := 1 to TeamCount do
  begin
    Sw := GetSwimCount(I);
    Min := KMMath.Min([Min, Sw]);
    Max := KMMath.Max([Max, Sw]);
  end;
end;

function TTournamentAlghoritm.IsChampDone: Boolean;
var
  Min, Max: Integer;
begin
  GetEachWithEachMinMax(Min, Max);
  Result := Min >= 1;
end;

procedure TTournamentAlghoritm.CleanDisperse;
var
  I, J: Integer;
begin
  for I := Low(FChampionship) to High(FChampionship) do
    for J := Low(FChampionship[I]) to High(FChampionship[I]) do
      if FChampionship[I, J] <> -1 then
        FChampionship[I, J] := 0;
end;

procedure TTournamentAlghoritm.DisperseBoats;
var
  I, J: Integer;
  Sequence: Integer;
  procedure _NextSeq;
  begin
    Inc(Sequence);
    if Sequence > RoundCount then Sequence := 1;
  end;
  function _IsApplicable(const TourIndex, Value: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := Low(FChampionship[TourIndex]) to High(FChampionship[TourIndex]) do
      if FChampionship[TourIndex, I] = Value then Exit(False);
  end;
begin
  CleanDisperse;

  Sequence := 1;
  //пройдем по каждой "клеточке" расчета в порядке: слева на право и сверху в низ
  for I := 0 to TeamCount - 1 do
    for J := Low(FChampionship) to High(FChampionship) do
    begin
      if FChampionship[J, I] = -1 then Continue; //если не плывем - пропустим ячейку
      while not _IsApplicable(J, Sequence) do _NextSeq; //если лодка уже используется в этом туре - возьмем следующую по кругу

      FChampionship[J, I] := Sequence;
      _NextSeq;
    end;

  CorrectDisperse; //скорректируем автоматическую рассадку (попытаемся ее улучшить перемещением позиций)
end;

procedure TTournamentAlghoritm.CorrectDisperse;
var
  TeamOnBoat: TIntArrayTable;

  procedure CorrectRacesCount(const CorrectableValue: Integer);
    function TryReplaceBoats(const TourIndex, Team1Index,
      Team2Index: Integer): Boolean; //проверяет, даст ли замена местами лодок команды1 и команды2 уменьшение "плохого" очка, если даст то заменяет их, и возвращает True; в противном случае ничего не делает и возвращает False
    var
      Boat1, Boat2, Races12, Races21: Integer;
      Team1Applicable, Team2Applicable: Boolean;
    begin
      Boat1 := FChampionship[TourIndex, Team1Index]; //статика
      Boat2 := FChampionship[TourIndex, Team2Index]; //итерируемая

      Races12 := GetTeamOnBoatRaceCount(Team1Index + 1, Boat2);
      Races21 := GetTeamOnBoatRaceCount(Team2Index + 1, Boat1);

      Team1Applicable := (Races12 + 1) < CorrectableValue;
      Team2Applicable := (Races21 + 1) < CorrectableValue;
      Result := Team1Applicable and Team2Applicable;
      if Result then
      begin
        FChampionship[TourIndex, Team1Index] := Boat2;
        FChampionship[TourIndex, Team2Index] := Boat1;
      end;
    end;
  var
    TeamFromIndex, TeamToIndex, BoatIndex, TourIndex: Integer;
    Replaced: Boolean;
  begin
    //для исправления "нехороших цифр" для начала найдем их в кроссе для того чтобы получить по ним доп. информацию (узнать команду и лодку, на которой эта команда плавает Value раз, чтобы уменьшить его на единицу)
    for BoatIndex := Low(TeamOnBoat) to High(TeamOnBoat) do
      for TeamFromIndex := Low(TeamOnBoat[BoatIndex]) to High(TeamOnBoat[BoatIndex]) do
        if TeamOnBoat[BoatIndex, TeamFromIndex] = CorrectableValue then //нашли искомое кол-во заездов (которое попытаемся уменьшить на единицу) в пересечении "команда<->лодка"
        begin
          TeamOnBoat := GetTeamOnBoatTable; //перед каждым поиском "плохого" числа, будем пересчитывать весь кросс
          Replaced := False;
          for TourIndex := Low(FChampionship) to High(FChampionship) do //найдем все пересечения тур<->команда в которых участвует "нехорошая" лодка
          begin
            if Replaced then Break; //если была успешная замена, то это пересечение можно считать уменьшеным на единицу и искать следующее пересечение
            if FChampionship[TourIndex, TeamFromIndex] = (BoatIndex + 1) then
              for TeamToIndex := 0 to TeamCount - 1 do
                if FChampionship[TourIndex, TeamToIndex] <> -1 then //если команда плывет
                begin
                  Replaced := TryReplaceBoats(TourIndex, TeamFromIndex, TeamToIndex);
                  if Replaced then Break; //если успешно "поменяли" команды местами, вернемся на предыдущий цикл (поиск тура с участием) по отсечению оставшихся плохих очков
                end;
          end;
        end;
  end;
var
  MaxRaces: Integer;
  I: Integer;
begin
  MaxRaces := Low(MaxRaces);
  TeamOnBoat := GetTeamOnBoatTable;
  for I := Low(TeamOnBoat) to High(TeamOnBoat) do //найдем максимальное кол-во "нехороших" заездов
    MaxRaces := KMMath.Max([MaxRaces, KMMath.Max(TeamOnBoat[I])]);

  for I := MaxRaces downto 2 do
    CorrectRacesCount(I); //исправить [I]
end;

procedure TTournamentAlghoritm.TeamBoundsCheckRaise(Team: TTeam; APIName: string);
begin
  if Team > TeamCount then
    raise Exception.CreateResFmt(@sOutOfBoundsFmt,
      [APIName, 'Team', Team, TeamCount]);
end;

procedure TTournamentAlghoritm.BoatBoundsCheckRaise(Boat: TTeam;
  APIName: string);
begin
  if Boat > RoundCount then
    raise Exception.CreateResFmt(@sOutOfBoundsFmt,
      [APIName, 'Boat', Boat, RoundCount]);
end;

procedure TTournamentAlghoritm.AdjustTeamRaces;
var
  Min, Max, CurrMin, CurrMax: Integer;
  Tour: TTour;
  BoatList: TList<TSortedInfo>;
  I: Integer;
begin
  GetRacesMinMax(Min, Max);

  BoatList := TList<TSortedInfo>.Create(TSortedComparer.Create(BoatCount));
  try
    repeat
      BoatList.Clear;
      for I := 1 to TeamCount do
        BoatList.Add(TSortedInfo.Create(I, GetSwimCount(I), 0));
      BoatList.Sort;

      Tour := CreateTour;
      for I := 1 to RoundCount do
        Tour[BoatList[I - 1].SortableNo - 1] := 0;

      AddTour(Tour);

      GetRacesMinMax(CurrMin, CurrMax);
    until (CurrMin >= Max); //прервем, когда дойдем до требуемого показателя на начало подгонки - "Max"
  finally
    BoatList.Free;
  end;
end;

procedure TTournamentAlghoritm.Calculate;
var
  _Tour: TTour;
  Min, Max: Integer;
begin
  FCanceled := False;
  FStartedAt := Now;
  FChampionship := nil;
  try
    PrepareCalculation; //вызовем метод инициализации конечного алгоритма

   //если в initcalc'e были какие то расчеты, не будем обрабатывать отсечки
     GetEachWithEachMinMax(Min, Max);
     FLastGameCut := Min;
     GetRacesMinMax(Min, Max);
     FLastTourCut := Min;

    while (
     (not IsChampDone) //турнир не досчтит
         or (Length(FChampionship) < FTourMinCount))
     and (not FCanceled) //не отменено
     and ( (FTourMaxCount < 1) or ((Length(FChampionship) < FTourMaxCount)) )
    do
    begin
      _Tour := CalculateTour;
      if not FCanceled then //если в процессе расчета тур не был отменен... (НЕ УБИРАТЬ!!!)
        AddTour(_Tour);

      {if (IsChampDone) and (AdjustСutoffs) then //если расчет окончен и требуется выровнять кол-во заездов у команд после расчета...
        AdjustTeamRaces; //...подгоним их}
    end;
  finally
    FCompletedAt := Now;
    DoDone;
  end;
end;

constructor TTournamentAlghoritm.Create;
begin
end;

class constructor TTournamentAlghoritm.CreateClass;
begin
  Randomize;
end;

function TTournamentAlghoritm.CreateTour: TTour;
var
  I: Integer;
begin
  SetLength(Result, TeamCount);
  for I := Low(Result) to High(Result) do
    Result[I] := -1;
end;

procedure TTournamentAlghoritm.AddTour(const Tour: TTour);
var
  Min, Max: Integer;
begin
  SetLength(FChampionship, Length(FChampionship) + 1);
  FChampionship[High(FChampionship)] := Tour;

  DoTourAdded;

  //есть отсечки?
  GetEachWithEachMinMax(Min, Max);
  if Min > FLastGameCut then
  begin //отсечка (каждый с каждым)
    FLastGameCut := Min;
    DoCutoff(ckEachWithEach, Min, Max);

    if AdjustСutoffs then {ToDo: перенести в Calculate}
      AdjustTeamRaces;
  end;
  //отсечка (новый круг)
  GetRacesMinMax(Min, Max);
  if Min > FLastTourCut then
  begin
    FLastTourCut := Min;
    DoCutoff(ckCircle, Min, Max);
  end;
end;

procedure TTournamentAlghoritm.PrepareCalculation;
begin
end;

procedure TTournamentAlghoritm.ReverseTeams(Count: Integer);
var
  I, J: Integer;
  FromPos, ToPos: Integer;
  FromValue, ToValue: Integer;
begin
  for I := 1 to Count do
  begin
    FromPos := Random(FTeamCount);
    ToPos   := Random(FTeamCount);
    for J := Low(FChampionship) to High(FChampionship) do
    begin
      FromValue := FChampionship[J][FromPos];
      ToValue := FChampionship[J][ToPos];

      FChampionship[J][FromPos] := ToValue;
      FChampionship[J][ToPos] := FromValue;
    end;
  end;
end;

procedure TTournamentAlghoritm.SaveToStream(Stream: TStream);
var
  I, J: Integer;
  _TourCount: Integer;
begin
  if Length(FChampionship) < 1 then
    raise Exception.CreateRes(@sNothingToSave);

  _TourCount := TourCount;

  Stream.Write(BinarySign[1], Length(BinarySign)); //сигнатура
  Stream.Write(BinaryVer, SizeOf(BinaryVer)); //версия формата данных
  //заголовок
    Stream.Write(TeamCount, SizeOf(TeamCount));
    Stream.Write(BoatCount, SizeOf(BoatCount));
    Stream.Write(_TourCount, SizeOf(Integer));
  //данные
    for I := Low(FChampionship) to High(FChampionship) do
      for J := Low(FChampionship[I]) to High(FChampionship[I]) do
        Stream.Write(FChampionship[I, J], SizeOf(FChampionship[I, J]));
end;

procedure TTournamentAlghoritm.LoadFromStream(Stream: TStream);
  procedure _Read(var Buffer; const Count: Cardinal);
  var
    _len: Cardinal;
  begin
    _len := Stream.Read(Buffer, Count);
    if _len <> Count then
      raise Exception.CreateRes(@sInvalidFormatVersion);
  end;
var
  Sign: AnsiString;
  Ver: Cardinal;
  _TeamCount, _BoatCount, _TourCount: Integer;
  I: Integer;
  Tour: TTour;
begin
  FChampionship := nil;

  SetLength(Sign, Length(BinarySign));
  _Read(Sign[1], Length(Sign));
  if Sign <> BinarySign then
    raise Exception.CreateRes(@sInvalidSign);
  _Read(Ver, SizeOf(Ver));
  if Ver > BinaryVer then //версия формата не совместима с загрузчиком
    raise Exception.CreateRes(@sInvalidFormatVersion);
  _Read(_TeamCount, SizeOf(_TeamCount));
  _Read(_BoatCount, SizeOf(_BoatCount));
  _Read(_TourCount, SizeOf(_TourCount));
  TeamCount := _TeamCount;
  BoatCount := _BoatCount;

  for I := 1 to _TourCount - 1 do
  begin
    Tour := CreateTour;
    _Read(Tour[0], SizeOf(Tour[0]) * Length(Tour));
    AddTour(Tour);
  end;

  if Length(FChampionship) > 0 then DoDone; //если что либо было загружено
end;

procedure TTournamentAlghoritm.SaveToFile(Filename: TFilename);
var
  S: TFileStream;
begin
  S := TFileStream.Create(Filename, fmCreate);
  try
    SaveToStream(S);
  finally
    S.Free;
  end;
end;

procedure TTournamentAlghoritm.LoadFromFile(Filename: TFilename);
var
  S: TFileStream;
begin
  S := TFileStream.Create(Filename, fmOpenRead);
  try
    LoadFromStream(S);
  finally
    S.Free;
  end;
end;

procedure TTournamentAlghoritm.DoCutoff(CutoffKind: TTourEventKind; const Min,
  Max: Integer);
begin
  if Assigned(FOnCutoff) then
    FOnCutoff(Self, CutoffKind, Min, Max);
end;

procedure TTournamentAlghoritm.DoDone;
begin
  if Assigned(FOnDone) then
    FOnDone(Self);
end;

procedure TTournamentAlghoritm.DoProgress(const Current, Max: Integer);
begin
  if Assigned(FOnProgress) then
    try
      FOnProgress(Self, Current, Max);
    except
      on E: EAbort do
        FCanceled := True;
    end;
end;

procedure TTournamentAlghoritm.DoTourAdded;
begin
  if Assigned(FOnTourAdded) then
    try
      FOnTourAdded(Self);
    except
      on E: EAbort do
        FCanceled := True;
    end;
end;

function TTournamentAlghoritm.GetChampCrossTab: TTeamCrossTab;
var
  I, J: Integer;
begin
  SetLength(Result, FTeamCount, FTeamCount);
  for I := Low(Result) to High(Result) do
    for J := Low(Result[I]) to High(Result[I]) do
      if (j - i) > 0 then
        Result[I][J] := GetSwimsCountBetweenTwoTeams(I + 1, J + 1)
      else
        Result[I][J] := -1;
end;

function TTournamentAlghoritm.GetChampionship: TChampionship;
var
  I, J: Integer;
begin
  if Length(FChampionship) < 1 then
    Exit(nil);

  //clone as well
  SetLength(Result, Length(FChampionship));
  for I := Low(Result) to High(Result) do
    begin
      SetLength(Result[I], Length(FChampionship[I]));
      for J := Low(Result[I]) to High(Result[I]) do
        Result[I][J] := FChampionship[I][J];
    end;
end;

function TTournamentAlghoritm.GetRoundCount: Integer;
begin
  Result := Min([BoatCount, TeamCount]);
end;

{ TTeamComparer }

function TSortedComparer.Compare(const Left,
  Right: TSortedInfo): Integer;
begin
  Result := Left.SwimCount - Right.SwimCount;
end;

{ TTeamSwimsInfo }

constructor TSortedInfo.Create(ASortableNo: Integer; ASwimCount,
  ARestCount: Integer);
begin
  SortableNo := ASortableNo;
  SwimCount := ASwimCount;
  RestCount := ARestCount;
end;

constructor TSortedComparer.Create(ARandMax: Integer);
begin
  FRandMax := ARandMax;
end;

{ TSortedDetailedComparer }

constructor TSortedDetailedComparer.Create(ARandMax: Integer;
  ARestConsider: Boolean);
begin
  FRandMax := ARandMax;
  FRestConsider := ARestConsider;
end;

function TSortedDetailedComparer.Compare(const Left,
  Right: TSortedInfo): Integer;
begin
  Result := Left.SwimCount - Right.SwimCount;

  if Result = 0 then
  begin
    if FRestConsider then //если требуется учет отдыха между заездами...
      Result := Right.RestCount - Left.RestCount;
    if Result = 0 then
      if FRandMax > 0 then
        Result := Random(FRandMax) - Random(FRandMax)
      else
        Result := Left.SortableNo - Right.SortableNo;
  end;
end;

end.
