unit frmEsito;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmEsitoPartita = class(TForm)
    PaintBox1: TPaintBox;

    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    Vinto : Boolean;
  end;

var
  frmEsitoPartita: TfrmEsitoPartita;

implementation

uses fbblTinker;


{$R *.dfm}

procedure TfrmEsitoPartita.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(Key = 27) then self.Close;
  if(Key = 13) then self.Close;
end;

procedure TfrmEsitoPartita.PaintBox1Paint(Sender: TObject);
begin
  if(vinto) then begin
    PaintBox1.Canvas.Draw(0, 0, Immagini.EsitoPartitaPositivo);
  end else begin
    PaintBox1.Canvas.Draw(0, 0, Immagini.EsitoPartitaNegativo);
  end;

  PaintBox1.Canvas.Brush.Style := bsClear;

  PaintBox1.Canvas.Font.Name := 'Verdana';

  PaintBox1.Canvas.Font.Style := [fsBold];
  PaintBox1.Canvas.Font.Size := 16;
  PaintBox1.Canvas.Font.Color := clYellow;
  PaintBox1.Canvas.TextOut(290, 300, 'Continua');

  PaintBox1.Canvas.Font.Style := [];
  PaintBox1.Canvas.Font.Size := 18;
  PaintBox1.Canvas.Font.Color := clWhite;
  PaintBox1.Canvas.TextOut(100, 130, self.Caption);
end;



procedure TfrmEsitoPartita.FormShow(Sender: TObject);
begin
  //  self.Cursor := crNone;
end;

end.
