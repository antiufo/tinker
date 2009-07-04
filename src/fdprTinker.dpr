program fdprTinker;

uses
  Forms,
  ffrmTinker in 'ffrmTinker.pas' {frmTinker},
  fbblTinker in 'fbblTinker.pas',
  ffrmHelp in 'ffrmHelp.pas' {frmAiuto},
  frmEsito in 'frmEsito.pas' {frmEsitoPartita};

// ffrmCaricamento in 'ffrmCaricamento.pas' {frmCaricamento};

{$R *.res}

begin
  //MessaggioErrore('dfg');
  Application.Initialize;
  Application.Title := 'Tinker';
  Application.CreateForm(TfrmTinker, frmTinker);
  Application.CreateForm(TfrmAiuto, frmAiuto);
  // Application.CreateForm(TfrmCaricamento, frmCaricamento);
 // frmCaricamento.Show();
 // frmTinker.Show();
 // frmCaricamento.Hide();
  Application.Run;

end.
