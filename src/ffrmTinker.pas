unit ffrmTinker;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, fbblTinker;

type
  TfrmTinker = class(TForm)
    Timer1: TTimer;
    PaintBox1: TPaintBox;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure StopFlicker(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
//    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTinker                   : TfrmTinker;
  //AltezzaRisoluzioneOriginale : Integer;
  //LarghezzaRisoluzioneOriginale : Integer;
implementation

{$R *.dfm}


function SetScreenResolution(Width, Height: integer): Longint;
var
  DeviceMode: TDeviceMode;
begin
  with DeviceMode do begin
    dmSize := SizeOf(TDeviceMode);
    dmPelsWidth := Width;
    dmPelsHeight := Height;
    dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
  end;
  Result := ChangeDisplaySettings(DeviceMode, CDS_FULLSCREEN);
end;

Procedure DimensionamentoAree;
Begin
  PaintBox.Left := 0;
  PaintBox.Top := 0;
  PaintBox.Width := frmTinker.ClientWidth;
  PaintBox.Height := frmTinker.ClientHeight;

  Bitmap.Width := PaintBox.Width;
  Bitmap.Height := PaintBox.Height;
End;




procedure TfrmTinker.FormPaint(Sender: TObject);
begin
  If Not Inizializzato Then Exit;
  MostraFrame(); //Ridisegna il vecchio frame per evitare il flickering
  //DisegnaSchermata();
end;



procedure TfrmTinker.StopFlicker(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;



procedure TfrmTinker.FormCreate(Sender: TObject);
begin
  //Panel1.Tag := 4434; //some sentinel value
 // Form1.Panel1.DoubleBuffered := True;
  //Form1.DoubleBuffered := True;
  Bitmap := TBitmap.Create;
  PaintBox := frmTinker.PaintBox1;


  //BUG-BUG: metodo spartano per cambiare e ripristinare risoluzione, tutte le finestre vengono rimpicciolite a 800x600
  frmTinker.Width := 800;
  frmTinker.Height := 600;
  //LarghezzaRisoluzioneOriginale := GetSystemMetrics(SM_CXSCREEN);
  //AltezzaRisoluzioneOriginale := GetSystemMetrics(SM_CYSCREEN);
  //SetScreenResolution(800, 600);


  //frmTinker.Width := Screen.Width - 100;
  //frmTinker.Height := Screen.Height - 200;

  
  DimensionamentoAree();
  CaricamentoImmagini();
  Inizializzato := True;

  //InizializzazioneGioco();
end;

procedure TfrmTinker.Timer1Timer(Sender: TObject);
begin
  //If Not Inizializzato Then Exit;

  If Not Rotazione.AnimazioneInEsecuzione Then Begin
    EsecuzioneLogicaDiGioco();
  End;
  DisegnoSchermata();
end;

procedure TfrmTinker.FormResize(Sender: TObject);
begin
  //If Not Inizializzato Then Exit;
  DimensionamentoAree();
  DisegnoSchermata();
end;


procedure TfrmTinker.FormShow(Sender: TObject);
begin
  InizializzazioneGioco();   {
  Elementi.Vettore[5].X:=5;
  Elementi.Vettore[6].X:=5;
  Elementi.Vettore[7].Y:=5;
  Elementi.Vettore[7].Z:=5;
  Elementi.Vettore[7].X:=5;
  Elementi.Vettore[7].X:=5; }
end;

procedure TfrmTinker.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //If Not Inizializzato Then Exit;
  If Occupato Then Exit;
  //application.Title :='fgh'; //TEMPTEMP

  If Rotazione.AnimazioneInEsecuzione Then Exit;
  
  If Key = $6D {Numpad minus} Then
    RotazioneScacchiera(-1);
  If Key = $6B {Numpad plus} Then
    RotazioneScacchiera(1);

  If Key = $55 Then Begin
    //AggiuntaElemento(BloccoFisso,2,4,1, 0, False, 0);
    
   // AggiuntaElemento(BloccoFisso, 1,1,1, 0, False, 0);
   // AggiuntaElemento(BloccoFisso, 2,2,2, 0, False, 0);

    AggiuntaElemento(Robot, 2,1,2, 1, False, 0);
  //  AggiuntaElemento(Robot, 2,1,1, 1, False, 0);
    AggiuntaElemento(Ascensore, 2,3,1, 1, True, 0);
    AggiuntaElemento(BloccoFisso, 1,1,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 1,2,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 1,3,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 1,3,2, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 1,5,1, 0, False, 0);
    AggiuntaElemento(Ascensore, 1,6,1, 0, False, 0);

    AggiuntaElemento(BloccoFisso, 4,1,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 4,2,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 4,3,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 4,4,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 5,1,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 5,2,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 5,3,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 5,4,1, 0, False, 0);
    
    AggiuntaElemento(BloccoMobile, 6,6,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 7,7,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 7,7,2, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 7,7,3, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 7,7,4, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 7,8,4, 0, False, 0);

   
   { AggiuntaElemento(BloccoFisso, 1,1,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 1,2,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 1,3,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile,7,3,2, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 1,5,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile,7,2,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile,7,3,1, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 6,3,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 6,4,1, 0, False, 0);
    AggiuntaElemento(BloccoMobile, 6,4,2, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 6,4,3, 0, False, 0);
    AggiuntaElemento(BloccoFisso, 2,5,2, 0, False, 0);  
    AggiuntaElemento(BloccoMobile, 6,4,10, 0, False, 0);
    AggiuntaElemento(Robot,1,1,2, 0, False, 0);      }


    {AggiuntaElemento(5,4,1,1, 0, False, 0);
    AggiuntaElemento(5,1,3,1, 0, False, 0);
    AggiuntaElemento(5,2,8,1, 0, False, 0);
    AggiuntaElemento(5,3,8,2, 0, False, 0);
    AggiuntaElemento(5,1,5,1, 0, False, 0);
    AggiuntaElemento(5,1,5,1, 0, False, 0);   }
  End;

  //
  If pRobot = Nil Then Exit;

  If Key = VK_LEFT Then
    GiraRobot(-1);
  If Key = VK_RIGHT Then
    GiraRobot(1);
  If Key = VK_DOWN Then
    GiraRobot(2);

  If pRobot^.Animazione.InEsecuzione Then Exit;


  If Key = VK_UP Then
    AvanzaRobot();



 // If Key = VK_DOWN Then
 //   RotazioneScacchiera(-1);

   // AggiuntaElemento(5,2,3,2, 0, False, 0);
  //If Key = 'i' Then
  //  AggiuntaElemento(5,2,2,1, 0, False, 0);


end;

{
procedure TfrmTinker.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //SetScreenResolution(LarghezzaRisoluzioneOriginale, AltezzaRisoluzioneOriginale);
end;
}

end.
