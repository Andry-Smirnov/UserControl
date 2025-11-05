unit uc_tools;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF WINDOWS}
  Windows,
{$ELSE}
  LCLType,
{$ENDIF}
  Buttons,
  Classes,
  ComCtrls,
  Controls,
  DB,
  DBGrids,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Grids,
  Messages,
  StdCtrls,
  SysUtils,
  Variants,
  //
  uc_base
  ;

type

  { TUserControlForm }

  TUserControlForm = class(TForm)
    Panel1: TPanel;
    LbDescricao: TLabel;
    Image1: TImage;
    Panel2: TPanel;
    SpeedUser: TSpeedButton;
    SpeedPerfil: TSpeedButton;
    Panel3: TPanel;
    SpeedLog: TSpeedButton;
    SpeedUserLog: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SpeedUserClick(Sender: TObject);
    procedure SpeedPerfilClick(Sender: TObject);
    procedure SpeedLogClick(Sender: TObject);
    procedure SpeedUserLogClick(Sender: TObject);
    procedure SpeedUserMouseEnter(Sender: TObject);
    procedure SpeedUserMouseLeave(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  protected
    FrmFrame: TCustomFrame;
  private
    { Private declarations }
  public
    FUsercontrol: TUserControl;

    procedure LoadDatasets;
  end;

var
  UserControlForm: TUserControlForm;

implementation

uses
  uc_logframe,
  uc_profileframe,
  uc_userframe,
  uc_frameuserslogged,
  uc_messages;

{$R *.lfm}
{ --------------------------------------------------------------------------- }
{ FORM }

procedure TUserControlForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FrmFrame) then
    FreeAndNil(FrmFrame);
  Action := caFree;
end;

procedure TUserControlForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    Close;
end;

procedure TUserControlForm.LoadDatasets;
begin
  with FUsercontrol do
  begin
    FUsercontrol.CurrentUser.UserProfile := Nil;
    FUsercontrol.CurrentUser.UserProfile := DataConnector.UCGetSQLDataset
      (Format('Select %s as IdUser, %s as Login, %s as Nome, %s as Email, %s as Perfil, %s as Privilegiado, %s as Tipo, %s as Senha, %s as UserNaoExpira, %s as DaysOfExpire , %s as UserInative from %s Where %s  = %s ORDER BY %s',
      [TableUsers.FieldUserID, TableUsers.FieldLogin, TableUsers.FieldUserName,
      TableUsers.FieldEmail, TableUsers.FieldProfile,
      TableUsers.FieldPrivileged, TableUsers.FieldTypeRec,
      TableUsers.FieldPassword, TableUsers.FieldUserExpired,
      TableUsers.FieldUserDaysSun, TableUsers.FieldUserInative,
      TableUsers.TableName, TableUsers.FieldTypeRec, QuotedStr('U'),
      TableUsers.FieldLogin]));

    FUsercontrol.CurrentUser.GroupProfile := Nil;
    FUsercontrol.CurrentUser.GroupProfile := DataConnector.UCGetSQLDataset
      (Format('Select %s as IdUser, %s as Login, %s as Nome, %s as Tipo from %s Where %s  = %s ORDER BY %s',
      [TableUsers.FieldUserID, TableUsers.FieldLogin, TableUsers.FieldUserName,
      TableUsers.FieldTypeRec, TableUsers.TableName, TableUsers.FieldTypeRec,
      QuotedStr('P'), TableUsers.FieldUserName]));
  end;
end;

procedure TUserControlForm.FormShow(Sender: TObject);
begin
  LoadDatasets;

  SpeedPerfil.Visible := FUsercontrol.UserProfile.Active;
  SpeedLog.Visible := FUsercontrol.LogControl.Active;
  SpeedUserLog.Visible := FUsercontrol.UsersLogged.Active;

  SpeedUserClick(Sender);
  Caption := FUsercontrol.UserSettings.UsersForm.WindowCaption;

  SpeedUser.Caption := FUsercontrol.UserSettings.Log.ColUser;
  SpeedPerfil.Caption := FUsercontrol.UserSettings.UsersProfile.ColProfile;
  SpeedUserLog.Caption := FUsercontrol.UserSettings.UsersLogged.LabelDescricao;

end;

procedure TUserControlForm.SpeedPerfilClick(Sender: TObject);
begin
  if FrmFrame is TProfileFrame then
    Exit;
  if Assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  LoadDatasets;

  FrmFrame := TProfileFrame.Create(Self);
  TProfileFrame(FrmFrame).DataPerfil.DataSet :=
    FUsercontrol.CurrentUser.GroupProfile;
  TProfileFrame(FrmFrame).BtnClose.ModalResult := mrOk;
  TProfileFrame(FrmFrame).Height := Panel3.Height;
  TProfileFrame(FrmFrame).Width := Panel3.Width;
  TProfileFrame(FrmFrame).FDataSetPerfilUsuario :=
    FUsercontrol.CurrentUser.GroupProfile;
  TProfileFrame(FrmFrame).FUserControl := FUsercontrol;
  TProfileFrame(FrmFrame).DbGridPerf.Columns[0].Title.Caption :=
    FUsercontrol.UserSettings.UsersProfile.ColProfile;
  with FUsercontrol.UserSettings.UsersProfile, TProfileFrame(FrmFrame) do
  begin
    LbDescricao.Caption := LabelDescription;
    BtnAddPer.Caption := BtAdd;
    BtnAltPer.Caption := BtChange;
    BtnExcPer.Caption := BtDelete;
    BtnAcePer.Caption := BtRights;
    BtnClose.Caption := BtClose;
  end;
  FrmFrame.Parent := Panel3;
end;

procedure TUserControlForm.SpeedUserClick(Sender: TObject);
begin
  if FrmFrame is TUserFrameForm then
    Exit;

  if Assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  LoadDatasets;

  FrmFrame := TUserFrameForm.Create(Self);
  TUserFrameForm(FrmFrame).FUsersListDataSet :=
    FUsercontrol.CurrentUser.UserProfile;
  TUserFrameForm(FrmFrame).DataUser.DataSet := TUserFrameForm(FrmFrame)
    .FUsersListDataSet;
  TUserFrameForm(FrmFrame).DataPerfil.DataSet :=
    FUsercontrol.CurrentUser.GroupProfile;
  TUserFrameForm(FrmFrame).BtnClose.ModalResult := mrOk;
  TUserFrameForm(FrmFrame).FUsercontrol := FUsercontrol;
  TUserFrameForm(FrmFrame).Height := Panel3.Height;
  TUserFrameForm(FrmFrame).Width := Panel3.Width;
  TUserFrameForm(FrmFrame).SetWindow;
  LbDescricao.Caption := FUsercontrol.UserSettings.UsersForm.LabelDescription;

  FrmFrame.Parent := Panel3;
end;

procedure TUserControlForm.SpeedUserLogClick(Sender: TObject);
begin
  if FrmFrame is TUCFrame_UsersLogged then
    Exit;

  if Assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TUCFrame_UsersLogged.Create(Self);
  LbDescricao.Caption := FUsercontrol.UserSettings.UsersLogged.LabelDescricao;
  TUCFrame_UsersLogged(FrmFrame).FUsercontrol := FUsercontrol;
  TUCFrame_UsersLogged(FrmFrame).SetWindow;
  TUCFrame_UsersLogged(FrmFrame).Height := Panel3.Height;
  TUCFrame_UsersLogged(FrmFrame).Width := Panel3.Width;
  TUCFrame_UsersLogged(FrmFrame).BtExit.ModalResult := mrOk;
  FrmFrame.Parent := Panel3;
end;

procedure TUserControlForm.SpeedUserMouseEnter(Sender: TObject);
begin
  with TSpeedButton(Sender) do
  begin
    Font.Style := [fsUnderline];
    Cursor := crHandPoint;
  end;
end;

procedure TUserControlForm.SpeedUserMouseLeave(Sender: TObject);
begin
  with TSpeedButton(Sender) do
  begin
    Font.Style := [];
    Cursor := crDefault;
  end;
end;

procedure TUserControlForm.SpeedLogClick(Sender: TObject);
begin
  if FrmFrame is TLogFrame then
    Exit;

  if Assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TLogFrame.Create(Self);
  LbDescricao.Caption := FUsercontrol.UserSettings.Log.LabelDescription;
  TLogFrame(FrmFrame).FUserControl := FUsercontrol;
  TLogFrame(FrmFrame).SetWindow;
  TLogFrame(FrmFrame).Height := Panel3.Height;
  TLogFrame(FrmFrame).Width := Panel3.Width;
  TLogFrame(FrmFrame).btfecha.ModalResult := mrOk;
  FrmFrame.Parent := Panel3;
end;

end.
