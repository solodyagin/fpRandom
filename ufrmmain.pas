unit ufrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    BtnGenNick: TButton;
    BtnGenPassword: TButton;
    ChkAlphCapital: TCheckBox;
    ChkAlphLowercase: TCheckBox;
    ChkAlphDigits: TCheckBox;
    ChkAlphSymbols: TCheckBox;
    ChkCustom: TCheckBox;
    EdtCustom: TEdit;
    EdtNumChars: TLabeledEdit;
    GroupBox1: TGroupBox;
    GrdResults: TStringGrid;
    StatusBar1: TStatusBar;
    UdNumChars: TUpDown;
    procedure BtnGenNickClick(Sender: TObject);
    procedure BtnGenPasswordClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrdResultsResize(Sender: TObject);
    procedure GrdResultsSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
    procedure UdNumCharsChanging(Sender: TObject; var AllowChange: Boolean);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.lfm}

uses
  Math, Clipbrd;

{ TFrmMain }

const
  ALPH_CAPITAL = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  ALPH_LOWERCASE = 'abcdefghijklmnopqrstuvwxyz';
  ALPH_DIGITS = '0123456789';
  ALPH_SYMBOLS = '~!@#$%^&*-_+=?';

const
  Weights: array[0..25, 0..25] of Integer = (
    (15, 97, 104, 184, 65, 28, 59, 142, 211, 15, 68, 504, 228, 1029, 19, 27, 12, 691, 198, 184, 88, 130, 30, 24, 133, 45),
    (114, 13, 0, 4, 155, 0, 0, 3, 72, 1, 0, 26, 0, 1, 37, 0, 0, 135, 4, 1, 21, 0, 0, 0, 28, 0),
    (201, 0, 6, 0, 148, 0, 0, 222, 97, 0, 62, 53, 0, 0, 116, 0, 3, 18, 1, 12, 14, 0, 1, 0, 30, 0),
    (297, 0, 0, 23, 275, 3, 4, 4, 162, 0, 0, 14, 6, 9, 132, 0, 0, 79, 8, 0, 38, 1, 11, 0, 61, 1),
    (150, 33, 32, 110, 103, 25, 36, 16, 79, 5, 30, 562, 114, 504, 57, 20, 4, 536, 180, 175, 27, 96, 27, 19, 132, 13),
    (68, 0, 0, 0, 48, 23, 1, 0, 53, 1, 0, 21, 0, 1, 24, 0, 0, 48, 0, 3, 5, 0, 1, 0, 5, 0),
    (150, 0, 0, 5, 98, 0, 12, 37, 81, 0, 0, 20, 1, 10, 35, 0, 0, 35, 3, 4, 42, 0, 9, 0, 8, 1),
    (422, 3, 0, 3, 209, 0, 1, 0, 149, 0, 1, 15, 6, 16, 91, 0, 0, 24, 2, 9, 45, 0, 2, 0, 24, 1),
    (430, 24, 166, 105, 281, 27, 56, 8, 2, 9, 77, 303, 92, 561, 99, 24, 10, 158, 309, 175, 26, 54, 2, 12, 22, 29),
    (130, 0, 0, 0, 82, 0, 0, 0, 20, 0, 1, 0, 0, 0, 74, 0, 0, 0, 0, 0, 44, 0, 1, 0, 2, 0),
    (266, 0, 0, 0, 157, 0, 0, 8, 122, 0, 7, 7, 0, 3, 72, 0, 0, 18, 7, 3, 17, 0, 2, 0, 38, 0),
    (540, 22, 9, 70, 439, 11, 6, 5, 496, 1, 11, 309, 26, 1, 199, 10, 0, 3, 23, 35, 63, 32, 5, 0, 137, 0),
    (511, 29, 4, 2, 167, 1, 0, 2, 217, 0, 1, 6, 22, 4, 123, 11, 0, 6, 3, 0, 28, 0, 0, 0, 25, 0),
    (625, 1, 71, 227, 392, 5, 95, 13, 295, 13, 14, 14, 0, 243, 129, 0, 1, 10, 33, 130, 29, 2, 4, 1, 74, 12),
    (27, 27, 35, 61, 23, 7, 10, 28, 18, 3, 38, 173, 62, 500, 23, 28, 0, 338, 104, 43, 37, 35, 33, 7, 27, 10),
    (93, 0, 0, 0, 75, 0, 0, 72, 33, 0, 0, 7, 0, 1, 21, 13, 0, 31, 3, 3, 5, 0, 0, 0, 4, 0),
    (4, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 51, 0, 2, 0, 0, 0),
    (491, 22, 37, 84, 333, 3, 37, 13, 561, 5, 20, 91, 47, 71, 223, 5, 0, 110, 44, 81, 61, 29, 14, 1, 114, 3),
    (233, 5, 24, 4, 151, 0, 1, 227, 123, 0, 14, 28, 23, 6, 89, 21, 0, 3, 90, 186, 43, 5, 5, 0, 27, 1),
    (366, 2, 10, 0, 214, 1, 1, 183, 155, 2, 2, 11, 1, 6, 174, 0, 0, 88, 9, 103, 38, 0, 4, 0, 59, 5),
    (38, 17, 32, 39, 52, 5, 19, 3, 37, 4, 15, 82, 39, 75, 11, 11, 0, 103, 120, 21, 0, 8, 2, 2, 17, 10),
    (163, 0, 0, 0, 141, 0, 0, 0, 169, 0, 1, 5, 0, 0, 27, 0, 0, 7, 0, 0, 2, 1, 0, 0, 9, 0),
    (73, 0, 0, 2, 57, 0, 0, 10, 57, 0, 1, 2, 1, 11, 11, 0, 0, 6, 4, 1, 0, 0, 0, 0, 23, 2),
    (22, 0, 0, 0, 11, 0, 0, 1, 24, 0, 0, 1, 1, 0, 6, 0, 0, 0, 0, 7, 4, 0, 1, 0, 3, 0),
    (151, 6, 10, 23, 45, 0, 2, 0, 10, 0, 3, 82, 13, 130, 42, 4, 0, 35, 35, 17, 12, 4, 1, 1, 1, 0),
    (89, 2, 0, 0, 46, 0, 0, 5, 52, 1, 0, 4, 0, 0, 23, 0, 0, 3, 2, 0, 22, 0, 2, 0, 7, 7)
    );

var
  Letters: array[0..25, 0..25] of Integer;

function GenerateNick(NumChars: Integer = 8): String;
var
  nameLen: Integer;
  curChar, firstChar, nextChar: Integer;
  res: String;
  i, j: Integer;
  rand: Integer;
begin
  // nameLen := 3 + Random(7);
  nameLen := Max(NumChars, 3);
  curChar := Random(26);
  res := ALPH_CAPITAL[1 + curChar];
  firstChar := curChar;
  for i := 2 to nameLen do
  begin
    rand := Random(1000);
    nextChar := 0;
    for j := 0 to 25 do
      if (rand >= Letters[firstChar][j]) then
        nextChar := nextChar + 1;
    firstChar := nextChar;
    res += ALPH_LOWERCASE[1 + nextChar];
  end;
  Result := res;
end;

function GeneratePassword(Alphabet: String; NumChars: Integer = 8): String;
var
  res: String;
  i: Integer;
begin
  res := '';
  for i := 0 to NumChars - 1 do
    res += Alphabet[1 + Random(Length(Alphabet))];
  Result := res;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  c, t: Integer;
  i, j: Integer;
begin
  ChkAlphCapital.Caption := ALPH_CAPITAL;
  ChkAlphCapital.Checked := True;
  ChkAlphLowercase.Caption := ALPH_LOWERCASE;
  ChkAlphLowercase.Checked := True;
  ChkAlphDigits.Caption := ALPH_DIGITS;
  ChkAlphDigits.Checked := True;
  ChkAlphSymbols.Caption := ALPH_SYMBOLS;
  EdtCustom.Text := ALPH_LOWERCASE;
  for i := 0 to 25 do
  begin
    c := 0;
    t := 0;
    for j := 0 to 25 do
      c += Weights[i][j];
    for j := 0 to 25 do
    begin
      t += Weights[i][j];
      Letters[i][j] := Round(t / c * 1000);
    end;
  end;
end;

procedure TFrmMain.GrdResultsResize(Sender: TObject);
begin
  GrdResults.ColCount := Round(GrdResults.ClientWidth / GrdResults.DefaultColWidth);
  GrdResults.RowCount := GrdResults.ClientHeight div GrdResults.DefaultRowHeight;
end;

procedure TFrmMain.GrdResultsSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
var
  s: String;
begin
  s := GrdResults.Cells[ACol, ARow];
  if s.IsEmpty then Exit;
  Clipboard.AsText := s;
  StatusBar1.SimpleText := Format('Text "%s" copied to clipboard', [s]);
end;

procedure TFrmMain.UdNumCharsChanging(Sender: TObject; var AllowChange: Boolean);
begin
  if GrdResults.Tag = 0 then
    BtnGenPassword.Click
  else
    BtnGenNick.Click;
end;

procedure TFrmMain.BtnGenNickClick(Sender: TObject);
var
  numChars: Integer;
  col, row: Integer;
begin
  GrdResults.Tag := 1;
  numChars := StrToIntDef(EdtNumChars.Text, 8);
  for col := 0 to GrdResults.ColCount - 1 do
    for row := 0 to GrdResults.RowCount - 1 do
      GrdResults.Cells[col, row] := GenerateNick(numChars);
  GrdResults.SetFocus;
end;

procedure TFrmMain.BtnGenPasswordClick(Sender: TObject);
var
  alphabet: String;
  numChars: Integer;
  col, row: Integer;
begin
  GrdResults.Tag := 0;
  alphabet := '';
  if ChkAlphCapital.Checked then
    alphabet += ALPH_CAPITAL;
  if ChkAlphLowercase.Checked then
    alphabet += ALPH_LOWERCASE;
  if ChkAlphDigits.Checked then
    alphabet += ALPH_DIGITS;
  if ChkAlphSymbols.Checked then
    alphabet += ALPH_SYMBOLS;
  if ChkCustom.Checked and (EdtCustom.Text <> '') then
    alphabet += EdtCustom.Text;
  if Length(alphabet) = 0 then
    Exit;
  numChars := StrToIntDef(EdtNumChars.Text, 8);
  for col := 0 to GrdResults.ColCount - 1 do
    for row := 0 to GrdResults.RowCount - 1 do
      GrdResults.Cells[col, row] := GeneratePassword(alphabet, numChars);
  GrdResults.SetFocus;
end;

initialization

  Randomize;

end.
