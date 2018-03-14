unit uCrossTabsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids,
  Generics.Collections,

  Tournaments.Calculations;

type
  TCrossTabsForm = class(TForm)
  private
    FCount: Integer;
  public
    procedure AddChampionship(ACaption: string; TeamCrossTab: TTeamCrossTab);
    function CreateSwimsCT(AOwner: TComponent;
      TeamCrossTab: TTeamCrossTab): TStringGrid;
  end;

var
  CrossTabsForm: TCrossTabsForm;

implementation

uses
  KMMath;

{$R *.dfm}

{ TCrossTabsForm }

function TCrossTabsForm.CreateSwimsCT(AOwner: TComponent;
  TeamCrossTab: TTeamCrossTab): TStringGrid;
var
  CrossTabStat: TDictionary<Integer,Integer>;
  I, J: Integer;
  Points: Integer;
  CrossTabHint: string;
  CrossTabStatItem: TPair<Integer,Integer>;
begin
  Result := TStringGrid.Create(AOwner);
  try
    Result.ColCount := Length(TeamCrossTab) + 1;
    Result.RowCount := Length(TeamCrossTab) + 1;

    CrossTabStat := TDictionary<Integer,Integer>.Create;
    try
      for I := 0 to Result.ColCount - 1 do
        for J := 0 to Result.RowCount - 1 do
          if ((j - i) > 0) or (j = 0) then //если нижняя диагональ, либо ячейки с номером команды
          begin
            if (I = 0) or (J = 0) then //Fixed - с номером команды
              Result.Cells[I, J] := IntToStr(Max([I, J]))
            else
            begin
              Points := TeamCrossTab[I - 1, J - 1];
              if CrossTabStat.ContainsKey(Points) then
                CrossTabStat.Items[Points] := CrossTabStat.Items[Points] + 1 //если есть - увеличим на единицу
              else
                CrossTabStat.Add(Points, 1); //иначе - добавим

              Result.Cells[I, J] := IntToStr(Points);
            end
          end
          else Result.Cells[I, J] := '';
      CrossTabHint := '';

      for CrossTabStatItem in CrossTabStat do
        CrossTabHint := CrossTabHint + Format('%d: %d' + sLineBreak,
          [CrossTabStatItem.Key, CrossTabStatItem.Value]);

      Result.Hint := CrossTabHint;
    finally
      CrossTabStat.Free;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TCrossTabsForm.AddChampionship(ACaption: string;
  TeamCrossTab: TTeamCrossTab);
var
  gb: TGroupBox;
  sg: TStringGrid;
begin
  gb := TGroupBox.Create(Self);
  try
    with gb do
    begin
      Parent := Self;
      Align := alTop;
      Caption := ACaption;
      sg := CreateSwimsCT(gb, TeamCrossTab);
      with sg do
      begin
        Parent := gb;
        Align := alClient;
        DefaultColWidth := 24;
        ShowHint := True;
      end;

      Width := sg.DefaultColWidth * (sg.ColCount + 2);
      Height := sg.DefaultRowHeight * (sg.RowCount + 2);
      Top := FCount + 1;
    end;

    Inc(FCount);
  except
    gb.Free;
    raise;
  end;
end;

end.
