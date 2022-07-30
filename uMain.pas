unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Vcl.StdCtrls;

type
  TGameStatus = (gsUnknown, gsWon, gsLose, gsDraw);
  TfrmMain = class(TForm)
    pnlMain: TPanel;
    pnlTitle: TPanel;
    imgLogo: TImage;
    pnlChoose: TPanel;
    imgSelect: TImage;
    pnlSelect: TPanel;
    imgRock: TImage;
    imgPaper: TImage;
    imgScissor: TImage;
    pnlGame: TPanel;
    imgUser: TImage;
    imgStatus: TImage;
    imgAI: TImage;
    pnlScores: TPanel;
    lblStatus: TLabel;
    lblSelect: TLabel;
    lblWon: TLabel;
    lblLose: TLabel;
    lblDraw: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure imgRockClick(Sender: TObject);
    procedure imgPaperClick(Sender: TObject);
    procedure imgScissorClick(Sender: TObject);
  private
    FAI: Integer;
    FGameStatus: TGameStatus;
    FWon, FLose, FDraw: Integer;
    procedure AssignJpgFromResource(var AImage: TImage; const AIdentifier: string);
    procedure StartGame(const AUser: Integer);
    function ComputeGame(const AUser, AAI: Integer): TGameStatus;
    procedure ShowScores;
    procedure SetImages(const AUser, AAI, AStatus: Integer);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

const
  CNames: array[1..3] of string = ('ROCK', 'PAPER', 'SCISSOR');
  CStatus: array[0..3] of string = ('NEWGAME', 'WON', 'LOSE', 'DRAW');

procedure TfrmMain.AssignJpgFromResource(var AImage: TImage; const AIdentifier: string);
var
  RS: TResourceStream;
  JPGImage: TJPEGImage;
begin
  JPGImage := TJPEGImage.Create;
  try
    RS := TResourceStream.Create(hInstance, AIdentifier, RT_RCDATA);
    try
      JPGImage.LoadFromStream(RS);
      AImage.Picture.Graphic := JPGImage;
    finally
      RS.Free;
    end;
  finally
    JPGImage.Free;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Randomize;
  AssignJpgFromResource(imgRock, CNames[1]);
  AssignJpgFromResource(imgPaper, CNames[2]);
  AssignJpgFromResource(imgScissor, CNames[3]);
  SetImages(-1, -1, -1);
  FWon := 0;
  FLose := 0;
  FDraw := 0;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  imgRock.Width := Round((pnlSelect.Width / 3) - (imgRock.Margins.Left + imgRock.Margins.Right));
  imgPaper.Width := Round((pnlSelect.Width / 3) - (imgPaper.Margins.Left + imgPaper.Margins.Right));
  imgScissor.Width := Round((pnlSelect.Width / 3) - (imgScissor.Margins.Left + imgScissor.Margins.Right));
  imgUser.Width := Round((pnlGame.Width / 3) - (imgUser.Margins.Left + imgUser.Margins.Right));
  imgStatus.Width := Round((pnlGame.Width / 3) - (imgStatus.Margins.Left + imgStatus.Margins.Right));
  imgAI.Width := Round((pnlGame.Width / 3) - (imgAI.Margins.Left + imgAI.Margins.Right));
  Self.Height := pnlTitle.Height + pnlTitle.Margins.Top + pnlTitle.Margins.Bottom +
                 pnlChoose.Height + pnlChoose.Margins.Top + pnlChoose.Margins.Bottom +
                 pnlSelect.Height + pnlSelect.Margins.Top + pnlSelect.Margins.Bottom +
                 pnlGame.Height + pnlGame.Margins.Top + pnlGame.Margins.Bottom +
                 pnlScores.Height + pnlScores.Margins.Top + pnlScores.Margins.Bottom +
                 GetSystemMetrics(SM_CYCAPTION);
end;

procedure TfrmMain.SetImages(const AUser, AAI, AStatus: Integer);
begin
  if ((AUser >= Low(CNames)) and (AUser <= High(CNames))) then
    AssignJpgFromResource(imgUser, CNames[AUser])
    else
    AssignJpgFromResource(imgUser, CStatus[0]);
  if ((AAI >= Low(CNames)) and (AAI <= High(CNames))) then
    AssignJpgFromResource(imgAI, CNames[AAI])
    else
    AssignJpgFromResource(imgAI, CStatus[0]);
  if ((AStatus >= Low(CStatus)) and (AStatus <= High(CStatus))) then
    AssignJpgFromResource(imgStatus, CStatus[AStatus])
    else
    AssignJpgFromResource(imgStatus, CStatus[0]);
end;

function TfrmMain.ComputeGame(const AUser, AAI: Integer): TGameStatus;
begin
  case AUser of
    1: case AAI of
         1: Result := gsDraw; // rock vs rock
         2: Result := gsLose; // rock vs paper
         3: Result := gsWon;  // rock vs scissor
         else
           Result := gsUnknown;
       end;
    2: case AAI of
         1: Result := gsWon;  // paper vs rock
         2: Result := gsDraw; // paper vs paper
         3: Result := gsLose; // paper vs scissor
         else
           Result := gsUnknown;
       end;
    3: case AAI of
         1: Result := gsLose; // scissor vs rock
         2: Result := gsWon;  // scissor vs paper
         3: Result := gsDraw; // scissor vs scissor
         else
           Result := gsUnknown;
       end;
    else
      Result := gsUnknown;
  end;
end;

procedure TfrmMain.ShowScores;
begin
  lblWon.Caption  := Format('You won %d times!', [FWon]);
  lblLose.Caption := Format('You lost %d times!', [FLose]);
  lblDraw.Caption := Format('%d times a draw!', [FDraw]);
end;

procedure TfrmMain.StartGame(const AUser: Integer);
begin
  FAI := Random(3) + 1;
  FGameStatus := ComputeGame(AUser, FAI);
  SetImages(AUser, FAI, Ord(FGameStatus));
  case FGameStatus of
    gsWon:  Inc(FWon);
    gsLose: Inc(FLose);
    gsDraw: Inc(FDraw);
    else
      ShowMessage('Unknown error signaled!' + #13#10 +
                  'User: ' + IntToStr(AUser) + #13#10 +
                  'AI: ' + IntToStr(FAI) + #13#10 +
                  'GameStatus: ' + IntToStr(Ord(FGameStatus)));
  end;
  ShowScores;
end;

procedure TfrmMain.imgRockClick(Sender: TObject);
begin
  StartGame(1);
end;

procedure TfrmMain.imgPaperClick(Sender: TObject);
begin
  StartGame(2);
end;

procedure TfrmMain.imgScissorClick(Sender: TObject);
begin
  StartGame(3);
end;

end.
