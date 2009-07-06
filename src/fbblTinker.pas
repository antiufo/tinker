unit fbblTinker;

//==============================================================================
  Interface
//==============================================================================





// FIXED: Sembra che correndo il robot possa non cadere
// FIXED: Se il robot spinge un blocco verso un nastro che punta verso di lui, i due compenetrano
// BUGBUG: Cadendo su un ascensore abbassato questo non si alza
// FIXED: Non si riesce a portare su un ascensore una pila di oggetti senza che questo si riabbassi appena alzato



Uses Graphics, ExtCtrls, SysUtils, Forms, Classes, Types, Math, StrUtils, TypInfo, Registry, frmEsito;

Type
  TDimensioni2dCubo = Record
                       a : Integer;
                       b : Integer;
                       c : Integer;
                      End;

//TBitmap
  TBitmapOnOff = Array[0..1] Of TBitmap;

  TBitmapColorizzate = Array[1..5] Of TBitmap;
  TBitmapColorizzateOnOff = Array[0..1] Of TBitmapColorizzate;

  TQuattroBitmap = Array[0..3] Of TBitmap;
  TQuattroBitmapColorizzateOnOff = Array[0..3] Of TBitmapColorizzateOnOff;

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

                Bomba                     : TBitmapColorizzateOnOff;

                InterruttorePavimento     : TBitmapOnOff;
                InterruttorePuzzle        : TBitmapColorizzateOnOff;
                InterruttoreLevetta       : TBitmapColorizzateOnOff;

                Ascensore                 : TBitmapOnOff;
                Nastro                    : TQuattroBitmapColorizzateOnOff;
                Teletrasporto             : TBitmap;

                BloccoPuzzle              : TBitmapColorizzate;
                //BloccoMetallico           : TBitmap;
                BloccoGhiaccio            : TBitmap;
                BloccoMobile              : TBitmap;
                BloccoFisso               : TBitmap;

                Robot                     : TQuattroBitmap;
                Traguardo                 : TBitmap;


                //Cubo                      : TBitmap;
                //Cubo2                     : TBitmap;
                //TestFrame                 : TBitmap;


                IconaCartella                 : TBitmap;
                IconaLivelloCompletato        : TBitmap;
                IconaLivelloSuperato          : TBitmap;
                IconaLivelloNonSuperato       : TBitmap;

               // InterruttoreBersaglio                   : TQuattroBitmapColorizzateOnOff;
               // Calamita                    : TQuattroBitmapColorizzateOnOff;
               // Specchio                    : TQuattroBitmap;

                Porta                       : TQuattroBitmapColorizzateOnOff;
               // Pistola                     : TQuattroBitmapColorizzateOnOff;
                Ingranaggio                 : TBitmap;
                Pila                        : TBitmap;

                EsitoPartitaPositivo                : TBitmap;
                EsitoPartitaNegativo                : TBitmap;

               //TODO Pistola                     : TQuattroBitmapColorizzateOnOff;

              End;



  TTipoElemento = ( BloccoFisso=01, BloccoMobile=02, BloccoGhiaccio=03, BloccoPuzzle=05,
                    Ascensore=11, Nastro=12, Teletrasporto=13,
                    InterruttorePavimento=21, InterruttorePuzzle=22, InterruttoreLevetta=24,
                    Bomba=31, Porta=32,
                    Pila=41, Ingranaggio=42,
                    Robot=51, Traguardo=52);

  TEntitaDiAttraversamento = (Personaggio, Blocco, Laser);
  TCausaSpostamento = (ComandoPersonaggio, AvvioTeletrasporto, SpintaPersonaggio, SpintaBlocco, Gravita, MovimentoBloccoSottostante, ScorrimentoNastroSottostante, Esplosione);

  TScacchiera = Record
                               Direzione              : Integer; // -1 o 1
                               PosizioneAnimazione    : Real;    // 0..1
                               Orientamento           : Integer; // 0..3
                               AnimazioneInEsecuzione : Boolean;
                               Bitmap                 : TBitmap;
                               CacheValida            : Boolean;
                           End;

  TPosizione3d = Record
                   X : Real;
                   Y : Real;
                   Z : Real;
                 End;

  TpElemento = ^TElemento;

  TMovimento = Record
                   X : Integer; // -1, 0 o 1
                   Y : Integer;
                   Z : Integer;
                   Direzione    : Integer; // 0..3: orizzontale, -1: giù, -2: su, -3: apparizione
                   Progresso    : Real;
                   InEsecuzione : Boolean;
                   Destinazione          : TPosizione3d;  // Posizione logica di fine Movimento
                   DistanzaCaduta        : Integer;
                 End;
  TElemento = Record
                Tipo         : TTipoElemento;
                Orientamento : Integer;
                Posizione             : TPosizione3d;  // Posizione logica prima dell'Movimento Movimento
                PosizioneFisica       : TPosizione3d;  // Posizione effettiva nello spazio fisico (cambia durante l'Movimento)
                Movimento            : TMovimento;   // Informazioni sulla direzione di Movimento
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
                  pElemento    : TpElemento;
                  Direzione    : Integer;
                  Destinazione : TPosizione3d;
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

  //TNaturaElemento = (Pavimentazione, Solido, Strumento, Oggetto);  //Oggetto: sia solido che strumento

  TTipoLivello = (LivelloCompletato, LivelloSuperato, LivelloNonSuperato, Cartella, Sistema);

  TVoceMenu = Record
                Testo      : String;
                Percorso   : String;
                Tipo       : TTipoLivello;
              End;  


  TSottomenu = (Chiuso, Principale, Caricamento, Aiuto);

  TArrayVociMenu = Array[0..1000] Of TVoceMenu;

  TVettoreVociMenu = Record
                       Vettore    : TArrayVociMenu;
                       Dimensione : Integer;
                     End;

  TArrayColorizzazioni = Array[1..5, 1..4] Of TColor;

  TMenu = Record
            Menu                 : TSottomenu;
            ElementoSelezionato  : Integer;
            Cartella             : String;
            CartellaSuperiore    : String;
            //Sfondo               : TBitmap;
            Voci                 : TVettoreVociMenu;
            PrimoElementoDaDisegnare   : Integer;
            UltimoElementoDaDisegnare  : Integer;
            UltimoLivelloCaricato : String;
          End;




Const
  Dimensioni2dCubo : TDimensioni2dCubo = (
                         a : 17;
                         b : 34;
                         c : 39;
                     );

  AltezzaMassima : Integer = 6;

  CartellaLivelli : String = '.\Levels\';
  ChiaveLivelliSuperati : String = '\Software\Tinker\Levels';

  Colorizzazioni : TArrayColorizzazioni = (
     ($2684FF, $006AFF, $005FDF, $0057CE), //Arancio  //Dal più chiaro al più scuro
     //($FF2679, $ff005d, $dd0051, $cc004a),
     ($CC007A, $B50069, $a0005d, $7f004a), // Viola
     ($22D822, $1DC11D, $1AA51A, $158715), // Verde
     ($C7D321, $AFBC1E, $9AA51A, $788214), // Verde acqua
     ($80E3F7, $74CCE0, $66B1c4, $5a9cad)  // Panna
  );



Var
  PaintBox : TPaintBox;
  Immagini : TImmagini;
  DimensioneScacchiera  : Integer;
  IncrementoCoordinataX : Real;
  IncrementoCoordinataY : Real;
  Bitmap                : TBitmap;
  Scacchiera            : TScacchiera;
Var
  Elementi              : TVettorepElementi;
  pRobot                : TpElemento;
  CodaOperazioni        : TCodaOperazioni;
  Inizializzato         : Boolean = False;
  MenuDiGioco           : TMenu;
  Livello               : String = '';
  RisoluzioneOriginaleH : Integer = 0;
  RisoluzioneOriginaleW : Integer = 0;
  LivelliSuperati : TRegistry;
  //CadutaRobot           : Integer;
  Energia               : Integer;
  IngranaggiTrovati     : Integer;
  IngranaggiTotali      : Integer;



//Procedure InizializzazioneGioco();
Procedure InizializzazioneScacchiera(Const Dimensioni : Integer);
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; Posizione : TPosizione3d; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Procedure AggiuntaElemento(Const Tipo : TTipoElemento; X: Integer; Y: Integer; Z: Integer; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
Procedure CaricamentoImmagini();

Procedure CaricamentoImmagine(Var Bitmap : TBitmap; Const NomeFile : String); overload; overload;
Procedure CaricamentoImmagine(Var BitmapColorizzate : TBitmapColorizzate; Const BaseNome : String); overload;
Procedure CaricamentoImmagine(Var BitmapOnOff : TBitmapOnOff; Const BaseNome : String); overload;
Procedure CaricamentoImmagine(Var BitmapColorizzateOnOff : TBitmapColorizzateOnOff; Const BaseNome : String); overload;
Procedure CaricamentoImmagine(Var QuattroBitmap : TQuattroBitmap; Const BaseNome : String); overload;
Procedure CaricamentoImmagine(Var QuattroBitmapColorizzateOnOff : TQuattroBitmapColorizzateOnOff; Const BaseNome : String); overload;


Procedure DisegnoArea(Const Immagine : TBitmap; Const x : Real; Const y : Real; Const z : Real; Var Bitmap : TBitmap);
Procedure MostraFrame();

Function Coordinata2dX(Const X : Real; Const Y : Real; Const Z : Real) : Integer;
Function Coordinata2dY(Const X : Real; Const Y : Real; Const Z : Real) : Integer;

Procedure DisegnoSchermata();

Procedure DisegnoScacchiera();
Procedure DisegnoMovimentoRotazione();
Procedure DisegnoElementi();
Procedure DisegnoTestoFondoElemento(Const Posizione : TPosizione3d; Const Testo : String; Var Bitmap : TBitmap);


Function ImmagineDaDisegnare(Const pElemento : TpElemento) : TBitmap;
Procedure RotazioneScacchiera(Const Direzione : Integer);
Function NuovoOrientamento(Const Numero : Integer; Const Direzione : Integer) : Integer;
Function ImmagineCasellaScacchiera(Const x: Integer; y: Integer) : TBitmap;

Procedure GiraRobot(Const Direzione : Integer);
Procedure AvanzaRobot;
Function CoordinateElementoVicino(Const Posizione : TPosizione3d; Const Direzione : Integer) : TPosizione3d;

Procedure AggiornamentoPrioritaDiDisegno;
Function PrioritaDiDisegno(Const pElemento : TpElemento) : Real;
Procedure OrdinamentoElementiPerPrioritaDiDisegno;
Procedure Scambio(Var Elemento1 : TpElemento; Var Elemento2 : TpElemento); overload;
Procedure Scambio(Var Elemento1 : Real;       Var Elemento2 : Real); overload;
Procedure Scambio(Var Elemento1 : Integer;    Var Elemento2 : Integer); overload;

Function EntroILimitiDellaScacchiera(Const Posizione : TPosizione3d) : Boolean;

Procedure Spostamento(Var pElemento : TpElemento; Const Direzione : Integer; Const Destinazione : TPosizione3d);
//Procedure SpostamentoGenerico(Var pElemento : TpElemento; Const Direzione : Integer; Const Destinazione : TPosizione3d);

Procedure SpostamentoElementoSuperiore(Const PosizioneBase : TPosizione3d; Var pElementoSuperiore : TpElemento; Const Direzione : Integer);

Procedure PreparazioneMovimento(Var pElemento : TpElemento; { Var pDestinazione : TpElemento;} Const Direzione : Integer; Const Destinazione : TPosizione3d);

//Procedure Caduta(Var pElemento : TpElemento);

Procedure AggiornamentoProgressoMovimento(Var pElemento : TpElemento);


Function Instabile(Const pElemento : TpElemento) : Boolean;

Procedure EsecuzioneLogicaDiGioco();

Function ElementoAttraversabile(Const pElemento : TpElemento; Const EntitaDiAttraversamento : TEntitaDiAttraversamento; Const Direzione : Integer) : Boolean;

//Procedure EsecuzioneEvento(Var pElemento : TpElemento; Var pSorgente : TpElemento; Const Direzione : Integer);

Function DirezioneRelativaElementi(Const Posizione1 : TPosizione3d; Const Posizione2 : TPosizione3d) : Integer;


Function Spostabile(Const pElemento : TpElemento; Const CausaSpostamento : TCausaSpostamento; Const Direzione : Integer) : Boolean;

Function PosizioniUguali(Const Posizione1 : TPosizione3d; Const Posizione2 : TPosizione3d) : Boolean;
Procedure CambioStatoAscensore(Var pAscensore : TpElemento; Const Attivato : Boolean);

Procedure Accodamento(Var pElemento : TpElemento; Const Direzione : Integer);
Procedure AccodamentoGenerico(Var pElemento : TpElemento; Const Direzione : Integer; Const Destinazione : TPosizione3d);
Procedure RimozioneDaCoda();

Procedure EsecuzioneOperazione(Var Operazione : TOperazione);

Procedure FineSpostamento(Var pElemento : TpElemento);

Function ElementoDiPavimentazione(Const pElemento : TpElemento) : Boolean;

Function ElementoInPosizione(Const Posizione : TPosizione3d; Const Pavimentazione : Boolean) : TpElemento;

Procedure AzionamentoTeletrasporto(Var pTeletrasporto : TpElemento);

Procedure MostraEsitoPartita(Const Testo : String; Const Vinto : Boolean);
Procedure MessaggioErrore(Const Testo : PAnsiChar);

Function TeletrasportoCorrispondente(Const pRiferimento : TpElemento) : TpElemento;

Procedure DisegnoMenu;
Procedure AperturaMenu(Const Menu : TSottomenu);


Procedure AzionaLevetta;

Procedure CambioStatoInterruttore(Var pInterruttore : TpElemento; Const Attivato : Boolean);

//PROCEDURE RGBToHSV (CONST R,G,B: Real; VAR H,S,V: Real);
//PROCEDURE HSVtoRGB (CONST H,S,V: Real; VAR R,G,B: Real);

Procedure AggiuntaVoceMenu(Const Testo : String; Const Percorso : String; Const Tipo : TTipoLivello);

Function PercorsoCartellaSuperiore(Const Percorso : String) : String;
Function UltimaPosizioneStringaInStringa(const SottoStringa: String; const Stringa: String): Integer;

Procedure CaricamentoLivello(Const Percorso : String);

Function IntToTipoElemento(Const Numero : Integer) : TTipoElemento;

Procedure DimensionamentoScacchiera();

Function IdentificatoreLivelloDaNomeFile(Const NomeFile : String) : String;
Function NomeDescrittivoLivello(Const NomeFile : String) : String;

Function StatoLivello(Const NomeFile : String) : TTipoLivello;

Procedure DimensionamentoAree(Const Larghezza : Integer; Const Altezza : Integer);

Procedure RaggiungimentoTraguardo();

Function CambiaCaricaBatteria(Const Incremento : Integer) : Boolean;


//Procedure AggiornamentoStatoInterruttore(Var pInterruttore : TpElemento);

Procedure EsplosioneBomba(var pBomba : TpElemento);

Procedure EliminazioneElemento(Var pElemento : TpElemento);

//==============================================================================
  Implementation

uses ConvUtils, ffrmTinker;
//==============================================================================

{Procedure InizializzazioneGioco;
Begin

End;}

Procedure InizializzazioneScacchiera;
Begin
  DimensioneScacchiera := Dimensioni;
  Scacchiera.Orientamento := 0;
  Scacchiera.CacheValida := False;
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
  pElemento^.Movimento.InEsecuzione := False;
  pElemento^.Movimento.Destinazione := Posizione;
  pElemento^.Movimento.Direzione := -3;
  pElemento^.Movimento.DistanzaCaduta := 0;
  pElemento^.PosizioneFisica := Posizione;
  pElemento^.Attivato := Attivato;
  pElemento^.Colore := Colore;

  //CadutaRobot := 0;

  If Tipo = Robot Then pRobot := pElemento;
End;

Procedure AggiuntaElemento(Const Tipo : TTipoElemento; X: Integer; Y: Integer; Z: Integer; Orientamento : Integer; Attivato : Boolean; Colore : Integer); overload;
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
  //InizializzazioneColorizzazione(Colorizzazioni[2], 100);

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

  CaricamentoImmagine(Immagini.Bomba, 'Bomba');

  CaricamentoImmagine(Immagini.InterruttorePavimento, 'InterruttorePavimento');
  CaricamentoImmagine(Immagini.InterruttorePuzzle, 'InterruttorePuzzle');
  CaricamentoImmagine(Immagini.InterruttoreLevetta, 'InterruttoreLevetta');

  CaricamentoImmagine(Immagini.Ascensore, 'Ascensore');
  CaricamentoImmagine(Immagini.Nastro, 'Nastro');
  CaricamentoImmagine(Immagini.Teletrasporto, 'Teletrasporto');


  CaricamentoImmagine(Immagini.BloccoPuzzle, 'BloccoPuzzle');
 // CaricamentoImmagine(Immagini.BloccoMetallico, 'BloccoMetallico');
  CaricamentoImmagine(Immagini.BloccoGhiaccio, 'BloccoGhiaccio');
  CaricamentoImmagine(Immagini.BloccoMobile, 'BloccoMobile');
  CaricamentoImmagine(Immagini.BloccoFisso, 'BloccoFisso');

  CaricamentoImmagine(Immagini.Robot, 'Robot');
  CaricamentoImmagine(Immagini.Traguardo, 'Traguardo');


        {



                InterruttorePavimento     : TBitmapOnOff;
                InterruttorePuzzle        : TBitmapColorizzateOnOff;
                InterruttoreLevetta       : TBitmapColorizzateOnOff;

                Ascensore                 : TBitmapOnOff;
                Nastro                    : TBitmapColorizzateOnOff;
                Teletrasporto             : TBitmap;

                BloccoPuzzle              : TBitmapColorizzate;
                BloccoMetallico           : TBitmap;
                BloccoGhiaccio            : TBitmap;
                BloccoMobile              : TBitmap;
                BloccoFisso               : TBitmap;

                Robot                     : TQuattroBitmap;
                Traguardo                 : TBitmap;
         }


  CaricamentoImmagine(Immagini.IconaCartella, 'IconaCartella');
  CaricamentoImmagine(Immagini.IconaLivelloNonSuperato, 'IconaLivelloNonSuperato');
  CaricamentoImmagine(Immagini.IconaLivelloSuperato, 'IconaLivelloSuperato');
  CaricamentoImmagine(Immagini.IconaLivelloCompletato, 'IconaLivelloCompletato');


 // CaricamentoImmagine(Immagini.InterruttoreBersaglio, 'InterruttoreBersaglio');
  //CaricamentoImmagine(Immagini.Calamita, 'Calamita');
  //CaricamentoImmagine(Immagini.Specchio, 'Specchio');
  CaricamentoImmagine(Immagini.Porta, 'Porta');
  CaricamentoImmagine(Immagini.Ingranaggio, 'Ingranaggio');
  CaricamentoImmagine(Immagini.Pila, 'Pila');


  
  CaricamentoImmagine(Immagini.EsitoPartitaPositivo, 'EsitoPartitaPositivo');
  CaricamentoImmagine(Immagini.EsitoPartitaNegativo, 'EsitoPartitaNegativo');

    {





  //CaricamentoImmagine(Immagini.Cubo, 'Cubo');

  CaricamentoImmagine(Immagini.Cubo, 'Cubo');
  CaricamentoImmagine(Immagini.Cubo2, 'Cubo2');

  CaricamentoQuattroImmagini(Immagini.Robot, 'Robot');

  CaricamentoImmagine(Immagini.AscensoreOn, 'AscensoreOn');
  CaricamentoImmagine(Immagini.AscensoreOff, 'AscensoreOff');

  CaricamentoQuattroImmagini(Immagini.NastroOn, 'NastroOn');
  CaricamentoQuattroImmagini(Immagini.NastroOff, 'NastroOff');

  CaricamentoImmagine(Immagini.Teletrasporto, 'Teletrasporto');

  CaricamentoImmagine(Immagini.BloccoMetallico, 'BloccoMetallico');
  CaricamentoImmagine(Immagini.BloccoMobile, 'BloccoMobile');
  CaricamentoImmagine(Immagini.BloccoGhiaccio, 'BloccoGhiaccio');

  CaricamentoImmagine(Immagini.Traguardo, 'Traguardo');

  CaricamentoImmaginiColorizzate(Immagini.LevettaOff, 'LevettaOff');
  CaricamentoImmaginiColorizzate(Immagini.LevettaOn, 'LevettaOn');

  CaricamentoImmaginiColorizzate(Immagini.BloccoPuzzle, 'BloccoPuzzle');
   }
End;

Procedure CaricamentoImmagine(Var BitmapColorizzate : TBitmapColorizzate; Const BaseNome : String); overload;
Var
  Indice   : Integer;
  X        : Integer;
  Y        : Integer;
  Bitmap   : TBitmap;
Begin

  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile('Images\'+BaseNome+'.bmp');  //HACK: percorso duplicato

  For Indice := 1 To 5 Do Begin
    BitmapColorizzate[Indice] := TBitmap.Create;
    BitmapColorizzate[Indice].Width := Bitmap.Width;
    BitmapColorizzate[Indice].Height := Bitmap.Height;
    BitmapColorizzate[Indice].Transparent := True;
    BitmapColorizzate[Indice].TransparentColor := clFuchsia;
    BitmapColorizzate[Indice].Canvas.Draw(0,0, Bitmap);
    For X := 0 To Bitmap.Width Do Begin
      For Y := 0 To Bitmap.Height Do Begin
        Case BitmapColorizzate[Indice].Canvas.Pixels[X, Y] Of
          $00E000 : BitmapColorizzate[Indice].Canvas.Pixels[X, Y] := Colorizzazioni[Indice, 1];
          $00C000 : BitmapColorizzate[Indice].Canvas.Pixels[X, Y] := Colorizzazioni[Indice, 2];
          $00A000 : BitmapColorizzate[Indice].Canvas.Pixels[X, Y] := Colorizzazioni[Indice, 3];
          $008000 : BitmapColorizzate[Indice].Canvas.Pixels[X, Y] := Colorizzazioni[Indice, 4];
        End;
      End;
    End;
  End;
End;

Procedure CaricamentoImmagine(Var QuattroBitmap : TQuattroBitmap; Const BaseNome : String); overload;
Begin
  CaricamentoImmagine(QuattroBitmap[0], BaseNome+'_0');
  CaricamentoImmagine(QuattroBitmap[1], BaseNome+'_1');
  CaricamentoImmagine(QuattroBitmap[2], BaseNome+'_2');
  CaricamentoImmagine(QuattroBitmap[3], BaseNome+'_3');
End;


Procedure CaricamentoImmagine(Var Bitmap : TBitmap; Const NomeFile : String); overload; overload;
Begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile('Images\'+NomeFile+'.bmp');
  Bitmap.Transparent := True;
  Bitmap.TransparentColor := clFuchsia;
End;

Procedure DisegnoArea; //Disegna una bitmap alle coordinate 3D specificate
Begin
  Bitmap.Canvas.Draw(Coordinata2dX(X, Y, Z), Coordinata2dY(X, Y, Z), Immagine);
End;

Procedure MostraFrame; // Copia l'intera Bitmap sulla Paintbox
Begin
  Paintbox.Canvas.Draw(0,0, Bitmap);
End;

Function Coordinata2dX;
Begin
  Coordinata2dX := Trunc(IncrementoCoordinataX + (x - y - 1) * Dimensioni2dCubo.b);
End;

Function Coordinata2dY;
Begin
  Coordinata2dY := Trunc(IncrementoCoordinataY + (x+y-2) * Dimensioni2dCubo.a - (z - 1) * Dimensioni2dCubo.c)
End;






procedure DisegnoSchermata;
begin

  If Not Scacchiera.CacheValida Then DisegnoScacchiera();

  Bitmap.Canvas.Draw(0, 0, Scacchiera.Bitmap);
  
  If Scacchiera.AnimazioneInEsecuzione Then Begin

  End Else Begin
    DisegnoElementi();
  End;


    

  If(Energia>0) then begin
    Bitmap.Canvas.Font.Color := clYellow;
    Bitmap.Canvas.Font.Name := 'Verdana';
    Bitmap.Canvas.Font.Size := 20;
    Bitmap.Canvas.Brush.Style := bsClear;
    Bitmap.Canvas.TextOut(bitmap.Width-100, 50, IntToStr(Energia));
  end;


  If MenuDiGioco.Menu <> Chiuso Then Begin
    DisegnoMenu();
  End;

  MostraFrame();

End;



Procedure DisegnoScacchiera; // Disegna la scacchiera
Var
  x: Integer;
  y: Integer;
Begin
//  MessaggioErrore('disegno scacchiera');
  Scacchiera.Bitmap.Canvas.Brush.Color := $000000;//$280000;
  Scacchiera.Bitmap.Canvas.FillRect(Rect(Bitmap.Width,Bitmap.Height,0,0));

  If Scacchiera.AnimazioneInEsecuzione Then Begin
    DisegnoMovimentoRotazione();
    Exit;
  End;

  // Disegna le caselle
  For x := 1 To DimensioneScacchiera Do
    For y := 1 To DimensioneScacchiera Do
      DisegnoArea(ImmagineCasellaScacchiera(x, y), x, y, 0, Scacchiera.Bitmap);

  // Disegna i bordi
  For y := 1 To DimensioneScacchiera Do
    DisegnoArea(Immagini.ScacchieraBordoSE, DimensioneScacchiera+1, y, 1, Scacchiera.Bitmap);
  For x := DimensioneScacchiera DownTo 1 Do
    DisegnoArea(Immagini.ScacchieraBordoSW, x, DimensioneScacchiera+1, 1, Scacchiera.Bitmap);
  For y := DimensioneScacchiera DownTo 1 Do
    DisegnoArea(Immagini.ScacchieraBordoNW, 0, y, 1, Scacchiera.Bitmap);
  For x := 1 To DimensioneScacchiera Do
    DisegnoArea(Immagini.ScacchieraBordoNE, x, 0, 1, Scacchiera.Bitmap);

  // Disegna gli angoli
  DisegnoArea(Immagini.ScacchieraAngoloE, DimensioneScacchiera+1, 0, 1, Scacchiera.Bitmap);
  DisegnoArea(Immagini.ScacchieraAngoloS, DimensioneScacchiera+1, DimensioneScacchiera+1, 1, Scacchiera.Bitmap);
  DisegnoArea(Immagini.ScacchieraAngoloW, 0, DimensioneScacchiera+1, 1, Scacchiera.Bitmap);
  DisegnoArea(Immagini.ScacchieraAngoloN, 0, 0, 1, Scacchiera.Bitmap);

  Scacchiera.CacheValida := True;

End;



Procedure DisegnoMovimentoRotazione();
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

  Angolo := Scacchiera.PosizioneAnimazione * Pi/2 * Scacchiera.Direzione;

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

  Scacchiera.Bitmap.Canvas.Brush.Color := $4980B3;//;$14185D;;
  Scacchiera.Bitmap.Canvas.Pen.Style := psClear;
  Scacchiera.Bitmap.Canvas.Polygon(Punti);
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
    If pElemento = Nil then continue;
    DisegnoArea(ImmagineDaDisegnare(pElemento), pElemento^.PosizioneFisica.X, pElemento^.PosizioneFisica.Y, pElemento^.PosizioneFisica.Z, Bitmap);
    //SLOWSLOW: questi calcoli vengono fatti anche nella DisegnoArea
    If pElemento^.Tipo = Teletrasporto Then DisegnoTestoFondoElemento(pElemento^.PosizioneFisica, IntToStr(pElemento^.Colore), Bitmap);
  End;
End;

Function ImmagineDaDisegnare;
Var
  Stato        : Integer;
  Colore       : Integer;
  Orientamento : Integer;
Begin

  If pElemento^.Attivato
    Then Stato := 1
    Else Stato := 0;
  Colore := pElemento^.Colore;
  Orientamento := pElemento^.Orientamento;

  Case pElemento^.Tipo Of
    Bomba : ImmagineDaDisegnare := Immagini.Bomba[Stato][Colore];

    InterruttorePavimento : ImmagineDaDisegnare := Immagini.InterruttorePavimento[Stato];
    InterruttorePuzzle : ImmagineDaDisegnare := Immagini.InterruttorePuzzle[Stato][Colore];
    InterruttoreLevetta : ImmagineDaDisegnare := Immagini.InterruttoreLevetta[Stato][Colore];

    Ascensore : ImmagineDaDisegnare := Immagini.Ascensore[Stato];
    Nastro : ImmagineDaDisegnare := Immagini.Nastro[Orientamento][Stato][Colore];
    Teletrasporto : ImmagineDaDisegnare := Immagini.Teletrasporto;

    BloccoPuzzle : ImmagineDaDisegnare := Immagini.BloccoPuzzle[Colore];
   // BloccoMetallico : ImmagineDaDisegnare := Immagini.BloccoMetallico;
    BloccoGhiaccio : ImmagineDaDisegnare := Immagini.BloccoGhiaccio;
    BloccoMobile : ImmagineDaDisegnare := Immagini.BloccoMobile;
    BloccoFisso : ImmagineDaDisegnare := Immagini.BloccoFisso;

    Robot : ImmagineDaDisegnare := Immagini.Robot[Orientamento];
    Traguardo : ImmagineDaDisegnare := Immagini.Traguardo;


    Porta : ImmagineDaDisegnare := Immagini.Porta[Orientamento][Stato][Colore];

   // InterruttoreBersaglio : ImmagineDaDisegnare := Immagini.InterruttoreBersaglio[Orientamento][Stato][Colore];
   // Pistola : ImmagineDaDisegnare := Immagini.Pistola[Orientamento][Stato][Colore];
    //Calamita : ImmagineDaDisegnare := Immagini.Calamita[Orientamento][Stato][Colore];

    Pila : ImmagineDaDisegnare := Immagini.Pila;
    Ingranaggio : ImmagineDaDisegnare := Immagini.Ingranaggio;

   //TODO Specchio : ImmagineDaDisegnare := Immagini.Specchio[Orientamento][Stato][Colore];





  End;

 // MessaggioErrore('Impossibile determinare l immagine da disegnare.')

  //BUGBUG: forse l'immagine viene ogni volta copiata, sarebbe meglio restituire il puntatore

  //ImmagineDaDisegnare := Immagini.BloccoPuzzle[2];


  {
  If pElemento^.Tipo = Ascensore Then Begin
    If pElemento^.Attivato
      Then ImmagineDaDisegnare := Immagini.AscensoreOn
      Else ImmagineDaDisegnare := Immagini.AscensoreOff;
    Exit;
  End;
  If pElemento^.Tipo = Nastro Then Begin
    If pElemento^.Attivato
      Then ImmagineDaDisegnare := Immagini.NastroOn[pElemento^.Orientamento]
      Else ImmagineDaDisegnare := Immagini.NastroOff[pElemento^.Orientamento];
    Exit;
  End;
  If pElemento^.Tipo = InterruttoreLevetta Then Begin
    If pElemento^.Attivato
      Then ImmagineDaDisegnare := Immagini.LevettaOn[pElemento^.Colore]
      Else ImmagineDaDisegnare := Immagini.LevettaOff[pElemento^.Colore];
    Exit;
  End;
  If pElemento^.Tipo = InterruttorePuzzle Then Begin
    If pElemento^.Attivato
      Then ImmagineDaDisegnare := Immagini.InterruttorePuzzleOn[pElemento^.Colore]
      Else ImmagineDaDisegnare := Immagini.InterruttorePuzzleOff[pElemento^.Colore];
    Exit;
  End;
  Case pElemento^.Tipo Of
    Robot: ImmagineDaDisegnare := Immagini.Robot[pElemento^.Orientamento];
    BloccoFisso: ImmagineDaDisegnare := Immagini.Cubo2;
    BloccoMobile: ImmagineDaDisegnare := Immagini.BloccoMobile;
    Teletrasporto: ImmagineDaDisegnare := Immagini.Teletrasporto;
    BloccoMetallico: ImmagineDaDisegnare := Immagini.BloccoMetallico;
    BloccoGhiaccio: ImmagineDaDisegnare := Immagini.BloccoGhiaccio;
    Traguardo: ImmagineDaDisegnare := Immagini.Traguardo;
    BloccoPuzzle: ImmagineDaDisegnare := Immagini.BloccoPuzzle[pElemento^.Colore];
  Else
    MessaggioErrore('Impossibile determinare l''immagine da disegnare.');
    //ImmagineDaDisegnare := Immagini.Cubo;
  End;}



End;


Procedure DisegnoTestoFondoElemento;
Var
  DimensioniTesto  : TSize;
  //Testo            : String;
Begin
  Bitmap.Canvas.Font.Color := clBlack;
  Bitmap.Canvas.Font.Size := 16;
  Bitmap.Canvas.Font.Style := [fsBold];
  Bitmap.Canvas.Font.Name := 'Verdana';
  //Bitmap.Canvas.Brush.Color := $800000; //HACK: viene colorato di marrone invece che non colorato
  DimensioniTesto := Bitmap.Canvas.TextExtent(Testo);
  Bitmap.Canvas.Brush.Style := bsClear;
  Bitmap.Canvas.TextOut(Coordinata2dX(Posizione.X, Posizione.Y, Posizione.Z) + Dimensioni2dCubo.b - DimensioniTesto.cx Div 2, Coordinata2dY(Posizione.X, Posizione.Y, Posizione.Z) + Dimensioni2dCubo.c + 5, Testo);

End;


Procedure RotazioneScacchiera;
Var
  Indice    : Integer;
  pElemento : TpElemento;
Begin
  Scacchiera.Orientamento := NuovoOrientamento(Scacchiera.Orientamento, Direzione);
  Scacchiera.Direzione := Direzione;
  Scacchiera.PosizioneAnimazione := 0;
  Scacchiera.AnimazioneInEsecuzione := True;
  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    if pElemento = Nil Then continue;
    pElemento^.Orientamento := NuovoOrientamento(pElemento^.Orientamento, Direzione);
    Scambio(pElemento^.Posizione.X, pElemento^.Posizione.Y);
    Scambio(pElemento^.PosizioneFisica.X, pElemento^.PosizioneFisica.Y);
    If Direzione = 1
      Then pElemento^.Posizione.X := DimensioneScacchiera + 1 - pElemento^.Posizione.X
      Else pElemento^.Posizione.Y := DimensioneScacchiera + 1 - pElemento^.Posizione.Y;
    If Direzione = 1
      Then pElemento^.PosizioneFisica.X := DimensioneScacchiera + 1 - pElemento^.PosizioneFisica.X
      Else pElemento^.PosizioneFisica.Y := DimensioneScacchiera + 1 - pElemento^.PosizioneFisica.Y;
     //BUGBUG: se la scacchiera ruota mentre qualcosa si muove c'è qualcosa che non va
  End;
End;


Function NuovoOrientamento;
Begin
  NuovoOrientamento := (Numero+Direzione +4) Mod 4;
End;



Function ImmagineCasellaScacchiera;
Begin
  If (x Mod 2 = 0) Xor (y Mod 2 = 0) Xor ((Scacchiera.Orientamento Mod 2 = 0) And (DimensioneScacchiera Mod 2 = 0)) Then
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


  If Not Spostabile(pRobot, ComandoPersonaggio, pRobot^.Orientamento) Then Exit;

  if(CambiaCaricaBatteria(-1)=False) then exit;

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
  If Direzione = -3 Then
  MessaggioErrore('CoordinateElementoVicino ha ricevuto una direzione pari a -3');
  CoordinateElementoVicino := PosizioneVicina;
End;

Procedure AggiornamentoPrioritaDiDisegno;
Var
  Indice : Integer;
Begin
  For Indice := 1 To Elementi.Dimensione Do Begin
    If Elementi.Vettore[Indice] = Nil Then continue;
    Elementi.Vettore[Indice]^.PrioritaDiDisegno := PrioritaDiDisegno(Elementi.Vettore[Indice]);
  End;
End;

Function PrioritaDiDisegno;
Var
  Priorita : Real;
Begin
  Priorita := pElemento^.PosizioneFisica.X + pElemento^.PosizioneFisica.Y + pElemento^.PosizioneFisica.Z;
  If ElementoDiPavimentazione(pElemento) Then Priorita := Priorita - 0.5;
  PrioritaDiDisegno := Priorita;
End;

Procedure OrdinamentoElementiPerPrioritaDiDisegno;
Var
  Indice1   : Integer;
  Indice2   : Integer;
  PosMinimo : Integer;
Begin
  If Elementi.Dimensione = 1 Then Exit;
  For Indice1 := 1 To Elementi.Dimensione - 1 Do Begin
    If Elementi.Vettore[Indice1] = Nil Then Continue;
    PosMinimo := Indice1;
    For Indice2 := Indice1 To Elementi.Dimensione Do Begin
      If (Elementi.Vettore[Indice2] <> Nil) And (Elementi.Vettore[Indice2]^.PrioritaDiDisegno < Elementi.Vettore[PosMinimo]^.PrioritaDiDisegno) Then
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



//Procedure Spostamento;
{Var
  Destinazione : TPosizione3d;
Begin

  Destinazione := CoordinateElementoVicino(pElemento^.Movimento.Destinazione, Direzione);
  SpostamentoGenerico(pElemento, Direzione, Destinazione);
End;}


Procedure Spostamento;
Var
  //Destinazione                : TPosizione3d;
  DestinazioneElementoSuperiore : TPosizione3d;
  PosizioneElementoVicino       : TPosizione3d;
  pElementoVicino               : TpElemento;
 // Indice  : Integer;
Begin

//  If Direzione = -3 Then MessaggioErrore('È stato chiesto di spostare l''elemento nella direzione -3');

  //BUGBUG: attenzione quando si distrugge un oggetto, il ciclo potrebbe corrompersi

  PreparazioneMovimento(pElemento, Direzione, Destinazione);

  PosizioneElementoVicino := pElemento^.Posizione;
  PosizioneElementoVicino.Z := PosizioneElementoVicino.Z + 1;


  pElementoVicino := ElementoInPosizione(PosizioneElementoVicino, False);
  If (pElementoVicino <> Nil)
    Then SpostamentoElementoSuperiore(Destinazione, pElementoVicino, Direzione);

  pElementoVicino := ElementoInPosizione(PosizioneElementoVicino, True);
  If (pElementoVicino <> Nil)
    Then SpostamentoElementoSuperiore(Destinazione, pElementoVicino, Direzione);


    //TODO qui stavo facendo qualcosa ma non mi ricordo cosa
  {If pElemento^.Tipo = InterruttorePavimento Then Begin
  pElementoVicino := ElementoInPosizione(pElemento^.Posizione, False);
  If (pElementoVicino <> Nil) And (pElementoVicino^.Tipo = Blocco)

  End;
  }



     //     If Direzione = -3
    //      Then Begin
    //        AccodamentoGenerico(pElementoVicino, Direzione, Destinazione)
    //      End;
    //      Else Accodamento(pElementoVicino, Direzione)

  pElementoVicino := ElementoInPosizione(pElemento^.Movimento.Destinazione, False);

  // Se spinto orizzontalmente, spingi anche l'elemento affianco
  If (pElementoVicino <> Nil) Then Begin
    If (Direzione >= 0) And ((pElementoVicino^.Tipo = BloccoMobile) Or (pElementoVicino^.Tipo = BloccoPuzzle)) Then Begin
      //MessaggioErrore('sposto vicino');
      Accodamento(pElementoVicino, Direzione);
    End;
  End;





End;



Procedure SpostamentoElementoSuperiore;
Var
  DestinazioneElementoSuperiore : TPosizione3d;
 // ProssimaCausaSpostamento      : TCausaSpostamento;
Begin

  DestinazioneElementoSuperiore := PosizioneBase;
  DestinazioneElementoSuperiore.Z := DestinazioneElementoSuperiore.Z + 1;
  If Spostabile(pElementoSuperiore, MovimentoBloccoSottostante, Direzione)
      Then AccodamentoGenerico(pElementoSuperiore, Direzione, DestinazioneElementoSuperiore)
      Else Accodamento(pElementoSuperiore, -1);    // BUGBUG: caduta, non semplice spostamento
End;



Procedure PreparazioneMovimento;
Begin
  pElemento^.Movimento.InEsecuzione := True;

  pElemento^.Movimento.Destinazione := Destinazione;
  pElemento^.Movimento.Direzione := Direzione;

  pElemento^.Movimento.X := Trunc(pElemento^.Movimento.Destinazione.X - pElemento^.Posizione.X);
  pElemento^.Movimento.Y := Trunc(pElemento^.Movimento.Destinazione.Y - pElemento^.Posizione.Y);
  pElemento^.Movimento.Z := Trunc(pElemento^.Movimento.Destinazione.Z - pElemento^.Posizione.Z);
  pElemento^.Movimento.Progresso := 0;
End;

{
Procedure Caduta;
Var
  Destinazione                : TPosizione3d;
Begin
  Spostamento(pElemento, -1);
End;
 }



Procedure AggiornamentoProgressoMovimento;
//Var
  //Indice              : Integer;
  //ElementoSottostante : TPosizione3d;
Var
  Progresso : Real;
Begin
  Progresso := pElemento^.Movimento.Progresso;

  Case pElemento^.Movimento.Direzione Of
    -3 : Progresso := Progresso + 0.04;
    -1 : Progresso := Progresso + (pElemento^.Movimento.DistanzaCaduta + Progresso)*0.15 + 0.01;
  Else
    Progresso := Progresso + 0.08;
  End;
  
  //DisegnoTestoFondoElemento(pElemento^.Posizione, 'dgh');
                                   //Rotazione.PosizioneAnimazione + 0.09 - Rotazione.PosizioneAnimazione * 0.06

  If pElemento^.Movimento.Direzione = -3 Then Begin
    If pElemento^.Tipo <> Bomba
     //Then
     Then pElemento^.PosizioneFisica.Z := pElemento^.Posizione.Z + Progresso*50 //HACK: viene posto molto in alto invece che nascosto
  End Else Begin
    pElemento^.PosizioneFisica.X := pElemento^.Posizione.X + pElemento^.Movimento.X * Progresso;
    pElemento^.PosizioneFisica.Y := pElemento^.Posizione.Y + pElemento^.Movimento.Y * Progresso;
    pElemento^.PosizioneFisica.Z := pElemento^.Posizione.Z + pElemento^.Movimento.Z * Progresso;
  End;


  If Progresso >= 1 Then Begin
    pElemento^.PosizioneFisica := pElemento^.Movimento.Destinazione;
    pElemento^.Posizione := pElemento^.Movimento.Destinazione;

    pElemento^.Movimento.InEsecuzione := False;
    FineSpostamento(pElemento);
  End;

  pElemento^.Movimento.Progresso := Progresso;

End;


Function Instabile;
//Var
//  Destinazione         : TPosizione3d;
  //pElementoSottostante : TpElemento;
Begin
  //BUGBUG: anche il blocco fisso può ora cadere, visto che cade sempre se viene spostata la sua base mentre lui non può muoversi orizzontalmente

  //FIXED DIR-TY: l'effetto non cambia, ma viene sempre mandato Blocco alla fnzione spostabile
  Instabile := Spostabile(pElemento, Gravita, -1);
End;


Procedure EsecuzioneLogicaDiGioco;
Var
  Indice    : Integer;
  pElemento : TpElemento;
Begin


  If Scacchiera.AnimazioneInEsecuzione Then Begin
    Scacchiera.PosizioneAnimazione := Scacchiera.PosizioneAnimazione + 0.09 - Scacchiera.PosizioneAnimazione * 0.06;

    If Scacchiera.PosizioneAnimazione >= 0.95 Then Begin // È finita
      Scacchiera.AnimazioneInEsecuzione := False;
      //DisegnoScacchiera();
    End;

    Scacchiera.CacheValida := False;

    Exit;
  End;


  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    If pElemento = Nil Then continue;
    If pElemento^.Movimento.InEsecuzione Then AggiornamentoProgressoMovimento(pElemento);
  End;


  For Indice := 1 To Elementi.Dimensione Do Begin
    pElemento := Elementi.Vettore[Indice];
    if pElemento = Nil Then continue;
    //FIXED DIR-TY: viene sempre usato blocco  (anche se il risultato non cambia)
    //HACK: bisognerebbe testare l'instabilità di un elemento solo quando serve
    If Not pElemento^.Movimento.InEsecuzione Then Begin
      If Spostabile(pElemento, Gravita, -1) Then //Begin
        Accodamento(pElemento, -1);

    //  End Else Begin
    //    CadutaRobot := 0;
    //  End;
    End;
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
 // If (Tipo = BloccoMetallico) Then Exit;
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
     // If (Tipo = InterruttoreBersaglio) Then Exit;
     // If (Tipo = Pistola) Then Exit;
    //  If (Tipo = Specchio) Then Exit;
     // If (Tipo = Calamita) Then Exit;
      If (Tipo = Bomba) Then Exit;
      If EntitaDiAttraversamento = Blocco Then Begin
         If (Tipo = Pila) Then Exit;
         If (Tipo = Ingranaggio) Then Exit;
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
 // If pElemento^.Movimento Then Exit;
  Tipo := pElemento^.Tipo;
  TipoSorgente := pSorgente^.Tipo;

  ///BUGBUG: sistemare una cazzatina qui
 // If pSorgente^.Movimento.Direzione <> -2 Then Exit;

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
//  Raggiungibile : Boolean;
//  ControlloTerminato : Boolean;
//  Indice             : Integer;
  pElementoVicino    : TpElemento;
  ProssimaEntitaDiAttraversamento : TEntitaDiAttraversamento;
  ProssimaCausaSpostamento        : TCausaSpostamento;
  TeoricamenteSpostabile          : Boolean;
Begin
  // FIXED: il robot non deve poter essere mosso da un blocco

  If (CausaSpostamento = Gravita) And (pElemento.Posizione.Z = 1) Then Begin
    Spostabile := False;
    Exit;
  End;

  If CausaSpostamento <> Gravita Then Begin
      pElemento^.Tipo := pElemento^.Tipo;
   End;


  // Con il teletrasporto si può sempre spostare qualcosa
  If CausaSpostamento = AvvioTeletrasporto Then Begin
    Spostabile := True;
    Exit;
  End;

  //HACK: se ci arriva per teletrasporto, immagina che si possa sempre
  If (Direzione <> -3) Then Begin
    Destinazione := CoordinateElementoVicino(pElemento^.Posizione, Direzione);
    If Not EntroILimitiDellaScacchiera(Destinazione) Then Begin
      Spostabile := False;
      Exit;
    End;
  End;

  // FIXED: il robot non deve poter essere mosso da un blocco
  // HACK: forse queste istruzioni non servono più
  If (pElemento^.Tipo = Robot) And (CausaSpostamento = SpintaBlocco) Then Begin
    Spostabile := False;
    Exit;
  End;




  TeoricamenteSpostabile := False;

  If (CausaSpostamento = MovimentoBloccoSottostante) Or (CausaSpostamento = Gravita)
    Then TeoricamenteSpostabile := True;

  If (pElemento^.Tipo = BloccoMobile) Or (pElemento^.Tipo = BloccoPuzzle)
    Then TeoricamenteSpostabile := True;

  If (pElemento^.Tipo = Robot) And ((CausaSpostamento = ComandoPersonaggio) Or (CausaSpostamento = ScorrimentoNastroSottostante))
    Then TeoricamenteSpostabile := True;

  If Not TeoricamenteSpostabile Then Begin
    Spostabile := False;
    Exit;
  End;




  //GENERICI

  // O non c'è ~gnente~

  pElementoVicino := ElementoInPosizione(Destinazione, False);
  If (pElementoVicino = Nil) Then Begin
    Spostabile := True;
    Exit;
  End;

  // O è attraversabile
  If pElemento^.Tipo = Robot
    Then ProssimaEntitaDiAttraversamento := Personaggio
    Else ProssimaEntitaDiAttraversamento := Blocco;
  If ElementoAttraversabile(pElementoVicino, ProssimaEntitaDiAttraversamento, Direzione) Then Begin
    Spostabile := True;
    Exit;
  End;


  // O Spostabile
                              // BUGBUG; specificare, non è sempre SpintaBlocco



    If Spostabile(pElementoVicino, SpintaBlocco, Direzione) Then Begin
      Spostabile := True;
      Exit;
    End;



  Spostabile := False;
 // Spostabile := True;
  Exit;

  //Si può sempre spostare qualcosa sopra alle pavimentazioni


  //BUGBUG: qui viene sempre usato blocco come entità di attraversamento, ma è sbagliato e gli effetti sono diversi


End;



Function PosizioniUguali;
Begin
  If (Posizione1.X = Posizione2.X) And (Posizione1.Y = Posizione2.Y) And (Posizione1.Z = Posizione2.Z)
    Then PosizioniUguali := True
    Else PosizioniUguali := False;
End;

Procedure CambioStatoAscensore;
Var
  pCarico          : TpElemento;
  PosizioneCarico  : TPosizione3d;
Begin
  If Attivato Then Begin
    pCarico := ElementoInPosizione(pAscensore^.Posizione, False);
    If pCarico <> Nil Then Accodamento(pCarico, -2);
  End Else Begin
    PosizioneCarico := pAscensore^.Posizione;
    PosizioneCarico.Z := PosizioneCarico.Z + 1;
    pCarico := ElementoInPosizione(PosizioneCarico, False);
    If pCarico <> Nil Then Accodamento(pCarico, -1);
  End;
  pAscensore^.Attivato := Attivato;
End;

Procedure AccodamentoGenerico;
Var
  pNuovo     : TpeCodaOperazioni;
Begin
//  Spostamento(pElemento, Direzione);
//Exit;
  If (Direzione <> -3) And Not PosizioniUguali(CoordinateElementoVicino(pElemento^.Posizione, Direzione), Destinazione) Then MessaggioErrore('La destinazione fornita per lo spostamento non è corretta.');

  New(pNuovo);
  pNuovo^.pSuccessivo := Nil;
  pNuovo^.Operazione.pElemento := pElemento;
  pNuovo^.Operazione.Direzione := Direzione;
  pNuovo^.Operazione.Destinazione := Destinazione;
  If CodaOperazioni.pInizio = Nil Then Begin
    CodaOperazioni.pInizio := pNuovo;
    CodaOperazioni.pFine := pNuovo;
  End Else Begin
    CodaOperazioni.pFine^.pSuccessivo := pNuovo;
    CodaOperazioni.pFine := pNuovo;
  End;
End;

Procedure Accodamento;
Var
  Destinazione   : TPosizione3d;
Begin
  If Direzione = -3 Then
  MessaggioErrore('Accodamento: è stato richiesto lo spostamento di un elemento in direzione -3 senza specificarne la destinazione.');
  Destinazione := CoordinateElementoVicino(pElemento^.Posizione, Direzione);
  AccodamentoGenerico(pElemento, Direzione, Destinazione);
//  Spostamento(pElemento, Direzione);
//Exit;

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

  //HACK: spostabile con blocco
  //If Spostabile(Operazione.pElemento, Blocco, Operazione.Direzione) Then Exit;
  Spostamento(Operazione.pElemento, Operazione.Direzione, Operazione.Destinazione);
End;


Procedure FineSpostamento;
Var
//  Indice                        : Integer;
  PosizioneElementoVicino       : TPosizione3d;
  pElementoVicino               : TpElemento;
  Direzione                     : Integer;
Begin
  Direzione := pElemento^.Movimento.Direzione;

  // HACK: viene usato destinazione invece di posizione
  PosizioneElementoVicino := CoordinateElementoVicino(pElemento^.Posizione, -1);


  


  pElementoVicino := ElementoInPosizione(pElemento^.Posizione, True);



  // Se è stato posizionato su un ascensore abbassato, alzalo
  If (pElementoVicino <> Nil) Then Begin
    If (pElementoVicino^.Tipo = Ascensore) And Not pElementoVicino^.Attivato And (Direzione <> -1)
      Then CambioStatoAscensore(pElementoVicino, True);
    If (pElementoVicino^.Tipo = Nastro) And pElementoVicino^.Attivato And Spostabile(pElemento, ScorrimentoNastroSottostante, pElementoVicino^.Orientamento) //HACK anche qua per blocco
      Then Accodamento(pElemento, pElementoVicino^.Orientamento);
    If (pElementoVicino^.Tipo = Teletrasporto) And (pElemento^.Movimento.Direzione <> -3)
      Then AzionamentoTeletrasporto(pElementoVicino);
    If (pElementoVicino^.Tipo = Traguardo) And (pElemento^.Tipo = Robot)
      Then RaggiungimentoTraguardo();
    If (pElementoVicino^.Tipo = InterruttorePuzzle) And (pElemento^.Tipo = BloccoPuzzle) And (pElemento^.Colore = pElementoVicino^.Colore)
      Then CambioStatoInterruttore(pElementoVicino, True);  // BUGBUG: non viene mai riportato a false
    If (pElementoVicino^.Tipo = Pila) And (pElemento^.Tipo = Robot) Then Begin
      EliminazioneElemento(pElementoVicino);
      CambiaCaricaBatteria(+10);
    End;
    If (pElementoVicino^.Tipo = Ingranaggio) And (pElemento^.Tipo = Robot) Then Begin
      EliminazioneElemento(pElementoVicino);
      IngranaggiTrovati := IngranaggiTrovati + 1;
    End;
  End;






  pElementoVicino := ElementoInPosizione(pElemento^.Posizione, False);
  If (pElementoVicino <> Nil) Then Begin
    If (pElementoVicino^.Tipo = Robot) And (pElemento^.Tipo <> Robot) And (pElemento^.Movimento.Direzione = -1)
      Then MostraEsitoPartita('Robot schiacciato!', False);
  End;

  If Instabile(pElemento) Then Begin
    pElemento^.Movimento.DistanzaCaduta := pElemento^.Movimento.DistanzaCaduta + 1;
  End Else Begin
    If (pElemento = pRobot) And (pElemento^.Movimento.DistanzaCaduta > 2)
      Then MostraEsitoPartita('Il robot è caduto da un'' altezza troppo elevata', False);
    pElemento^.Movimento.DistanzaCaduta := 0;
       // Else CadutaRobot := 0;
  End;



  PosizioneElementoVicino := pElemento^.Posizione;
  PosizioneElementoVicino.Z := PosizioneElementoVicino.Z - 1;  
  pElementoVicino := ElementoInPosizione(PosizioneElementoVicino, False);

  // Se è stato posizionato su un ascensore alzato, abbassalo
  If (pElementoVicino <> Nil) Then Begin
    If (pElementoVicino^.Tipo = Ascensore) And pElementoVicino^.Attivato And (Direzione <> -2)
      Then CambioStatoAscensore(pElementoVicino, False);
  End;





    {For Indice := 1 To Elementi.Dimensione Do Begin
      pVicino := Elementi.Vettore[Indice];
      If PosizioniUguali(pVicino^.Posizione, pElemento^.Posizione) Then Begin
        If (pVicino^.Tipo = Ascensore) And (Elementi.Vettore[Indice]^.Attivato = False) Then Begin
          If pElemento^.Movimento.Direzione <> -1 Then Begin
            CambioStatoAscensore(pVicino, pElemento, True);
          End;
        End;
      End;

      If PosizioniUguali(pVicino^.Posizione, PosizioneElementoSottostante) Then Begin
        If (pVicino^.Tipo = Ascensore) And (Elementi.Vettore[Indice]^.Attivato = True) Then Begin
          If pElemento^.Movimento.Direzione <> -2 Then Begin
            CambioStatoAscensore(pVicino, pElemento, False);
          End;
        End;
      End;
      //la chiamata sopra funziona per tutte le direzioni
    End;
    }


        //EsecuzioneEvento(Elementi.Vettore[Indice], pElemento, pElemento^.Movimento.Direzione);
    //If (Instabile(pElemento)) Then Caduta(pElemento);

    //For Indice := 1 To Elementi.Dimensione Do Begin
    //  If PosizioniUguali(pElemento^.Posizione, pElemento^.Destinazione) Then Begin
    //    EsecuzioneEvento(pElemento, pElemento, pElemento^.Movimento.Direzione);
    //  End;
    //End;

End;


Function ElementoDiPavimentazione;
Var
  Tipo : TTipoElemento;
Begin
  Tipo := pElemento^.Tipo;

 { NaturaElemento := Solido;
  If Tipo = BloccoPuzzle Then Exit;
  If Tipo = BloccoMetallico Then Exit;
  If Tipo = BloccoGhiaccio Then Exit;
  If Tipo = BloccoMobile Then Exit;
  If Tipo = BloccoFisso Then Exit;
  If pElemento^.Attivato And ((Tipo = Ascensore) Or (Tipo = Porta)) Then Exit;
  If Tipo = Robot Then Exit;
  }

  ElementoDiPavimentazione := True;
  //HACK DISABLED: ora porte e ascensori attivati sono considerati pavimentazione
  If Not pElemento^.Attivato And ((Tipo = Ascensore) Or (Tipo = Porta)) Then Exit;
  If Tipo = InterruttorePavimento Then Exit;
  If Tipo = InterruttorePuzzle Then Exit;
  If Tipo = Nastro Then Exit;
  If Tipo = Teletrasporto Then Exit;
  If Tipo = Traguardo Then Exit;
  If Tipo = Pila Then Exit;
  If Tipo = Ingranaggio Then Exit;

  ElementoDiPavimentazione := False;

  {NaturaElemento := Oggetto;
  If Tipo = Pila Then Exit;
  If Tipo = Ruota Then Exit;
  If Tipo = Bomba Then Exit;
  If Tipo = Calamita Then Exit;
  If Tipo = Specchio Then Exit;
  If Tipo = Pistola Then Exit;
  If Tipo = InterruttoreBersaglio Then Exit;
  If Tipo = InterruttoreLevetta Then Exit;

   i := 0 div i;
  }
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
    // BUGBUG: spreco di risorse, viene continuamente chiamata la NaturaElemento
    If PosizioniUguali(pElemento^.Posizione, Posizione) And (ElementoDiPavimentazione(pElemento) = Pavimentazione) Then Begin
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


Procedure AzionamentoTeletrasporto;
Var
  pCarico                      : TpElemento;
//  PosizioneCarico              : TPosizione3d;
  pTeletrasportoGemello        : TpElemento;
  pCaricoTeletrasportoGemello  : TpElemento;
Begin
  pCarico := ElementoInPosizione(pTeletrasporto^.Posizione, False);
  If pCarico = Nil Then MessaggioErrore('Il teletrasporto è stato azionato senza che sia presente un carico');

  pTeletrasportoGemello := TeletrasportoCorrispondente(pTeletrasporto);
  pCaricoTeletrasportoGemello := ElementoInPosizione(pTeletrasportoGemello^.Posizione, False);

  AccodamentoGenerico(pCarico, -3, pTeletrasportoGemello^.Posizione);

  If pCaricoTeletrasportoGemello <> Nil Then Begin
    AccodamentoGenerico(pCaricoTeletrasportoGemello, -3, pTeletrasporto^.Posizione);

  End;



  //SpostamentoGenerico(pCaricoTeletrasportoGemello, -3, pCarico^.Posizione);


  //Accodamento(pCarico, -2);
End;


Procedure MostraEsitoPartita;
Begin
  frmEsitoPartita := TfrmEsitoPartita.Create(frmTinker);
  frmEsitoPartita.Caption := Testo;
  frmEsitoPartita.Vinto := Vinto;
  frmEsitoPartita.ShowModal();

  //if(Vinto=False) Then begin
  Energia := -1;
  Livello := '';
  AperturaMenu(Caricamento);
  //end;
  

End;


Procedure MessaggioErrore;
Begin
   MostraEsitoPartita(Testo, False) ;
//  Application.MessageBox(Testo, 'Tinker', 0);
End;

Function TeletrasportoCorrispondente;
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
    If (pElemento^.Tipo = Teletrasporto) And (pElemento <> pRiferimento) And (pElemento^.Colore = pRiferimento^.Colore) Then Begin
      ElementoTrovato := True;
      RicercaTerminata := True;
    End Else Begin
      If Indice = Elementi.Dimensione Then Begin
        ElementoTrovato := False;
        RicercaTerminata := True;
      End;
    End;
  Until RicercaTerminata;
  If Not ElementoTrovato Then MessaggioErrore('Non è stato trovato il teletrasporto corrispondente.');
  TeletrasportoCorrispondente := pElemento
End;



Procedure DisegnoMenu;
Var
  Titolo                   : String;
  Indice                   : Integer;
  X                        : Integer;
  Y                        : Integer;
  W                        : Integer;
//  H                        : Integer;
  VociVisualizzabili       : Integer;
  LarghezzaTestoContinua   : Integer;
  PosizioneIconaX          : Integer;
  PosizioneIconaY          : Integer;
  //UltimoElementoDaDisegnare : Integer;
Begin
  //Bitmap.Canvas.Draw(0,0,MenuDiGioco.Sfondo);
  W := 600;
//  H := Bitmap.Height - 200;
  X := (Bitmap.Width - 600) Div 2;
  Y := 100;//(Bitmap.Height - H) Div 2;

  VociVisualizzabili := (Bitmap.Height - Y) Div 30 - 3;

  If MenuDiGioco.ElementoSelezionato < MenuDiGioco.PrimoElementoDaDisegnare Then Begin
    MenuDiGioco.PrimoElementoDaDisegnare := MenuDiGioco.ElementoSelezionato;
  End;

  If MenuDiGioco.ElementoSelezionato > MenuDiGioco.PrimoElementoDaDisegnare + VociVisualizzabili Then Begin
    MenuDiGioco.PrimoElementoDaDisegnare := MenuDiGioco.ElementoSelezionato - VociVisualizzabili;
  End;

  MenuDiGioco.UltimoElementoDaDisegnare := MenuDiGioco.PrimoElementoDaDisegnare + VociVisualizzabili;
  MenuDiGioco.UltimoElementoDaDisegnare := Min(MenuDiGioco.UltimoElementoDaDisegnare, MenuDiGioco.Voci.Dimensione);

  //If H + 200 > Bitmap.Height Then MenuDiGioco.UltimoElementoDaDisegnare := MenuDiGioco.PrimoElementoDaDisegnare + 5;



  Bitmap.Canvas.Font.Style := [];
  Bitmap.Canvas.Brush.Color := $C8D0D4;

  Bitmap.Canvas.Brush.Style := bsClear;
  Bitmap.Canvas.Pen.Style := psClear;


 // Bitmap.Canvas.Rectangle(X, Y, W+X, H+Y);
  Bitmap.Canvas.Font.Name := 'Comics Sans MS';

  If MenuDiGioco.Menu = Caricamento Then Begin
    Bitmap.Canvas.Font.Size := 16;
    Bitmap.Canvas.Font.Color := clYellow;
    If MenuDiGioco.Cartella = ''
      Then Titolo := 'Cartella principale'
      Else Titolo := MenuDiGioco.Cartella;
    Bitmap.Canvas.TextOut(X + 10, 30, Titolo);
  End;


  Bitmap.Canvas.Font.Color := clBlue;
  Bitmap.Canvas.Font.Size := 16;
  LarghezzaTestoContinua := Bitmap.Canvas.TextExtent('(Continua)').cx; //HACK: testo duplicato
  If MenuDiGioco.PrimoElementoDaDisegnare <> 1
    Then Bitmap.Canvas.TextOut(X+(W-LarghezzaTestoContinua) Div 2, 60, '(Continua)');
  If MenuDiGioco.UltimoElementoDaDisegnare <> MenuDiGioco.Voci.Dimensione
    Then Bitmap.Canvas.TextOut(X+(W-LarghezzaTestoContinua) Div 2, Y+VociVisualizzabili*30+40, '(Continua)');



  Bitmap.Canvas.Font.Size := 18;

 // UltimoElementoDaDisegnare := ;
  For Indice := MenuDiGioco.PrimoElementoDaDisegnare To MenuDiGioco.UltimoElementoDaDisegnare Do Begin
    If (MenuDiGioco.Menu = Caricamento) Then Begin
      PosizioneIconaX := X + 1;
      PosizioneIconaY := Y +(Indice - MenuDiGioco.PrimoElementoDaDisegnare)*30 + 5;
      Case MenuDiGioco.Voci.Vettore[Indice].Tipo Of
        LivelloCompletato : Bitmap.Canvas.Draw(PosizioneIconaX, PosizioneIconaY, Immagini.IconaLivelloCompletato);
        LivelloSuperato : Bitmap.Canvas.Draw(PosizioneIconaX, PosizioneIconaY, Immagini.IconaLivelloSuperato);
        LivelloNonSuperato : Bitmap.Canvas.Draw(PosizioneIconaX, PosizioneIconaY, Immagini.IconaLivelloNonSuperato);
        Cartella : Bitmap.Canvas.Draw(PosizioneIconaX, PosizioneIconaY, Immagini.IconaCartella);
        Sistema : ;
      End;


    End;
    If Indice = MenuDiGioco.ElementoSelezionato
      Then Bitmap.Canvas.Font.Color := clYellow
      Else Bitmap.Canvas.Font.Color := clBlue;
    Bitmap.Canvas.TextOut(X + 20, Y+(Indice - MenuDiGioco.PrimoElementoDaDisegnare)*30, MenuDiGioco.Voci.Vettore[Indice].Testo);

  End;

End;


Procedure AperturaMenu;
Var
  Rec         : TSearchRec;
  //TipoLivello : TTipoLivello;
//  IdentificatoreLivello : String;
Begin
  //If (MenuDiGioco.Menu <> Caricamento) Then
  MenuDiGioco.ElementoSelezionato := 1;
  MenuDiGioco.Menu := Menu;
  MenuDiGioco.Voci.Dimensione := 0;

  MenuDiGioco.PrimoElementoDaDisegnare := 1;
  If Menu = Principale Then Begin     
    If Livello <> '' Then AggiuntaVoceMenu('Riavvia livello', 'RESTART', Sistema);
    AggiuntaVoceMenu('Carica partita', 'LOAD', Sistema);
    AggiuntaVoceMenu('Aiuto', 'HELP', Sistema);
    AggiuntaVoceMenu('Esci', 'EXIT', Sistema);
  End;
  If Menu = Caricamento Then Begin
    If MenuDiGioco.Cartella = ''
      Then AggiuntaVoceMenu('< Menu principale', 'BACK', Sistema)
      Else AggiuntaVoceMenu('< Livello superiore', 'BACK', Sistema);
    If FindFirst (CartellaLivelli + MenuDiGioco.Cartella + '\*', faAnyFile, Rec) = 0 Then Begin
      Repeat
        If (Rec.Name = '.') Or (Rec.Name = '..') Then Continue;
        If (Rec.Attr And faDirectory) <> 0 Then Begin
          AggiuntaVoceMenu(Rec.Name, MenuDiGioco.Cartella+'\'+Rec.Name, Cartella);
        End Else Begin
          If ExtractFileExt(Rec.Name) = '.tnk'
            Then Begin
              AggiuntaVoceMenu(NomeDescrittivoLivello(Rec.Name), MenuDiGioco.Cartella+'\'+Rec.Name, StatoLivello(Rec.Name));
              If IdentificatoreLivelloDaNomeFile(Rec.Name) = MenuDiGioco.UltimoLivelloCaricato Then MenuDiGioco.ElementoSelezionato := MenuDiGioco.Voci.Dimensione;
            End;
        End;
      Until FindNext(Rec) <> 0;
      FindClose(Rec) ;
    End;
  End;


End;

Procedure AzionaLevetta;
Var
  pLevetta : TpElemento;
Begin
  pLevetta := ElementoInPosizione(CoordinateElementoVicino(pRobot^.Posizione, pRobot^.Orientamento), False);
  If (pLevetta = Nil) Or (pLevetta^.Tipo <> InterruttoreLevetta) Then Exit;

  CambioStatoInterruttore(pLevetta, Not pLevetta^.Attivato);
  

End;

Procedure CaricamentoImmagine(Var BitmapOnOff : TBitmapOnOff; Const BaseNome : String); overload;
Begin
  CaricamentoImmagine(BitmapOnOff[0], BaseNome + '_Off');
  CaricamentoImmagine(BitmapOnOff[1], BaseNome + '_On');
End;

Procedure CaricamentoImmagine(Var BitmapColorizzateOnOff : TBitmapColorizzateOnOff; Const BaseNome : String); overload;
Begin
  CaricamentoImmagine(BitmapColorizzateOnOff[0], BaseNome + '_Off');
  CaricamentoImmagine(BitmapColorizzateOnOff[1], BaseNome + '_On');
End;

Procedure CaricamentoImmagine(Var QuattroBitmapColorizzateOnOff : TQuattroBitmapColorizzateOnOff; Const BaseNome : String); overload;
Begin
  CaricamentoImmagine(QuattroBitmapColorizzateOnOff[0], BaseNome + '_0');
  CaricamentoImmagine(QuattroBitmapColorizzateOnOff[1], BaseNome + '_1');
  CaricamentoImmagine(QuattroBitmapColorizzateOnOff[2], BaseNome + '_2');
  CaricamentoImmagine(QuattroBitmapColorizzateOnOff[3], BaseNome + '_3');
End;

Procedure CambioStatoInterruttore;
Var
  Indice : Integer;
Begin
  pInterruttore.Attivato := Attivato;
  For Indice := 1 To Elementi.Dimensione Do Begin
    If Elementi.Vettore[Indice] = Nil Then Continue;
    If pInterruttore.Colore = Elementi.Vettore[Indice]^.Colore Then Begin
      Case Elementi.Vettore[Indice]^.Tipo Of
        Nastro : Elementi.Vettore[Indice]^.Attivato := Attivato; //BUGBUG: porta via in una funzione separata e sposta oggetto sopra il teletrasporto se viene attivato
        Bomba : If Attivato Then EsplosioneBomba(Elementi.Vettore[Indice]);
        Porta : Elementi.Vettore[Indice]^.Attivato := Not Elementi.Vettore[Indice]^.Attivato;
       // Calamita : Elementi.Vettore[Indice]^.Attivato := Attivato;
       //TODO Specchio : si dovrebbe girare?
       // Pistola : Elementi.Vettore[Indice]^.Attivato := Attivato;
      End;
    End;


 //TODOTODO
  End;

End;




   {


// http://www.efg2.com/Lab/Graphics/Colors/HSV.htm


// RGB, each 0 to 255, to HSV.
// H = 0.0 to 360.0 (corresponding to 0..360.0 degrees around hexcone)
// S = 0.0 (shade of gray) to 1.0 (pure color)
// V = 0.0 (black) to 1.0 {white)

// Based on C Code in "Computer Graphics -- Principles and Practice,"
// Foley et al, 1996, p. 592. 

PROCEDURE RGBToHSV;
  VAR
    Delta: Real;
    Min : Real;
BEGIN
  Min := MinValue( [R, G, B] );    // USES Math
  V := MaxValue( [R, G, B] );

  Delta := V - Min;

  // Calculate saturation: saturation is 0 if r, g and b are all 0
  IF       V = 0.0
  THEN S := 0
  ELSE S := Delta / V;

  IF       S = 0.0
  THEN H := NaN    // Achromatic: When s = 0, h is undefined
  ELSE BEGIN       // Chromatic
    IF       R = V
    THEN // between yellow and magenta [degrees]
      H := 60.0 * (G - B) / Delta
    ELSE
      IF       G = V
      THEN // between cyan and yellow
        H := 120.0 + 60.0 * (B - R) / Delta
      ELSE
        IF       B = V
        THEN // between magenta and cyan
          H := 240.0 + 60.0 * (R - G) / Delta;

    IF H < 0.0
    THEN H := H + 360.0
  END
END;
 

 


// Based on C Code in "Computer Graphics -- Principles and Practice,"
// Foley et al, 1996, p. 593.
//
// H = 0.0 to 360.0 (corresponding to 0..360 degrees around hexcone)
// NaN (undefined) for S = 0
// S = 0.0 (shade of gray) to 1.0 (pure color)
// V = 0.0 (black) to 1.0 (white)

PROCEDURE HSVtoRGB;
  VAR
    f : Real;
    i : INTEGER;
    hTemp: Real; // since H is CONST parameter
    p,q,t: Real;
BEGIN
  IF       S = 0.0    // color is on black-and-white center line
  THEN BEGIN
    IF       IsNaN(H)
    THEN BEGIN
      R := V;           // achromatic: shades of gray
      G := V;
      B := V
    END
    //ELSE RAISE EColorError.Create('HSVtoRGB: S = 0 and H has a value');
  END

  ELSE BEGIN // chromatic color
    IF       H = 360.0         // 360 degrees same as 0 degrees
    THEN hTemp := 0.0
    ELSE hTemp := H;

    hTemp := hTemp / 60;     // h is now IN [0,6)
    i := TRUNC(hTemp);        // largest integer <= h
    f := hTemp - i;                  // fractional part of h

    p := V * (1.0 - S);
    q := V * (1.0 - (S * f));
    t := V * (1.0 - (S * (1.0 - f)));

    CASE i OF
      0: BEGIN R := V; G := t;  B := p  END;
      1: BEGIN R := q; G := V; B := p  END;
      2: BEGIN R := p; G := V; B := t   END;
      3: BEGIN R := p; G := q; B := V  END;
      4: BEGIN R := t;  G := p; B := V  END;
      5: BEGIN R := V; G := p; B := q  END
    END
  END
END;


Procedure InizializzazioneColorizzazioni;
Var
  IndiceColore    : Integer;
  IndiceVariante  : Integer;
  Base            : Array[1..4] Of
Begin

  For IndiceColore := 1 To 5 Do Begin      //HACK: vengono usati direttamente 5 e 4
    For IndiceVariante := 1 To 4 Do Begin
      Colorizzazioni[IndiceColore, IndiceVariante]
    End;
  End;


End;
      }


Procedure AggiuntaVoceMenu;
Var
  Posizione : Integer;
Begin
  MenuDiGioco.Voci.Dimensione := MenuDiGioco.Voci.Dimensione + 1;
  Posizione := MenuDiGioco.Voci.Dimensione;
  MenuDiGioco.Voci.Vettore[Posizione].Testo := Testo;
  MenuDiGioco.Voci.Vettore[Posizione].Percorso := Percorso;
  MenuDiGioco.Voci.Vettore[Posizione].Tipo := Tipo;
End;

Function PercorsoCartellaSuperiore;
Begin
  PercorsoCartellaSuperiore := Copy(Percorso, 1, UltimaPosizioneStringaInStringa('\', Percorso) - 1);
End;

Function UltimaPosizioneStringaInStringa;
Var
  Posizione : Integer;
Begin
   Posizione := Pos(ReverseString(SottoStringa), ReverseString(Stringa)) ;

   if (Posizione <> 0) then
     Posizione := ((Length(Stringa) - Length(SottoStringa)) + 1) - Posizione + 1;
   UltimaPosizioneStringaInStringa := Posizione;
end;



Procedure CaricamentoLivello;
var
  FileLivello         : TextFile;
  Riga                : String;
  Parametri           : TStringList;
  ParametriNumerici   : Array[0..9] Of Integer;
  Indice              : Integer;
Begin
  Livello := Percorso;
  Scacchiera.Orientamento := 1;
  CodaOperazioni.pInizio := Nil;
  CodaOperazioni.pFine := Nil;
  Elementi.Dimensione := 0;
  pRobot := Nil;
  IngranaggiTrovati := 0;
  IngranaggiTotali := 0;

  MenuDiGioco.UltimoLivelloCaricato := IdentificatoreLivelloDaNomeFile(Percorso);

  Parametri := TStringList.Create;
  Parametri.Delimiter := ' ';

  AssignFile(FileLivello, Percorso);
  Reset(FileLivello);
  While Not EOF(FileLivello) Do Begin
    ReadLn(FileLivello, Riga);
    If Riga = '' Then Continue;
    If Riga[1] = ';' Then Continue;
    Parametri.Clear;
    Parametri.DelimitedText := Riga;
    Try     //BUGBUG: questo try non sembra funzionare
     //Indice:=
      //HACK: riga lunghissima piena di strtoint
      If StrToInt(Parametri[0]) = 0
        Then Begin
          InizializzazioneScacchiera(StrToInt(Parametri[1]));
          if(parametri.Count>2)
            then Energia := StrToInt(Parametri[2])
            else Energia := -1;
        End Else AggiuntaElemento(IntToTipoElemento(StrToInt(Parametri[0])), StrToInt(Parametri[1]),StrToInt(Parametri[2]),StrToInt(Parametri[3]), StrToInt(Parametri[4]), Parametri[5]='1', StrToInt(Parametri[6]) );
        If(IntToTipoElemento(StrToInt(Parametri[0]))=Ingranaggio) Then IngranaggiTotali := IngranaggiTotali + 1;
    Except
     // On EConversionError Do
      MessaggioErrore('dgh');
    End;
  End;
  CloseFile(FileLivello);
  DimensionamentoScacchiera();
End;


Function IntToTipoElemento;
Var
  Tipo : TTipoElemento;
Begin
  // HACK: un ciclo semplicemente per convertire un intero nel corrispondente TTipoElemento
  For Tipo := Low(TTipoElemento) To High(TTipoElemento) Do
    If Ord(Tipo) = Numero Then IntToTipoElemento := Tipo;
  //IntToTipoElemento := TTipoElemento;
End;

Procedure DimensionamentoScacchiera;
Var
  AltezzaTotale2d : Real;
Begin
  Scacchiera.Bitmap.Width := PaintBox.Width;
  Scacchiera.Bitmap.Height := PaintBox.Height;

  //MenuDiGioco.Sfondo.Width := PaintBox.Width;
  //MenuDiGioco.Sfondo.Height := PaintBox.Height;

  AltezzaTotale2d := (AltezzaMassima) * Dimensioni2dCubo.c + (DimensioneScacchiera+1)*2*Dimensioni2dCubo.a;
  IncrementoCoordinataX := Bitmap.Width Div 2;
  IncrementoCoordinataY := (Bitmap.Height - AltezzaTotale2d) / 2 + (AltezzaMassima-1) * Dimensioni2dCubo.c;

End;





Function IdentificatoreLivelloDaNomeFile;
Var
  Stringhe : TStringList;
Begin
  Stringhe := TStringList.Create;
  Stringhe.Clear;
  Stringhe.Delimiter := '.';
  Stringhe.DelimitedText := NomeFile;
  If Stringhe.Count < 2 Then Begin //Errore, il nome del file deve contenere almeno 2 punti : nome.id.tnk
    IdentificatoreLivelloDaNomeFile := '';
    Exit;
  End;
  IdentificatoreLivelloDaNomeFile := Stringhe[Stringhe.Count-2];
End;

Function NomeDescrittivoLivello;
Begin
{Var
  Stringhe : TStringList;
Begin
  Stringhe := TStringList.Create;
  Stringhe.Clear;
  Stringhe.Delimiter := '.';
  Stringhe.DelimitedText := NomeFile;

  NomeDescrittivoLivello := Stringhe[0];
}

  //HACK: meno quarantuno
  NomeDescrittivoLivello := Copy(NomeFile, 1, Length(NomeFile) - 41);  //BUGBUG: se il nome non contiene il GUID non si vede il nome del livello, ma col metodo del TStringList suddivide anche dove ci sono gli spazi

End;


Function StatoLivello;
Var
  IdentificatoreLivello : String;
Begin
  IdentificatoreLivello := IdentificatoreLivelloDaNomeFile(NomeFile);
  If IdentificatoreLivello = '' Then Begin
    StatoLivello := LivelloNonSuperato;
  End;

  If LivelliSuperati.ValueExists(IdentificatoreLivello) Then Begin
    If LivelliSuperati.ReadInteger(IdentificatoreLivello) = 1
      Then StatoLivello := LivelloCompletato
      Else StatoLivello := LivelloSuperato
  End Else Begin
    StatoLivello := LivelloNonSuperato;
  End;
End;



Procedure DimensionamentoAree;
Begin
  PaintBox.Left := 0;
  PaintBox.Top := 0;
  PaintBox.Width := Larghezza;
  PaintBox.Height := Altezza;

  Bitmap.Width := PaintBox.Width;
  Bitmap.Height := PaintBox.Height;

  Scacchiera.CacheValida := False;

  DimensionamentoScacchiera();

End;


Procedure RaggiungimentoTraguardo;
Begin


  //HACK: due scritture sul registro con codice duplicato
  If( IngranaggiTrovati = IngranaggiTotali) And (IngranaggiTotali>0) {Hai preso tutte le ruote dentate} Then Begin
    LivelliSuperati.WriteInteger(IdentificatoreLivelloDaNomeFile(Livello), 1);
  End Else Begin
    If StatoLivello(Livello) = LivelloNonSuperato
      Then LivelliSuperati.WriteInteger(IdentificatoreLivelloDaNomeFile(Livello), 0);
  End;

  MostraEsitoPartita('Livello completato.', True);
End;

   {
Procedure AggiornamentoStatoInterruttore;
Var
  Indice : Integer;
Begin
  For Indice := 1 To Elementi.Vettore[Indice] Do Begin
    If Elementi.Vettore[Indice]
  End;

end;
  }


Function CambiaCaricaBatteria;
Begin
  If(Energia = -1) then begin
     CambiaCaricaBatteria := True;
     Exit;
  end;

  Energia := Energia + Incremento;
  If(Energia = 0)
    then CambiaCaricaBatteria := False
    else CambiaCaricaBatteria := True;

  if (Energia = 0) Then MostraEsitoPartita('Batteria esaurita!', False);
End;



Procedure EsplosioneBomba;
Var
  pElementoVicino                      : TpElemento;
  Direzione : Integer;
  DestinazioneBomba : TPosizione3d;
Begin
  pBomba.Attivato := True;
  DestinazioneBomba.X := 1;
  DestinazioneBomba.Y := 1;
  DestinazioneBomba.Z := 100;
  AccodamentoGenerico(pBomba, -3, DestinazioneBomba);
  For Direzione := 0 To 3 Do Begin
    pElementoVicino := ElementoInPosizione(CoordinateElementoVicino(pBomba.Posizione, Direzione), False);
    If(pElementoVicino <> Nil) Then Begin
      If(pElementoVicino.Tipo = BloccoGhiaccio) Then Begin
        EliminazioneElemento(pElementoVicino);
        //AccodamentoGenerico(pElementoVicino, -3, DestinazioneBomba);
      End Else Begin
        If(Spostabile(pElementoVicino, Esplosione,   Direzione)) Then Begin
          Accodamento(pElementoVicino, Direzione);
        End;
      End;
    End;
  End;


  //If pCarico = Nil Then MessaggioErrore('Il teletrasporto è stato azionato senza che sia presente un carico');






  //SpostamentoGenerico(pCaricoTeletrasportoGemello, -3, pCarico^.Posizione);

End;


Procedure EliminazioneElemento;
Begin
  pElemento.Posizione.Z := 100;
  pElemento.PosizioneFisica.Z := 100;
End;


end.
