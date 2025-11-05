unit uc_addprofile;

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
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Messages,
  StdCtrls,
  SysUtils,
  uc_base;

type
  TAddProfileForm = class(TForm)
    Panel1: TPanel;
    LbDescricao: TLabel;
    Image1: TImage;
    Panel3: TPanel;
    btGravar: TBitBtn;
    btCancela: TBitBtn;
    Panel2: TPanel;
    lbNome: TLabel;
    EditDescricao: TEdit;
    procedure btCancelaClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
  private
    function GetNewIdUser: Integer;
  public
    FChanged: Boolean;
    FUserControl: TUserControl;
    FNewUserID: Integer;
    FUserProfileDataSet: TDataSet;
  end;

implementation

{$R *.lfm}

procedure TAddProfileForm.btCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TAddProfileForm.btGravarClick(Sender: TObject);
var
  FProfile: String;
begin
  btGravar.Enabled := False;
  with FUserControl do
    if not FChanged then
      begin // inclui perfil
        FNewUserID := GetNewIdUser;
        FProfile := EditDescricao.Text;
        if Assigned(onAddProfile) then
          onAddProfile(TObject(Self.Owner.Owner), FProfile);

        DataConnector.UCExecSQL
          (Format('INSERT INTO %s(%s, %s, %s) Values(%d,%s,%s)',
          [TableUsers.TableName, TableUsers.FieldUserID, TableUsers.FieldUserName,
          TableUsers.FieldTypeRec, FNewUserID, QuotedStr(FProfile),
          QuotedStr('P')]));

      end
    else
      begin // alterar perfil
        // FNewUserID := TfrmCadastrarPerfil(Self.Owner).FDataSetPerfilUsuario.FieldByName('IdUser').AsInteger;
        FProfile := EditDescricao.Text;

        DataConnector.UCExecSQL(Format('UPDATE %s SET %s = %s WHERE %s = %d',
          [TableUsers.TableName, TableUsers.FieldUserName, QuotedStr(FProfile),
          TableUsers.FieldUserID, FNewUserID]));
      end;
  FUserProfileDataSet.Close;
  FUserProfileDataSet.Open;
  FUserProfileDataSet.Locate('IDUser', FNewUserID, []);
  Close;
end;

function TAddProfileForm.GetNewIdUser: Integer;
var
  TempDs: TDataSet;
begin
  with FUserControl do
    TempDs := DataConnector.UCGetSQLDataSet('SELECT ' + TableUsers.FieldUserID +
      ' as MaxUserID from ' + TableUsers.TableName + ' ORDER BY ' +
      TableUsers.FieldUserID + ' DESC');
  Result := TempDs.FieldByName('MaxUserID').AsInteger + 1;
  TempDs.Close;
  FreeAndNil(TempDs);
end;

end.
