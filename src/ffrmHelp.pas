unit ffrmHelp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw;

type
  TfrmAiuto = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAiuto: TfrmAiuto;

implementation

{$R *.dfm}


procedure TfrmAiuto.FormShow(Sender: TObject);
begin
          frmAiuto.WebBrowser1.Width := frmAiuto.ClientWidth;
          frmAiuto.WebBrowser1.Height := frmAiuto.ClientHeight;
          frmAiuto.WebBrowser1.SetFocus;  //BUGBUG niente fuoco
          frmAiuto.WebBrowser1.Show;
          
end;



//BUGBUG non funzionano
procedure TfrmAiuto.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if(key=VK_ESCAPE) then frmAiuto.Close;
end;

procedure TfrmAiuto.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if(key=Char(27)) then frmAiuto.Close;
end;

end.
