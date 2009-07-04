object frmTinker: TfrmTinker
  Left = 701
  Top = 619
  Width = 516
  Height = 331
  Caption = 'Tinker'
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 184
    Top = 96
    Width = 105
    Height = 105
  end
  object Timer1: TTimer
    Interval = 15
    OnTimer = Timer1Timer
    Left = 80
    Top = 64
  end
end
