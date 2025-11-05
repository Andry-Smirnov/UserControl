unit uc_userframe;

interface

{$I 'usercontrol.inc'}

uses
{$IFDEF DELPHI5_UP}
  Variants,
{$ENDIF}
  Buttons,
  Classes,
  Controls,
  Db,
  DBGrids,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Grids,
  uc_adduser,
  Messages,
  uc_password,
  StdCtrls,
  SysUtils,
  uc_base,
  {$IFDEF WINDOWS}Windows,{$ELSE}LCLType,{$ENDIF}
  uc_userpermissions
  ;

type
  TUserFrameForm = class(TFrame)
    Panel3: TPanel;
    btAdic: TBitBtn;
    BtAlt: TBitBtn;
    BtExclui: TBitBtn;
    BtAcess: TBitBtn;
    BtnClose: TBitBtn;
    BtPass: TBitBtn;
    DbGridUser: TDBGrid;
    DataUser: TDataSource;
    DataPerfil: TDataSource;
    procedure btAdicClick(Sender: TObject);
    procedure BtAltClick(Sender: TObject);
    procedure BtAcessClick(Sender: TObject);
    procedure BtPassClick(Sender: TObject);
    procedure BtExcluiClick(Sender: TObject);
  protected
    PasswordForm: TCustomForm;
    FAddUserForm: TAddUserForm;

    procedure SetWindowUserProfile;
    procedure SetWindowUser(Adicionar: Boolean);
    procedure ActionBtPermissUserDefault;
    procedure FDataSetCadastroUsuarioAfterScroll(DataSet: TDataSet);
  private
  public
    FUsercontrol: TUserControl;
    FUsersListDataSet: TDataSet;

    procedure SetWindow;
    destructor Destroy; override;
  end;

implementation

uses
  uc_messages;

{$R *.lfm}

procedure TUserFrameForm.btAdicClick(Sender: TObject);
begin
  FAddUserForm := TAddUserForm.Create(Self);
  FAddUserForm.FUsercontrol := Self.FUsercontrol;
  SetWindowUser(True);
  FAddUserForm.ShowModal;
  FreeAndNil(FAddUserForm);
end;

procedure TUserFrameForm.BtAltClick(Sender: TObject);
begin
  if FUsersListDataSet.IsEmpty then
    Exit;
  FAddUserForm := TAddUserForm.Create(Self);
  FAddUserForm.FUsercontrol := Self.FUsercontrol;
  SetWindowUser(False);
  with FAddUserForm do
    begin
      FAltera := True;
      vNovoIDUsuario := FUsersListDataSet.FieldByName('IdUser').AsInteger;
      EditNome.Text := FUsersListDataSet.FieldByName('Nome').AsString;
      EditLogin.Text := FUsersListDataSet.FieldByName('Login').AsString;
      EditEmail.Text := FUsersListDataSet.FieldByName('Email').AsString;
      ComboPerfil.KeyValue := FUsersListDataSet.FieldByName('Perfil').AsInteger;
      ckPrivilegiado.Checked := StrToBool(FUsersListDataSet.FieldByName('Privilegiado').AsString);
      ckUserExpired.Checked := StrToBool(FUsersListDataSet.FieldByName('UserNaoExpira').AsString);
      SpinExpira.Value := FUsersListDataSet.FieldByName('DaysOfExpire').AsInteger;
      ComboStatus.ItemIndex := FUsersListDataSet.FieldByName('UserInative').AsInteger;
      if FAddUserForm.ComboStatus.Enabled then
        FAddUserForm.ComboStatus.Enabled :=
          not((FUsercontrol.User.ProtectAdministrator) and
          (FUsersListDataSet.FieldByName('Login').AsString = FUsercontrol.Login.InitialLogin.User));
      ShowModal;
    end;
  FreeAndNil(FAddUserForm);
end;

procedure TUserFrameForm.BtExcluiClick(Sender: TObject);
var
  TempID: Integer;
  CanDelete: Boolean;
  ErrorMsg: string;
begin
  if FUsersListDataSet.IsEmpty then
    Exit;
  TempID := FUsersListDataSet.FieldByName('IDUser').AsInteger;
  if Application.MessageBox(
    PChar(Format(FUsercontrol.UserSettings.UsersForm.PromptDelete,
    [FUsersListDataSet.FieldByName('Login').AsString])),
    PChar(FUsercontrol.UserSettings.UsersForm.PromptDelete_WindowCaption),
    MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = idYes then
    begin
      CanDelete := True;
      if Assigned(FUsercontrol.onDeleteUser) then
        FUsercontrol.onDeleteUser(TObject(Owner), TempID, CanDelete, ErrorMsg);
      if not CanDelete then
      begin
        MessageDlg(ErrorMsg, mtWarning, [mbOK], 0);
        Exit;
      end;

      FUsercontrol.DataConnector.UCExecSQL(
        'Delete from ' + FUsercontrol.TableRights.TableName + ' where ' +
        FUsercontrol.TableRights.FieldUserID + ' = ' + IntToStr(TempID));
      FUsercontrol.DataConnector.UCExecSQL(
        'Delete from ' + FUsercontrol.TableUsers.TableName + ' where ' +
        FUsercontrol.TableUsers.FieldUserID + ' = ' + IntToStr(TempID));
      FUsersListDataSet.Close;
      FUsersListDataSet.Open;
    end;
end;

procedure TUserFrameForm.BtPassClick(Sender: TObject);
begin
  if FUsersListDataSet.IsEmpty then
    Exit;

  PasswordForm := TPasswordForm.Create(Self);
  TPasswordForm(PasswordForm).Position := FUsercontrol.UserSettings.WindowsPosition;
  TPasswordForm(PasswordForm).FUsercontrol := FUsercontrol;
  TPasswordForm(PasswordForm).Caption := Format(FUsercontrol.UserSettings.ResetPassword.WindowCaption,
    [FUsersListDataSet.FieldByName('Login').AsString]);
  if TPasswordForm(PasswordForm).ShowModal = mrOk then
    begin

      (*
        if (Assigned(FUsercontrol.MailUserControl)) and (FUsercontrol.MailUserControl.SenhaForcada.Ativo ) then
          try
            FUsercontrol.MailUserControl.EnviaEmailSenhaForcada(
            FUsersListDataSet.FieldByName('NOME').AsString ,
            FUsersListDataSet.FieldByName('LOGIN').AsString,
            TPasswordForm(PasswordForm).edtSenha.Text ,
            FUsersListDataSet.FieldByName('EMAIL').AsString,
            '');

          except
            on E : Exception do
              FUsercontrol.Log(e.Message, 0);
          end;

      *)
      FUsercontrol.ChangePassword(FUsersListDataSet.FieldByName('IDUser').AsInteger,
        TPasswordForm(PasswordForm).edtSenha.Text);
    end;
  FreeAndNil(PasswordForm);
end;

destructor TUserFrameForm.Destroy;
begin
  // nada a destruir
  // n�o destruir o FUsersListDataSet o USERCONTROL toma conta dele
  inherited;
end;

procedure TUserFrameForm.BtAcessClick(Sender: TObject);
begin
  if FUsersListDataSet.IsEmpty then
    Exit;
  UserPermissions := TUserPermissions(Self);
  UserPermissions.FUsercontrol := FUsercontrol;
  SetWindowUserProfile;
  UserPermissions.lbUser.Caption := FUsersListDataSet.FieldByName('Login').AsString;
  ActionBtPermissUserDefault;
end;

procedure TUserFrameForm.SetWindowUserProfile;
begin
  with FUsercontrol.UserSettings.Rights do
    begin
      UserPermissions.Caption := WindowCaption;
      UserPermissions.LbDescricao.Caption := LabelUser;
      UserPermissions.lbUser.Left := UserPermissions.LbDescricao.Left + UserPermissions.LbDescricao.Width + 5;
      UserPermissions.PageMenu.Caption := PageMenu;
      UserPermissions.PageAction.Caption := PageActions;
      UserPermissions.PageControls.Caption := PageControls; // By Vicente Barros Leonel
      UserPermissions.BtLibera.Caption := BtUnlock;
      UserPermissions.BtBloqueia.Caption := BtLOck;
      UserPermissions.BtGrava.Caption := BtSave;
      UserPermissions.BtCancel.Caption := BtCancel;
      UserPermissions.Position := FUsercontrol.UserSettings.WindowsPosition;
    end;
end;

procedure TUserFrameForm.ActionBtPermissUserDefault;
var
  TempCampos, TempCamposEX: string;
begin
  UserPermissions.FTempUserID := FUsersListDataSet.FieldByName('IdUser').AsInteger;
  with FUsercontrol do
    begin
      TempCampos := Format(' %s as IdUser, %s as Modulo, %s as ObjName, %s as UCKey ',
        [TableRights.FieldUserID, TableRights.FieldModule,
        TableRights.FieldComponentName, TableRights.FieldKey]);
      TempCamposEX := Format(' %s, %s as FormName ',
        [TempCampos, TableRights.FieldFormName]);

      UserPermissions.PermissionsDataset := DataConnector.UCGetSQLDataset(
        Format('SELECT %s FROM %s TAB WHERE TAB.%s = %s AND TAB.%s = %s',
        [TempCampos, TableRights.TableName, TableRights.FieldUserID,
        FUsersListDataSet.FieldByName('IdUser').AsString,
        TableRights.FieldModule, QuotedStr(ApplicationID)]));
      UserPermissions.PermissionsDataset.Open;

      UserPermissions.PermissionsDatasetEx := DataConnector.UCGetSQLDataset(
        Format('SELECT %s FROM %s TAB1 WHERE TAB1.%s = %s AND TAB1.%s = %s',
        [TempCamposEX, TableRights.TableName + 'EX', TableRights.FieldUserID,
        FUsersListDataSet.FieldByName('IdUser').AsString,
        TableRights.FieldModule, QuotedStr(ApplicationID)]));
      UserPermissions.PermissionsDatasetEx.Open;

      UserPermissions.ProfilesDataset := DataConnector.UCGetSQLDataset(
        Format('Select %s from %s tab Where tab.%s = %s and tab.%s = %s',
        [TempCampos, TableRights.TableName, TableRights.FieldUserID,
        FUsersListDataSet.FieldByName('Perfil').AsString,
        TableRights.FieldModule, QuotedStr(ApplicationID)]));
      UserPermissions.ProfilesDataset.Open;

      UserPermissions.ProfilesDatasetEx := DataConnector.UCGetSQLDataset(
        Format('Select %s from %s tab1 Where tab1.%s = %s and tab1.%s = %s',
        [TempCamposEX, TableRights.TableName + 'EX', TableRights.FieldUserID,
        FUsersListDataSet.FieldByName('Perfil').AsString,
        TableRights.FieldModule, QuotedStr(ApplicationID)]));

      UserPermissions.ProfilesDatasetEx.Open;

      UserPermissions.ShowModal;

      FUsersListDataSet.Close;
      FUsersListDataSet.Open;

      FUsersListDataSet.Locate('idUser', UserPermissions.FTempUserID, []);

      FreeAndNil(UserPermissions);
    end;
end;

procedure TUserFrameForm.FDataSetCadastroUsuarioAfterScroll(DataSet: TDataSet);
begin
  if (FUsercontrol.User.ProtectAdministrator)
    and (DataSet.FieldByName('Login').AsString = FUsercontrol.Login.InitialLogin.User) then
    begin
      BtExclui.Enabled := False;
      BtPass.Enabled := False;
      if FUsercontrol.CurrentUser.Username <> FUsercontrol.Login.InitialLogin.User then
        BtAcess.Enabled := False;
    end
  else
    begin
      BtExclui.Enabled := True;
      BtPass.Enabled := True;
      BtAcess.Enabled := True;
    end;
end;

procedure TUserFrameForm.SetWindow;
begin
  FUsersListDataSet.AfterScroll := FDataSetCadastroUsuarioAfterScroll;
  FDataSetCadastroUsuarioAfterScroll(FUsersListDataSet);
  with FUsercontrol.UserSettings.UsersForm do
    begin
      DbGridUser.Columns[0].Title.Caption := ColName;
      DbGridUser.Columns[1].Title.Caption := ColLogin;
      DbGridUser.Columns[2].Title.Caption := ColEmail;

      btAdic.Caption := BtAdd;
      BtAlt.Caption := BtChange;
      BtExclui.Caption := BtDelete;
      BtAcess.Caption := BtRights;
      BtPass.Caption := BtPassword;
      BtnClose.Caption := BtClose;
    end;
end;

procedure TUserFrameForm.SetWindowUser(Adicionar: Boolean);
begin
  with FUsercontrol.UserSettings.AddChangeUser do
    begin
      FAddUserForm.Caption := WindowCaption;
      if Adicionar then
        FAddUserForm.LbDescricao.Caption := LabelAdd
      else
        begin
          FAddUserForm.LbDescricao.Caption := LabelChange;
          FAddUserForm.LbDescricao.Tag := FUsersListDataSet.FieldByName('IdUser').AsInteger;
        end;

      FAddUserForm.FUsersListDataSet := DataUser.DataSet;
      FAddUserForm.Label1.Caption := LabelStatus;
      FAddUserForm.lbNome.Caption := LabelName;
      FAddUserForm.lbLogin.Caption := LabelLogin;
      FAddUserForm.lbEmail.Caption := LabelEmail;
      FAddUserForm.ckPrivilegiado.Caption := CheckPrivileged;
      FAddUserForm.lbPerfil.Caption := LabelPerfil;
      FAddUserForm.btGravar.Caption := BtSave;
      FAddUserForm.btCancela.Caption := BtCancel;
      FAddUserForm.Position := Self.FUsercontrol.UserSettings.WindowsPosition;
      FAddUserForm.LabelExpira.Caption := ExpiredIn;
      FAddUserForm.LabelDias.Caption := Day;
      FAddUserForm.ckUserExpired.Caption := CheckExpira;
      FAddUserForm.ComboPerfil.ListSource := DataPerfil;
      FAddUserForm.ComboStatus.Enabled := not Adicionar;
      with FAddUserForm.ComboStatus.Items do
        begin
          Clear;
          Add(StatusActive);
          Add(StatusDisabled);
        end;
      FAddUserForm.ComboStatus.ItemIndex := 0;
    end;
end;

end.
