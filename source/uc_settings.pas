unit uc_settings;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes,
  Forms,
  uc_messages,
  uc_language;

type
  TUCSettings = class(TComponent)
  private
    FAddProfileFormMSG: TUCAddProfileFormMSG;
    FAddUserFormMSG: TUCAddUserFormMSG;
    FCadUserFormMSG: TUCCadUserFormMSG;
    FLogControlFormMSG: TUCLogControlFormMSG;
    FLoginFormMSG: TUCLoginFormMSG;
    FPermissFormMSG: TUCPermissFormMSG;
    FProfileUserFormMSG: TUCProfileUserFormMSG;
    FResetPassword: TUCResetPassword;
    FTrocaSenhaFormMSG: TUCTrocaSenhaFormMSG;
    FUserCommomMSG: TUCUserCommonMSG;
    FAppMessagesMSG: TUCAppMessagesMSG;
    FPosition: TPosition;
    fLanguage: TUCLanguage;
    fUsersLogged: TUCCadUserLoggedMSG;
    fBancoDados: TUCTypeBancoDados;
    procedure SetFAddProfileFormMSG(const Value: TUCAddProfileFormMSG);
    procedure SetFAddUserFormMSG(const Value: TUCAddUserFormMSG);
    procedure SetFCadUserFormMSG(const Value: TUCCadUserFormMSG);
    procedure SetFFormLoginMsg(const Value: TUCLoginFormMSG);
    procedure SetFLogControlFormMSG(const Value: TUCLogControlFormMSG);
    procedure SetFPermissFormMSG(const Value: TUCPermissFormMSG);
    procedure SetFProfileUserFormMSG(const Value: TUCProfileUserFormMSG);
    procedure SetFResetPassword(const Value: TUCResetPassword);
    procedure SetFTrocaSenhaFormMSG(const Value: TUCTrocaSenhaFormMSG);
    procedure SetFUserCommonMSg(const Value: TUCUserCommonMSG);
    procedure SetAppMessagesMSG(const Value: TUCAppMessagesMSG);
    procedure SetfLanguage(const Value: TUCLanguage);
    procedure SetfUsersLogged(const Value: TUCCadUserLoggedMSG);
    procedure SetfBancoDados(const Value: TUCTypeBancoDados);
  public
    Type_Int: string;
    Type_Char: string;
    Type_VarChar: string;
    Type_Memo: string;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property AppMessages: TUCAppMessagesMSG read FAppMessagesMSG write SetAppMessagesMSG;
    property CommonMessages: TUCUserCommonMSG read FUserCommomMSG write SetFUserCommonMSg;
    property Login: TUCLoginFormMSG read FLoginFormMSG write SetFFormLoginMsg;
    property Log: TUCLogControlFormMSG read FLogControlFormMSG write SetFLogControlFormMSG;
    property UsersForm: TUCCadUserFormMSG read FCadUserFormMSG write SetFCadUserFormMSG;
    property AddChangeUser: TUCAddUserFormMSG read FAddUserFormMSG write SetFAddUserFormMSG;
    property AddChangeProfile: TUCAddProfileFormMSG read FAddProfileFormMSG write SetFAddProfileFormMSG;
    property UsersProfile: TUCProfileUserFormMSG read FProfileUserFormMSG write SetFProfileUserFormMSG;
    property Rights: TUCPermissFormMSG read FPermissFormMSG write SetFPermissFormMSG;
    property ChangePassword: TUCTrocaSenhaFormMSG read FTrocaSenhaFormMSG write SetFTrocaSenhaFormMSG;
    property ResetPassword: TUCResetPassword read FResetPassword write SetFResetPassword;
    property BancoDados: TUCTypeBancoDados read fBancoDados write SetfBancoDados;
    property WindowsPosition: TPosition read FPosition write FPosition default poMainFormCenter;
    property Language: TUCLanguage read fLanguage write SetfLanguage;
    property UsersLogged: TUCCadUserLoggedMSG read fUsersLogged write SetfUsersLogged;
  end;

procedure IniSettings(DestSettings: TUCUserSettings);
procedure IniSettings2(DestSettings: TUCSettings);

procedure AlterLanguage(DestSettings: TUCUserSettings);
procedure AlterLanguage2(DestSettings: TUCSettings);

procedure RetornaSqlBancoDados(fBanco: TUCTypeBancoDados;
  var Int, char, VarChar, Memo: string);

implementation

uses
  Graphics,
  SysUtils,
  uc_base;
  // UCConsts;

{$IFDEF DELPHI9_UP} {$REGION 'Inicializacao'} {$ENDIF}

procedure RetornaSqlBancoDados(fBanco: TUCTypeBancoDados;
  var Int, char, VarChar, Memo: string);
begin
  Int := 'INT';
  char := 'CHAR';
  VarChar := 'VARCHAR';

  case fBanco of
    Firebird:
      Memo := 'BLOB SUB_TYPE 1 SEGMENT SIZE 1024';
    Interbase:
      Memo := 'BLOB SUB_TYPE 1 SEGMENT SIZE 1024';
    MySql:
      Memo := 'MEDIUMBLOB';
    PARADOX:
      Memo := 'BLOB(1024,1)';
    Oracle:
      Memo := 'LONG RAW';
    SqlServer:
      Memo := 'NTEXT';
    PostgreSQL:
      Memo := 'TEXT';
  end;
end;

procedure IniSettings(DestSettings: TUCUserSettings);
var
  tmp: TBitmap;
begin
  with DestSettings.CommonMessages do
  begin
    if BlankPassword = '' then
      BlankPassword := ChangeLanguage(ucEnglish, 'Const_Men_SenhaDesabitada');
    if PasswordChanged = '' then
      PasswordChanged := ChangeLanguage(ucEnglish, 'Const_Men_SenhaAlterada');
    if InitialMessage.Text = '' then
      InitialMessage.Text := ChangeLanguage(ucEnglish, 'Const_Men_MsgInicial');
    if MaxLoginAttemptsError = '' then
      MaxLoginAttemptsError :=
        ChangeLanguage(ucEnglish, 'Const_Men_MaxTentativas');
    if InvalidLogin = '' then
      InvalidLogin := ChangeLanguage(ucEnglish, 'Const_Men_LoginInvalido');
    if InactiveLogin = '' then
      InactiveLogin := ChangeLanguage(ucEnglish, 'Const_Men_LoginInativo');

    if AutoLogonError = '' then
      AutoLogonError := ChangeLanguage(ucEnglish, 'Const_Men_AutoLogonError');
    if UsuarioExiste = '' then
      UsuarioExiste := ChangeLanguage(ucEnglish, 'Const_Men_UsuarioExiste');
    if PasswordExpired = '' then
      PasswordExpired := ChangeLanguage(ucEnglish, 'Const_Men_PasswordExpired');
    if ForcaTrocaSenha = '' then
      ForcaTrocaSenha := ChangeLanguage(ucEnglish,
        'Const_ErrPass_ForcaTrocaSenha');
  end;

  with DestSettings.Login do
  begin
    if BtCancel = '' then
      BtCancel := ChangeLanguage(ucEnglish, 'Const_Log_BtCancelar');
    if BtOK = '' then
      BtOK := ChangeLanguage(ucEnglish, 'Const_Log_BtOK');
    if LabelPassword = '' then
      LabelPassword := ChangeLanguage(ucEnglish, 'Const_Log_LabelSenha');
    if LabelUser = '' then
      LabelUser := ChangeLanguage(ucEnglish, 'Const_Log_LabelUsuario');
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_Log_WindowCaption');

    if LabelTentativa = '' then
      LabelTentativa := ChangeLanguage(ucEnglish, 'Const_Log_LabelTentativa');
    if LabelTentativas = '' then
      LabelTentativas := ChangeLanguage(ucEnglish, 'Const_Log_LabelTentativas');

    try
      tmp := TBitmap.Create;
      tmp.LoadFromResourceName(HInstance, 'UCLOCKLOGIN');
      LeftImage.Assign(tmp);
    finally
      FreeAndNil(tmp);
    end;
  end;

  with DestSettings.UsersForm do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_Cad_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(ucEnglish, 'Const_Cad_LabelDescricao');
    if ColName = '' then
      ColName := ChangeLanguage(ucEnglish, 'Const_Cad_ColunaNome');
    if ColLogin = '' then
      ColLogin := ChangeLanguage(ucEnglish, 'Const_Cad_ColunaLogin');
    if ColEmail = '' then
      ColEmail := ChangeLanguage(ucEnglish, 'Const_Cad_ColunaEmail');
    if BtAdd = '' then
      BtAdd := ChangeLanguage(ucEnglish, 'Const_Cad_BtAdicionar');
    if BtChange = '' then
      BtChange := ChangeLanguage(ucEnglish, 'Const_Cad_BtAlterar');
    if BtDelete = '' then
      BtDelete := ChangeLanguage(ucEnglish, 'Const_Cad_BtExcluir');
    if BtRights = '' then
      BtRights := ChangeLanguage(ucEnglish, 'Const_Cad_BtPermissoes');
    if BtPassword = '' then
      BtPassword := ChangeLanguage(ucEnglish, 'Const_Cad_BtSenha');
    if BtClose = '' then
      BtClose := ChangeLanguage(ucEnglish, 'Const_Cad_BtFechar');
    if PromptDelete = '' then
      PromptDelete := ChangeLanguage(ucEnglish, 'Const_Cad_ConfirmaExcluir');
    if PromptDelete_WindowCaption = '' then
      PromptDelete_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_Cad_ConfirmaDelete_WindowCaption');
    // added by fduenas
  end;

  with DestSettings.UsersProfile do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_Prof_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(ucEnglish, 'Const_Prof_LabelDescricao');
    if ColProfile = '' then
      ColProfile := ChangeLanguage(ucEnglish, 'Const_Prof_ColunaNome');
    if BtAdd = '' then
      BtAdd := ChangeLanguage(ucEnglish, ' Const_Prof_BtAdicionar');
    if BtChange = '' then
      BtChange := ChangeLanguage(ucEnglish, 'Const_Prof_BtAlterar');
    if BtDelete = '' then
      BtDelete := ChangeLanguage(ucEnglish, 'Const_Prof_BtExcluir');
    if BtRights = '' then
      BtRights := ChangeLanguage(ucEnglish, 'Const_Prof_BtPermissoes');
    if BtClose = '' then
      BtClose := ChangeLanguage(ucEnglish, 'Const_Prof_BtFechar');
    if PromptDelete = '' then
      PromptDelete := ChangeLanguage(ucEnglish, 'Const_Prof_ConfirmaExcluir');
    if PromptDelete_WindowCaption = '' then
      PromptDelete_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_Prof_ConfirmaDelete_WindowCaption');
    // added by fduenas
  end;

  with DestSettings.AddChangeUser do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_Inc_WindowCaption');
    if LabelAdd = '' then
      LabelAdd := ChangeLanguage(ucEnglish, 'Const_Inc_LabelAdicionar');
    if LabelChange = '' then
      LabelChange := ChangeLanguage(ucEnglish, 'Const_Inc_LabelAlterar');
    if LabelName = '' then
      LabelName := ChangeLanguage(ucEnglish, 'Const_Inc_LabelNome');
    if LabelLogin = '' then
      LabelLogin := ChangeLanguage(ucEnglish, 'Const_Inc_LabelLogin');
    if LabelEmail = '' then
      LabelEmail := ChangeLanguage(ucEnglish, 'Const_Inc_LabelEmail');
    if LabelPerfil = '' then
      LabelPerfil := ChangeLanguage(ucEnglish, 'Const_Inc_LabelPerfil');
    if CheckPrivileged = '' then
      CheckPrivileged := ChangeLanguage(ucEnglish, 'Const_Inc_CheckPrivilegiado');

    if BtSave = '' then
      BtSave := ChangeLanguage(ucEnglish, 'Const_Inc_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(ucEnglish, 'Const_Inc_BtCancelar');

    if CheckExpira = '' then
      CheckExpira := ChangeLanguage(ucEnglish, 'Const_Inc_CheckEspira');
    if Day = '' then
      Day := ChangeLanguage(ucEnglish, 'Const_Inc_Dia');
    if ExpiredIn = '' then
      ExpiredIn := ChangeLanguage(ucEnglish, 'Const_Inc_ExpiraEm');

    if LabelStatus = '' then
      LabelStatus := ChangeLanguage(ucEnglish, 'Const_Inc_LabelStatus');

    if StatusActive = '' then
      StatusActive := ChangeLanguage(ucEnglish, 'Const_Inc_StatusActive');

    if StatusDisabled = '' then
      StatusDisabled := ChangeLanguage(ucEnglish, 'Const_Inc_StatusDisabled');
  end;

  with DestSettings.AddChangeProfile do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_PInc_WindowCaption');
    if LabelAdd = '' then
      LabelAdd := ChangeLanguage(ucEnglish, 'Const_PInc_LabelAdicionar');
    if LabelChange = '' then
      LabelChange := ChangeLanguage(ucEnglish, 'Const_PInc_LabelAlterar');
    if LabelName = '' then
      LabelName := ChangeLanguage(ucEnglish, 'Const_PInc_LabelNome');
    if BtSave = '' then
      BtSave := ChangeLanguage(ucEnglish, 'Const_PInc_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(ucEnglish, 'Const_PInc_BtCancelar');
  end;

  with DestSettings.Rights do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_Perm_WindowCaption');
    if LabelUser = '' then
      LabelUser := ChangeLanguage(ucEnglish, 'Const_Perm_LabelUsuario');
    if LabelProfile = '' then
      LabelProfile := ChangeLanguage(ucEnglish, 'Const_Perm_LabelPerfil');
    if PageMenu = '' then
      PageMenu := ChangeLanguage(ucEnglish, 'Const_Perm_PageMenu');
    if PageActions = '' then
      PageActions := ChangeLanguage(ucEnglish, 'Const_Perm_PageActions');
    if PageControls = '' then
      PageControls := ChangeLanguage(ucEnglish, 'Const_Perm_PageControls');
    // by vicente barros leonel
    if BtUnlock = '' then
      BtUnlock := ChangeLanguage(ucEnglish, 'Const_Perm_BtLibera');
    if BtLock = '' then
      BtLock := ChangeLanguage(ucEnglish, 'Const_Perm_BtBloqueia');
    if BtSave = '' then
      BtSave := ChangeLanguage(ucEnglish, 'Const_Perm_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(ucEnglish, 'Const_Perm_BtCancelar');
  end;

  with DestSettings.ChangePassword do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_Troc_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(ucEnglish, 'Const_Troc_LabelDescricao');
    if LabelCurrentPassword = '' then
      LabelCurrentPassword :=
        ChangeLanguage(ucEnglish, 'Const_Troc_LabelSenhaAtual');
    if LabelNewPassword = '' then
      LabelNewPassword := ChangeLanguage(ucEnglish, 'Const_Troc_LabelNovaSenha');
    if LabelConfirm = '' then
      LabelConfirm := ChangeLanguage(ucEnglish, 'Const_Troc_LabelConfirma');
    if BtSave = '' then
      BtSave := ChangeLanguage(ucEnglish, 'Const_Troc_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(ucEnglish, 'Const_Troc_BtCancelar');
  end;

  with DestSettings.CommonMessages.ChangePasswordError do
  begin
    if InvalidCurrentPassword = '' then
      InvalidCurrentPassword :=
        ChangeLanguage(ucEnglish, 'Const_ErrPass_SenhaAtualInvalida');
    if NewPasswordError = '' then
      NewPasswordError := ChangeLanguage(ucEnglish,
        'Const_ErrPass_ErroNovaSenha');
    if NewEqualCurrent = '' then
      NewEqualCurrent := ChangeLanguage(ucEnglish,
        'Const_ErrPass_NovaIgualAtual');
    if PasswordRequired = '' then
      PasswordRequired := ChangeLanguage(ucEnglish,
        'Const_ErrPass_SenhaObrigatoria');
    if MinPasswordLength = '' then
      MinPasswordLength := ChangeLanguage(ucEnglish, 'Const_ErrPass_SenhaMinima');
    if InvalidNewPassword = '' then
      InvalidNewPassword := ChangeLanguage(ucEnglish,
        'Const_ErrPass_SenhaInvalida');
  end;

  with DestSettings.ResetPassword do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_DefPass_WindowCaption');
    if LabelPassword = '' then
      LabelPassword := ChangeLanguage(ucEnglish, 'Const_DefPass_LabelSenha');
  end;

  with DestSettings.Log do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(ucEnglish, 'Const_LogC_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(ucEnglish, 'Const_LogC_LabelDescricao');
    if LabelUser = '' then
      LabelUser := ChangeLanguage(ucEnglish, 'Const_LogC_LabelUsuario');
    if LabelDate = '' then
      LabelDate := ChangeLanguage(ucEnglish, 'Const_LogC_LabelData');
    if LabelLevel = '' then
      LabelLevel := ChangeLanguage(ucEnglish, 'Const_LogC_LabelNivel');
    if ColLevel = '' then
      ColLevel := ChangeLanguage(ucEnglish, 'Const_LogC_ColunaNivel');
    if ColAppID = '' then
      ColAppID := ChangeLanguage(ucEnglish, 'Const_LogC_ColunaAppID');
    if ColMessage = '' then
      ColMessage := ChangeLanguage(ucEnglish, 'Const_LogC_ColunaMensagem');
    if ColUser = '' then
      ColUser := ChangeLanguage(ucEnglish, 'Const_LogC_ColunaUsuario');
    if ColDate = '' then
      ColDate := ChangeLanguage(ucEnglish, 'Const_LogC_ColunaData');
    if BtFilter = '' then
      BtFilter := ChangeLanguage(ucEnglish, 'Const_LogC_BtFiltro');
    if BtDelete = '' then
      BtDelete := ChangeLanguage(ucEnglish, 'Const_LogC_BtExcluir');
    if BtClose = '' then
      BtClose := ChangeLanguage(ucEnglish, 'Const_LogC_BtFechar');
    if PromptDelete = '' then
      PromptDelete := ChangeLanguage(ucEnglish, 'Const_LogC_ConfirmaExcluir');
    if PromptDelete_WindowCaption = '' then
      PromptDelete_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_LogC_ConfirmaDelete_WindowCaption');
    // added by fduenas
    if OptionUserAll = '' then
      OptionUserAll := ChangeLanguage(ucEnglish, 'Const_LogC_Todos');
    // added by fduenas
    if OptionLevelLow = '' then
      OptionLevelLow := ChangeLanguage(ucEnglish, 'Const_LogC_Low');
    // added by fduenas
    if OptionLevelNormal = '' then
      OptionLevelNormal := ChangeLanguage(ucEnglish, 'Const_LogC_Normal');
    // added by fduenas
    if OptionLevelHigh = '' then
      OptionLevelHigh := ChangeLanguage(ucEnglish, 'Const_LogC_High');
    // added by fduenas
    if OptionLevelCritic = '' then
      OptionLevelCritic := ChangeLanguage(ucEnglish, 'Const_LogC_Critic');
    // added by fduenas
    if DeletePerformed = '' then
      DeletePerformed := ChangeLanguage(ucEnglish, 'Const_LogC_ExcluirEfectuada');
    // added by fduenas
  end;

  with DestSettings.AppMessages do
  begin
    if MsgsForm_BtNew = '' then
      MsgsForm_BtNew := ChangeLanguage(ucEnglish, 'Const_Msgs_BtNew');
    if MsgsForm_BtReplay = '' then
      MsgsForm_BtReplay := ChangeLanguage(ucEnglish, 'Const_Msgs_BtReplay');
    if MsgsForm_BtForward = '' then
      MsgsForm_BtForward := ChangeLanguage(ucEnglish, 'Const_Msgs_BtForward');
    if MsgsForm_BtDelete = '' then
      MsgsForm_BtDelete := ChangeLanguage(ucEnglish, 'Const_Msgs_BtDelete');
    if MsgsForm_BtClose = '' then
      MsgsForm_BtDelete := ChangeLanguage(ucEnglish, 'Const_Msgs_BtClose');
    // added by fduenas
    if MsgsForm_WindowCaption = '' then
      MsgsForm_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_Msgs_WindowCaption');
    if MsgsForm_ColFrom = '' then
      MsgsForm_ColFrom := ChangeLanguage(ucEnglish, 'Const_Msgs_ColFrom');
    if MsgsForm_ColSubject = '' then
      MsgsForm_ColSubject := ChangeLanguage(ucEnglish, 'Const_Msgs_ColSubject');
    if MsgsForm_ColDate = '' then
      MsgsForm_ColDate := ChangeLanguage(ucEnglish, 'Const_Msgs_ColDate');
    if MsgsForm_PromptDelete = '' then
      MsgsForm_PromptDelete :=
        ChangeLanguage(ucEnglish, 'Const_Msgs_PromptDelete');
    if MsgsForm_PromptDelete_WindowCaption = '' then
      MsgsForm_PromptDelete_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_Msgs_PromptDelete_WindowCaption');
    if MsgsForm_NoMessagesSelected = '' then
      MsgsForm_NoMessagesSelected :=
        ChangeLanguage(ucEnglish, 'Const_Msgs_NoMessagesSelected');
    if MsgsForm_NoMessagesSelected_WindowCaption = '' then
      MsgsForm_NoMessagesSelected_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_Msgs_NoMessagesSelected_WindowCaption');
    if MsgRec_BtClose = '' then
      MsgRec_BtClose := ChangeLanguage(ucEnglish, 'Const_MsgRec_BtClose');
    if MsgRec_WindowCaption = '' then
      MsgRec_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_MsgRec_WindowCaption');
    if MsgRec_Title = '' then
      MsgRec_Title := ChangeLanguage(ucEnglish, 'Const_MsgRec_Title');
    if MsgRec_LabelFrom = '' then
      MsgRec_LabelFrom := ChangeLanguage(ucEnglish, 'Const_MsgRec_LabelFrom');
    if MsgRec_LabelDate = '' then
      MsgRec_LabelDate := ChangeLanguage(ucEnglish, 'Const_MsgRec_LabelDate');
    if MsgRec_LabelSubject = '' then
      MsgRec_LabelSubject := ChangeLanguage(ucEnglish,
        'Const_MsgRec_LabelSubject');
    if MsgRec_LabelMessage = '' then
      MsgRec_LabelMessage := ChangeLanguage(ucEnglish,
        'Const_MsgRec_LabelMessage');
    if MsgSend_BtSend = '' then
      MsgSend_BtSend := ChangeLanguage(ucEnglish, 'Const_MsgSend_BtSend');
    if MsgSend_BtCancel = '' then
      MsgSend_BtCancel := ChangeLanguage(ucEnglish, 'Const_MsgSend_BtCancel');
    if MsgSend_WindowCaption = '' then
      MsgSend_WindowCaption :=
        ChangeLanguage(ucEnglish, 'Const_MsgSend_WindowCaption');
    if MsgSend_Title = '' then
      MsgSend_Title := ChangeLanguage(ucEnglish, 'Const_MsgSend_Title');
    if MsgSend_GroupTo = '' then
      MsgSend_GroupTo := ChangeLanguage(ucEnglish, 'Const_MsgSend_GroupTo');
    if MsgSend_RadioUser = '' then
      MsgSend_RadioUser := ChangeLanguage(ucEnglish, 'Const_MsgSend_RadioUser');
    if MsgSend_RadioAll = '' then
      MsgSend_RadioAll := ChangeLanguage(ucEnglish, 'Const_MsgSend_RadioAll');
    if MsgSend_GroupMessage = '' then
      MsgSend_GroupMessage :=
        ChangeLanguage(ucEnglish, 'Const_MsgSend_GroupMessage');
    if MsgSend_LabelSubject = '' then
      MsgSend_LabelSubject :=
        ChangeLanguage(ucEnglish, 'Const_MsgSend_LabelSubject'); // added by fduenas
    if MsgSend_LabelMessageText = '' then
      MsgSend_LabelMessageText :=
        ChangeLanguage(ucEnglish, 'Const_MsgSend_LabelMessageText'); // added by fduenas
  end;

  DestSettings.WindowsPosition := poMainFormCenter;
  { mudar aqui
    With DestSettings.TypeFieldsDB do
    Begin
    If Type_VarChar = '' then
    Type_VarChar   := 'VarChar';
    if Type_Char = '' then
    Type_Char      := 'Char';
    if Type_Int = '' then
    Type_Int       := 'Int';
    end; }

  with DestSettings.UsersLogged do
  begin
    if BtnMessage = '' then
      BtnMessage := ChangeLanguage(ucEnglish, 'Const_UserLogged_BtnMsg');
    if BtnRefresh = '' then
      BtnRefresh := ChangeLanguage(ucEnglish, 'Const_UserLogged_Refresh');
    if Btnclose = '' then
      Btnclose := ChangeLanguage(ucEnglish, 'Const_Msgs_BtClose');
    if LabelDescricao = '' then
      LabelDescricao := ChangeLanguage(ucEnglish,
        'Const_UserLogged_LabelDescricao');
    if LabelCaption = '' then
      LabelCaption := ChangeLanguage(ucEnglish, 'Const_UserLogged_LabelCaption');
    if ColName = '' then
      ColName := ChangeLanguage(ucEnglish, 'Const_Cad_ColunaNome');
    if ColLogin = '' then
      ColLogin := ChangeLanguage(ucEnglish, 'Const_Cad_ColunaLogin');
    if ColComputer = '' then
      ColComputer := ChangeLanguage(ucEnglish, 'Const_CadColuna_Computer');
    if ColData = '' then
      ColData := ChangeLanguage(ucEnglish, 'Const_CadColuna_Data');
    if InputCaption = '' then
      InputCaption := ChangeLanguage(ucEnglish, 'Const_UserLogged_InputCaption');
    if InputText = '' then
      InputText := ChangeLanguage(ucEnglish, 'Const_UserLogged_InputText');
    if MsgSystem = '' then
      MsgSystem := ChangeLanguage(ucEnglish, 'Const_UserLogged_MsgSystem');
  end;

end;

procedure IniSettings2(DestSettings: TUCSettings);
var
  tmp: TBitmap;
begin
  with DestSettings.CommonMessages do
  begin
    if BlankPassword = '' then
      BlankPassword := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_SenhaDesabitada');
    if PasswordChanged = '' then
      PasswordChanged := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_SenhaAlterada');
    if InitialMessage.Text = '' then
      InitialMessage.Text := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_MsgInicial');
    if MaxLoginAttemptsError = '' then
      MaxLoginAttemptsError :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_Men_MaxTentativas');
    if InvalidLogin = '' then
      InvalidLogin := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_LoginInvalido');
    if InactiveLogin = '' then
      InactiveLogin := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_LoginInativo');
    if AutoLogonError = '' then
      AutoLogonError := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_AutoLogonError');
    if UsuarioExiste = '' then
      UsuarioExiste := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_UsuarioExiste');
    if PasswordExpired = '' then
      PasswordExpired := ChangeLanguage(DestSettings.fLanguage,
        'Const_Men_PasswordExpired');
    if ForcaTrocaSenha = '' then
      ForcaTrocaSenha := ChangeLanguage(DestSettings.fLanguage,
        'Const_ErrPass_ForcaTrocaSenha');
  end;

  with DestSettings.Login do
  begin
    if BtCancel = '' then
      BtCancel := ChangeLanguage(DestSettings.fLanguage, 'Const_Log_BtCancelar');
    if BtOK = '' then
      BtOK := ChangeLanguage(DestSettings.fLanguage, 'Const_Log_BtOK');
    if LabelPassword = '' then
      LabelPassword := ChangeLanguage(DestSettings.fLanguage,
        'Const_Log_LabelSenha');
    if LabelUser = '' then
      LabelUser := ChangeLanguage(DestSettings.fLanguage,
        'Const_Log_LabelUsuario');
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_Log_WindowCaption');

    if LabelTentativa = '' then
      LabelTentativa := ChangeLanguage(DestSettings.fLanguage,
        'Const_Log_LabelTentativa');
    if LabelTentativas = '' then
      LabelTentativas := ChangeLanguage(DestSettings.fLanguage,
        'Const_Log_LabelTentativas');

    try
      tmp := TBitmap.Create;
      tmp.LoadFromResourceName(HInstance, 'UCLOCKLOGIN');
      LeftImage.Assign(tmp);
    finally
      FreeAndNil(tmp);
    end;
  end;

  with DestSettings.UsersForm do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_Cad_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(DestSettings.fLanguage,
        'Const_Cad_LabelDescricao');
    if ColName = '' then
      ColName := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_ColunaNome');
    if ColLogin = '' then
      ColLogin := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_ColunaLogin');
    if ColEmail = '' then
      ColEmail := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_ColunaEmail');
    if BtAdd = '' then
      BtAdd := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_BtAdicionar');
    if BtChange = '' then
      BtChange := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_BtAlterar');
    if BtDelete = '' then
      BtDelete := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_BtExcluir');
    if BtRights = '' then
      BtRights := ChangeLanguage(DestSettings.fLanguage,
        'Const_Cad_BtPermissoes');
    if BtPassword = '' then
      BtPassword := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_BtSenha');
    if BtClose = '' then
      BtClose := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_BtFechar');
    if PromptDelete = '' then
      PromptDelete := ChangeLanguage(DestSettings.fLanguage,
        'Const_Cad_ConfirmaExcluir');
    if PromptDelete_WindowCaption = '' then
      PromptDelete_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_ConfirmaDelete_WindowCaption');
  end;

  with DestSettings.UsersProfile do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_Prof_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(DestSettings.fLanguage,
        'Const_Prof_LabelDescricao');
    if ColProfile = '' then
      ColProfile := ChangeLanguage(DestSettings.fLanguage,
        'Const_Prof_ColunaNome');
    if BtAdd = '' then
      BtAdd := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtAdicionar');
    if BtChange = '' then
      BtChange := ChangeLanguage(DestSettings.fLanguage, 'Const_Prof_BtAlterar');
    if BtDelete = '' then
      BtDelete := ChangeLanguage(DestSettings.fLanguage, 'Const_Prof_BtExcluir');
    if BtRights = '' then
      BtRights := ChangeLanguage(DestSettings.fLanguage,
        'Const_Prof_BtPermissoes');
    if BtClose = '' then
      BtClose := ChangeLanguage(DestSettings.fLanguage, 'Const_Prof_BtFechar');
    if PromptDelete = '' then
      PromptDelete := ChangeLanguage(DestSettings.fLanguage,
        'Const_Prof_ConfirmaExcluir');
    if PromptDelete_WindowCaption = '' then
      PromptDelete_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage,
        'Const_Prof_ConfirmaDelete_WindowCaption');
    // added by fduenas
  end;

  with DestSettings.AddChangeUser do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_WindowCaption');
    if LabelAdd = '' then
      LabelAdd := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_LabelAdicionar');
    if LabelChange = '' then
      LabelChange := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_LabelAlterar');
    if LabelName = '' then
      LabelName := ChangeLanguage(DestSettings.fLanguage, 'Const_Inc_LabelNome');
    if LabelLogin = '' then
      LabelLogin := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_LabelLogin');
    if LabelEmail = '' then
      LabelEmail := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_LabelEmail');
    if CheckPrivileged = '' then
      CheckPrivileged := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_CheckPrivilegiado');
    if BtSave = '' then
      BtSave := ChangeLanguage(DestSettings.fLanguage, 'Const_Inc_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(DestSettings.fLanguage, 'Const_Inc_BtCancelar');
    if LabelPerfil = '' then
      LabelPerfil := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_LabelPerfil');

    if CheckExpira = '' then
      CheckExpira := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_CheckEspira');
    if Day = '' then
      Day := ChangeLanguage(DestSettings.fLanguage, 'Const_Inc_Dia');
    if ExpiredIn = '' then
      ExpiredIn := ChangeLanguage(DestSettings.fLanguage, 'Const_Inc_ExpiraEm');
    if LabelStatus = '' then
      LabelStatus := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_LabelStatus');
    if StatusActive = '' then
      StatusActive := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_StatusActive');

    if StatusDisabled = '' then
      StatusDisabled := ChangeLanguage(DestSettings.fLanguage,
        'Const_Inc_StatusDisabled');

  end;

  with DestSettings.AddChangeProfile do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_PInc_WindowCaption');
    if LabelAdd = '' then
      LabelAdd := ChangeLanguage(DestSettings.fLanguage,
        'Const_PInc_LabelAdicionar');
    if LabelChange = '' then
      LabelChange := ChangeLanguage(DestSettings.fLanguage,
        'Const_PInc_LabelAlterar');
    if LabelName = '' then
      LabelName := ChangeLanguage(DestSettings.fLanguage, 'Const_PInc_LabelNome');
    if BtSave = '' then
      BtSave := ChangeLanguage(DestSettings.fLanguage, 'Const_PInc_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(DestSettings.fLanguage, 'Const_PInc_BtCancelar');
  end;

  with DestSettings.Rights do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_Perm_WindowCaption');
    if LabelUser = '' then
      LabelUser := ChangeLanguage(DestSettings.fLanguage,
        'Const_Perm_LabelUsuario');
    if LabelProfile = '' then
      LabelProfile := ChangeLanguage(DestSettings.fLanguage,
        'Const_Perm_LabelPerfil');
    if PageMenu = '' then
      PageMenu := ChangeLanguage(DestSettings.fLanguage, 'Const_Perm_PageMenu');
    if PageActions = '' then
      PageActions := ChangeLanguage(DestSettings.fLanguage,
        'Const_Perm_PageActions');
    if PageControls = '' then
      PageControls := ChangeLanguage(DestSettings.fLanguage,
        'Const_Perm_PageControls'); // by vicente barros leonel
    if BtUnlock = '' then
      BtUnlock := ChangeLanguage(DestSettings.fLanguage, 'Const_Perm_BtLibera');
    if BtLock = '' then
      BtLock := ChangeLanguage(DestSettings.fLanguage, 'Const_Perm_BtBloqueia');
    if BtSave = '' then
      BtSave := ChangeLanguage(DestSettings.fLanguage, 'Const_Perm_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(DestSettings.fLanguage, 'Const_Perm_BtCancelar');
  end;

  with DestSettings.ChangePassword do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_Troc_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(DestSettings.fLanguage,
        'Const_Troc_LabelDescricao');
    if LabelCurrentPassword = '' then
      LabelCurrentPassword := ChangeLanguage(DestSettings.fLanguage,
        'Const_Troc_LabelSenhaAtual');
    if LabelNewPassword = '' then
      LabelNewPassword := ChangeLanguage(DestSettings.fLanguage,
        'Const_Troc_LabelNovaSenha');
    if LabelConfirm = '' then
      LabelConfirm := ChangeLanguage(DestSettings.fLanguage,
        'Const_Troc_LabelConfirma');
    if BtSave = '' then
      BtSave := ChangeLanguage(DestSettings.fLanguage, 'Const_Troc_BtGravar');
    if BtCancel = '' then
      BtCancel := ChangeLanguage(DestSettings.fLanguage, 'Const_Troc_BtCancelar');
  end;

  with DestSettings.CommonMessages.ChangePasswordError do
  begin
    if InvalidCurrentPassword = '' then
      InvalidCurrentPassword :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_ErrPass_SenhaAtualInvalida');
    if NewPasswordError = '' then
      NewPasswordError := ChangeLanguage(DestSettings.fLanguage,
        'Const_ErrPass_ErroNovaSenha');
    if NewEqualCurrent = '' then
      NewEqualCurrent := ChangeLanguage(DestSettings.fLanguage,
        'Const_ErrPass_NovaIgualAtual');
    if PasswordRequired = '' then
      PasswordRequired := ChangeLanguage(DestSettings.fLanguage,
        'Const_ErrPass_SenhaObrigatoria');
    if MinPasswordLength = '' then
      MinPasswordLength := ChangeLanguage(DestSettings.fLanguage,
        'Const_ErrPass_SenhaMinima');
    if InvalidNewPassword = '' then
      InvalidNewPassword := ChangeLanguage(DestSettings.fLanguage,
        'Const_ErrPass_SenhaInvalida');
  end;

  with DestSettings.ResetPassword do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_DefPass_WindowCaption');
    if LabelPassword = '' then
      LabelPassword := ChangeLanguage(DestSettings.fLanguage,
        'Const_DefPass_LabelSenha');
  end;

  with DestSettings.Log do
  begin
    if WindowCaption = '' then
      WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_WindowCaption');
    if LabelDescription = '' then
      LabelDescription := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_LabelDescricao');
    if LabelUser = '' then
      LabelUser := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_LabelUsuario');
    if LabelDate = '' then
      LabelDate := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_LabelData');
    if LabelLevel = '' then
      LabelLevel := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_LabelNivel');
    if ColLevel = '' then
      ColLevel := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ColunaNivel');
    if ColAppID = '' then
      ColAppID := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ColunaAppID');
    if ColMessage = '' then
      ColMessage := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ColunaMensagem');
    if ColUser = '' then
      ColUser := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ColunaUsuario');
    if ColDate = '' then
      ColDate := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_ColunaData');
    if BtFilter = '' then
      BtFilter := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_BtFiltro');
    if BtDelete = '' then
      BtDelete := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_BtExcluir');
    if BtClose = '' then
      BtClose := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_BtFechar');
    if PromptDelete = '' then
      PromptDelete := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ConfirmaExcluir');
    if PromptDelete_WindowCaption = '' then
      PromptDelete_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ConfirmaDelete_WindowCaption');
    // added by fduenas
    if OptionUserAll = '' then
      OptionUserAll := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_Todos');
    // added by fduenas
    if OptionLevelLow = '' then
      OptionLevelLow := ChangeLanguage(DestSettings.fLanguage, 'Const_LogC_Low');
    // added by fduenas
    if OptionLevelNormal = '' then
      OptionLevelNormal := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_Normal'); // added by fduenas
    if OptionLevelHigh = '' then
      OptionLevelHigh := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_High');
    // added by fduenas
    if OptionLevelCritic = '' then
      OptionLevelCritic := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_Critic'); // added by fduenas
    if DeletePerformed = '' then
      DeletePerformed := ChangeLanguage(DestSettings.fLanguage,
        'Const_LogC_ExcluirEfectuada'); // added by fduenas
  end;

  with DestSettings.AppMessages do
  begin
    if MsgsForm_BtNew = '' then
      MsgsForm_BtNew := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_BtNew');
    if MsgsForm_BtReplay = '' then
      MsgsForm_BtReplay := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_BtReplay');
    if MsgsForm_BtForward = '' then
      MsgsForm_BtForward := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_BtForward');
    if MsgsForm_BtDelete = '' then
      MsgsForm_BtDelete := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_BtDelete');
    if MsgsForm_BtClose = '' then
      MsgsForm_BtClose := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_BtClose'); // added by fduenas
    if MsgsForm_WindowCaption = '' then
      MsgsForm_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_Msgs_WindowCaption');
    if MsgsForm_ColFrom = '' then
      MsgsForm_ColFrom := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_ColFrom');
    if MsgsForm_ColSubject = '' then
      MsgsForm_ColSubject := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_ColSubject');
    if MsgsForm_ColDate = '' then
      MsgsForm_ColDate := ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_ColDate');
    if MsgsForm_PromptDelete = '' then
      MsgsForm_PromptDelete :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_Msgs_PromptDelete');
    if MsgsForm_PromptDelete_WindowCaption = '' then
      MsgsForm_PromptDelete_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_PromptDelete_WindowCaption'); // added by fduenas
    if MsgsForm_NoMessagesSelected = '' then
      MsgsForm_NoMessagesSelected :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_Msgs_NoMessagesSelected');
    // added by fduenas
    if MsgsForm_NoMessagesSelected_WindowCaption = '' then
      MsgsForm_NoMessagesSelected_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage,
        'Const_Msgs_NoMessagesSelected_WindowCaption'); // added by fduenas
    if MsgRec_BtClose = '' then
      MsgRec_BtClose := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_BtClose');
    if MsgRec_WindowCaption = '' then
      MsgRec_WindowCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_WindowCaption');
    if MsgRec_Title = '' then
      MsgRec_Title := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_Title');
    if MsgRec_LabelFrom = '' then
      MsgRec_LabelFrom := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_LabelFrom');
    if MsgRec_LabelDate = '' then
      MsgRec_LabelDate := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_LabelDate');
    if MsgRec_LabelSubject = '' then
      MsgRec_LabelSubject := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_LabelSubject');
    if MsgRec_LabelMessage = '' then
      MsgRec_LabelMessage := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgRec_LabelMessage');
    if MsgSend_BtSend = '' then
      MsgSend_BtSend := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_BtSend');
    if MsgSend_BtCancel = '' then
      MsgSend_BtCancel := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_BtCancel');
    if MsgSend_WindowCaption = '' then
      MsgSend_WindowCaption :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_MsgSend_WindowCaption');
    if MsgSend_Title = '' then
      MsgSend_Title := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_Title');
    if MsgSend_GroupTo = '' then
      MsgSend_GroupTo := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_GroupTo');
    if MsgSend_RadioUser = '' then
      MsgSend_RadioUser := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_RadioUser');
    if MsgSend_RadioAll = '' then
      MsgSend_RadioAll := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_RadioAll');
    if MsgSend_GroupMessage = '' then
      MsgSend_GroupMessage := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_GroupMessage');
    if MsgSend_LabelSubject = '' then
      MsgSend_LabelSubject := ChangeLanguage(DestSettings.fLanguage,
        'Const_MsgSend_LabelSubject'); // added by fduenas
    if MsgSend_LabelMessageText = '' then
      MsgSend_LabelMessageText :=
        ChangeLanguage(DestSettings.fLanguage, 'Const_MsgSend_LabelMessageText');
    // added by fduenas
  end;

  DestSettings.WindowsPosition := poMainFormCenter;

  { With DestSettings.TypeFieldsDB do
    Begin
    If Type_VarChar = '' then
    Type_VarChar   := 'VarChar';
    if Type_Char = '' then
    Type_Char      := 'Char';
    if Type_Int = '' then
    Type_Int       := 'Int';
    end;   mudar aqui }

  with DestSettings.UsersLogged do
  begin
    if BtnMessage = '' then
      BtnMessage := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_BtnMsg');
    if BtnRefresh = '' then
      BtnRefresh := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_Refresh');
    if Btnclose = '' then
      Btnclose := ChangeLanguage(DestSettings.fLanguage, 'Const_Msgs_BtClose');
    if LabelDescricao = '' then
      LabelDescricao := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_LabelDescricao');
    if LabelCaption = '' then
      LabelCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_LabelCaption');
    if ColName = '' then
      ColName := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_ColunaNome');
    if ColLogin = '' then
      ColLogin := ChangeLanguage(DestSettings.fLanguage, 'Const_Cad_ColunaLogin');
    if ColComputer = '' then
      ColComputer := ChangeLanguage(DestSettings.fLanguage,
        'Const_CadColuna_Computer');
    if ColData = '' then
      ColData := ChangeLanguage(DestSettings.fLanguage, 'Const_CadColuna_Data');
    if InputCaption = '' then
      InputCaption := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_InputCaption');
    if InputText = '' then
      InputText := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_InputText');
    if MsgSystem = '' then
      MsgSystem := ChangeLanguage(DestSettings.fLanguage,
        'Const_UserLogged_MsgSystem');
  end;
end;

{ ------------------------------------------------------------------------------- }

procedure AlterLanguage(DestSettings: TUCUserSettings);
begin
  with DestSettings.CommonMessages do
  begin
    BlankPassword := ChangeLanguage(DestSettings.Language,
      'Const_Men_SenhaDesabitada');
    PasswordChanged := ChangeLanguage(DestSettings.Language,
      'Const_Men_SenhaAlterada');
    InitialMessage.Text := ChangeLanguage(DestSettings.Language,
      'Const_Men_MsgInicial');
    MaxLoginAttemptsError := ChangeLanguage(DestSettings.Language,
      'Const_Men_MaxTentativas');
    InvalidLogin := ChangeLanguage(DestSettings.Language,
      'Const_Men_LoginInvalido');
    InactiveLogin := ChangeLanguage(DestSettings.Language,
      'Const_Men_LoginInativo');
    AutoLogonError := ChangeLanguage(DestSettings.Language,
      'Const_Men_AutoLogonError');
    UsuarioExiste := ChangeLanguage(DestSettings.Language,
      'Const_Men_UsuarioExiste');
    PasswordExpired := ChangeLanguage(DestSettings.Language,
      'Const_Men_PasswordExpired');
  end;

  with DestSettings.Login do
  begin
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Log_BtCancelar');
    BtOK := ChangeLanguage(DestSettings.Language, 'Const_Log_BtOK');
    LabelPassword := ChangeLanguage(DestSettings.Language, 'Const_Log_LabelSenha');
    LabelUser := ChangeLanguage(DestSettings.Language, 'Const_Log_LabelUsuario');
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Log_WindowCaption');
    LabelTentativa := ChangeLanguage(DestSettings.Language,
      'Const_Log_LabelTentativa');
    LabelTentativas := ChangeLanguage(DestSettings.Language,
      'Const_Log_LabelTentativas');
  end;

  with DestSettings.UsersForm do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Cad_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_Cad_LabelDescricao');
    ColName := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaNome');
    ColLogin := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaLogin');
    ColEmail := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaEmail');
    BtAdd := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtAdicionar');
    BtChange := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtAlterar');
    BtDelete := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtExcluir');
    BtRights := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtPermissoes');
    BtPassword := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtSenha');
    BtClose := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtFechar');
    PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_Cad_ConfirmaExcluir');
    PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_Cad_ConfirmaDelete_WindowCaption');
  end;

  with DestSettings.UsersProfile do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Prof_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_Prof_LabelDescricao');
    ColProfile := ChangeLanguage(DestSettings.Language, 'Const_Prof_ColunaNome');
    BtAdd := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtAdicionar');
    BtChange := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtAlterar');
    BtDelete := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtExcluir');
    BtRights := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtPermissoes');
    BtClose := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtFechar');
    PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_Prof_ConfirmaExcluir');
    PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_Prof_ConfirmaDelete_WindowCaption');
  end;

  with DestSettings.AddChangeUser do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Inc_WindowCaption');
    LabelAdd := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelAdicionar');
    LabelChange := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelAlterar');
    LabelName := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelNome');
    LabelLogin := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelLogin');
    LabelEmail := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelEmail');
    CheckPrivileged := ChangeLanguage(DestSettings.Language,
      'Const_Inc_CheckPrivilegiado');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_Inc_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Inc_BtCancelar');
    LabelPerfil := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelPerfil');
    CheckExpira := ChangeLanguage(DestSettings.Language, 'Const_Inc_CheckEspira');
    Day := ChangeLanguage(DestSettings.Language, 'Const_Inc_Dia');
    ExpiredIn := ChangeLanguage(DestSettings.Language, 'Const_Inc_ExpiraEm');
    LabelStatus := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelStatus');
    StatusActive := ChangeLanguage(DestSettings.Language, 'Const_Inc_StatusActive');
    StatusDisabled := ChangeLanguage(DestSettings.Language,
      'Const_Inc_StatusDisabled');
  end;

  with DestSettings.AddChangeProfile do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_PInc_WindowCaption');
    LabelAdd := ChangeLanguage(DestSettings.Language, 'Const_PInc_LabelAdicionar');
    LabelChange := ChangeLanguage(DestSettings.Language, 'Const_PInc_LabelAlterar');
    LabelName := ChangeLanguage(DestSettings.Language, 'Const_PInc_LabelNome');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_PInc_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_PInc_BtCancelar');
  end;

  with DestSettings.Rights do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Perm_WindowCaption');
    LabelUser := ChangeLanguage(DestSettings.Language, 'Const_Perm_LabelUsuario');
    LabelProfile := ChangeLanguage(DestSettings.Language, 'Const_Perm_LabelPerfil');
    PageMenu := ChangeLanguage(DestSettings.Language, 'Const_Perm_PageMenu');
    PageActions := ChangeLanguage(DestSettings.Language, 'Const_Perm_PageActions');
    PageControls := ChangeLanguage(DestSettings.Language,
      'Const_Perm_PageControls');
    BtUnlock := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtLibera');
    BtLock := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtBloqueia');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtCancelar');
  end;

  with DestSettings.ChangePassword do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Troc_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelDescricao');
    LabelCurrentPassword := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelSenhaAtual');
    LabelNewPassword := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelNovaSenha');
    LabelConfirm := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelConfirma');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_Troc_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Troc_BtCancelar');
  end;

  with DestSettings.CommonMessages.ChangePasswordError do
  begin
    InvalidCurrentPassword := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaAtualInvalida');
    NewPasswordError := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_ErroNovaSenha');
    NewEqualCurrent := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_NovaIgualAtual');
    PasswordRequired := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaObrigatoria');
    MinPasswordLength := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaMinima');
    InvalidNewPassword := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaInvalida');
  end;

  with DestSettings.ResetPassword do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_DefPass_WindowCaption');
    LabelPassword := ChangeLanguage(DestSettings.Language,
      'Const_DefPass_LabelSenha');
  end;

  with DestSettings.Log do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_LogC_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_LogC_LabelDescricao');
    LabelUser := ChangeLanguage(DestSettings.Language, 'Const_LogC_LabelUsuario');
    LabelDate := ChangeLanguage(DestSettings.Language, 'Const_LogC_LabelData');
    LabelLevel := ChangeLanguage(DestSettings.Language, 'Const_LogC_LabelNivel');
    ColLevel := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaNivel');
    ColAppID := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaAppID');
    ColMessage := ChangeLanguage(DestSettings.Language,
      'Const_LogC_ColunaMensagem');
    ColUser := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaUsuario');
    ColDate := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaData');
    BtFilter := ChangeLanguage(DestSettings.Language, 'Const_LogC_BtFiltro');
    BtDelete := ChangeLanguage(DestSettings.Language, 'Const_LogC_BtExcluir');
    BtClose := ChangeLanguage(DestSettings.Language, 'Const_LogC_BtFechar');
    PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_LogC_ConfirmaExcluir');
    PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_LogC_ConfirmaDelete_WindowCaption');
    OptionUserAll := ChangeLanguage(DestSettings.Language, 'Const_LogC_Todos');
    OptionLevelLow := ChangeLanguage(DestSettings.Language, 'Const_LogC_Low');
    OptionLevelNormal := ChangeLanguage(DestSettings.Language, 'Const_LogC_Normal');
    OptionLevelHigh := ChangeLanguage(DestSettings.Language, 'Const_LogC_High');
    OptionLevelCritic := ChangeLanguage(DestSettings.Language, 'Const_LogC_Critic');
    DeletePerformed := ChangeLanguage(DestSettings.Language,
      'Const_LogC_ExcluirEfectuada');
  end;

  with DestSettings.AppMessages do
  begin
    MsgsForm_BtNew := ChangeLanguage(DestSettings.Language, 'Const_Msgs_BtNew');
    MsgsForm_BtReplay := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_BtReplay');
    MsgsForm_BtForward := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_BtForward');
    MsgsForm_BtDelete := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_BtDelete');
    MsgsForm_BtClose := ChangeLanguage(DestSettings.Language, 'Const_Msgs_BtClose');
    // added by fduenas
    MsgsForm_WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_WindowCaption');
    MsgsForm_ColFrom := ChangeLanguage(DestSettings.Language, 'Const_Msgs_ColFrom');
    MsgsForm_ColSubject := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_ColSubject');
    MsgsForm_ColDate := ChangeLanguage(DestSettings.Language, 'Const_Msgs_ColDate');
    MsgsForm_PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_PromptDelete');
    MsgsForm_PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_Msgs_PromptDelete_WindowCaption');
    // added by fduenas
    MsgsForm_NoMessagesSelected :=
      ChangeLanguage(DestSettings.Language, 'Const_Msgs_NoMessagesSelected');
    // added by fduenas
    MsgsForm_NoMessagesSelected_WindowCaption :=
      ChangeLanguage(DestSettings.Language,
      'Const_Msgs_NoMessagesSelected_WindowCaption'); // added by fduenas
    MsgRec_BtClose := ChangeLanguage(DestSettings.Language, 'Const_MsgRec_BtClose');
    MsgRec_WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_WindowCaption');
    MsgRec_Title := ChangeLanguage(DestSettings.Language, 'Const_MsgRec_Title');
    MsgRec_LabelFrom := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelFrom');
    MsgRec_LabelDate := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelDate');
    MsgRec_LabelSubject := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelSubject');
    MsgRec_LabelMessage := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelMessage');
    MsgSend_BtSend := ChangeLanguage(DestSettings.Language, 'Const_MsgSend_BtSend');
    MsgSend_BtCancel := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_BtCancel');
    MsgSend_WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_WindowCaption');
    MsgSend_Title := ChangeLanguage(DestSettings.Language, 'Const_MsgSend_Title');
    MsgSend_GroupTo := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_GroupTo');
    MsgSend_RadioUser := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_RadioUser');
    MsgSend_RadioAll := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_RadioAll');
    MsgSend_GroupMessage := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_GroupMessage');
    MsgSend_LabelSubject := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_LabelSubject'); // added by fduenas
    MsgSend_LabelMessageText :=
      ChangeLanguage(DestSettings.Language, 'Const_MsgSend_LabelMessageText');
    // added by fduenas
  end;

  DestSettings.WindowsPosition := poMainFormCenter;

  with DestSettings.UsersLogged do
  begin
    BtnMessage := ChangeLanguage(DestSettings.Language, 'Const_UserLogged_BtnMsg');
    BtnRefresh := ChangeLanguage(DestSettings.Language, 'Const_UserLogged_Refresh');
    Btnclose := ChangeLanguage(DestSettings.Language, 'Const_Msgs_BtClose');
    LabelDescricao := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_LabelDescricao');
    LabelCaption := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_LabelCaption');
    ColName := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaNome');
    ColLogin := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaLogin');
    ColComputer := ChangeLanguage(DestSettings.Language,
      'Const_CadColuna_Computer');
    ColData := ChangeLanguage(DestSettings.Language, 'Const_CadColuna_Data');
    InputCaption := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_InputCaption');
    InputText := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_InputText');
    MsgSystem := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_MsgSystem');
  end;
end;

procedure AlterLanguage2(DestSettings: TUCSettings);
begin
  with DestSettings.CommonMessages do
  begin
    BlankPassword := ChangeLanguage(DestSettings.Language,
      'Const_Men_SenhaDesabitada');
    PasswordChanged := ChangeLanguage(DestSettings.Language,
      'Const_Men_SenhaAlterada');
    InitialMessage.Text := ChangeLanguage(DestSettings.Language,
      'Const_Men_MsgInicial');
    MaxLoginAttemptsError := ChangeLanguage(DestSettings.Language,
      'Const_Men_MaxTentativas');
    InvalidLogin := ChangeLanguage(DestSettings.Language,
      'Const_Men_LoginInvalido');
    InactiveLogin := ChangeLanguage(DestSettings.fLanguage,
      'Const_Men_LoginInativo');
    AutoLogonError := ChangeLanguage(DestSettings.Language,
      'Const_Men_AutoLogonError');
    UsuarioExiste := ChangeLanguage(DestSettings.Language,
      'Const_Men_UsuarioExiste');
    PasswordExpired := ChangeLanguage(DestSettings.Language,
      'Const_Men_PasswordExpired');
  end;

  with DestSettings.Login do
  begin
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Log_BtCancelar');
    BtOK := ChangeLanguage(DestSettings.Language, 'Const_Log_BtOK');
    LabelPassword := ChangeLanguage(DestSettings.Language, 'Const_Log_LabelSenha');
    LabelUser := ChangeLanguage(DestSettings.Language, 'Const_Log_LabelUsuario');
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Log_WindowCaption');
    LabelTentativa := ChangeLanguage(DestSettings.Language,
      'Const_Log_LabelTentativa');
    LabelTentativas := ChangeLanguage(DestSettings.Language,
      'Const_Log_LabelTentativas');
  end;

  with DestSettings.UsersForm do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Cad_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_Cad_LabelDescricao');
    ColName := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaNome');
    ColLogin := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaLogin');
    ColEmail := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaEmail');
    BtAdd := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtAdicionar');
    BtChange := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtAlterar');
    BtDelete := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtExcluir');
    BtRights := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtPermissoes');
    BtPassword := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtSenha');
    BtClose := ChangeLanguage(DestSettings.Language, 'Const_Cad_BtFechar');
    PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_Cad_ConfirmaExcluir');
    PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_Cad_ConfirmaDelete_WindowCaption');
  end;

  with DestSettings.UsersProfile do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Prof_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_Prof_LabelDescricao');
    ColProfile := ChangeLanguage(DestSettings.Language, 'Const_Prof_ColunaNome');
    BtAdd := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtAdicionar');
    BtChange := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtAlterar');
    BtDelete := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtExcluir');
    BtRights := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtPermissoes');
    BtClose := ChangeLanguage(DestSettings.Language, 'Const_Prof_BtFechar');
    PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_Prof_ConfirmaExcluir');
    PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_Prof_ConfirmaDelete_WindowCaption');
  end;

  with DestSettings.AddChangeUser do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Inc_WindowCaption');
    LabelAdd := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelAdicionar');
    LabelChange := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelAlterar');
    LabelName := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelNome');
    LabelLogin := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelLogin');
    LabelEmail := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelEmail');
    CheckPrivileged := ChangeLanguage(DestSettings.Language,
      'Const_Inc_CheckPrivilegiado');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_Inc_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Inc_BtCancelar');
    LabelPerfil := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelPerfil');
    CheckExpira := ChangeLanguage(DestSettings.Language, 'Const_Inc_CheckEspira');
    Day := ChangeLanguage(DestSettings.Language, 'Const_Inc_Dia');
    ExpiredIn := ChangeLanguage(DestSettings.Language, 'Const_Inc_ExpiraEm');
    LabelStatus := ChangeLanguage(DestSettings.Language, 'Const_Inc_LabelStatus');
    StatusActive := ChangeLanguage(DestSettings.Language, 'Const_Inc_StatusActive');
    StatusDisabled := ChangeLanguage(DestSettings.Language,
      'Const_Inc_StatusDisabled');
  end;

  with DestSettings.AddChangeProfile do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_PInc_WindowCaption');
    LabelAdd := ChangeLanguage(DestSettings.Language, 'Const_PInc_LabelAdicionar');
    LabelChange := ChangeLanguage(DestSettings.Language, 'Const_PInc_LabelAlterar');
    LabelName := ChangeLanguage(DestSettings.Language, 'Const_PInc_LabelNome');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_PInc_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_PInc_BtCancelar');
  end;

  with DestSettings.Rights do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Perm_WindowCaption');
    LabelUser := ChangeLanguage(DestSettings.Language, 'Const_Perm_LabelUsuario');
    LabelProfile := ChangeLanguage(DestSettings.Language, 'Const_Perm_LabelPerfil');
    PageMenu := ChangeLanguage(DestSettings.Language, 'Const_Perm_PageMenu');
    PageActions := ChangeLanguage(DestSettings.Language, 'Const_Perm_PageActions');
    PageControls := ChangeLanguage(DestSettings.Language,
      'Const_Perm_PageControls');
    BtUnlock := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtLibera');
    BtLock := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtBloqueia');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Perm_BtCancelar');
  end;

  with DestSettings.ChangePassword do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Troc_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelDescricao');
    LabelCurrentPassword := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelSenhaAtual');
    LabelNewPassword := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelNovaSenha');
    LabelConfirm := ChangeLanguage(DestSettings.Language,
      'Const_Troc_LabelConfirma');
    BtSave := ChangeLanguage(DestSettings.Language, 'Const_Troc_BtGravar');
    BtCancel := ChangeLanguage(DestSettings.Language, 'Const_Troc_BtCancelar');
  end;

  with DestSettings.CommonMessages.ChangePasswordError do
  begin
    InvalidCurrentPassword := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaAtualInvalida');
    NewPasswordError := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_ErroNovaSenha');
    NewEqualCurrent := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_NovaIgualAtual');
    PasswordRequired := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaObrigatoria');
    MinPasswordLength := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaMinima');
    InvalidNewPassword := ChangeLanguage(DestSettings.Language,
      'Const_ErrPass_SenhaInvalida');
  end;

  with DestSettings.ResetPassword do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_DefPass_WindowCaption');
    LabelPassword := ChangeLanguage(DestSettings.Language,
      'Const_DefPass_LabelSenha');
  end;

  with DestSettings.Log do
  begin
    WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_LogC_WindowCaption');
    LabelDescription := ChangeLanguage(DestSettings.Language,
      'Const_LogC_LabelDescricao');
    LabelUser := ChangeLanguage(DestSettings.Language, 'Const_LogC_LabelUsuario');
    LabelDate := ChangeLanguage(DestSettings.Language, 'Const_LogC_LabelData');
    LabelLevel := ChangeLanguage(DestSettings.Language, 'Const_LogC_LabelNivel');
    ColLevel := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaNivel');
    ColAppID := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaAppID');
    ColMessage := ChangeLanguage(DestSettings.Language,
      'Const_LogC_ColunaMensagem');
    ColUser := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaUsuario');
    ColDate := ChangeLanguage(DestSettings.Language, 'Const_LogC_ColunaData');
    BtFilter := ChangeLanguage(DestSettings.Language, 'Const_LogC_BtFiltro');
    BtDelete := ChangeLanguage(DestSettings.Language, 'Const_LogC_BtExcluir');
    BtClose := ChangeLanguage(DestSettings.Language, 'Const_LogC_BtFechar');
    PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_LogC_ConfirmaExcluir');
    PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_LogC_ConfirmaDelete_WindowCaption');
    OptionUserAll := ChangeLanguage(DestSettings.Language, 'Const_LogC_Todos');
    OptionLevelLow := ChangeLanguage(DestSettings.Language, 'Const_LogC_Low');
    OptionLevelNormal := ChangeLanguage(DestSettings.Language, 'Const_LogC_Normal');
    OptionLevelHigh := ChangeLanguage(DestSettings.Language, 'Const_LogC_High');
    OptionLevelCritic := ChangeLanguage(DestSettings.Language, 'Const_LogC_Critic');
    DeletePerformed := ChangeLanguage(DestSettings.Language,
      'Const_LogC_ExcluirEfectuada');
  end;

  with DestSettings.AppMessages do
  begin
    MsgsForm_BtNew := ChangeLanguage(DestSettings.Language, 'Const_Msgs_BtNew');
    MsgsForm_BtReplay := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_BtReplay');
    MsgsForm_BtForward := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_BtForward');
    MsgsForm_BtDelete := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_BtDelete');
    MsgsForm_BtClose := ChangeLanguage(DestSettings.Language, 'Const_Msgs_BtClose');
    // added by fduenas
    MsgsForm_WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_WindowCaption');
    MsgsForm_ColFrom := ChangeLanguage(DestSettings.Language, 'Const_Msgs_ColFrom');
    MsgsForm_ColSubject := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_ColSubject');
    MsgsForm_ColDate := ChangeLanguage(DestSettings.Language, 'Const_Msgs_ColDate');
    MsgsForm_PromptDelete := ChangeLanguage(DestSettings.Language,
      'Const_Msgs_PromptDelete');
    MsgsForm_PromptDelete_WindowCaption :=
      ChangeLanguage(DestSettings.Language, 'Const_Msgs_PromptDelete_WindowCaption');
    // added by fduenas
    MsgsForm_NoMessagesSelected :=
      ChangeLanguage(DestSettings.Language, 'Const_Msgs_NoMessagesSelected');
    // added by fduenas
    MsgsForm_NoMessagesSelected_WindowCaption :=
      ChangeLanguage(DestSettings.Language,
      'Const_Msgs_NoMessagesSelected_WindowCaption'); // added by fduenas
    MsgRec_BtClose := ChangeLanguage(DestSettings.Language, 'Const_MsgRec_BtClose');
    MsgRec_WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_WindowCaption');
    MsgRec_Title := ChangeLanguage(DestSettings.Language, 'Const_MsgRec_Title');
    MsgRec_LabelFrom := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelFrom');
    MsgRec_LabelDate := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelDate');
    MsgRec_LabelSubject := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelSubject');
    MsgRec_LabelMessage := ChangeLanguage(DestSettings.Language,
      'Const_MsgRec_LabelMessage');
    MsgSend_BtSend := ChangeLanguage(DestSettings.Language, 'Const_MsgSend_BtSend');
    MsgSend_BtCancel := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_BtCancel');
    MsgSend_WindowCaption := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_WindowCaption');
    MsgSend_Title := ChangeLanguage(DestSettings.Language, 'Const_MsgSend_Title');
    MsgSend_GroupTo := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_GroupTo');
    MsgSend_RadioUser := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_RadioUser');
    MsgSend_RadioAll := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_RadioAll');
    MsgSend_GroupMessage := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_GroupMessage');
    MsgSend_LabelSubject := ChangeLanguage(DestSettings.Language,
      'Const_MsgSend_LabelSubject'); // added by fduenas
    MsgSend_LabelMessageText :=
      ChangeLanguage(DestSettings.Language, 'Const_MsgSend_LabelMessageText');
    // added by fduenas
  end;

  DestSettings.WindowsPosition := poMainFormCenter;

  with DestSettings.UsersLogged do
  begin
    BtnMessage := ChangeLanguage(DestSettings.Language, 'Const_UserLogged_BtnMsg');
    BtnRefresh := ChangeLanguage(DestSettings.Language, 'Const_UserLogged_Refresh');
    Btnclose := ChangeLanguage(DestSettings.Language, 'Const_Msgs_BtClose');
    LabelDescricao := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_LabelDescricao');
    LabelCaption := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_LabelCaption');
    ColName := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaNome');
    ColLogin := ChangeLanguage(DestSettings.Language, 'Const_Cad_ColunaLogin');
    ColComputer := ChangeLanguage(DestSettings.Language,
      'Const_CadColuna_Computer');
    ColData := ChangeLanguage(DestSettings.Language, 'Const_CadColuna_Data');
    InputCaption := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_InputCaption');
    InputText := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_InputText');
    MsgSystem := ChangeLanguage(DestSettings.Language,
      'Const_UserLogged_MsgSystem');
  end;

end;

{ ------------------------------------------------------------------------------- }

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCSettings'} {$ENDIF}
{ TUCSettings }

procedure TUCSettings.Assign(Source: TPersistent);
begin
  if Source is TUCUserSettings then
  begin
    Self.CommonMessages.Assign(TUCUserSettings(Source).CommonMessages);
    // modified by fduenas
    Self.AppMessages.Assign(TUCUserSettings(Source).AppMessages);
    // modified by fduenas
    Self.WindowsPosition := WindowsPosition;
  end
  else
    inherited;
end;

constructor TUCSettings.Create(AOwner: TComponent);
begin
  inherited;
  fLanguage := ucPortuguesBr;
  FAppMessagesMSG := TUCAppMessagesMSG.Create(nil);
  FLoginFormMSG := TUCLoginFormMSG.Create(nil);
  FUserCommomMSG := TUCUserCommonMSG.Create(nil);
  FCadUserFormMSG := TUCCadUserFormMSG.Create(nil);
  FAddUserFormMSG := TUCAddUserFormMSG.Create(nil);
  FAddProfileFormMSG := TUCAddProfileFormMSG.Create(nil);
  FPermissFormMSG := TUCPermissFormMSG.Create(nil);
  FProfileUserFormMSG := TUCProfileUserFormMSG.Create(nil);
  FTrocaSenhaFormMSG := TUCTrocaSenhaFormMSG.Create(nil);
  FResetPassword := TUCResetPassword.Create(nil);
  FLogControlFormMSG := TUCLogControlFormMSG.Create(nil);
  fBancoDados := Firebird;
  RetornaSqlBancoDados(fBancoDados, Type_Int, Type_Char, Type_VarChar,
    Type_Memo);
  fUsersLogged := TUCCadUserLoggedMSG.Create(nil);
  if csDesigning in ComponentState then
    IniSettings2(Self);
end;

destructor TUCSettings.Destroy;
begin
  // added by fduenas
  FAppMessagesMSG.Free;
  FLoginFormMSG.Free;
  FUserCommomMSG.Free;
  FCadUserFormMSG.Free;
  FAddUserFormMSG.Free;
  FAddProfileFormMSG.Free;
  FPermissFormMSG.Free;
  FProfileUserFormMSG.Free;
  FTrocaSenhaFormMSG.Free;
  FResetPassword.Free;
  FLogControlFormMSG.Free;
  fUsersLogged.Free;
  inherited;
end;

procedure TUCSettings.SetAppMessagesMSG(const Value: TUCAppMessagesMSG);
begin
  FAppMessagesMSG := Value;
end;

procedure TUCSettings.SetFAddProfileFormMSG(const Value: TUCAddProfileFormMSG);
begin
  FAddProfileFormMSG := Value;
end;

procedure TUCSettings.SetFAddUserFormMSG(const Value: TUCAddUserFormMSG);
begin
  FAddUserFormMSG := Value;
end;

procedure TUCSettings.SetfBancoDados(const Value: TUCTypeBancoDados);
begin
  fBancoDados := Value;
  RetornaSqlBancoDados(fBancoDados, Type_Int, Type_Char, Type_VarChar,
    Type_Memo);
end;

procedure TUCSettings.SetFCadUserFormMSG(const Value: TUCCadUserFormMSG);
begin
  FCadUserFormMSG := Value;
end;

procedure TUCSettings.SetFFormLoginMsg(const Value: TUCLoginFormMSG);
begin
  FLoginFormMSG := Value;
end;

procedure TUCSettings.SetfLanguage(const Value: TUCLanguage);
begin
  fLanguage := Value;
  AlterLanguage2(Self);
end;

procedure TUCSettings.SetFLogControlFormMSG(const Value: TUCLogControlFormMSG);
begin
  FLogControlFormMSG := Value;
end;

procedure TUCSettings.SetFPermissFormMSG(const Value: TUCPermissFormMSG);
begin
  FPermissFormMSG := Value;
end;

procedure TUCSettings.SetFProfileUserFormMSG(const Value: TUCProfileUserFormMSG);
begin
  FProfileUserFormMSG := Value;
end;

procedure TUCSettings.SetFResetPassword(const Value: TUCResetPassword);
begin
  FResetPassword := Value;
end;

procedure TUCSettings.SetFTrocaSenhaFormMSG(const Value: TUCTrocaSenhaFormMSG);
begin
  FTrocaSenhaFormMSG := Value;
end;

procedure TUCSettings.SetFUserCommonMSg(const Value: TUCUserCommonMSG);
begin
  FUserCommomMSG := Value;
end;

procedure TUCSettings.SetfUsersLogged(const Value: TUCCadUserLoggedMSG);
begin
  fUsersLogged := Value;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}

end.
