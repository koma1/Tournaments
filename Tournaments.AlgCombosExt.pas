unit Tournaments.AlgCombosExt;

interface

uses
  Tournaments.Calculations,
  Tournaments.AlgCombos;

type
  TTournamentAlghoritmCombosExt = class(TTournamentAlghoritmCombos)
  protected
    procedure PrepareCalculation; override;
  public
    property Randomization;
  end;

implementation

uses
  Tournaments.Alg1;

{ TTournamentAlghoritmCombosExt }

procedure TTournamentAlghoritmCombosExt.PrepareCalculation;
var
  PredefAlg: TTournamentAlghoritmOne;
  PredefCount: Integer;
  _Championship: TChampionship;
  I: Integer;
begin
  PredefCount := TeamCount div BoatCount;
  PredefAlg := TTournamentAlghoritmOne.Create;
  try
    PredefAlg.TourMinCount := PredefCount;
    PredefAlg.TourMaxCount := PredefCount;
    PredefAlg.Randomization := Randomization;
    PredefAlg.TeamCount := TeamCount;
    PredefAlg.BoatCount := BoatCount;

    PredefAlg.Calculate;
    _Championship := PredefAlg.Championship;
  finally
    PredefAlg.Free;
  end;

  for I := Low(_Championship) to High(_Championship) do
    AddTour(_Championship[I]);

  inherited;
end;

end.
