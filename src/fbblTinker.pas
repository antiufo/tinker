unit fbblTinker;

//==============================================================================
  Interface
//==============================================================================


Uses Graphics, ExtCtrls, SysUtils, Forms, Classes, Types;

Type
  TDimensioni2dCubo = Record
                       a : Integer;
                       b : Integer;
                       c : Integer;
                      End;

  TQuattroBitmap = Array[0..3] Of TBitmap;

  TImmagini = Record
                ScacchieraAngoloE         : TBitmap;
                ScacchieraAngoloN         : TBitmap;
                ScacchieraAngoloW         : TBitmap;
                ScacchieraAngoloS         : TBitmap;
                ScacchieraBordoNE         : TBitmap;
                ScacchieraBordoNW         : TBitmap;
                ScacchieraBordoSW         : TBitmap;
                ScacchieraBordoSE         : TBitmap;
                ScacchieraCellaBianca     : TBitmap;
                ScacchieraCellaNera       : TBitmap;
                Cubo                      : TBitmap;
                Cubo2                     : TBitmap;
                TestFrame                 : TBitmap;
                Robot                     : TQuattroBitmap;   
                AscensoreOff              : TBitmap;
                AscensoreOn               : TBitmap;
              End;



  TTipoElemento = ( BloccoFisso, BloccoMobile, BloccoGhiaccio, BloccoMetallico, BloccoPuzzle,
                    Ascensore, Nastro, Teletrasporto,
                    InterruttorePavimento, InterruttorePuzzle, InterruttoreBersaglio, InterruttoreLevetta,
                    Bomba, Porta, Calamita, Specchio, Pistola,
                    Pila, Ruota,
                    Robot);

  TEntitaDiAttraversamento = (Personaggio, Blocco, Laser);

  TInformazioniRotazione = Record
                               Direzione              : Integer; // -1 o 1
                               PosizioneAnimazione    : Real;    // 0..1
                               OrientamentoScacchiera : Integer; // 0..3
                               AnimazioneInEsecuzione : Boolean;
                           End;

  TPosizione3d = Record
                   X : Real;
                   Y : Real;
                   Z : Real;
                 End;

  TpElemento = ^TElemento;

  TAnimazione = Record
                   X : Integer; // -1, 0 o 1
                   Y : Integer;
                   Z : Integer;
                   Direzione    : Integer;
                   Progresso    : Real;
                   InEsecuzione : Boolean;
                   Destinazione          : TPosizione3d;  // Posizione logica di fine animazione
                 End;
  TElemento = Record
                Tipo         : TTipoElemento;
                Orientamento : Integer;
                Posizione             : TPosizione3d;  // Posizione logica prima dell'animazione animazione
                PosizioneFisica       : TPosizione3d;  // Posizione effettiva nello spazio fisico (cambia durante l'animazione)
                Animazione            : TAnimazione;   // Informazioni sulla direzione di animazione
                PrioritaDiDisegno : Real;
                Attivato     : Boolean;
                Colore       : Integer;
              End;
              

  TArraypElementi = Array[1..1000] Of TpElemento;  // BUGBUG: attenzione, massimo mille elementi, poi crash

  TVettorepElementi = Record
                       Vettore    : TArraypElementi;
                       Dimensione : Integer;
                     End;

  TOperazione = Record
                  pElemento   : TpElemento;
                  Direzione   : Integer;
                End;

  TpeCodaOperazioni = ^TeCodaOperazioni;

  TeCodaOperazioni = Record
                       pSuccessivo  : TpeCodaOperazioni;
                       Operazione   : TOperazione;
                     End;

  TCodaOperazioni = Record
                      pInizio   : TpeCodaOperazioni;
                      pFine     : TpeCodaOperazioni;
                    End;



Const
  Dimensioni2dCubo : TDimensioni2dCubo = (
                         a : 17;
                         b : 34;
                         c : 39;
                     );

  AltezzaMassima : Integer = 6;

Var
  PaintBox : TPaintBox;
  Immagini : TImmagini;
  DimensioneScacchiera  : Integer;
  IncrementoCoordinataX : Real;
  IncrementoCoordinataY : Real;
  Bitmap                : TBitmap;
  Rotazione             : TInformazioniRotazione;
Var
  Elementi              : TVettorepElementi;
  pRobot                : TpElemento;
  CodaOperazioni        : TCodaOperazioni; 



Procedure InizializzazioneGioco();
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; Posizione : TPosizione3d; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; X: Real; Y: Real; Z: Real; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Procedure CaricamentoImmagini();
Procedure CaricamentoQuattroImmagini(Var QuattroImmagini : TQuattroBitmap; Const BaseNome : String);
Procedure CaricamentoImmagine(Var Bitmap : TBitmap; Const NomeFile : String);
Procedure DisegnoArea(Const Immagine : TBitmap; Const x : Real; Const y : Real; Const z : Real);
Procedure MostraFrame();

Procedure DisegnoSchermata();

Procedure DisegnoScacchiera();
Procedure DisegnoAnimazioneRotazione();
Procedure DisegnoElementi();


Function ImmagineDaDisegnare(Const pElemento : TpElemento) : TBitmap;
Procedure RotazioneScacchiera(Const Direzione : Integer);
Function NuovoOrientamento(Const Numero : Integer; Const Direzione : Integer) : Integer;
Function ImmagineCasellaScacchiera(Const x: Integer; y: Integer) : TBitmap;

Procedure GiraRobot(Const Direzione : Integer);
Procedure AvanzaRobot;
Function CoordinateElementoVicino(Const Posizione : TPosizione3d; Const Direzione : Integer) : TPosizione3d;

Procedure AggiornamentoPrioritaDiDisegno;
Function PrioritaDiDisegno(Const Posizione : TPosizione3d) : Real;
Procedure OrdinamentoElementiPerPrioritaDiDisegno;
Procedure Scambio(Var Elemento1 : TpElemento; Var Elemento2 : TpElemento); overload;
Procedure Scambio(Var Elemento1 : Real;       Var Elemento2 : Real); overload;
Procedure Scambio(Var Elemento1 : Integer;    Var Elemento2 : Integer); overload;

Function EntroILimitiDellaScacchiera(Const Posizione : TPosizione3d) : Boolean;

Procedure Spostamento(Var pElemento : TpElemento; Const Direzione : Integer);

Procedure PreparazioneAnimazione(Var pElemento : TpElemento; { Var pDestinazione : TpElemento;} Const Direzione : Integer);

//Procedure Caduta(Var pElemento : TpElemento);

Procedure AggiornamentoProgressoAnimazione(Var pElemento : TpElemento);


Function Instabile(Const pElemento : TpElemento) : Boolean;

Procedure EsecuzioneLogicaDiGioco();

Function ElementoAttraversabile(Const pElemento : TpElemento; Const EntitaDiAttraversamento : TEntitaDiAttraversamento; Const Direzione : Integer) : Boolean;

//Procedure EsecuzioneEvento(Var pElemento : TpElemento; Var pSorgente : TpElemento; Const Direzione : Integer);

Function DirezioneRelativaElementi(Const Posizione1 : TPosizione3d; Const Posizione2 : TPosizione3d) : Integer;


Function Spostabile(Const pElemento : TpElemento; Const ElementoAttraversante : TEntitaDiAttraversamento; Const Direzione : Integer) : Boolean;

Function PosizioniUguali(Const Posizione1 : TPosizione3d; Const Posizione2 : TPosizione3d) : Boolean;
Procedure CambioStatoAscensore(Var pAscensore : TpElemento; Var pCarico : TpElemento; Const Attivato : Boolean);

Procedure Accodamento(Var pElemento : TpElemento; Const Direzione : Integer);
Procedure RimozioneDaCoda();

Procedure EsecuzioneOperazione(Var Operazione : TOperazione);

Procedure FineSpostamento(Var pElemento : TpElemento);

//==============================================================================
  Implementation
//==============================================================================

Procedure InizializzazioneGioco;
Begin
  DimensioneScacchiera := 8;
  Rotazione.OrientamentoScacchiera := 0;
  CodaOperazioni.pInizio := Nil;
  CodaOperazioni.pFine := Nil;
End;

Procedure AggiuntaElemento(Const Tipo : TTipoElemento; Posizione : TPosizione3d; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Var
  pElemento : TpElemento;
  Indice    : Integer;
Begin
  Elementi.Dimensione := Elementi.Dimensione + 1;
  Indice := Elementi.Dimensione;
  New(pElemento);
  Elementi.Vettore[Indice] := pElemento;

  pElemento^.Tipo := Tipo;
  pElemento^.Orientamento := Orientamento;
  pElemento^.Posizione := Posizione;
  pElemento^.Animazione.InEsecuzione := False;
  pElemento^.Animazione.Destinazione := Posizione;
  pElemento^.PosizioneFisica := Posizione;
  pElemento^.Attivato := Attivato;
  pElemento^.Colore := Colore;

  If Tipo = Robot Then pRobot := pElemento;
End;

Procedure AggiuntaElemento(Const Tipo : TTipoElemento; X: Real; Y: Real; Z: Real; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Var
  Posizione : TPosizione3d;
Begin
  Posizione.X := X;
  Posizione.Y := Y;
  Posizione.Z := Z;

  AggiuntaElemento(Tipo, Posizione, Orientamento, Attivato, Colore);
End;


Procedure CaricamentoImmagini;
Begin
  CaricamentoImmagine(Immagini.ScacchieraAngoloE, 'ScacchieraAngoloE');
  CaricamentoImmagine(Immagini.ScacchieraAngoloN, 'ScacchieraAngoloN');
  CaricamentoImmagine(Immagini.ScacchieraAngoloW, 'ScacchieraAngoloW');
  CaricamentoImmagine(Immagini.ScacchieraAngoloS, 'ScacchieraAngoloS');
  CaricamentoImmagine(Immagini.ScacchieraBordoNE, 'ScacchieraBordoNE');
  CaricamentoImmagine(Immagini.ScacchieraBordoNW, 'ScacchieraBordoNW');
  CaricamentoImmagine(Immagini.ScacchieraBordoSW, 'ScacchieraBordoSW');
  CaricamentoImmagine(Immagini.ScacchieraBordoSE, 'ScacchieraBordoSE');
  CaricamentoImmagine(Immagini.ScacchieraCellaBianca, 'ScacchieraCellaBianca');
  CaricamentoImmagine(Immagini.ScacchieraCellaNera, 'ScacchieraCellaNera');

  CaricamentoImmagine(Immagini.Cubo, 'Cubo');

  CaricamentoImmagine(Immagini.Cubo, 'Cubo');
  CaricamentoImmagine(Immagini.Cubo2, 'Cubo2');

  CaricamentoQuattroImmagini(Immagini.Robot, 'Robot');

  CaricamentoImmagine(Immagini.AscensoreOn, 'AscensoreOn');
  CaricamentoImmagine(Immagini.AscensoreOff, 'AscensoreOff');

End;

Procedure CaricamentoQuattroImmagini;
Begin
  CaricamentoImmagine(QuattroImmagini[0], BaseNome+'_0');
  CaricamentoImmagine(QuattroImmagini[1], BaseNome+'_1');
  CaricamentoImmagine(QuattroImmagini[2], BaseNome+'_2');
  CaricamentoImmagine(QuattroImmagini[3], BaseNome+'_3');
End;

Procedure CaricamentoImmagine;
Begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile('Images\'+NomeFile+'.bmp');
  Bitmap.Transparent := True;
  Bitmap.TransparentColor := clFuchsia;
End;

Procedure DisegnoArea; //Disegna una bitmap alle coordinate 3D specificate
Begin
  Bitmap.Canvas.Draw(Trunc(IncrementoCoordinataX + (x - y - 1) * Dimensioni2dCubo.b), Trunc(IncrementoCoordinataY + (x+y-2) * Dimensioni2dCubo.a - (z - 1) * Dimensioni2dCubo.c), Immagine);
End;

Procedure MostraFrame; // Copia l'intera Bitmap sulla Paintbox
Begin
  Paintbox.Canvas.Draw(0,0, Bitmap);
End;






procedure DisegnoSchermata;
var
  AltezzaTotale2d : Real;
begin
  AltezzaTotale2d := (AltezzaMassima) * Dimensioni2dCubo.c + (DimensioneScacchiera+1)*2*Dimensioni2dCubo.a;
  IncrementoCoordinataX := Bitmap.Width Div 2;
  IncrementoCoordinataY := (Bitmap.Height - AltezzaTotale2d) / 2 + (AltezzaMassima-1) * Dimensioni2dCubo.c;

  Bitmap.Canvas.Brush.Color := $300000;
  Bitmap.Canvas.FillRect(Rect(Bitmap.Width,Bitmap.Height,0,0));


  If Rotazione.AnimazioneInEsecuzione Then Begin
    Rotazione.PosizioneAnimazione := Rotazione.PosizioneAnimazione + 0.09 - Rotazione.PosizioneAnimazione * 0.06;
    DisegnoAnimazioneRotazione();
    If Rotazione.PosizioneAnimazione >= 0.95 Then Begin // � finita
      Rotazione.AnimazioneInEsecuzione := False;
    End;
  End Else Begin
    DisegnoScacchiera();
    DisegnoElementi();
  End;

  MostraFrame();
End;



Procedure DisegnoScacchiera; // Disegna la scacchiera
Var
  x: Integer;
  y: Integer;
Begin
  // Disegna le caselle
  For x := 1 To DimensioneScacchiera Do
    For y := 1 To DimensioneScacchiera Do
      DisegnoArea(ImmagineCasellaScacchiera(x, y), x, y, 0);

  // Disegna i bordi
  For y := 1 To DimensioneScacchiera Do
    DisegnoArea(Immagini.ScacchieraBordoSE, DimensioneScacchiera+1, y, 1);
  For x := DimensioneScacchiera DownTo 1 Do
    DisegnoArea(Immagini.ScacchieraBordoSW, x, DimensioneScacchiera+1, 1);
  For y := DimensioneScacchiera DownTo 1 Do
    DisegnoArea(Immagini.ScacchieraBordoNW, 0, y, 1);
  For x := 1 To DimensioneScacchiera Do
    DisegnoArea(Immagini.ScacchieraBordoNE, x, 0, 1);

  // Disegna gli angoli
  DisegnoArea(Immagini.ScacchieraAngoloE, DimensioneScacchiera+1, 0, 1);
  DisegnoArea(Immagini.ScacchieraAngoloS, DimensioneScacchiera+1, DimensioneScacchiera+1, 1);
  DisegnoArea(Immagini.ScacchieraAngoloW, 0, DimensioneScacchiera+1, 1);
  DisegnoArea(Immagini.ScacchieraAngoloN, 0, 0, 1);
End;

Procedure DisegnoAnimazioneRotazione();
Var
  Lunghezza2dScacchiera : Integer;
  Altezza2dScacchiera   : Integer;
  ax                     : Integer;
  bx                     : Integer;
  ay                     : Integer;
  by                     : Integer;
  Punti                  : Array[1..4] Of TPoint;
  xcentro                : Integer;
  ycentro                : Integer;
  Angolo                 : Real;
Begin
  Lunghezza2dScacchiera := (DimensioneScacchiera + 2) * Dimensioni2dCubo.b * 2;
  Altezza2dScacchiera := (DimensioneScacchiera + 2) * Dimensioni2dCubo.a * 2;

  xcentro := Trunc(IncrementoCoordinataX);
  ycentro := Trunc(IncrementoCoordinataY + Altezza2dScacchiera / 2);

  Angolo := Rotazione.PosizioneAnimazione * Pi/2 * Rotazione.Direzione;

  ax:=Round(cos(Angolo)*Lunghezza2dScacchiera/2);
  bx:=Round(sin(Angolo)*Lunghezza2dScacchiera/2);
  ay:=Round(cos(Angolo)*Altezza2dScacchiera/2);
  by:=Round(sin(Angolo)*Altezza2dScacchiera/2);

  Punti[1].X := xcentro + ax;
  Punti[1].Y := ycentro + by;
  Punti[2].X := xcentro + bx;
  Punti[2].Y := ycentro - ay;
  Punti[3].X := xcentro - ax;
  Punti[3].Y := ycentro - by;
  Punti[4].X := xcentro - bx;
  Punti[4].Y := ycentro + ay;

  Bitmap.Canvas.Brush.Color := $4980B3;//;$14185D;;
  Bitmap.Canvas.Pen.Style := psClear;
  Bitmap.Canvas.Polygon(Punti);
End;

Procedure DisegnoElementi();
Var
  Indice         : Integer;
  pElemento      : TpElemento;
Begin
  If Elementi.Dimensione = 0 Then Exit;
  AggiornamentoPrioritaDiDisegno();
  OrdinamentoElementiPerPrioritaDiDisegno();

  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    DisegnoArea(ImmagineDaDisegnare(pElemento), pElemento^.PosizioneFisica.X, pElemento^.PosizioneFisica.Y, pElemento^.PosizioneFisica.Z);
  End;
End;

Function ImmagineDaDisegnare;
Begin
  If pElemento^.Tipo = Ascensore Then Begin
    If pElemento^.Attivato
      Then ImmagineDaDisegnare := Immagini.AscensoreOn
      Else ImmagineDaDisegnare := Immagini.AscensoreOff;
    Exit;
  End;
  Case  pElemento^.Tipo Of
    Robot: ImmagineDaDisegnare := Immagini.Robot[pElemento^.Orientamento];
    BloccoFisso: ImmagineDaDisegnare := Immagini.Cubo2;
    BloccoMobile: ImmagineDaDisegnare := Immagini.Cubo;
  Else
    ImmagineDaDisegnare := Immagini.Cubo;
  End;

End;



Procedure RotazioneScacchiera;
Var
  Indice    : Integer;
  pElemento : TpElemento;
Begin
  Rotazione.OrientamentoScacchiera := NuovoOrientamento(Rotazione.OrientamentoScacchiera, Direzione);
  Rotazione.Direzione := Direzione;
  Rotazione.PosizioneAnimazione := 0;
  Rotazione.AnimazioneInEsecuzione := True;
  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    pElemento^.Orientamento := NuovoOrientamento(pElemento^.Orientamento, Direzione);
    Scambio(pElemento^.Posizione.X, pElemento^.Posizione.Y);
    Scambio(pElemento^.PosizioneFisica.X, pElemento^.PosizioneFisica.Y);
    If Direzione = 1
      Then pElemento^.Posizione.X := DimensioneScacchiera + 1 - pElemento^.Posizione.X
      Else pElemento^.Posizione.Y := DimensioneScacchiera + 1 - pElemento^.Posizione.Y;
    If Direzione = 1
      Then pElemento^.PosizioneFisica.X := DimensioneScacchiera + 1 - pElemento^.PosizioneFisica.X
      Else pElemento^.PosizioneFisica.Y := DimensioneScacchiera + 1 - pElemento^.PosizioneFisica.Y;
     //BUGBUG: se la scacchiera ruota mentre qualcosa si muove c'� qualcosa che non va
  End;
End;


Function NuovoOrientamento;
Begin
  NuovoOrientamento := (Numero+Direzione +4) Mod 4;
End;



Function ImmagineCasellaScacchiera;
Begin
  If (x Mod 2 = 0) Xor (y Mod 2 = 0) Xor ((Rotazione.OrientamentoScacchiera Mod 2 = 0) And (DimensioneScacchiera Mod 2 = 0)) Then
    ImmagineCasellaScacchiera := Immagini.ScacchieraCellaNera
  Else
    ImmagineCasellaScacchiera := Immagini.ScacchieraCellaBianca;
End;




Procedure GiraRobot;
Begin
  pRobot^.Orientamento := NuovoOrientamento(pRobot^.Orientamento, Direzione);
End;


Procedure AvanzaRobot;
Begin
  // BUGBUG: spostabile va fatto ora o quando viene elaborata la coda?
  If Not Spostabile(pRobot, Personaggio, pRobot^.Orientamento) Then Exit;
  Accodamento(pRobot, pRobot^.Orientamento);
  //Accodamento(pRobot, pRobot^.Orientamento);
 // Spostamento(pRobot, pRobot^.Orientamento);
End;

Function CoordinateElementoVicino;
Var
  PosizioneVicina : TPosizione3d;
Begin
  PosizioneVicina.X := Posizione.X;
  PosizioneVicina.Y := Posizione.Y;
  PosizioneVicina.Z := Posizione.Z;
  If Direzione = 0 Then PosizioneVicina.X := Posizione.X + 1;
  If Direzione = 1 Then PosizioneVicina.Y := Posizione.Y + 1;
  If Direzione = 2 Then PosizioneVicina.X := Posizione.X - 1;
  If Direzione = 3 Then PosizioneVicina.Y := Posizione.Y - 1;
  If Direzione = -1 Then PosizioneVicina.Z := Posizione.Z - 1; //GIU
  If Direzione = -2 Then PosizioneVicina.Z := Posizione.Z + 1; //SU
  CoordinateElementoVicino := PosizioneVicina;
End;

Procedure AggiornamentoPrioritaDiDisegno;
Var
  Indice : Integer;
Begin
  For Indice := 1 To Elementi.Dimensione Do Begin
    Elementi.Vettore[Indice]^.PrioritaDiDisegno := PrioritaDiDisegno(Elementi.Vettore[Indice]^.PosizioneFisica);
  End;
End;

Function PrioritaDiDisegno;
Begin
  PrioritaDiDisegno := Posizione.X + Posizione.Y + Posizione.Z
End;

Procedure OrdinamentoElementiPerPrioritaDiDisegno;
Var
  Indice1   : Integer;
  Indice2   : Integer;
  PosMinimo : Integer;
Begin
  If Elementi.Dimensione = 1 Then Exit;
  For Indice1 := 1 To Elementi.Dimensione - 1 Do Begin
    PosMinimo := Indice1;
    For Indice2 := Indice1 To Elementi.Dimensione Do Begin
      If Elementi.Vettore[Indice2]^.PrioritaDiDisegno < Elementi.Vettore[PosMinimo]^.PrioritaDiDisegno Then
        PosMinimo := Indice2;
    End;
    If PosMinimo > Indice1 Then
      Scambio(Elementi.Vettore[PosMinimo], Elementi.Vettore[Indice1]);
  End;
End;


Procedure Scambio(Var Elemento1 : Real; Var Elemento2 : Real);
Var
  VecchioElemento1 : Real;
Begin
  VecchioElemento1 := Elemento1;
  Elemento1 := Elemento2;
  Elemento2 := VecchioElemento1;
End;


Procedure Scambio(Var Elemento1 : Integer; Var Elemento2 : Integer);
Var
  VecchioElemento1 : Integer;
Begin
  VecchioElemento1 := Elemento1;
  Elemento1 := Elemento2;
  Elemento2 := VecchioElemento1;
End;

Procedure Scambio(Var Elemento1 : TpElemento; Var Elemento2 : TpElemento);
Var
  VecchioElemento1 : TpElemento;
Begin
  VecchioElemento1 := Elemento1;
  Elemento1 := Elemento2;
  Elemento2 := VecchioElemento1;
End;

Function EntroILimitiDellaScacchiera;
Begin
  If (
       (Posizione.X < 1) Or (Posizione.X > DimensioneScacchiera)  Or
       (Posizione.Y < 1) Or (Posizione.Y > DimensioneScacchiera)  Or
       (Posizione.Z < 1) Or (Posizione.Z > AltezzaMassima)
      ) //TODOTODO sistemare qui per il controllo sull'asse Z
    Then EntroILimitiDellaScacchiera := False
    Else EntroILimitiDellaScacchiera := True;
End;



Procedure Spostamento;
Var
  Destinazione                : TPosizione3d;
  PosizioneElementoSuperiore  : TPosizione3d;
  Indice  : Integer;
Begin
  Destinazione := CoordinateElementoVicino(pElemento^.Animazione.Destinazione, Direzione);

  //BUGBUG: attenzione quando si distrugge un oggetto, il ciclo potrebbe corrompersi

  PosizioneElementoSuperiore := pElemento^.Posizione;
  PosizioneElementoSuperiore.Z := PosizioneElementoSuperiore.Z + 1;

  For Indice := 1 To Elementi.Dimensione Do Begin


    If PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, PosizioneElementoSuperiore) Then Begin
      If Spostabile(Elementi.Vettore[Indice], Blocco, Direzione)
        Then Accodamento(Elementi.Vettore[Indice], Direzione)
        Else Accodamento(Elementi.Vettore[Indice], -1);    // BUGBUG: caduta, non semplice spostamento
         //Spostamento(Elementi.Vettore[Indice], Direzione)
      //  Else Caduta(Elementi.Vettore[Indice]);
    End;

    //Sposta blocchi affiancati (solo se il movimento � orizzontale)
    If (Direzione >= 0) And ((Elementi.Vettore[Indice]^.Tipo = BloccoMobile) Or (Elementi.Vettore[Indice]^.Tipo = BloccoPuzzle)) And PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, Destinazione) Then Begin
      //EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, pElemento^.Animazione.Direzione);
      //Spostamento(Elementi.Vettore[Indice], Direzione);
      Accodamento(Elementi.Vettore[Indice], Direzione);
    End;
  End;



  PreparazioneAnimazione(pElemento, Direzione);
End;

Procedure PreparazioneAnimazione;
Begin
  pElemento^.Animazione.InEsecuzione := True;

  pElemento^.Animazione.Destinazione := CoordinateElementoVicino(pElemento^.Posizione, Direzione);
  pElemento^.Animazione.Direzione := Direzione;

  pElemento^.Animazione.X := Trunc(pElemento^.Animazione.Destinazione.X - pElemento^.Posizione.X);
  pElemento^.Animazione.Y := Trunc(pElemento^.Animazione.Destinazione.Y - pElemento^.Posizione.Y);
  pElemento^.Animazione.Z := Trunc(pElemento^.Animazione.Destinazione.Z - pElemento^.Posizione.Z);
  pElemento^.Animazione.Progresso := 0;
End;

{
Procedure Caduta;
Var
  Destinazione                : TPosizione3d;
Begin
  Spostamento(pElemento, -1);
End;
 }



Procedure AggiornamentoProgressoAnimazione;
//Var
  //Indice              : Integer;
  //ElementoSottostante : TPosizione3d;
Begin
  pElemento^.Animazione.Progresso := pElemento^.Animazione.Progresso + 0.2;
  pElemento^.PosizioneFisica.X := pElemento^.Posizione.X + pElemento^.Animazione.X * pElemento^.Animazione.Progresso;
  pElemento^.PosizioneFisica.Y := pElemento^.Posizione.Y + pElemento^.Animazione.Y * pElemento^.Animazione.Progresso;
  pElemento^.PosizioneFisica.Z := pElemento^.Posizione.Z + pElemento^.Animazione.Z * pElemento^.Animazione.Progresso;
  If pElemento^.Animazione.Progresso >= 1 Then Begin
    pElemento^.PosizioneFisica := pElemento^.Animazione.Destinazione;
    pElemento^.Posizione := pElemento^.Animazione.Destinazione;

    pElemento^.Animazione.InEsecuzione := False;
    FineSpostamento(pElemento);
  End;
End;


Function Instabile;
//Var
//  Destinazione         : TPosizione3d;
  //pElementoSottostante : TpElemento;
Begin
  //BUGBUG: anche il blocco fisso pu� ora cadere, visto che cade sempre se viene spostata la sua base mentre lui non pu� muoversi orizzontalmente

  //DIRTY: l'effetto non cambia, ma viene sempre mandato Blocco alla fnzione spostabile
  Instabile := Spostabile(pElemento, Blocco, -1);
End;


Procedure EsecuzioneLogicaDiGioco;
Var
  Indice    : Integer;
  pElemento : TpElemento;
Begin



  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    If pElemento^.Animazione.InEsecuzione Then AggiornamentoProgressoAnimazione(pElemento);
  End;


  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    //DIRTY: viene sempre usato blocco  (anche se il risultato non cambia)
    If Not pElemento^.Animazione.InEsecuzione And Spostabile(pElemento, Blocco, -1) Then Accodamento(pElemento, -1);
  End;


  While CodaOperazioni.pInizio <> Nil Do Begin
    EsecuzioneOperazione(CodaOperazioni.pInizio^.Operazione);
    RimozioneDaCoda();
  End;
End;


Function ElementoAttraversabile;
Var
  Tipo : TTipoElemento;
Begin
  ElementoAttraversabile := False;
  Tipo := pElemento^.Tipo;

  If (Tipo = Porta) And (pElemento^.Attivato) Then Exit;
  If (Tipo = BloccoMetallico) Then Exit;
  If (Tipo = BloccoFisso) Then Exit;

  If (Tipo = BloccoPuzzle) Then Exit;
  If (Tipo = BloccoMobile) Then Exit;

  If EntitaDiAttraversamento = Laser Then Begin // Laser
    If (Tipo = Ascensore) And (pElemento^.Attivato) Then Exit;
    If (Tipo = BloccoPuzzle) Then Exit;
    If (Tipo = BloccoMobile) Then Exit;

    
  End Else Begin // Blocco / Robot

    // Qualsiasi direzione
    If (Tipo = BloccoGhiaccio) Then Exit;
    If (Tipo = BloccoGhiaccio) Then Exit;

    If Direzione < 0 Then Begin // Blocco/Robot Da sopra (o dal basso)
      //If (Tipo = BloccoPuzzle) Then Exit;
      //If (Tipo = BloccoMobile) Then Exit;
      
      If (Tipo = Ascensore) And (pElemento^.Attivato) Then Exit;

    End Else Begin // Blocco/Robot Di lato
      If (Tipo = Ascensore) And (pElemento^.Attivato) Then Exit;
      If (Tipo = InterruttoreLevetta) Then Exit;
      If (Tipo = InterruttoreBersaglio) Then Exit;
      If (Tipo = Pistola) Then Exit;
      If (Tipo = Specchio) Then Exit;
      If (Tipo = Calamita) Then Exit;
      If (Tipo = Bomba) Then Exit;
      If EntitaDiAttraversamento = Blocco Then Begin
         If (Tipo = Pila) Then Exit;
         If (Tipo = Ruota) Then Exit;
      End;

      If (Tipo = Robot) Then Exit;
    End;

  End;

  ElementoAttraversabile := True;

End;

{
Procedure EsecuzioneEvento;
Var
  Tipo             : TTipoElemento;
  TipoSorgente     : TTipoElemento;
Begin
 // If pElemento^.Animazione Then Exit;
  Tipo := pElemento^.Tipo;
  TipoSorgente := pSorgente^.Tipo;

  ///BUGBUG: sistemare una cazzatina qui
 // If pSorgente^.Animazione.Direzione <> -2 Then Exit;

  If Direzione < 0 Then Begin
    //If (Tipo = Ascensore) And (Direzione = -2) Then
     // Accodamento(pElemento, 1);
    //  CambioStatoAscensore(pElemento, pSorgente, False);
    If (Tipo = Ascensore) And (Direzione = -1) Then
      CambioStatoAscensore(pElemento, pSorgente, True);
  End Else Begin
    If (Tipo = Ascensore) Then
      CambioStatoAscensore(pElemento, pSorgente, True);
  End;

End; }


Function DirezioneRelativaElementi;
Begin
  DirezioneRelativaElementi := 0;//Per evitare il warning di Delphi  
  If Posizione1.X < Posizione2.X Then DirezioneRelativaElementi := 0;
  If Posizione1.Y < Posizione2.Y Then DirezioneRelativaElementi := 1;
  If Posizione1.X > Posizione2.X Then DirezioneRelativaElementi := 2;
  If Posizione1.Y > Posizione2.Y Then DirezioneRelativaElementi := 3;
End;

Function Spostabile;
Var
  Destinazione  : TPosizione3d;
  Raggiungibile : Boolean;
  ControlloTerminato : Boolean;
  Indice             : Integer;
  pElementoVicino    : TpElemento;
Begin
  // forse BUGBUG: il robot non deve poter essere mosso da un blocco
  If (pElemento^.Tipo <> Robot) And (pElemento^.Tipo <> BloccoMobile) And (pElemento^.Tipo <> BloccoPuzzle) And (Direzione <> -1) Then Begin
    Spostabile := False;
    Exit;
  End;

  Destinazione := CoordinateElementoVicino(pElemento^.Posizione, Direzione);
  If Not EntroILimitiDellaScacchiera(Destinazione) Then Begin
    Spostabile := False;
    Exit;
  End;

  Raggiungibile := False; // per evitare il Warning di Delphi

  ControlloTerminato := False;
  Indice := 0;

  Repeat
    Indice := Indice + 1;
    pElementoVicino := Elementi.Vettore[Indice];
    If ((PosizioniUguali(pElementoVicino.Posizione, Destinazione)) And
             Not ( ElementoAttraversabile(pElementoVicino, ElementoAttraversante, Direzione) Or
              Spostabile(pElementoVicino, Blocco, Direzione) )     ) Then Begin
        Raggiungibile := False;
        ControlloTerminato := True;
      End Else Begin
        If Indice = Elementi.Dimensione Then Begin
          Raggiungibile := True;
          ControlloTerminato := True;
        End;
      End;
  Until ControlloTerminato;

  Spostabile := Raggiungibile;
End;



Function PosizioniUguali;
Begin
  If (Posizione1.X = Posizione2.X) And (Posizione1.Y = Posizione2.Y) And (Posizione1.Z = Posizione2.Z)
    Then PosizioniUguali := True
    Else PosizioniUguali := False;
End;

Procedure CambioStatoAscensore;
Begin
  pAscensore^.Attivato := Attivato;
  If Attivato Then Begin
    Accodamento(pCarico, -2);
  End Else Begin
    Accodamento(pCarico, -1);
  End;

End;

Procedure Accodamento;
Var
  pNuovo     : TpeCodaOperazioni;
Begin
  New(pNuovo);
  pNuovo^.pSuccessivo := Nil;
  pNuovo^.Operazione.pElemento := pElemento;
  pNuovo^.Operazione.Direzione := Direzione;
  If CodaOperazioni.pInizio = Nil Then Begin
    CodaOperazioni.pInizio := pNuovo;
    CodaOperazioni.pFine := pNuovo;
  End Else Begin
    CodaOperazioni.pFine^.pSuccessivo := pNuovo;
    CodaOperazioni.pFine := pNuovo;
  End;
End;

Procedure RimozioneDaCoda;
Begin
  // BUGBUG: bisognerebbe liberare la memoria

  If CodaOperazioni.pInizio^.pSuccessivo = Nil Then Begin
    CodaOperazioni.pInizio := Nil;
    CodaOperazioni.pFine := Nil;
  End Else Begin
    CodaOperazioni.pInizio := CodaOperazioni.pInizio^.pSuccessivo;
  End;
End;

Procedure EsecuzioneOperazione;
Begin

  //DIRTY: spostabile con blocco
  //If Spostabile(Operazione.pElemento, Blocco, Operazione.Direzione) Then Exit;
  Spostamento(Operazione.pElemento, Operazione.Direzione);
End;


Procedure FineSpostamento;
Var
  Indice                        : Integer;
  PosizioneElementoSottostante  : TPosizione3d;
  pVicino                       : TpElemento;
Begin
    // DIRTY: viene usato destinazione invece di posizione
    PosizioneElementoSottostante := CoordinateElementoVicino(pElemento^.Posizione, -1);


    For Indice := 1 To Elementi.Dimensione Do Begin
      pVicino := Elementi.Vettore[Indice];
      If PosizioniUguali(pVicino^.Posizione, pElemento^.Posizione) Then Begin
        If (pVicino^.Tipo = Ascensore) And (Elementi.Vettore[Indice]^.Attivato = False) Then Begin
          If pElemento^.Animazione.Direzione <> -1 Then Begin
            CambioStatoAscensore(pVicino, pElemento, True);
          End;
        End;
      End;

      If PosizioniUguali(pVicino^.Posizione, PosizioneElementoSottostante) Then Begin
        If (pVicino^.Tipo = Ascensore) And (Elementi.Vettore[Indice]^.Attivato = True) Then Begin
          If pElemento^.Animazione.Direzione <> -2 Then Begin
            CambioStatoAscensore(pVicino, pElemento, False);
          End;
        End;
      End;
      //la chiamata sopra funziona per tutte le direzioni
    End;



        //EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, pElemento^.Animazione.Direzione);
    //If (Instabile(pElemento)) Then Caduta(pElemento);

    //For Indice := 1 To Elementi.Dimensione Do Begin
    //  If PosizioniUguali(pElemento^.Posizione, pElemento^.Destinazione) Then Begin
    //    EsecuzioneEvento(pElemento, pElemento, pElemento^.Animazione.Direzione);
    //  End;
    //End;

End;


end.
