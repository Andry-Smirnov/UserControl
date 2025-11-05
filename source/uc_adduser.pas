unit uc_adduser;

{$MODE Delphi}

interface

{$I 'UserControl.inc'}

uses
{$IFDEF WINDOWS}
  LCLIntf,
  LCLType,
  LMessages,
{$ELSE}
  LCLType,
{$ENDIF}
{$IFDEF DELPHI5_UP}
  Variants,
{$ENDIF}
  Buttons,
  Classes,
  Controls,
  DB,
  DBCtrls,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Messages,
  Spin,
  StdCtrls,
  SysUtils,
  //
  uc_base
  ;

type
  TAddUserForm = class(TForm)
    Panel1: TPanel;
    LbDescricao: TLabel;
    Image1: TImage;
    Panel3: TPanel;
    btGravar: TBitBtn;
    btCancela: TBitBtn;
    Panel2: TPanel;
    lbNome: TLabel;
    EditNome: TEdit;
    lbLogin: TLabel;
    EditLogin: TEdit;
    lbEmail: TLabel;
    EditEmail: TEdit;
    ckPrivilegiado: TCheckBox;
    lbPerfil: TLabel;
    ComboPerfil: TDBLookupComboBox;
    btlimpa: TSpeedButton;
    ckUserExpired: TCheckBox;
    LabelExpira: TLabel;
    SpinExpira: TSpinEdit;
    LabelDias: TLabel;
    ComboStatus: TComboBox;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btCancelaClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    function GetNewIdUser: Integer;
    procedure btlimpaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ckUserExpiredClick(Sender: TObject);
  private
    FormSenha: TCustomForm;
    { Private declarations }
  public
    { Public declarations }
    FAltera: Boolean;
    FUserControl: TUserControl;
    FUsersListDataSet: TDataSet;
    vNovoIDUsuario: Integer;
  end;

implementation

uses
  uc_password;

{$R *.lfm}

procedure TAddUserForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TAddUserForm.FormCreate(Sender: TObject);
begin
  Self.BorderIcons := [];
  Self.BorderStyle := bsDialog;
end;

procedure TAddUserForm.btCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TAddUserForm.btGravarClick(Sender: TObject);
var
  vNovaSenha: String;
  vNome: String;
  vLogin: String;
  vEmail: String;
  vUserExpired: Integer;
  vPerfil: Integer;
  vPrivilegiado: Boolean;
begin
  btGravar.Enabled := False;

  with FUserControl do
    if not FAltera then
    begin // inclui user
      if Self.FUserControl.ExisteUsuario(EditLogin.Text) then
      begin
        MessageDlg
          (Format(FUserControl.UserSettings.CommonMessages.UsuarioExiste,
          [EditLogin.Text]), mtWarning, [mbOK], 0);
        Exit;
      end;

      FormSenha := TPasswordForm.Create(Self);
      TPasswordForm(FormSenha).Position := UserSettings.WindowsPosition;
      TPasswordForm(FormSenha).FUserControl := FUserControl;
      TPasswordForm(FormSenha).Caption :=
        Format(FUserControl.UserSettings.ResetPassword.WindowCaption,
        [EditLogin.Text]);
      if TPasswordForm(FormSenha).ShowModal <> mrOk then
      begin
        btGravar.Enabled := True;
        Exit;
      end;
      vNovaSenha := TPasswordForm(FormSenha).edtSenha.Text;
      vNovoIDUsuario := GetNewIdUser;
      vNome := EditNome.Text;
      vLogin := EditLogin.Text;
      vEmail := EditEmail.Text;
      FreeAndNil(FormSenha);

      if ComboPerfil.KeyValue = null then
        vPerfil := 0
      else
        vPerfil := ComboPerfil.KeyValue;

      vPrivilegiado := ckPrivilegiado.Checked;
      vUserExpired := StrToInt(BoolToStr(ckUserExpired.Checked));

      AddUser(vLogin, vNovaSenha, vNome, vEmail, vPerfil, vUserExpired,
        SpinExpira.Value, vPrivilegiado);

      {$IFNDEF FPC}
      if (Assigned(FUserControl.MailUserControl)) and
        (FUserControl.MailUserControl.AdicionaUsuario.Ativo) then
        try
          FUserControl.MailUserControl.EnviaEmailAdicionaUsuario(vNome, vLogin,
            Encrypt(vNovaSenha, EncryptKey), vEmail, IntToStr(vPerfil),
            EncryptKey);
        except
          on E: Exception do
            Log(E.Message, 0);
        end;
      {$ENDIF}
    end
    else
    begin // alterar user
      // vNovoIDUsuario := TfrmCadastrarUsuario(Self.Owner).FDataSetCadastroUsuario.FieldByName('IdUser').AsInteger;
      vNome := EditNome.Text;
      vLogin := EditLogin.Text;
      vEmail := EditEmail.Text;
      if ComboPerfil.KeyValue = null then
        vPerfil := 0
      else
        vPerfil := ComboPerfil.KeyValue;

      vUserExpired := StrToInt(BoolToStr(ckUserExpired.Checked));
      // Added by Petrus van Breda 28/04/2007
      vPrivilegiado := ckPrivilegiado.Checked;
      ChangeUser(vNovoIDUsuario, vLogin, vNome, vEmail, vPerfil, vUserExpired,
        SpinExpira.Value, ComboStatus.ItemIndex, vPrivilegiado);

      {$IFNDEF FPC}
      if (Assigned(FUserControl.MailUserControl)) and
        (FUserControl.MailUserControl.AlteraUsuario.Ativo) then
        try
          FUserControl.MailUserControl.EnviaEmailAlteraUsuario(vNome, vLogin,
            'Nгo Alterada', vEmail, IntToStr(vPerfil), EncryptKey);
        except
          on E: Exception do
            Log(E.Message, 2);
        end;
      {$ENDIF}

    end;

  { With TfrmCadastrarUsuario(Owner) do
    Begin }
  FUsersListDataSet.Close;
  FUsersListDataSet.Open;
  FUsersListDataSet.Locate('idUser', vNovoIDUsuario, []);
  // End;
  Close;
end;

function TAddUserForm.GetNewIdUser: Integer;
var
  DataSet: TDataSet;
  SQLStmt: String;
begin
  with FUserControl do
  begin
    SQLStmt := Format('SELECT %s.%s FROM %s ORDER BY %s DESC',
      [TableUsers.TableName, TableUsers.FieldUserID, TableUsers.TableName,
      TableUsers.FieldUserID]);
    try
      DataSet := DataConnector.UCGetSQLDataSet(SQLStmt);
      Result := DataSet.Fields[0].AsInteger + 1;
      DataSet.Close;
    finally
      SysUtils.FreeAndNil(DataSet);
    end;
  end;
end;

procedure TAddUserForm.btlimpaClick(Sender: TObject);
begin
  ComboPerfil.KeyValue := null;
end;

procedure TAddUserForm.FormShow(Sender: TObject);
begin
  if not FUserControl.UserProfile.Active then
  begin
    lbPerfil.Visible := False;
    ComboPerfil.Visible := False;
    btlimpa.Visible := False;
  end
  else
  begin
    ComboPerfil.ListSource.DataSet.Close;
    ComboPerfil.ListSource.DataSet.Open;
  end;

  // Opзгo de senha so deve aparecer qdo setada como true no componente By Vicente Barros Leonel
  ckUserExpired.Visible := FUserControl.Login.ActiveDateExpired;

  ckPrivilegiado.Visible := FUserControl.User.UsePrivilegedField;
  EditLogin.CharCase := Self.FUserControl.Login.CharCaseUser;

  SpinExpira.Visible := ckUserExpired.Visible;
  LabelExpira.Visible := ckUserExpired.Visible;
  LabelDias.Visible := ckUserExpired.Visible;

  if (FUserControl.User.ProtectAdministrator) and
    (EditLogin.Text = FUserControl.Login.InitialLogin.User) then
    EditLogin.Enabled := False;
end;

procedure TAddUserForm.ckUserExpiredClick(Sender: TObject);
begin
  SpinExpira.Enabled := not ckUserExpired.Checked;
end;

end.
