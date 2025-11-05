unit uc_password;

{$MODE Delphi}

interface

{$I 'usercontrol.inc'}

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Buttons,
  Classes,
  Controls,
  Dialogs,
  Forms,
  Graphics,
  Messages,
  StdCtrls,
  SysUtils,
  Variants,
  uc_base;

type
  TPasswordForm = class(TForm)
    edtSenha: TEdit;
    edtConfirmaSenha: TEdit;
    btnOK: TBitBtn;
    BtCancel: TBitBtn;
    LabelSenha: TLabel;
    LabelConfirma: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function CompararSenhas(Senha, ConfirmaSenha: string): boolean;
  public
    fUserControl: TUserControl;
  end;

implementation

{$R *.lfm}

{ TForm1 }

function TPasswordForm.CompararSenhas(Senha, ConfirmaSenha: string): boolean;
begin
  Result := False;
  with fUserControl do
    begin
      if (UserPasswordChange.ForcePassword) and (Senha = '') then
        MessageDlg(UserSettings.CommonMessages.ChangePasswordError.
          PasswordRequired,
          mtWarning, [mbOK], 0)
      else if Length(Senha) < UserPasswordChange.MinPasswordLength then
        MessageDlg(Format(UserSettings.CommonMessages.ChangePasswordError.
          MinPasswordLength, [UserPasswordChange.MinPasswordLength]), mtWarning,
          [mbOK], 0)
      else if Pos(LowerCase(Senha), 'abcdeasdfqwerzxcv1234567890321654987teste' +
        LowerCase(CurrentUser.UserName) + LowerCase(CurrentUser.UserLogin)) > 0 then
        MessageDlg(UserSettings.CommonMessages.ChangePasswordError.
          InvalidNewPassword, mtWarning, [mbOK], 0)
      else if (Senha <> ConfirmaSenha) then
        MessageDlg(UserSettings.CommonMessages.ChangePasswordError.
          NewPasswordError,
          mtWarning, [mbOK], 0)
      else
        Result := True;
    end;
end;

procedure TPasswordForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPasswordForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if not (ModalResult = mrCancel) then
  begin
    CanClose := CompararSenhas(edtSenha.Text, edtConfirmaSenha.Text);
    if not CanClose then
      edtSenha.SetFocus;
  end;
end;

procedure TPasswordForm.FormCreate(Sender: TObject);
begin
  edtSenha.Clear;
  edtConfirmaSenha.Clear;
end;

procedure TPasswordForm.FormShow(Sender: TObject);
begin
  edtSenha.CharCase := fUserControl.Login.CharCasePass;
  edtConfirmaSenha.CharCase := fUserControl.Login.CharCasePass;
  LabelSenha.Caption := fUserControl.UserSettings.Login.LabelPassword;
  LabelConfirma.Caption := fUserControl.UserSettings.ChangePassword.LabelConfirm;
  btnOK.Caption := fUserControl.UserSettings.Login.BtOk;
  BtCancel.Caption := fUserControl.UserSettings.Login.BtCancel;
end;

end.
