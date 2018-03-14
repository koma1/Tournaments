unit uProgressForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls;

type
  TProgressForm = class(TForm)
    lblTourNumber: TLabel;
    pb: TProgressBar;
    statsb: TStatusBar;
    tmrTime: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure tmrTimeTimer(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    FStartedAt, FTourStartedAt: TDateTime;
    FOnCancelRequest: TNotifyEvent;
  protected
    procedure DoCancelRequest; virtual;
  public
    procedure NewTour(const Tour: Integer);
    procedure ProgressChanged(const Current, Total: Integer);
  published
    property OnCancelRequest: TNotifyEvent read FOnCancelRequest
      write FOnCancelRequest;
  end;

implementation

{$R *.dfm}

procedure TProgressForm.DoCancelRequest;
begin
  if Assigned(FOnCancelRequest) then
    FOnCancelRequest(Self);
end;

procedure TProgressForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  DoCancelRequest;

  CanClose := False;
end;

procedure TProgressForm.FormHide(Sender: TObject);
begin
  tmrTime.Enabled := False;
end;

procedure TProgressForm.FormShow(Sender: TObject);
begin
  tmrTime.Enabled := True;
  FStartedAt := Now;
end;

procedure TProgressForm.NewTour(const Tour: Integer);
begin
  FTourStartedAt := Now;
  lblTourNumber.Caption := Format('Òóð ¹ %d', [Tour])
end;

procedure TProgressForm.ProgressChanged(const Current, Total: Integer);
begin
  pb.Max := Total;
  pb.Position := Current;
  statsb.Panels[1].Text := Format('%d / %d', [Current, Total]);

  Application.ProcessMessages;
end;

procedure TProgressForm.tmrTimeTimer(Sender: TObject);
begin
  statsb.Panels[0].Text := TimeToStr(Now - FTourStartedAt);
  statsb.Panels[2].Text := TimeToStr(Now - FStartedAt) + '      ';

  Application.ProcessMessages;
end;

end.
