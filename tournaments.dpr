program tournaments;

uses
  Vcl.Forms,
  uTourTable in 'uTourTable.pas' {TourTableForm},
  Tournaments.Calculations in 'Tournaments.Calculations.pas',
  {$IFDEF DEBUG}
  uCrossTabsForm in 'uCrossTabsForm.pas' {CrossTabsForm},
  {$ENDIF }
  uProgressForm in 'uProgressForm.pas' {ProgressForm},
  Tournaments.Controls in 'Tournaments.Controls.pas',
  Tournaments.Consts in 'Tournaments.Consts.pas',
  Tournaments.Alg1 in 'Tournaments.Alg1.pas',
  Tournaments.AlgCombos in 'Tournaments.AlgCombos.pas',
  Tournaments.AlgCombosExt in 'Tournaments.AlgCombosExt.pas',
  KMMath in 'KMMath.pas';

{TourTableForm}

{$R *.res}

begin
  {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Расчет турнирных таблиц';
  Application.CreateForm(TTourTableForm, TourTableForm);
  {$IFDEF DEBUG} Application.CreateForm(TCrossTabsForm, CrossTabsForm); {$ENDIF}
  Application.Run;
end.
