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
                   //pDestinazione : TpElemento;
                   Destinazione          : TPosizione3d;  // Posizione logica di fine animazione
                 End;
  TElemento = Record
                Tipo         : TTipoElemento;
                Orientamento : Integer;
              {  Pos1: Real;
                Pos2: Real;
                Pos3: Real;
                Pos4: Real;
               }
                Posizione             : TPosizione3d;  // Posizione logica prima dell'animazione animazione
                PosizioneFisica       : TPosizione3d;  // Posizione effettiva nello spazio fisico (cambia durante l'animazione)
                Animazione            : TAnimazione;   // Informazioni sulla direzione di animazione
                //X                 : Real;
                //Y                 : Real;
                //Z                 : Real;
                PrioritaDiDisegno : Real;
                Attivato     : Boolean;
                Colore       : Integer;
              End;





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

  //KeyBoardState : TKeyboardState;


Procedure InizializzazioneGioco();
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; Posizione : TPosizione3d; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; X: Real; Y: Real; Z: Real; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
//Procedure AggiornaPrioritaDiDisegno(Var Elemento : TpElemento);
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
Function CoordinateElementoVicino(Const Elemento : TpElemento; Const Direzione : Integer) : TPosizione3d;

//Procedure InizializzazioneLista(Var Lista : TListaElementi);
//Procedure InserimentoInLista(Const Elemento : TElemento; Var Lista : TListaElementi);

Procedure AggiornamentoPrioritaDiDisegno;
Function PrioritaDiDisegno(Const Posizione : TPosizione3d) : Real;
Procedure OrdinamentoElementiPerPrioritaDiDisegno;
Procedure Scambio(Var Elemento1 : TpElemento; Var Elemento2 : TpElemento); overload;
Procedure Scambio(Var Elemento1 : Real;       Var Elemento2 : Real); overload;
Procedure Scambio(Var Elemento1 : Integer;    Var Elemento2 : Integer); overload;

Function EntroILimitiDellaScacchiera(Const Posizione : TPosizione3d) : Boolean;

Function ElementoInPosizione(Const Posizione : TPosizione3d) : TpElemento;

//Function Spostabile(Const pElemento : TpElemento; Const Direzione : Integer) : Boolean;
Procedure Spostamento(Var pElemento : TpElemento; Const Direzione : Integer);

Procedure PreparazioneAnimazione(Var pElemento : TpElemento; { Var pDestinazione : TpElemento;} Const Direzione : Integer);

Procedure Caduta(Var pElemento : TpElemento);

Procedure AggiornamentoProgressoAnimazione(Var pElemento : TpElemento);


Function Instabile(Const pElemento : TpElemento) : Boolean;

Procedure EsecuzioneLogicaDiGioco();

//Procedure ControlloPosizioneRaggiungibile(Const Posizione : TPosizione3d; Const EntitaDiAttraversamento : TEntitaDiAttraversamento; Const DallAlto : Boolean; Out Raggiungibile : Boolean; Out ElementiPresenti : TVettorepElementi; Const Direzione : Integer);
Function ElementoAttraversabile(Const pElemento : TpElemento; Const EntitaDiAttraversamento : TEntitaDiAttraversamento; Const Direzione : Integer) : Boolean;

Procedure EsecuzioneEvento(Var pElemento : TpElemento; Var pSorgente : TpElemento; Const Direzione : Integer);

Function DirezioneRelativaElementi(Const Posizione1 : TPosizione3d; Const Posizione2 : TPosizione3d) : Integer;


Function Spostabile(Const pElemento : TpElemento; Const ElementoAttraversante : TEntitaDiAttraversamento; Const Direzione : Integer) : Boolean;


//Procedure EsecuzioneLogicaEventi(Const Posizione : TPosizione3d; Const EntitaDiAttraversamento : TEntitaDiAttraversamento; Const DallAlto : Boolean; Var pElemento : TpElemento);

Function PosizioniUguali(Const Posizione1 : TPosizione3d; Const Posizione2 : TPosizione3d) : Boolean;
Procedure CambioStatoAscensore(Var pAscensore : TpElemento; Var pCarico : TpElemento; Const Attivato : Boolean);

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

 // Posizione.Z := 3;

  pElemento^.Tipo := Tipo;
  pElemento^.Orientamento := Orientamento;
  pElemento^.Posizione := Posizione;
  pElemento^.PosizioneFisica := Posizione;
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
  Occupato := True; // DIRTY: Occupato è probabilmente inutile
  AltezzaTotale2d := (AltezzaMassima) * Dimensioni2dCubo.c + (DimensioneScacchiera+1)*2*Dimensioni2dCubo.a;
  IncrementoCoordinataX := Bitmap.Width Div 2;
  IncrementoCoordinataY := (Bitmap.Height - AltezzaTotale2d) / 2 + (AltezzaMassima-1) * Dimensioni2dCubo.c;

  Bitmap.Canvas.Brush.Color := $300000;
  Bitmap.Canvas.FillRect(Rect(Bitmap.Width,Bitmap.Height,0,0));


  If Rotazione.AnimazioneInEsecuzione Then Begin
    Rotazione.PosizioneAnimazione := Rotazione.PosizioneAnimazione + 0.09 - Rotazione.PosizioneAnimazione * 0.06;
    //Rotazione.PosizioneAnimazione := Rotazione.PosizioneAnimazione + 0.01 + Rotazione.PosizioneAnimazione * 0.146;
    DisegnoAnimazioneRotazione();
    If Rotazione.PosizioneAnimazione >= 0.95 Then Begin // È finita
      Rotazione.AnimazioneInEsecuzione := False;
      //Occupato := False;
    End;
  End Else Begin
    DisegnoScacchiera();
    DisegnoElementi();
  End;

  //DisegnoArea(Immagini.Cubo, 2, 3, 1);
  //DisegnoArea(Immagini.Cubo2, 4, 1, 1);


  Occupato := False;
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
{Var
  Contatore                      : Integer;
  Indice                         : Integer;
  PrioritaUltimoBloccoDisegnato  : Real;
  IndiceMinimoAttuale            : Integer;
  MinimoAttuale                  : Real;
  pElemento                      : TpElemento; }
Begin
  If Elementi.Dimensione = 0 Then Exit;
  //FIXED: se due elementi hanno la stessa priorità ne viene disegnato solo uno

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


    {
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

  }
  
  //ImmagineDaDisegnare := Immagini.Cubo;
End;



Procedure RotazioneScacchiera;
Var
  Indice    : Integer;
  pElemento : TpElemento;
Begin
  //Occupato := True;
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
    //AggiornaPrioritaDiDisegno(Elementi.Vettore[Indice]);


    //BUGBUG: se la scacchiera ruota mentre qualcosa si muove c'è qualcosa che non va
    {If pElemento^.Animazione.InEsecuzione Then Begin
      //Scambio(pElemento^.Animazione.X, pElemento^.Animazione.Y);
      If Direzione = 1
        Then pElemento^.Animazione.X := - pElemento^.Animazione.X
        Else pElemento^.Animazione.Y := - pElemento^.Animazione.Y;
    End;}
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
  Destinazione     : TPosizione3d;
//  Raggiungibile    : Boolean;
//  ElementiPresenti : TVettorepElementi;

//  Indice           : Integer;
//  pElemento    : TpElemento;
Begin
  Destinazione := CoordinateElementoVicino(pRobot, pRobot^.Orientamento);

  //If Not Spostabile(pRobot, pRobot^.Orientamento);

  If Not Spostabile(pRobot, Personaggio, pRobot^.Orientamento) Then Exit;

  //EsecuzioneLogicaEventi(Destinazione, Personaggio, False, pRobot);

  //ControlloPosizioneRaggiungibile(Destinazione, Personaggio, False, Raggiungibile, ElementiPresenti, pRobot^.Orientamento);


  //If Not Raggiungibile Then Exit;

  //EsecuzioneEventi(ElementiPresenti, Personaggio, False);

  //For Indice := 1 To ElementiPresenti.Dimensione Do Begin
  //  EsecuzioneEvento(ElementiPresenti.Vettore[Indice], pRobot, False);
  //End;

  

  //If Not PosizioneRaggiungibile(Destinazione, True, False) Then Exit;

  {pElemento := ElementoInPosizione(Destinazione);
  If pElemento <> Nil Then Begin
    If pElemento^.Tipo = BloccoFisso Then Exit;
    If pElemento^.Tipo = BloccoMobile Then Begin
       If Spostabile(pElemento, pRobot^.Orientamento) Then Begin
           Spostamento(pElemento, pRobot^.Orientamento);
           PreparazioneAnimazione(pElemento);
           //pRobot^.Posizione := Destinazione;
       End Else Begin
           Exit;
       End;    
    End;
  End;    }

  //BUGBUG: va prima questo o esecuzione logica eventi?
  Spostamento(pRobot, pRobot^.Orientamento);

  //pRobot^.Posizione := Destinazione;
  //PreparazioneAnimazione(pRobot);
  //AggiornaPrioritaDiDisegno(pRobot);
End;

Function CoordinateElementoVicino;
Var
  Posizione : TPosizione3d;
Begin
  //If (Direzione < 0) Or (Direzione > 3) Then Begin
  //  Posizione.X := 0/0;
  //End;
  Posizione.X := Elemento.Posizione.X;
  Posizione.Y := Elemento.Posizione.Y;
  Posizione.Z := Elemento.Posizione.Z;
  If Direzione = 0 Then Posizione.X := Posizione.X + 1;
  If Direzione = 1 Then Posizione.Y := Posizione.Y + 1;
  If Direzione = 2 Then Posizione.X := Posizione.X - 1;
  If Direzione = 3 Then Posizione.Y := Posizione.Y - 1;
  If Direzione = -1 Then Posizione.Z := Posizione.Z - 1; //GIU
  If Direzione = -2 Then Posizione.Z := Posizione.Z + 1; //SU
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
  //PrioritaDiDisegno := Posizione.X * 65536 + Posizione.Y * 256 + Posizione.Z
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

Function ElementoInPosizione;
Var
  Indice           : Integer;
  pElemento        : TpElemento;
  RicercaTerminata : Boolean;
  ElementoTrovato  : Boolean;
Begin
  RicercaTerminata := False;
  ElementoTrovato := False; // Per evitare il Warning di delphi
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
 {
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
End; }


Procedure Spostamento;
Var
  //pElementoVicino             : TpElemento;
  //Destinazione                : TPosizione3d;
  Destinazione                : TPosizione3d;
  PosizioneElementoSuperiore  : TPosizione3d;
  Indice  : Integer;
Begin
  Destinazione := CoordinateElementoVicino(pElemento, Direzione);

  //pElementoVicino := ElementoInPosizione(Destinazione);
  //If pElementoVicino <> Nil Then Spostamento(pElementoVicino, Direzione);

  //BUGBUG: attenzione quando si distrugge un oggetto, il ciclo potrebbe corrompersi
  //Indice:=0;


  //PosizioneElementoSuperiore := pElemento^.Posizione;
  //PosizioneElementoSuperiore.Z := PosizioneElementoSuperiore.Z + 1;

  //pElementoVicino := ElementoInPosizione(PosizioneElementoSuperiore);
  //If pElementoVicino <> Nil Then Begin

  //TODOTODO: da mettere apposto
 //   If Spostabile(pElementoVicino, Direzione)
   //   Then Spostamento(pElementoVicino, Direzione)
    //  Else Cadi(pElementoVicino)
  //End;

  PosizioneElementoSuperiore := pElemento^.Posizione;
  PosizioneElementoSuperiore.Z := PosizioneElementoSuperiore.Z + 1;

  For Indice := 1 To Elementi.Dimensione Do Begin


    If PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, PosizioneElementoSuperiore) Then Begin
      If Spostabile(Elementi.Vettore[Indice], Blocco, Direzione)
        Then
         Spostamento(Elementi.Vettore[Indice], Direzione)
        Else Caduta(Elementi.Vettore[Indice]);
    End;

    

    //Sposta blocchi affiancati (solo se il movimento è orizzontale)
    If (Direzione >= 0) And ((Elementi.Vettore[Indice]^.Tipo = BloccoMobile) Or (Elementi.Vettore[Indice]^.Tipo = BloccoPuzzle)) And PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, Destinazione) Then Begin
      //EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, pElemento^.Animazione.Direzione);
      Spostamento(Elementi.Vettore[Indice], Direzione);
    End;
  End;

  //pElemento^.Destinazione := Destinazione;
  PreparazioneAnimazione(pElemento, Direzione);
End;

Procedure PreparazioneAnimazione;
Begin
  // BUGBUG qui vengono effettuate delle sottrazioni, ma Animazione deve sempre contenere -1, 0 o 1
  pElemento^.Animazione.InEsecuzione := True;

  pElemento^.Animazione.Destinazione := CoordinateElementoVicino(pElemento, Direzione);
  pElemento^.Animazione.Direzione := Direzione;

 // pElemento^.Animazione.pDestinazione := pDestinazione;

  pElemento^.Animazione.X := Trunc(pElemento^.Animazione.Destinazione.X - pElemento^.Posizione.X);
  pElemento^.Animazione.Y := Trunc(pElemento^.Animazione.Destinazione.Y - pElemento^.Posizione.Y);
  pElemento^.Animazione.Z := Trunc(pElemento^.Animazione.Destinazione.Z - pElemento^.Posizione.Z);
  pElemento^.Animazione.Progresso := 0;
  //Occupato := True;
End;


//FIXED: Nome procedura poco rigoroso: la caduta può anche non verificarsi
Procedure Caduta;
Var
  //pElementoSottostante        : TpElemento;
  Destinazione                : TPosizione3d;
Begin
  //Destinazione := pElemento^.Posizione;
  //Destinazione.Z := Destinazione.Z - 1;

  //If Not Spostabile(pElemento, Blocco, -1) Then Exit;   //DIRTY: gli effetti sono gli stessi, ma viene usato sempre Blocco anche quando cade il robot

  Spostamento(pElemento, -1);

  //If Not EntroILimitiDellaScacchiera(Destinazione) Then Begin
  //  Exit;
  //End;

  //pElemento^.Posizione := Destinazione;
  //PreparazioneAnimazione(pElemento);

  //pElementoSottostante := ElementoInPosizione(Destinazione);
  //If (pElementoSottostante <> Nil) And (pElementoSottostante^.Tipo = Robot) And (pElementoSottostante^.Attivato = Robot) Begin

    //Cadi(pElemento);
  //End;
End;




Procedure AggiornamentoProgressoAnimazione;
Var
  Indice              : Integer;
  ElementoSottostante : TPosizione3d;
Begin
  pElemento^.Animazione.Progresso := pElemento^.Animazione.Progresso + 0.2;
  pElemento^.PosizioneFisica.X := pElemento^.Posizione.X + pElemento^.Animazione.X * pElemento^.Animazione.Progresso;
  pElemento^.PosizioneFisica.Y := pElemento^.Posizione.Y + pElemento^.Animazione.Y * pElemento^.Animazione.Progresso;
  pElemento^.PosizioneFisica.Z := pElemento^.Posizione.Z + pElemento^.Animazione.Z * pElemento^.Animazione.Progresso;
  If pElemento^.Animazione.Progresso >= 1 Then Begin
    pElemento^.PosizioneFisica := pElemento^.Animazione.Destinazione;
    pElemento^.Posizione := pElemento^.Animazione.Destinazione;

    //If pElemento^.Animazione.pDestinazione <> Nil Then
    //  EsecuzioneEvento(pElemento^.Animazione.pDestinazione, pElemento, pElemento^.Animazione.Direzione);
    //End;
    pElemento^.Animazione.InEsecuzione := False;
    ElementoSottostante := CoordinateElementoVicino(pElemento, -1);
    For Indice := 1 To Elementi.Dimensione Do Begin
      If PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, pElemento^.Animazione.Destinazione) Then Begin
        EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, pElemento^.Animazione.Direzione);
      End;
      //la chiamata sopra funziona per tutte le direzioni
      
    //  If PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, ElementoSottostante) Then Begin
    //    EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, -1);
    //  End;
    End;

    If (Instabile(pElemento)) Then Caduta(pElemento);

    //For Indice := 1 To Elementi.Dimensione Do Begin
    //  If PosizioniUguali(pElemento^.Posizione, pElemento^.Destinazione) Then Begin
    //    EsecuzioneEvento(pElemento, pElemento, pElemento^.Animazione.Direzione);
    //  End;
    //End;





 //   If ((pElemento^.Tipo <> Robot) And ( pRobot^.Posizione.X = pElemento^.Posizione.X) And
 //   ( pRobot^.Posizione.Y = pElemento^.Posizione.Y) And
 //   ( pRobot^.Posizione.Z = pElemento^.Posizione.Z)) Then
    //TODOTODO fine partita per schiacciamento robot

    
   //   pRobot^.Posizione.X := pRobot^.Posizione.X/0;
    // BUGBUG non è detto
    //Occupato := False;
  End;
End;







Function Instabile;
Var    
  Destinazione         : TPosizione3d;
  pElementoSottostante : TpElemento;
Begin
  //BUGBUG: anche il blocco fisso può ora cadere, visto che cade sempre se viene spostata la sua base mentre lui non può muoversi orizzontalmente
  //DIRTY: questo controllo dovrebbe già venire effettuato dentro la Spostabile()
  If (pElemento^.Posizione.Z = 1) {Or (pElemento^.Tipo = BloccoFisso)} Then Begin
    Instabile := False;
    Exit;
  End;
  //DIRTY: l'effetto non cambia, ma viene sempre mandato Blocco alla fnzione spostabile
  Instabile := Spostabile(pElemento, Blocco, -1);
  //Destinazione := pElemento^.Posizione;
  //Destinazione.Z := Destinazione.Z - 1;
  //pElementoSottostante := ElementoInPosizione(Posizione);
  //If (pElementoSottostante = Nil) Or (pElementoSottostante^.Tipo = Robot) Or ((pElementoSottostante^.Tipo = Ascensore) And (pElementoSottostante^.Attivato = False))
  //  Then Instabile := True
  //  Else Instabile := False;
End;


Procedure EsecuzioneLogicaDiGioco;
Var
  Indice    : Integer;
  pElemento : TpElemento;
Begin
  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];

    If pElemento^.Animazione.InEsecuzione Then Begin
      AggiornamentoProgressoAnimazione(pElemento);

    End Else Begin
      //If Instabile(Elementi.Vettore[Indice]) Then
      //  Caduta(Elementi.Vettore[Indice]);

    End;
    
  End;
End;

{
//BUGBUG: questa proc viene chiamata inutilmente due volte per muovere un oggetto: la prima volta per controllare che si possa, la seconda per ottenere il vettore degli elementi che si trovano in quel punto.
Procedure ControlloPosizioneRaggiungibile;
Var
  Indice                  : Integer;
  IndiceElementiPresenti  : Integer;
  pElemento               : TpElemento;
  ControlloTerminato      : Boolean;
  Dummy   : TVettorepElementi;
  PosizioneVicinaRaggiungibile : Boolean;
Begin

  If Not EntroILimitiDellaScacchiera(Posizione) Then Begin
    Raggiungibile := False;
    Exit;
  End;

  Raggiungibile := True;
  ControlloTerminato := False;
  Indice := 0;
  IndiceElementiPresenti := 0;

  Repeat
    Indice := Indice + 1;
    pElemento := Elementi.Vettore[Indice];
    If (
         (pElemento^.Posizione.X = Posizione.X) And
         (pElemento^.Posizione.Y = Posizione.Y) And
         (pElemento^.Posizione.Z = Posizione.Z)
       ) Then Begin
           If ElementoAttraversabile(pElemento, EntitaDiAttraversamento, DallAlto) Then Begin
             IndiceElementiPresenti := IndiceElementiPresenti + 1;
             ElementiPresenti.Vettore[IndiceElementiPresenti] := pElemento;
           End Else Begin
             Raggiungibile := False;
             ControlloTerminato := True;
           End;
           //DIRTY: istruzione sporca
           ControlloPosizioneRaggiungibile(CoordinateElementoVicino(pElemento, Direzione), Blocco, DallAlto, PosizioneVicinaRaggiungibile, Dummy, Direzione);
           If Not PosizioneVicinaRaggiungibile Then Begin
             Raggiungibile := False;
             ControlloTerminato := True;
           End;
         End Else Begin
           If Indice = Elementi.Dimensione Then Begin
             ControlloTerminato := True;
           End;
         End;
  Until ControlloTerminato;



  If Raggiungibile Then Begin
     ElementiPresenti.Dimensione := IndiceElementiPresenti;
  End;


End;  }
        

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
    If (Tipo = Ascensore) And (pElemento^.Attivato) Then Exit;

    If Direzione < 0 Then Begin // Blocco/Robot Da sopra (o dal basso)
      //If (Tipo = BloccoPuzzle) Then Exit;
      //If (Tipo = BloccoMobile) Then Exit;

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

Procedure EsecuzioneEvento;
Var
  Tipo             : TTipoElemento;
  TipoSorgente     : TTipoElemento;
Begin
 // If pElemento^.Animazione Then Exit;
  Tipo := pElemento^.Tipo;
  TipoSorgente := pSorgente^.Tipo;



  If Direzione < 0 Then Begin
    If (Tipo = Ascensore) Then
       //   Spostamento(pSorgente, Direzione);
      CambioStatoAscensore(pElemento, pSorgente, False);
  End Else Begin
    // Già gestito all'inizio dell'animazione nella procedura Spostamento
    //If (Tipo = BloccoMobile) Or (Tipo = BloccoPuzzle) Then
    //DirezioneRelativaElementi(pSorgente^.Posizione, pElemento^.Posizione)
      //Spostamento(pElemento, Direzione);
    If (Tipo = Ascensore) Then
    //      Spostamento(pSorgente, Direzione);
      CambioStatoAscensore(pElemento, pSorgente, True);
  End;

End;


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
  If (pElemento^.Tipo <> Robot) And (pElemento^.Tipo <> BloccoMobile) And (pElemento^.Tipo <> BloccoPuzzle) Then Begin
    Spostabile := False;
    Exit;
  End;

  Destinazione := CoordinateElementoVicino(pElemento, Direzione);
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



{Procedure EsecuzioneLogicaEventi;
Var
  Indice  : Integer;
Begin

  //BUGBUG: attenzione quando si distrugge un oggetto, il ciclo potrebbe corrompersi
  For Indice := 1 To Elementi.Dimensione Do Begin
      //If PosizioniUguali(Elementi.Vettore[Indice]^.Posizione, pElemento^.Posizione) Then
      //EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, False);
  End;

End;  }

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
    Spostamento(pCarico, -2);
  End Else Begin
    Spostamento(pCarico, -1);
  End;

End;


end.
