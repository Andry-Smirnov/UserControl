unit uc_loginwindow;

interface

{$I 'usercontrol.inc'}

uses
  {$IFDEF DELPHI5_UP}
  Variants,
  {$ENDIF}
  Buttons,
  Classes,
  Controls,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Math,
  Messages,
  StdCtrls,
  SysUtils,
  uc_base,
  {$IFDEF WINDOWS}Windows,{$ELSE}LCLType,{$ENDIF}
  ComCtrls;

type
  TLoginForm = class(TForm)
    PTop: TPanel;
    ImgTop: TImage;
    PLeft: TPanel;
    imgLeft: TImage;
    PBottom: TPanel;
    ImgBottom: TImage;
    Panel1: TPanel;
    StatusBar: TStatusBar;
    PLogin: TPanel;
    LbUsuario: TLabel;
    LbSenha: TLabel;
    lbEsqueci: TLabel;
    EditUsuario: TEdit;
    EditSenha: TEdit;
    btOK: TBitBtn;
    BtCancela: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtCancelaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditUsuarioChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure BotoesClickVisualizacao(Sender: TObject);
  public
    FUserControl: TUserControl;
  end;

implementation

{$R *.lfm}

procedure TLoginForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TLoginForm.BotoesClickVisualizacao(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

procedure TLoginForm.BtCancelaClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TLoginForm.FormShow(Sender: TObject);
var
  w, h: integer;
begin
  w := Max(ImgTop.Width, imgLeft.Width + PLogin.Width);
  w := Max(w, ImgBottom.Width);
  h := Max(imgLeft.Height + ImgTop.Height + ImgBottom.Height,
    ImgTop.Height + PLogin.Height + ImgBottom.Height);

  Width := w;
  Height := h + 28;
  if FUserControl.Login.MaxLoginAttempts > 0 then
    begin
      Height := Height + 19;
      StatusBar.Panels[0].Text := FUserControl.UserSettings.Login.LabelTentativa;
      StatusBar.Panels[2].Text := FUserControl.UserSettings.Login.LabelTentativas;
    end;

  // Topo
  PTop.Height := ImgTop.Height;
  ImgTop.AutoSize := False;
  ImgTop.Align := alClient;
  ImgTop.Center := True;

  // Centro
  PLeft.Width := imgLeft.Width;
  imgLeft.AutoSize := False;
  imgLeft.Align := alClient;
  imgLeft.Center := True;

  // Bottom
  PBottom.Height := ImgBottom.Height;
  ImgBottom.AutoSize := False;
  ImgBottom.Align := alClient;
  ImgBottom.Center := True;

  PTop.Visible := ImgTop.Picture <> nil;
  PLeft.Visible := imgLeft.Picture <> nil;
  PBottom.Visible := ImgBottom.Picture <> nil;

  if FUserControl.Login.GetLoginName = lnUserName then
    EditUsuario.Text := FUserControl.GetLocalUserName;
  if FUserControl.Login.GetLoginName = lnMachineName then
    EditUsuario.Text := FUserControl.GetLocalComputerName;

  Position := Self.FUserControl.UserSettings.WindowsPosition;
  EditUsuario.CharCase := Self.FUserControl.Login.CharCaseUser;
  EditSenha.CharCase := Self.FUserControl.Login.CharCasePass;
  EditUsuario.SetFocus;
end;

procedure TLoginForm.EditUsuarioChange(Sender: TObject);
begin
  lbEsqueci.Enabled := Length(EditUsuario.Text) > 0;
end;

procedure TLoginForm.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    begin
      Key := #0;
{$IFDEF WINDOWS}
      Perform(WM_NEXTDLGCTL, 0, 0);
{$ENDIF}
    end;
end;

end.
