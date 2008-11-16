Unit fbblTinker;

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
              End;



  TTipoElemento = (BloccoFisso, BloccoMobile, Robot);

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

  TElemento = Record
                Tipo         : TTipoElemento;
                Orientamento : Integer;
              {  Pos1: Real;
                Pos2: Real;
                Pos3: Real;
                Pos4: Real;
               }
                Posizione    : TPosizione3d;
                //X                 : Real;
                //Y                 : Real;
                //Z                 : Real;
                PrioritaDiDisegno : Real;
                Attivato     : Boolean;
                Colore       : Integer;
              End;

  TpElemento = ^TElemento;

  {TpeListaElementi = ^TeListaElementi;

  TeListaElementi = Record
                      pSuccessivo : TpeListaElementi;
                      Elemento    : TElemento;
                    End;
                    
  TListaElementi = Record
                     pInizio   : TpeListaElementi;
                     pFine     : TpeListaElementi;
                   End;}


              

  TArraypElementi = Array[1..1000] Of TpElemento;  // BUGBUG: attenzione, massimo mille elementi, poi crash

  TVettorepElementi = Record
                       Vettore    : TArraypElementi;
                       Dimensione : Integer;
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
  Occupato              : Boolean;
  Rotazione             : TInformazioniRotazione;
Var
  Elementi              : TVettorepElementi;
  Inizializzato         : Boolean = False;
  pRobot                : TpElemento;


Procedure InizializzazioneGioco();
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; Posizione : TPosizione3d; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; X: Real; Y: Real; Z: Real; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
//Procedure AggiornaPrioritaDiDisegno(Var Elemento : TpElemento);
Procedure CaricaImmagini();
Procedure CaricaQuattroImmagini(Var QuattroImmagini : TQuattroBitmap; Const BaseNome : String);
Procedure CaricaImmagine(Var Bitmap : TBitmap; Const NomeFile : String);
Procedure DisegnaArea(Const Immagine : TBitmap; Const x : Real; Const y : Real; Const z : Real);
Procedure MostraFrame();

Procedure DisegnaSchermata();

Procedure DisegnaScacchiera();
Procedure DisegnaAnimazioneRotazione();
Procedure DisegnaElementi();


Function ImmagineDaDisegnare(Const pElemento : TpElemento) : TBitmap;
Procedure RotazioneScacchiera(Const Direzione : Integer);
Function NuovoOrientamento(Const Numero : Integer; Const Direzione : Integer) : Integer;
Function ImmagineCasellaScacchiera(Const x: Integer; y: Integer) : TBitmap;

Procedure GiraRobot(Const Direzione : Integer);
Procedure AvanzaRobot;
Function CoordinateElementoVicino(Const Elemento : TpElemento; Const Direzione : Integer) : TPosizione3d;

//Procedure InizializzazioneLista(Var Lista : TListaElementi);
//Procedure InserimentoInLista(Const Elemento : TElemento; Var Lista : TListaElementi);

Procedure AggiornaPrioritaDiDisegno;
Function PrioritaDiDisegno(Const Posizione : TPosizione3d) : Real;
Procedure OrdinamentoElementiPerPrioritaDiDisegno;
Procedure Scambio(Var Elemento1 : TpElemento; Var Elemento2 : TpElemento); overload;
Procedure Scambio(Var Elemento1 : Real;       Var Elemento2 : Real); overload;

Function EntroILimitiDellaScacchiera(Const Posizione : TPosizione3d) : Boolean;

Function ElementoInPosizione(Const Posizione : TPosizione3d) : TpElemento;

Function Spostabile(Const pElemento : TpElemento; Const Direzione : Integer) : Boolean;
Procedure Sposta(Var pElemento : TpElemento; Const Direzione : Integer);
Procedure Cadi(Var pElemento : TpElemento);

//==============================================================================
  Implementation
//==============================================================================

Procedure InizializzazioneGioco;
Begin
  DimensioneScacchiera := 8;
  Rotazione.OrientamentoScacchiera := 0;
  //InizializzazioneLista(Elementi);


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
  //Elementi.Vettore[Indice].Posizione.X := X;
  //Elementi.Vettore[Indice].Posizione.Y := Y;
  //Elementi.Vettore[Indice].Posizione.Z := Z;

  //AggiornaPrioritaDiDisegno(pElemento); spostato in un unico ciclo prima di disegnare
  pElemento^.Attivato := Attivato;
  pElemento^.Colore := Colore;

  //InserimentoInLista(Elemento, Elementi);

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

{Procedure AggiornaPrioritaDiDisegno;
Begin
  //Elemento.PrioritaDiDisegno := Elemento.Posizione.X * 65536 + Elemento.Posizione.Y * 256 + Elemento.Posizione.Z;
  Elemento.PrioritaDiDisegno := Elemento.Posizione.X + Elemento.Posizione.Y + Elemento.Posizione.Z;
End;  }


Procedure CaricaImmagini;
Begin
  CaricaImmagine(Immagini.ScacchieraAngoloE, 'ScacchieraAngoloE');
  CaricaImmagine(Immagini.ScacchieraAngoloN, 'ScacchieraAngoloN');
  CaricaImmagine(Immagini.ScacchieraAngoloW, 'ScacchieraAngoloW');
  CaricaImmagine(Immagini.ScacchieraAngoloS, 'ScacchieraAngoloS');
  CaricaImmagine(Immagini.ScacchieraBordoNE, 'ScacchieraBordoNE');
  CaricaImmagine(Immagini.ScacchieraBordoNW, 'ScacchieraBordoNW');
  CaricaImmagine(Immagini.ScacchieraBordoSW, 'ScacchieraBordoSW');
  CaricaImmagine(Immagini.ScacchieraBordoSE, 'ScacchieraBordoSE');
  CaricaImmagine(Immagini.ScacchieraCellaBianca, 'ScacchieraCellaBianca');
  CaricaImmagine(Immagini.ScacchieraCellaNera, 'ScacchieraCellaNera');

  CaricaImmagine(Immagini.Cubo, 'Cubo');

  CaricaImmagine(Immagini.Cubo, 'Cubo');
  CaricaImmagine(Immagini.Cubo2, 'Cubo2');

  CaricaQuattroImmagini(Immagini.Robot, 'Robot');

End;

Procedure CaricaQuattroImmagini;
Begin
  CaricaImmagine(QuattroImmagini[0], BaseNome+'_0');
  CaricaImmagine(QuattroImmagini[1], BaseNome+'_1');
  CaricaImmagine(QuattroImmagini[2], BaseNome+'_2');
  CaricaImmagine(QuattroImmagini[3], BaseNome+'_3');
End;

Procedure CaricaImmagine;
Begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile('Images\'+NomeFile+'.bmp');
  Bitmap.Transparent := True;
  Bitmap.TransparentColor := clFuchsia;
End;

Procedure DisegnaArea; //Disegna una bitmap alle coordinate 3D specificate
Begin
  Bitmap.Canvas.Draw(Trunc(IncrementoCoordinataX + (x - y - 1) * Dimensioni2dCubo.b), Trunc(IncrementoCoordinataY + (x+y-2) * Dimensioni2dCubo.a - (z - 1) * Dimensioni2dCubo.c), Immagine);
End;

Procedure MostraFrame; // Copia l'intera Bitmap sulla Paintbox
Begin
  Paintbox.Canvas.Draw(0,0, Bitmap);
End;






procedure DisegnaSchermata;
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
    //Rotazione.PosizioneAnimazione := Rotazione.PosizioneAnimazione + 0.01 + Rotazione.PosizioneAnimazione * 0.146;
    DisegnaAnimazioneRotazione();
    If Rotazione.PosizioneAnimazione >= 0.95 Then Begin // È finita
      Rotazione.AnimazioneInEsecuzione := False;
      Occupato := False;
    End;
  End Else Begin
    DisegnaScacchiera();
    DisegnaElementi();
  End;

  //DisegnoArea(Immagini.Cubo, 2, 3, 1);
  //DisegnoArea(Immagini.Cubo2, 4, 1, 1);


  MostraFrame();
End;



Procedure DisegnaScacchiera; // Disegna la scacchiera
Var
  x: Integer;
  y: Integer;
Begin
  // Disegna le caselle
  For x := 1 To DimensioneScacchiera Do
    For y := 1 To DimensioneScacchiera Do
      DisegnaArea(ImmagineCasellaScacchiera(x, y), x, y, 0);

  // Disegna i bordi
  For y := 1 To DimensioneScacchiera Do
    DisegnaArea(Immagini.ScacchieraBordoSE, DimensioneScacchiera+1, y, 1);
  For x := DimensioneScacchiera DownTo 1 Do
    DisegnaArea(Immagini.ScacchieraBordoSW, x, DimensioneScacchiera+1, 1);
  For y := DimensioneScacchiera DownTo 1 Do
    DisegnaArea(Immagini.ScacchieraBordoNW, 0, y, 1);
  For x := 1 To DimensioneScacchiera Do
    DisegnaArea(Immagini.ScacchieraBordoNE, x, 0, 1);

  // Disegna gli angoli
  DisegnaArea(Immagini.ScacchieraAngoloE, DimensioneScacchiera+1, 0, 1);
  DisegnaArea(Immagini.ScacchieraAngoloS, DimensioneScacchiera+1, DimensioneScacchiera+1, 1);
  DisegnaArea(Immagini.ScacchieraAngoloW, 0, DimensioneScacchiera+1, 1);
  DisegnaArea(Immagini.ScacchieraAngoloN, 0, 0, 1);
End;

Procedure DisegnaAnimazioneRotazione();
Var
  Lunghezza2dScacchhiera : Integer;
  Altezza2dScacchhiera   : Integer;
  ax                     : Integer;
  bx                     : Integer;
  ay                     : Integer;
  by                     : Integer;
  Punti                  : Array[1..4] Of TPoint;
  xcentro                : Integer;
  ycentro                : Integer;
  Angolo                 : Real;
Begin
  Lunghezza2dScacchhiera := (DimensioneScacchiera + 2) * Dimensioni2dCubo.b * 2;
  Altezza2dScacchhiera := (DimensioneScacchiera + 2) * Dimensioni2dCubo.a * 2;

  xcentro := Trunc(IncrementoCoordinataX);
  ycentro := Trunc(IncrementoCoordinataY + Altezza2dScacchhiera / 2);

  Angolo := Rotazione.PosizioneAnimazione * Pi/2 * Rotazione.Direzione;

  ax:=Round(cos(Angolo)*Lunghezza2dScacchhiera/2);
  bx:=Round(sin(Angolo)*Lunghezza2dScacchhiera/2);
  ay:=Round(cos(Angolo)*Altezza2dScacchhiera/2);
  by:=Round(sin(Angolo)*Altezza2dScacchhiera/2);

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

Procedure DisegnaElementi();
Var
  Indice         : Integer;
  pElemento      : TpElemento;
{Var
  Contatore                      : Integer;
  Indice                         : Integer;
  PrioritaUltimoBloccoDisegnato  : Real;
  IndiceMinimoAttuale            : Integer;
  MinimoAttuale                  : Real;
  pElemento                      : TpElemento; }
Begin
  If Elementi.Dimensione = 0 Then Exit;
  //BUGBUG: se due elementi hanno la stessa priorità ne viene disegnato solo uno

  {PrioritaUltimoBloccoDisegnato := -1;

  For Contatore := 1 To Elementi.Dimensione Do Begin// Non è un indice
    IndiceMinimoAttuale := -1;
    MinimoAttuale := Infinity;
    For Indice := 1 To Elementi.Dimensione Do Begin
      If (Elementi.Vettore[Indice].PrioritaDiDisegno < MinimoAttuale) And (Elementi.Vettore[Indice].PrioritaDiDisegno > PrioritaUltimoBloccoDisegnato) Then Begin
        IndiceMinimoAttuale := Indice;
        MinimoAttuale := Elementi.Vettore[Indice].PrioritaDiDisegno;
      End;
    End;
    PrioritaUltimoBloccoDisegnato := MinimoAttuale;
    pElemento := Elementi.Vettore[IndiceMinimoAttuale];
    DisegnaArea(ImmagineDaDisegnare(pElemento), pElemento^.Posizione.X, pElemento^.Posizione.Y, pElemento^.Posizione.Z);
  End;
  }

  AggiornaPrioritaDiDisegno();
  OrdinamentoElementiPerPrioritaDiDisegno();

  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    DisegnaArea(ImmagineDaDisegnare(pElemento), pElemento^.Posizione.X, pElemento^.Posizione.Y, pElemento^.Posizione.Z);
  End;

End;










Function ImmagineDaDisegnare;
Begin
  If pElemento^.Tipo = Robot Then Begin
    ImmagineDaDisegnare := Immagini.Robot[pElemento^.Orientamento];
    Exit;
  End;
  If pElemento^.Tipo = BloccoFisso Then Begin
    ImmagineDaDisegnare := Immagini.Cubo2;
    Exit;
  End;
  If pElemento^.Tipo = BloccoMobile Then Begin
    ImmagineDaDisegnare := Immagini.Cubo;
    Exit;
  End;
  //ImmagineDaDisegnare := Immagini.Cubo;
End;



Procedure RotazioneScacchiera;
Var
  Indice   : Integer;
Begin
  Occupato := True;
  Rotazione.OrientamentoScacchiera := NuovoOrientamento(Rotazione.OrientamentoScacchiera, Direzione);
  Rotazione.Direzione := Direzione;
  Rotazione.PosizioneAnimazione := 0;
  Rotazione.AnimazioneInEsecuzione := True;
  For Indice := 1 To Elementi.Dimensione Do Begin
    Scambio(Elementi.Vettore[Indice].Posizione.X, Elementi.Vettore[Indice].Posizione.Y);
    If Direzione = 1
      Then Elementi.Vettore[Indice].Posizione.X := DimensioneScacchiera + 1 - Elementi.Vettore[Indice].Posizione.X
      Else Elementi.Vettore[Indice].Posizione.Y := DimensioneScacchiera + 1 - Elementi.Vettore[Indice].Posizione.Y;
    //AggiornaPrioritaDiDisegno(Elementi.Vettore[Indice]);
    Elementi.Vettore[Indice].Orientamento := NuovoOrientamento(Elementi.Vettore[Indice].Orientamento, Direzione);
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
Var
  Destinazione : TPosizione3d;
  pElemento    : TpElemento;
Begin
  Destinazione := CoordinateElementoVicino(pRobot, pRobot^.Orientamento);
  If Not EntroILimitiDellaScacchiera(Destinazione) Then Exit;
  pElemento := ElementoInPosizione(Destinazione);
  If pElemento <> Nil Then Begin
    If pElemento^.Tipo = BloccoFisso Then Exit;
    If pElemento^.Tipo = BloccoMobile Then Begin
       If Spostabile(pElemento, pRobot^.Orientamento) Then Begin
           Sposta(pElemento, pRobot^.Orientamento);
           pRobot^.Posizione := Destinazione;
       End;
       Exit
    End;
  End;   
  pRobot^.Posizione := Destinazione;

  //AggiornaPrioritaDiDisegno(pRobot);
End;

Function CoordinateElementoVicino;
Var
  Posizione : TPosizione3d;
Begin
  Posizione.X := Elemento.Posizione.X;
  Posizione.Y := Elemento.Posizione.Y;
  Posizione.Z := Elemento.Posizione.Z;
  If Direzione = 0 Then Posizione.X := Posizione.X + 1;
  If Direzione = 1 Then Posizione.Y := Posizione.Y + 1;
  If Direzione = 2 Then Posizione.X := Posizione.X - 1;
  If Direzione = 3 Then Posizione.Y := Posizione.Y - 1;
  CoordinateElementoVicino := Posizione;
End;

{
Procedure InizializzazioneLista;
Begin
  Lista.pInizio := Nil;
  Lista.pFine := Nil;
End;


Procedure InserimentoInLista;
Var
  pPenultimo : TpeListaElementi;
Begin
  If Lista.pInizio = Nil Then Begin
     New(Lista.pInizio);
     Lista.pFine := Lista.pInizio;
     Lista.pInizio^.Elemento := Elemento;
     Lista.pInizio^.pPrecedente = Nil;
     Lista.pInizio^.pSuccessivo = Nil;
  End Else Begin
     New(Lista.pFine^.pSuccessivo);
     pPenultimo := Lista.pFine;
     Lista.pFine := pPenultimo^.pSuccessivo;
     Lista.pFine^.Elemento := Elemento;
     Lista.pFine^.pPrecedente = pPenultimo;
     Lista.pFine^.pSuccessivo = Nil;
  End;
End;  }

Procedure AggiornaPrioritaDiDisegno;
Var
  Indice : Integer;
Begin
  For Indice := 1 To Elementi.Dimensione Do Begin
    Elementi.Vettore[Indice]^.PrioritaDiDisegno := PrioritaDiDisegno(Elementi.Vettore[Indice]^.Posizione);
  End;
End;

Function PrioritaDiDisegno;
Begin
  PrioritaDiDisegno := Posizione.X * 65536 + Posizione.Y * 256 + Posizione.Z
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

Function ElementoInPosizione;
Var
  Indice           : Integer;
  pElemento        : TpElemento;
  RicercaTerminata : Boolean;
  ElementoTrovato  : Boolean;
Begin
  RicercaTerminata := False;
  Indice := 0;
  Repeat
    Indice := Indice + 1;
    pElemento := Elementi.Vettore[Indice];
    If (
         (pElemento^.Posizione.X = Posizione.X) And
         (pElemento^.Posizione.Y = Posizione.Y) And
         (pElemento^.Posizione.Z = Posizione.Z)
       ) Then Begin
           ElementoTrovato := True;
           RicercaTerminata := True;
         End Else Begin
           If Indice = Elementi.Dimensione Then Begin
             ElementoTrovato := False;
             RicercaTerminata := True;
           End;  
         End;
  Until RicercaTerminata;
  If ElementoTrovato
    Then ElementoInPosizione := pElemento
    Else ElementoInPosizione := Nil;
End;

Function Spostabile;
Var
  pElementoVicino : TpElemento;
  Destinazione    : TPosizione3d;
Begin
  // Il blocco stesso è di natura spostabile?
  If pElemento^.Tipo <> BloccoMobile Then Begin
    Spostabile := False;
    Exit;
  End;

  // Entro i limiti della scacchiera?
  Destinazione := CoordinateElementoVicino(pElemento, Direzione);
  If Not EntroILimitiDellaScacchiera(Destinazione) Then Begin
    Spostabile := False;
    Exit;
  End;

  // Ricorsivo per i blocchi vicini
  pElementoVicino := ElementoInPosizione(Destinazione);
  If pElementoVicino <> Nil Then Begin
    If Not Spostabile(pElementoVicino, Direzione) Then Begin
      Spostabile := False;
      Exit;
    End;
  End;
  Spostabile := True;
End;


Procedure Sposta;
Var
  pElementoVicino             : TpElemento;
  Destinazione                : TPosizione3d;
  PosizioneElementoSuperiore  : TPosizione3d;
Begin
  Destinazione := CoordinateElementoVicino(pElemento, Direzione);

  pElementoVicino := ElementoInPosizione(Destinazione);
  If pElementoVicino <> Nil Then Sposta(pElementoVicino, Direzione);

  PosizioneElementoSuperiore := pElemento^.Posizione;
  PosizioneElementoSuperiore.Z := PosizioneElementoSuperiore.Z + 1;
  pElementoVicino := ElementoInPosizione(PosizioneElementoSuperiore);
  If pElementoVicino <> Nil Then Begin
    If Spostabile(pElementoVicino, Direzione)
      Then Sposta(pElementoVicino, Direzione)
      Else Cadi(pElementoVicino)
  End;

  pElemento^.Posizione := Destinazione;

End;

Procedure Cadi;
Var
  pElementoVicino             : TpElemento;
  Destinazione                : TPosizione3d;
Begin
  Destinazione := pElemento^.Posizione;
  Destinazione.Z := Destinazione.Z - 1;
  If Not EntroILimitiDellaScacchiera(Destinazione) Then Begin
    Exit;
  End;
  pElementoVicino := ElementoInPosizione(Destinazione);
  If pElementoVicino <> Nil Then Begin
    pElemento^.Posizione := Destinazione;
    Cadi(pElemento);
  End;
End;


end.
