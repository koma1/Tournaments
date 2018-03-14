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
  //1. ���� ���, ��� �������� ������ ���������
  TeamList := TList<TSortedInfo>.Create(TSortedDetailedComparer.Create(FRandomizationHigh, FRestConsider));
  with TeamList do //������ � ������ ����������
  try
    for I := 1 to TeamCount do
      Add(TSortedInfo.Create(I, GetSwimCount(I), GetTogetherRestCount(I))); //��������� - �������; ���-�� �������� ���� �������; ����� ������ (������) ���� �������

    //����������� ������� �� �������� ����������
    Sort;

    Result := CreateTour;
    JointSwimCurrent := 1;

    while (GetTourTeamCount(Result) < RoundCount) and ((JointSwimLimit > -1) or (JointSwimCurrent >= JointSwimLimit)) do
    begin
      repeat //��������� ��������
      until (not ForceAddTeam(TeamList, Result, JointSwimCurrent)) or (GetTourTeamCount(Result) = RoundCount); //��������� "�����������" ������� � ���

      Inc(JointSwimCurrent);
    end;
  finally
    Free;
  end;
end;

function TTournamentAlghoritmOne.ForceAddTeam(TeamList: TList<TSortedInfo>;
  Tour: TTour; JointSwimCurrent: Integer): Boolean;
  //��������� �������, ������� �� ���� �� ������� � ����, ��� ��� ���� � ���� ����
  //���� ������� ������� ��������� ���� �������, �� ������ - True; ����� - False
  //TeamList - ��� ��������� � ������� �������
  //Tour - ��� ����������� �������
var
  I, J: Integer;
  Applicable: Boolean;
begin
  for I := 0 to TeamList.Count - 1 do //"��������" �� ���� ��������� ��� ������ ��������...
    if Tour[TeamList[I].SortableNo - 1] < 0 then
    begin
      Applicable := True;
      for J := Low(Tour) to High(Tour) do //��������� - �������� �� ������� ������� � ������ �� ������ � ������ ����\
        if Tour[J] >= 0 then
          if GetSwimsCountBetweenTwoTeams(TeamList[I].SortableNo, J + 1) >= JointSwimCurrent then //���� ��� ��� ������� �������� ����� ����� ������, ��� ��� ������������� �� ������ ����� (���.: SwimLimit)
          begin
            Applicable := False; //������ ������� - ������ ������� �� ��������� � ���� ����
            Break; //�������� ��������� ���������
          end;
      if Applicable then //���� ������� ��������� �� ���� ��������� � ������ ����...
      begin
        Tour[TeamList[I].SortableNo - 1] := 0;
        Exit(True);
      end;
    end;

  Result := False; // �� ��������� :-(
end;

end.
