unit Tournaments.Controls;

interface

uses
  System.SysUtils,
  Vcl.Grids,
  Generics.Collections,
  KMMath,

  Tournaments.Consts,
  Tournaments.Calculations;

type
  TStringGridTournaments = class helper for TStringGrid
  public
    procedure DrawChampionship(Championship: TChampionship);
    procedure DrawSummary(Alghoritm: TTournamentAlghoritm);
    procedure DrawCrosstab(TeamSwimsCrossTab: TTeamCrossTab);
    procedure DrawIntArrayTable(BoatsDisperse: TIntArrayTable);
  end;

implementation

function __GetBoatAsText(Team: TTeam; Tour: TTour): string;
begin
  if Tour[Team - 1] > 0 then
    Result := Format(sBoatWithNumberFmt, [Tour[Team - 1]])
  else if Tour[Team - 1] = 0 then
    Result := '+'
  else
    Result := '';
end;

{ TStringGridTournaments }

procedure TStringGridTournaments.DrawIntArrayTable(
  BoatsDisperse: TIntArrayTable);
var
  I, J: Integer;
begin
  ColCount := Length(BoatsDisperse) + 1;
  RowCount := Length(BoatsDisperse[0]) + 1;

  //’инт кросс-таба
    for I := 0 to ColCount - 1 do
      for J := 0 to RowCount - 1 do
        if (I = 0) and (J <> 0) then
          Cells[I, J] := IntToStr(J)
        else if (J = 0) and (I <> 0) then
          Cells[I, J] := IntToStr(I)
        else if (J <> 0) and (I <> 0) then
          Cells[I, J] := IntToStr(BoatsDisperse[I - 1, J - 1]);


        {if ((j - i) > 0) or (j = 0) then //если нижн€€ диагональ, либо €чейки с номером команды
        begin
          if (I = 0) or (J = 0) then //Fixed с номером команды
            Cells[I, J] := IntToStr(Max([I, J]))
          else
            Cells[I, J] := IntToStr(BoatsDisperse[I - 1, J - 1]);
        end
        else Cells[I, J] := '';}
end;

procedure TStringGridTournaments.DrawChampionship(Championship: TChampionship);
var
  TourCount, TeamCount: Integer;
  I, J: Integer;
begin
  ColCount := 1;
  RowCount := 1;

  TourCount := Length(Championship);
  if TourCount > 0 then
  begin
    TeamCount := Length(Championship[0]);

    ColCount := TourCount + 1;
    RowCount := TeamCount + 1;

    for I := 1 to TeamCount do
      Cells[0, I] := Format(sTeamWithNumberFmt, [I]);
    for I := 1 to TourCount do
      Cells[I, 0] := Format(sRaceWithNumberFmt, [I]);

    for I := Low(Championship) to High(Championship) do
      for J := 0 to TeamCount - 1 do
        Cells[I + 1, J + 1] := __GetBoatAsText(J + 1, Championship[I]);

    FixedCols := 1;
    FixedRows := 1;
  end;
end;

procedure TStringGridTournaments.DrawCrosstab(TeamSwimsCrossTab: TTeamCrossTab);
var
  I, J: Integer;
begin
  ColCount := Length(TeamSwimsCrossTab) + 1;
  RowCount := Length(TeamSwimsCrossTab) + 1;

  //’инт кросс-таба
    for I := 0 to ColCount - 1 do
      for J := 0 to RowCount - 1 do
        if ((j - i) > 0) or (j = 0) then //если нижн€€ диагональ, либо €чейки с номером команды
        begin
          if (I = 0) or (J = 0) then //Fixed с номером команды
            Cells[I, J] := IntToStr(Max([I, J]))
          else
            Cells[I, J] := IntToStr(TeamSwimsCrossTab[I - 1, J - 1]);
        end
        else Cells[I, J] := '';
end;

procedure TStringGridTournaments.DrawSummary(Alghoritm: TTournamentAlghoritm);
var
  TeamCount: Integer;
  I: Integer;
begin
  ColCount := 2;
  TeamCount := Alghoritm.TeamCount;

  RowCount := TeamCount + 1;
  Cells[0, 0] := sTeam;
  Cells[1, 0] := sRaceCount;
  for I := 1 to TeamCount do
  begin
    Cells[0, I] := Format(sTeamWithNumberFmt, [I]); //є команды
    Cells[1, I] := IntToStr(Alghoritm.GetSwimCount(I)); //общее заплывов
  end;

  FixedRows := 1;
end;

end.
