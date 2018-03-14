unit Tournaments.Alg1;

interface

uses
  Generics.Collections,
  Generics.Defaults,

  KMMath,

  Tournaments.Calculations;

type
  TTournamentAlghoritmOne = class(TTournamentAlghoritm)
  private
    FRandomizationHigh: Integer;
    FRestConsider: Boolean;
    FJointSwimLimit: Integer;
    function ForceAddTeam(TeamList: TList<TSortedInfo>; Tour: TTour;
      JointSwimCurrent: Integer): Boolean;
  protected
    procedure PrepareCalculation; override;
    function CalculateTour: TTour; override;
  public
    property RestConsider: Boolean read FRestConsider write FRestConsider;
    property Randomization;
    property JointSwimLimit: Integer read FJointSwimLimit write FJointSwimLimit;
  end;


implementation

{ TTournamentAlghoritmOne }

procedure TTournamentAlghoritmOne.PrepareCalculation;
begin
  inherited;

  if Randomization then
    FRandomizationHigh := TeamCount * 2
  else
    FRandomizationHigh := 0;
end;

function TTournamentAlghoritmOne.CalculateTour: TTour;
var
  TeamList: TList<TSortedInfo>;
  JointSwimCurrent: Integer;
  I: Integer;
begin
  //1. ищем тех, кто заплывал меньше остальных
  TeamList := TList<TSortedInfo>.Create(TSortedDetailedComparer.Create(FRandomizationHigh, FRestConsider));
  with TeamList do //список с очками сортировки
  try
    for I := 1 to TeamCount do
      Add(TSortedInfo.Create(I, GetSwimCount(I), GetTogetherRestCount(I))); //добавляем - команда; кол-во заплывов этой команды; туров отдыха (подряд) этой команды

    //отсортируем команды по правилам сортировки
    Sort;

    Result := CreateTour;
    JointSwimCurrent := 1;

    while (GetTourTeamCount(Result) < RoundCount) and ((JointSwimLimit > -1) or (JointSwimCurrent >= JointSwimLimit)) do
    begin
      repeat //локальная рекурсия
      until (not ForceAddTeam(TeamList, Result, JointSwimCurrent)) or (GetTourTeamCount(Result) = RoundCount); //добавляем "оптимальную" команду в тур

      Inc(JointSwimCurrent);
    end;
  finally
    Free;
  end;
end;

function TTournamentAlghoritmOne.ForceAddTeam(TeamList: TList<TSortedInfo>;
  Tour: TTour; JointSwimCurrent: Integer): Boolean;
  //подбирает команду, которая ни разу не плавала с теми, кто уже есть в этом туре
  //если таковую команду подобрать таки удалось, то вернет - True; иначе - False
  //TeamList - все доступные к подбору команды
  //Tour - уже добавленные команды
var
  I, J: Integer;
  Applicable: Boolean;
begin
  for I := 0 to TeamList.Count - 1 do //"проходим" по всем доступным для выбора командам...
    if Tour[TeamList[I].SortableNo - 1] < 0 then
    begin
      Applicable := True;
      for J := Low(Tour) to High(Tour) do //проверяем - подходит ли текущая команда к каждой из команд в данном туре\
        if Tour[J] >= 0 then
          if GetSwimsCountBetweenTwoTeams(TeamList[I].SortableNo, J + 1) >= JointSwimCurrent then //если эти две команды сплавали между собой больше, чем это позволительно на данном этапе (пар.: SwimLimit)
          begin
            Applicable := False; //задаем признак - данные команды не применимы в этом туре
            Break; //пытаемся подобрать следующую
          end;
      if Applicable then //если команда применима ко всем остальным в данном туре...
      begin
        Tour[TeamList[I].SortableNo - 1] := 0;
        Exit(True);
      end;
    end;

  Result := False; // не подобрали :-(
end;

end.
