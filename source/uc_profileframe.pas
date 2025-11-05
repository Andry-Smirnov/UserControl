unit uc_profileframe;

interface

{$I 'UserControl.inc'}

uses
{$IFDEF WINDOWS}Windows,{$ELSE}LCLType,{$ENDIF}
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
  Messages,
  StdCtrls,
  SysUtils,
  //
  uc_addprofile,
  uc_base,
  uc_userpermissions;

type
  TProfileFrame = class(TFrame)
    DbGridPerf: TDBGrid;
    Panel2: TPanel;
    BtnAddPer: TBitBtn;
    BtnAltPer: TBitBtn;
    BtnExcPer: TBitBtn;
    BtnClose: TBitBtn;
    BtnAcePer: TBitBtn;
    DataPerfil: TDataSource;
    procedure BtnAddPerClick(Sender: TObject);
    procedure BtnAltPerClick(Sender: TObject);
    procedure BtnExcPerClick(Sender: TObject);
    procedure BtnAcePerClick(Sender: TObject);
  protected
    IncludeProfile: TAddProfileForm;

    procedure ActionBtPermissProfileDefault;
    procedure SetWindowPerfil(Adicionar: Boolean);
    procedure SetWindowProfile;
  private
  public
    FUserControl: TUserControl;
    FDataSetPerfilUsuario: TDataset;

    destructor Destroy; override;
  end;

implementation

{$R *.lfm}

procedure TProfileFrame.SetWindowPerfil(Adicionar: Boolean);
begin
  with FUserControl.UserSettings.AddChangeProfile do
    begin
      IncludeProfile.Caption := WindowCaption;
      if Adicionar then
        IncludeProfile.LbDescricao.Caption := LabelAdd
      else
        IncludeProfile.LbDescricao.Caption := LabelChange;

      IncludeProfile.lbNome.Caption := LabelName;
      IncludeProfile.btGravar.Caption := BtSave;
      IncludeProfile.btCancela.Caption := BtCancel;
      IncludeProfile.Position := FUserControl.UserSettings.WindowsPosition;
      IncludeProfile.FUserProfileDataSet := FDataSetPerfilUsuario;
    end;
end;

procedure TProfileFrame.ActionBtPermissProfileDefault;
var
  TempCampos, TempCamposEX: String;
begin
  UserPermissions.FTempUserID := FDataSetPerfilUsuario.FieldByName('IdUser').AsInteger;
  with FUserControl do
    begin
      TempCampos :=
        Format(' %s AS IdUser, %s AS Modulo, %s AS ObjName, %s AS UCKey ',
        [TableRights.FieldUserID, TableRights.FieldModule,
        TableRights.FieldComponentName, TableRights.FieldKey]);
      TempCamposEX := Format('%s, %s AS FormName ', [TempCampos, TableRights.FieldFormName]);

      UserPermissions.PermissionsDataset := DataConnector.UCGetSQLDataset
        (Format('SELECT %s from %s tab WHERE tab.%s = %s AND tab.%s = %s',
        [TempCampos, TableRights.TableName, TableRights.FieldUserID,
        FDataSetPerfilUsuario.FieldByName('IdUser').AsString,
        TableRights.FieldModule, QuotedStr(ApplicationID)]));

      UserPermissions.PermissionsDataset.Open;

      UserPermissions.PermissionsDatasetEx := DataConnector.UCGetSQLDataset
        (Format('SELECT %s FROM %s tab1 WHERE tab1.%s = %s AND tab1.%s = %s',
        [TempCamposEX, TableRights.TableName + 'EX', TableRights.FieldUserID,
        FDataSetPerfilUsuario.FieldByName('IdUser').AsString,
        TableRights.FieldModule, QuotedStr(ApplicationID)]));

      UserPermissions.PermissionsDatasetEx.Open;

      UserPermissions.ProfilesDataset := TDataset.Create(UserPermissions);

      UserPermissions.ShowModal;

      FDataSetPerfilUsuario.Close;
      FDataSetPerfilUsuario.Open;
      FDataSetPerfilUsuario.Locate('idUser', UserPermissions.FTempUserID, []);

      FreeAndNil(UserPermissions);
    end;
end;

procedure TProfileFrame.SetWindowProfile;
begin
  with FUserControl.UserSettings.Rights do
    begin
      UserPermissions.Caption := WindowCaption;
      UserPermissions.LbDescricao.Caption := LabelProfile;
      UserPermissions.lbUser.Left := UserPermissions.LbDescricao.Left + UserPermissions.LbDescricao.Width + 5;
      UserPermissions.PageMenu.Caption := PageMenu;
      UserPermissions.PageAction.Caption := PageActions;
      UserPermissions.PageControls.Caption := PageControls; // By Vicente Barros Leonel
      UserPermissions.BtLibera.Caption := BtUnlock;
      UserPermissions.BtBloqueia.Caption := BtLock;
      UserPermissions.BtGrava.Caption := BtSave;
      UserPermissions.BtCancel.Caption := BtCancel;
      UserPermissions.Position := FUserControl.UserSettings.WindowsPosition;
    end;
end;

procedure TProfileFrame.BtnAcePerClick(Sender: TObject);
begin
  if FDataSetPerfilUsuario.IsEmpty then
    Exit;
  UserPermissions := TUserPermissions(self);
  UserPermissions.FUserControl := FUserControl;
  SetWindowProfile;
  UserPermissions.lbUser.Caption := FDataSetPerfilUsuario.FieldByName('Nome').AsString;
  ActionBtPermissProfileDefault;
end;

procedure TProfileFrame.BtnAddPerClick(Sender: TObject);
begin
  try
    IncludeProfile := TAddProfileForm.Create(self);
    IncludeProfile.FUserControl := self.FUserControl;
    SetWindowPerfil(True);
    IncludeProfile.ShowModal;
  finally
    FreeAndNil(IncludeProfile);
  end;
end;

procedure TProfileFrame.BtnAltPerClick(Sender: TObject);
begin
  if FDataSetPerfilUsuario.IsEmpty then
    Exit;
  try
    IncludeProfile := TAddProfileForm.Create(self);
    IncludeProfile.FUserControl := self.FUserControl;
    IncludeProfile.FNewUserID := FDataSetPerfilUsuario.FieldByName('IdUser').AsInteger;
    SetWindowPerfil(False);
    with IncludeProfile do
      begin
        EditDescricao.Text := FUserProfileDataSet.FieldByName('Nome').AsString;
        FChanged := True;
        ShowModal;
      end;
  finally
    FreeAndNil(IncludeProfile);
  end;
end;

procedure TProfileFrame.BtnExcPerClick(Sender: TObject);
var
  TempID: Integer;
  CanDelete: Boolean;
  ErrorMsg: String;
  TempDS: TDataset;
begin
  if FDataSetPerfilUsuario.IsEmpty then
    Exit;
  TempID := FDataSetPerfilUsuario.FieldByName('IDUser').AsInteger;
  TempDS := FUserControl.DataConnector.UCGetSQLDataset
    ('SELECT ' + FUserControl.TableUsers.FieldUserID + ' AS IdUser FROM ' +
    FUserControl.TableUsers.TableName + ' WHERE ' +
    FUserControl.TableUsers.FieldTypeRec + ' = ' + QuotedStr('U') + ' AND ' +
    FUserControl.TableUsers.FieldProfile + ' = ' + IntToStr(TempID));

  if TempDS.FieldByName('IdUser').AsInteger > 0 then
    begin
      TempDS.Close;
      FreeAndNil(TempDS);
      // changed by fduenas: PromptDelete_WindowCaption
      if Application.MessageBox(
        PChar(Format(FUserControl.UserSettings.UsersProfile.PromptDelete,
        [FDataSetPerfilUsuario.FieldByName('Nome').AsString])),
        PChar(FUserControl.UserSettings.UsersProfile.PromptDelete_WindowCaption),
        MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) <> idYes then
        Exit;
    end
  else
    begin
      TempDS.Close;
      FreeAndNil(TempDS);
    end;

  CanDelete := True;
  if Assigned(FUserControl.onDeleteProfile) then
    FUserControl.onDeleteProfile(TObject(Owner), TempID, CanDelete, ErrorMsg);
  if not CanDelete then
    begin
      MessageDlg(ErrorMsg, mtWarning, [mbOK], 0);
      Exit;
    end;

  with FUserControl do
    begin
      DataConnector.UCExecSQL('DELETE FROM ' + TableUsers.TableName + ' WHERE ' +
        TableUsers.FieldUserID + ' = ' + IntToStr(TempID));
      DataConnector.UCExecSQL('DELETE FROM ' + TableRights.TableName + ' WHERE ' +
        TableRights.FieldUserID + ' = ' + IntToStr(TempID));
      DataConnector.UCExecSQL('DELETE FROM ' + TableRights.TableName + 'EX WHERE '
        + TableRights.FieldUserID + ' = ' + IntToStr(TempID));
      DataConnector.UCExecSQL('UPDATE ' + TableUsers.TableName + ' SET ' +
        TableUsers.FieldProfile + ' = null WHERE ' + TableUsers.FieldUserID +
        ' = ' + IntToStr(TempID));
    end;
  FDataSetPerfilUsuario.Close;
  FDataSetPerfilUsuario.Open;
end;

destructor TProfileFrame.Destroy;
begin
  // nada a destruir
  // não destruir o FDataSetPerfilUsuario o USERCONTROL toma conta dele
  inherited;
end;

end.
