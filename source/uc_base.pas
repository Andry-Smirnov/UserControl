{
  -----------------------------------------------------------------------------
  Unit Name: UCBase
  Author:    QmD
  changed:   06-dez-2004
  Purpose:   Main Unit
  History:   included delphi 2005 support
  ----------------------------------------------------------------------------- }

unit uc_base;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

{$I 'UserControl.inc'}

uses
{$IFDEF WINDOWS}
  Windows,
{$ELSE}
  LCLType,
{$ENDIF}
{$IFNDEF FPC}
  ActnMan,
  ActnMenus,
  ExtActns,
{$ENDIF}
  ActnList,
  Variants,
  Classes,
  Controls,
  DB,
  Forms,
  Graphics,
  Menus,
  StdCtrls,
  SysUtils,
  //
{$IFNDEF FPC}
  uc_mail,
{$ENDIF}
  md5,
  uc_datainfo,
  uc_language,
  uc_dataconnector,
  uc_messages,
  uc_settings
  ;

const
  llBaixo = 0;
  llNormal = 1;
  llMedio = 2;
  llCritico = 3;

  // Version
const
  UCVersion = 'Laz 2.33 RC1';

type
  // Pensando em usar GUID para gerar a chave das tabelas !!!!
  TUCGUID = class
    // Creates and returns a new globally unique identifier
    class function NovoGUID: TGUID;
    // sometimes we need to have an "empty" value, like NULL
    class function EmptyGUID: TGUID;
    // Checks whether a Guid is EmptyGuid
    class function IsEmptyGUID(GUID: TGUID): boolean;
    // Convert to string
    class function ToString(GUID: TGUID): string;
    // convert to quoted string
    class function ToQuotedString(GUID: TGUID): string;
    // return a GUID from string
    class function FromString(Value: string): TGUID;
    // Indicates whether two TGUID values are the same
    class function EqualGUIDs(GUID1, GUID2: TGUID): boolean;
    // Creates and returns a new globally unique identifier string
    class function NovoGUIDString: string;
  end;

  TUCAboutVar = string;

  // classe para armazenar usuario logado = currentuser
  TUCCurrentUser = class(TComponent)
  private
    FUserProfile: TDataSet;
    FGroupProfile: TDataSet;
  public
    UserID: integer;
    Profile: integer;
    UserIDOld: integer;
    LogonID: string;
    UserName: string;
    UserLogin: string;
    Password: string;
    // PassLivre:       String;
    Email: string;
    DateExpiration: TDateTime;
    Privileged: boolean;
    UserNotExpired: boolean;
    UserDaysExpired: integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    // Cadastro de Usuarios
    property UserProfile: TDataSet read FUserProfile write FUserProfile;
    // Cadastro de Perfil
    property GroupProfile: TDataSet read FGroupProfile write FGroupProfile;
  end;

  // armazenar menuitem ou action responsavel pelo controle de usuarios
  TUCUser = class(TPersistent)
  private
    FAction: TAction;
    FMenuItem: TMenuItem;
    FUsePrivilegedField: boolean;
    FProtectAdministrator: boolean;
    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
    property UsePrivilegedField: boolean read FUsePrivilegedField
      write FUsePrivilegedField default False;
    property ProtectAdministrator: boolean read FProtectAdministrator
      write FProtectAdministrator default True;
  end;

  // armazenar menuitem ou action responsavel pelo Perfil de usuarios
  TUCUserProfile = class(TPersistent)
  private
    FAtive: boolean;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: boolean read FAtive write FAtive default True;
  end;

  // armazenar menuitem ou action responsavel pelo Form trocar senha
  TUCChangeUserPassword = class(TPersistent)
  private
    FForcePassword: boolean;
    FMinPasswordLength: integer;
    FAction: TAction;
    FMenuItem: TMenuItem;

    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
    property ForcePassword: boolean read FForcePassword write FForcePassword default False;
    property MinPasswordLength: integer read FMinPasswordLength write FMinPasswordLength default 0;
  end;

  // armazenar menuitem ou action responsavel pelo logoff
  TUCUserLogoff = class(TPersistent)
  private
    FAction: TAction;
    FMenuItem: TMenuItem;

    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
  end;

  // armazenar configuracao de Auto-Logon
  TUCAutoLogin = class(TPersistent)
  private
    FActive: boolean;
    FUser: string;
    FPassword: string;
    FMessageOnError: boolean;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: boolean read FActive write FActive default False;
    property User: string read FUser write FUser;
    property Password: string read FPassword write FPassword;
    property MessageOnError: boolean read FMessageOnError write FMessageOnError default True;
  end;

  // armazenar Dados do Login que sera criado na primeira execucao do programa.
  TUCInitialLogin = class(TPersistent)
  private
    FUser: string;
    FPassword: string;
    FInitialRights: TStrings;
    FEmail: string;

    procedure SetInitialRights(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property User: string read FUser write FUser;
    property Email: string read FEmail write FEmail;
    property Password: string read FPassword write FPassword;
    property InitialRights: TStrings read FInitialRights write SetInitialRights;
  end;

  TUCGetLoginName = (lnNone, lnUserName, lnMachineName);

  TUCLogin = class(TPersistent)
  private
    FAutoLogin: TUCAutoLogin;
    FMaxLoginAttempts: integer;
    FInitialLogin: TUCInitialLogin;
    FGetLoginName: TUCGetLoginName;
    fCharCaseUser: TEditCharCase;
    fCharCasePass: TEditCharCase;
    fDateExpireActive: boolean;
    fDaysOfSunExpired: word;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoLogin: TUCAutoLogin read FAutoLogin write FAutoLogin;
    property InitialLogin: TUCInitialLogin read FInitialLogin write FInitialLogin;
    property MaxLoginAttempts: integer read FMaxLoginAttempts write FMaxLoginAttempts;
    property GetLoginName: TUCGetLoginName read FGetLoginName write FGetLoginName default lnNone;
    property CharCaseUser: TEditCharCase read fCharCaseUser write fCharCaseUser default ecNormal;
    property CharCasePass: TEditCharCase read fCharCasePass write fCharCasePass default ecNormal;
    property ActiveDateExpired: boolean read fDateExpireActive write fDateExpireActive default False;
    property DaysOfSunExpired: word read fDaysOfSunExpired write fDaysOfSunExpired default 30;
  end;

  TUCNotAllowedItems = class(TPersistent)
    // Ocultar e/ou Desabilitar os itens que o usuario nao tem acesso
  private
    FMenuVisible: boolean;
    FActionVisible: boolean;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property MenuVisible: boolean read FMenuVisible write FMenuVisible default True;
    property ActionVisible: boolean read FActionVisible write FActionVisible default True;
  end;

  TUCLogControl = class(TPersistent) // Responsavel pelo Controle de Log
  private
    FActive: boolean;
    FTableLog: string;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: boolean read FActive write FActive default True;
    property TableLog: string read FTableLog write FTableLog;
  end;

  TUCControlRight = class(TPersistent)
    // Menu / ActionList/ActionManager ou ActionMainMenuBar a serem Controlados
  private
    FActionList: TActionList;
    {$IFNDEF FPC}
    FActionManager: TActionManager;
    FActionMainMenuBar: TActionMainMenuBar;
    {$ENDIF}
    FMainMenu: TMenu;
    procedure SetActionList(const Value: TActionList);
    {$IFNDEF FPC}
    procedure SetActionManager(const Value: TActionManager);
    procedure SetActionMainMenuBar(const Value: TActionMainMenuBar);
    {$ENDIF}
    procedure SetMainMenu(const Value: TMenu);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ActionList: TActionList read FActionList write SetActionList;
    property MainMenu: TMenu read FMainMenu write SetMainMenu;
{$IFNDEF FPC}
    property ActionManager: TActionManager read FActionManager write SetActionManager;
    property ActionMainMenuBar: TActionMainMenuBar read FActionMainMenuBar write SetActionMainMenuBar;
{$ENDIF}
  end;

  TOnLogin = procedure(Sender: TObject; var User, Password: string) of object;
  TOnLoginSucess = procedure(Sender: TObject; IdUser: integer;
    Usuario, Nome, Senha, Email: string; Privileged: boolean) of object;
  TOnLoginError = procedure(Sender: TObject; Usuario, Senha: string) of object;
  TOnApplyRightsMenuItem = procedure(Sender: TObject; MenuItem: TMenuItem) of object;
  TOnApllyRightsActionItem = procedure(Sender: TObject; Action: TAction) of object;
  TCustomUserForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomUserProfileForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomLoginForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomUserPasswordChangeForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomLogControlForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomInitialMessage = procedure(Sender: TObject; var CustomForm: TCustomForm;
    var Msg: TStrings) of object;
  TCustomUserLoggedForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object; // Cesar: 13/07/2005
  TOnAddUser = procedure(Sender: TObject; var Login, Password, Name, Mail: string;
    var Profile: integer; var Privuser: boolean) of object;
  TOnChangeUser = procedure(Sender: TObject; IdUser: integer;
    var Login, Name, Mail: string; var Profile: integer;
    var Privuser: boolean) of object;
  TOnDeleteUser = procedure(Sender: TObject; IdUser: integer;
    var CanDelete: boolean; var ErrorMsg: string) of object;
  TOnAddProfile = procedure(Sender: TObject; var Profile: string) of object;
  TOnDeleteProfile = procedure(Sender: TObject; IDProfile: integer;
    var CanDelete: boolean; var ErrorMsg: string) of object;
  TOnChangePassword = procedure(Sender: TObject; IdUser: integer;
    Login, CurrentPassword, NewPassword: string) of object;
  TOnLogoff = procedure(Sender: TObject; IdUser: integer) of object;

  TUCExtraRights = class;
  TUCExecuteThread = class;
  TUCApplicationMessage = class;
  TUCControls = class;
  TUCUsersLogged = class; // Cesar: 12/07/2005

  TUCLoginMode = (lmActive, lmPassive);
  TUCCriptografia = (cStandard, cMD5);

  TUserControl = class(TComponent) // Classe principal
  private
    FCurrentUser: TUCCurrentUser;
    FUserSettings: TUCUserSettings;
    FApplicationID: string;
    FNotAllowedItems: TUCNotAllowedItems;
    FOnLogin: TOnLogin;
    FOnStartApplication: TNotifyEvent;
    FOnLoginError: TOnLoginError;
    FOnLoginSucess: TOnLoginSucess;
    FOnApplyRightsActionIt: TOnApllyRightsActionItem;
    FOnApplyRightsMenuIt: TOnApplyRightsMenuItem;
    FLogControl: TUCLogControl;
    FEncrytKey: word;
    FUser: TUCUser;
    FLogin: TUCLogin;
    FUserProfile: TUCUserProfile;
    FUserPasswordChange: TUCChangeUserPassword;
    FControlRight: TUCControlRight;
    FOnCustomCadUsuarioForm: TCustomUserForm;
    FCustomLogControlForm: TCustomLogControlForm;
    FCustomLoginForm: TCustomLoginForm;
    FCustomPerfilUsuarioForm: TCustomUserProfileForm;
    FCustomTrocarSenhaForm: TCustomUserPasswordChangeForm;
    FOnAddProfile: TOnAddProfile;
    FOnAddUser: TOnAddUser;
    FOnChangePassword: TOnChangePassword;
    FOnChangeUser: TOnChangeUser;
    FOnDeleteProfile: TOnDeleteProfile;
    FOnDeleteUser: TOnDeleteUser;
    FOnLogoff: TOnLogoff;
    FCustomInicialMsg: TCustomInitialMessage;
    FAbout: TUCAboutVar;
    FExtraRights: TUCExtraRights;
    FThUCRun: TUCExecuteThread;
    FAutoStart: boolean;
    FTableRights: TUCTableRights;
    FTableUsers: TUCUsersTable;
    FLoginMode: TUCLoginMode;
    FControlList: TList;
    FDataConnector: TUCDataConnector;
    FLoginMonitorList: TList;
    FAfterLogin: TNotifyEvent;
    FCheckValidationKey: boolean;
    FCriptografia: TUCCriptografia;
    FUsersLogged: TUCUsersLogged;
    FTableUsersLogged: TUCTableUsersLogged;
    FUsersLogoff: TUCUserLogoff;
    fLanguage: TUCLanguage;
    {$IFNDEF FPC}
    FMailUserControl: TMailUserControl;
    {$ENDIF}
    procedure SetExtraRights(Value: TUCExtraRights);
    procedure ActionCadUser(Sender: TObject);
    procedure ActionTrocaSenha(Sender: TObject);
    procedure ActionOKLogin(Sender: TObject);
    procedure TestaFecha(Sender: TObject; var CanClose: boolean);
    procedure ApplySettings(SourceSettings: TUCSettings);
    procedure UnlockEX(FormObj: TCustomForm; ObjName: string);
    procedure LockEX(FormObj: TCustomForm; ObjName: string; naInvisible: boolean);
{$IFNDEF FPC}
    { .$IFDEF UCACTMANAGER }
    procedure TrataActMenuBarIt(IT: TActionClientItem; ADataset: TDataSet);
    procedure IncPermissActMenuBar(IdUser: integer; Act: TAction);
    { .$ENDIF }
{$ENDIF}
    procedure SetDataConnector(const Value: TUCDataConnector);
    procedure DoCheckValidationField;
    procedure SetLanguage(const Value: TUCLanguage);
{$IFNDEF FPC}
    procedure SetFMailUserControl(const Value: TMailUserControl);
{$ENDIF}
    procedure ActionEsqueceuSenha(Sender: TObject);
  protected
    FRetry: integer;
    // Formulários
    FChangePasswordForm: TCustomForm;
    FLoginForm: TCustomForm;
    FSettingsForm: TCustomForm;
    // -----

    procedure Loaded; override;
    // Criar Formulários
    procedure CriaFormTrocarSenha; dynamic;
    // -----

    procedure ActionLogoff(Sender: TObject); dynamic;
    procedure ActionTSBtGrava(Sender: TObject);
    procedure SetUserSettings(const Value: TUCUserSettings);
    procedure SetfrmLoginWindow(Form: TCustomForm);
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure RegistraCurrentUser(Dados: TDataSet); // Pass: String);
    procedure ApplyRightsObj(ADataset: TDataSet; FProfile: boolean = False);
    procedure ShowLogin;
    procedure ApplyRights;

    // Criar Tabelas
    procedure CriaTabelaLog;
    procedure CriaTabelaRights(ExtraRights: boolean = False);
    procedure CriaTabelaUsuarios(TableExists: boolean);
    procedure CriaTabelaMsgs(const TableName: string);
    // -----

    // Atualiza Versao
    procedure AtualizarVersao;
    // --------

    procedure TryAutoLogon;
    procedure AddUCControlMonitor(UCControl: TUCControls);
    procedure DeleteUCControlMonitor(UCControl: TUCControls);
    procedure ApplyRightsUCControlMonitor;
    procedure LockControlsUCControlMonitor;
    procedure AddLoginMonitor(UCAppMessage: TUCApplicationMessage);
    procedure DeleteLoginMonitor(UCAppMessage: TUCApplicationMessage);
    procedure NotificationLoginMonitor;
    procedure ShowNewConfig;
  public
    procedure Logoff;
    procedure Execute;
    procedure StartLogin;
    procedure ShowChangePassword;
    procedure ChangeUser(IdUser: integer; Login, Name, Mail: string;
      Profile, UserExpired, UserDaysSun, Status: integer; Privuser: boolean);
    procedure ChangePassword(IdUser: integer; NewPassword: string);
    procedure AddRight(IdUser: integer; ItemRight: TObject;
      FullPath: boolean = True); overload;
    procedure AddRight(IdUser: integer; ItemRight: string); overload;
    procedure AddRightEX(IdUser: integer; Module, FormName, ObjName: string);
    procedure HideField(Sender: TField; var Text: string; DisplayText: boolean);
    procedure Log(Msg: string; Level: integer = llNormal);
    function VerificaLogin(User, Password: string;
      SoVerificarUsuarioAdmin: boolean = False): integer; // Boolean;
    function GetLocalUserName: string;
    function GetLocalComputerName: string;
    function AddUser(Login, Password, Name, Mail: string;
      Profile, UserExpired, DaysExpired: integer; Privuser: boolean): integer;
    function ExisteUsuario(Login: string): boolean;
    function GetAllUsers(Names: boolean): TStringList;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property CurrentUser: TUCCurrentUser read FCurrentUser write FCurrentUser;
    property UserSettings: TUCUserSettings read FUserSettings write SetUserSettings;
  published
    property About: TUCAboutVar read FAbout write FAbout;
    property Criptografia: TUCCriptografia read FCriptografia
      write FCriptografia default cStandard;
    property AutoStart: boolean read FAutoStart write FAutoStart default False;
    property ApplicationID: string read FApplicationID write FApplicationID;
    property ControlRight: TUCControlRight read FControlRight write FControlRight;
    // Controle dos formularios
    property User: TUCUser read FUser write FUser;
    property UserProfile: TUCUserProfile read FUserProfile write FUserProfile;
    property UserPasswordChange: TUCChangeUserPassword
      read FUserPasswordChange write FUserPasswordChange;
    property UsersLogged: TUCUsersLogged read FUsersLogged write FUsersLogged;
    property UsersLogoff: TUCUserLogoff read FUsersLogoff write FUsersLogoff;
    property LogControl: TUCLogControl read FLogControl write FLogControl;
{$IFNDEF FPC}
    property MailUserControl: TMailUserControl
      read FMailUserControl write SetFMailUserControl;
{$ENDIF}
    property Language: TUCLanguage read fLanguage write SetLanguage;
    property EncryptKey: word read FEncrytKey write FEncrytKey;
    property NotAllowedItems: TUCNotAllowedItems read FNotAllowedItems write FNotAllowedItems;
    property Login: TUCLogin read FLogin write FLogin;
    property ExtraRights: TUCExtraRights read FExtraRights write SetExtraRights;
    property LoginMode: TUCLoginMode read FLoginMode write FLoginMode default lmActive;
    // Tabelas
    property TableUsers: TUCUsersTable read FTableUsers write FTableUsers;
    property TableRights: TUCTableRights read FTableRights write FTableRights;
    property TableUsersLogged: TUCTableUsersLogged
      read FTableUsersLogged write FTableUsersLogged;

    property DataConnector: TUCDataConnector read FDataConnector write SetDataConnector;
    property CheckValidationKey: boolean read FCheckValidationKey write FCheckValidationKey default False;
    // Eventos
    property OnLogin: TOnLogin read FOnLogin write FOnLogin;
    property OnStartApplication: TNotifyEvent read FOnStartApplication write FOnStartApplication;
    property OnLoginSucess: TOnLoginSucess read FOnLoginSucess write FOnLoginSucess;
    property OnLoginError: TOnLoginError read FOnLoginError write FOnLoginError;
    property OnApplyRightsMenuIt: TOnApplyRightsMenuItem read FOnApplyRightsMenuIt write FOnApplyRightsMenuIt;
    property OnApplyRightsActionIt: TOnApllyRightsActionItem read FOnApplyRightsActionIt write FOnApplyRightsActionIt;
    property OnCustomUsersForm: TCustomUserForm read FOnCustomCadUsuarioForm write FOnCustomCadUsuarioForm;
    property OnCustomUsersProfileForm: TCustomUserProfileForm read FCustomPerfilUsuarioForm write FCustomPerfilUsuarioForm;
    property OnCustomLoginForm: TCustomLoginForm read FCustomLoginForm write FCustomLoginForm;
    property OnCustomChangePasswordForm: TCustomUserPasswordChangeForm read FCustomTrocarSenhaForm write FCustomTrocarSenhaForm;
    property OnCustomLogControlForm: TCustomLogControlForm read FCustomLogControlForm write FCustomLogControlForm;
    property OnCustomInitialMsg: TCustomInitialMessage read FCustomInicialMsg write FCustomInicialMsg;
    property OnCustomUserLoggedForm: TCustomUserForm read FOnCustomCadUsuarioForm write FOnCustomCadUsuarioForm;
    // Cesar: 13/07/2005
    property OnAddUser: TOnAddUser read FOnAddUser write FOnAddUser;
    property OnChangeUser: TOnChangeUser read FOnChangeUser write FOnChangeUser;
    property OnDeleteUser: TOnDeleteUser read FOnDeleteUser write FOnDeleteUser;
    property OnAddProfile: TOnAddProfile read FOnAddProfile write FOnAddProfile;
    property OnDeleteProfile: TOnDeleteProfile read FOnDeleteProfile write FOnDeleteProfile;
    property OnChangePassword: TOnChangePassword read FOnChangePassword write FOnChangePassword;
    property OnLogoff: TOnLogoff read FOnLogoff write FOnLogoff;
    property OnAfterLogin: TNotifyEvent read FAfterLogin write FAfterLogin;
  end;

  TUCExtraRightsItem = class(TCollectionItem)
  private
    FFormName: string;
    FCompName: string;
    FCaption: string;
    FGroupName: string;
    procedure SetFormName(const Value: string);
    procedure SetCompName(const Value: string);
    procedure SetCaption(const Value: string);
    procedure SetGroupName(const Value: string);
  protected
    function GetDisplayName: string; override;
  public
  published
    property FormName: string read FFormName write SetFormName;
    property CompName: string read FCompName write SetCompName;
    property Caption: string read FCaption write SetCaption;
    property GroupName: string read FGroupName write SetGroupName;
  end;

  TUCExtraRights = class(TCollection)
  private
    FUCBase: TUserControl;
    function GetItem(Index: integer): TUCExtraRightsItem;
    procedure SetItem(Index: integer; Value: TUCExtraRightsItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(UCBase: TUserControl);
    function Add: TUCExtraRightsItem;
    property Items[Index: integer]: TUCExtraRightsItem read GetItem write SetItem;
      default;
  end;

  TUCVerificaMensagemThread = class(TThread)
  private
    procedure VerNovaMansagem;
  public
    AOwner: TComponent;
  protected
    procedure Execute; override;
  end;

  TUCExecuteThread = class(TThread)
  private
    procedure UCStart;
  public
    AOwner: TComponent;
  protected
    procedure Execute; override;
  end;

  TUCApplicationMessage = class(TComponent)
  private
    FActive: boolean;
    FReady: boolean;
    FInterval: integer;
    FUserControl: TUserControl;
    FVerifThread: TUCVerificaMensagemThread;
    FTableMessages: string;
    procedure SetActive(const Value: boolean);
    procedure SetUserControl(const Value: TUserControl);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation);
      override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowMessages(Modal: boolean = True);
    procedure SendAppMessage(ToUser: integer; Subject, Msg: string);
    procedure DeleteAppMessage(IdMsg: integer);
    procedure CheckMessages;
  published
    property Active: boolean read FActive write SetActive;
    property Interval: integer read FInterval write FInterval;
    property TableMessages: string read FTableMessages write FTableMessages;
    property UserControl: TUserControl read FUserControl write SetUserControl;
  end;

  TUCComponentsVar = string;

  TUCNotAllowed = (naInvisible, naDisabled);

  TUCControls = class(TComponent)
  private
    FGroupName: string;
    FComponents: TUCComponentsVar;
    FUserControl: TUserControl;
    FNotAllowed: TUCNotAllowed;
    function GetAccessType: string;
    function GetActiveForm: string;
    procedure SetGroupName(const Value: string);
    procedure SetUserControl(const Value: TUserControl);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation);
      override;
  public
    destructor Destroy; override;
    procedure ApplyRights;
    procedure LockControls;
    procedure ListComponents(Form: string; List: TStringList);
    property Components: TUCComponentsVar read FComponents write FComponents;
  published
    property AccessType: string read GetAccessType;
    property ActiveForm: string read GetActiveForm;
    property GroupName: string read FGroupName write SetGroupName;
    property UserControl: TUserControl read FUserControl write SetUserControl;

    property NotAllowed: TUCNotAllowed
      read FNotAllowed write FNotAllowed default naInvisible;
  end;

  TUCUsersLogged = class(TPersistent)
    // Cesar: 12/07/2005: classe que armazena os usuarios logados no sistema
  private
    FUserControl: TUserControl;
    FAtive: boolean;
    procedure AddCurrentUser;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure DelCurrentUser;
    procedure CriaTableUserLogado;
    function UsuarioJaLogado(ID: integer): boolean;
  published
    property Active: boolean read FAtive write FAtive default True;
  end;

function Decrypt(const S: ansistring; Key: word): ansistring;
function Encrypt(const S: ansistring; Key: word): ansistring;
function MD5Sum(strValor: string): string;

{ TODO -oLuiz -cUpgrade : Mudar o GetLoginName para a Unit principal }

implementation

{$R UCLock.res}

uses
  DBGrids,
  Dialogs,
  //
  uc_loginwindow,
  uc_receivedmessage,
  uc_systemmessage,
  uc_tools,
  uc_changeuserpassword,
  uc_userpermissions;

{$IFDEF DELPHI9_UP} {$REGION 'TUSerControl'} {$ENDIF}
  { TUserControl }

constructor TUserControl.Create(AOwner: TComponent);
begin
  inherited;
  FCurrentUser := TUCCurrentUser.Create(Self);
  FControlRight := TUCControlRight.Create(Self);
  FLogin := TUCLogin.Create(Self);
  FLogControl := TUCLogControl.Create(Self);
  FUser := TUCUser.Create(Self);
  FUserProfile := TUCUserProfile.Create(Self);
  FUserPasswordChange := TUCChangeUserPassword.Create(Self);
  FUsersLogged := TUCUsersLogged.Create(Self);
  FUsersLogoff := TUCUserLogoff.Create(Self);
  FUserSettings := TUCUserSettings.Create(Self);
  FNotAllowedItems := TUCNotAllowedItems.Create(Self);
  FExtraRights := TUCExtraRights.Create(Self);
  FTableUsers := TUCUsersTable.Create(Self);
  FTableRights := TUCTableRights.Create(Self);
  FTableUsersLogged := TUCTableUsersLogged.Create(Self);

  if csDesigning in ComponentState then
    begin
      with TableUsers do
        begin
          if TableName = '' then
            TableName := ChangeLanguage(fLanguage, 'Const_TableUsers_TableName');
          if FieldUserID = '' then
            FieldUserID := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldUserID');
          if FieldUserName = '' then
            FieldUserName := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldUserName');
          if FieldLogin = '' then
            FieldLogin := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldLogin');
          if FieldPassword = '' then
            FieldPassword := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldPassword');
          if FieldEmail = '' then
            FieldEmail := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldEmail');
          if FieldPrivileged = '' then
            FieldPrivileged := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldPrivileged');
          if FieldTypeRec = '' then
            FieldTypeRec := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldTypeRec');
          if FieldProfile = '' then
            FieldProfile := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldProfile');
          if FieldKey = '' then
            FieldKey := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldKey');

          if FieldDateExpired = '' then
            FieldDateExpired := ChangeLanguage(fLanguage, 'Const_TableUsers_FieldDateExpired');

          if FieldUserExpired = '' then
            FieldUserExpired := ChangeLanguage(fLanguage, 'Const_TableUser_FieldUserExpired');

          if FieldUserDaysSun = '' then
            FieldUserDaysSun := ChangeLanguage(fLanguage, 'Const_TableUser_FieldUserDaysSun');

          if FieldUserInative = '' then
            FieldUserInative := ChangeLanguage(fLanguage, 'Const_TableUser_FieldUserInative');
        end;

      with TableRights do
        begin
          if TableName = '' then
            TableName := ChangeLanguage(fLanguage, 'Const_TableRights_TableName');
          if FieldUserID = '' then
            FieldUserID := ChangeLanguage(fLanguage, 'Const_TableRights_FieldUserID');
          if FieldModule = '' then
            FieldModule := ChangeLanguage(fLanguage, 'Const_TableRights_FieldModule');
          if FieldComponentName = '' then
            FieldComponentName :=
              ChangeLanguage(fLanguage, 'Const_TableRights_FieldComponentName');
          if FieldFormName = '' then
            FieldFormName := ChangeLanguage(fLanguage, 'Const_TableRights_FieldFormName');
          if FieldKey = '' then
            FieldKey := ChangeLanguage(fLanguage, 'Const_TableRights_FieldKey');
        end;

      with TableUsersLogged do
        begin
          if TableName = '' then
            TableName := ChangeLanguage(fLanguage, 'Const_TableUsersLogged_TableName');
          if FieldLogonID = '' then
            FieldLogonID := ChangeLanguage(fLanguage, 'Const_TableUsersLogged_FieldLogonID');
          if FieldUserID = '' then
            FieldUserID := ChangeLanguage(fLanguage, 'Const_TableUsersLogged_FieldUserID');
          if FieldApplicationID = '' then
            FieldApplicationID :=
              ChangeLanguage(fLanguage, 'Const_TableUsersLogged_FieldApplicationID');
          if FieldMachineName = '' then
            FieldMachineName := ChangeLanguage(fLanguage, 'Const_TableUsersLogged_FieldMachineName');
          if FieldData = '' then
            FieldData := ChangeLanguage(fLanguage, 'Const_TableUsersLogged_FieldData');
        end;

      if LogControl.TableLog = '' then
        LogControl.TableLog := 'UCLog';
      if ApplicationID = '' then
        ApplicationID := 'ProjetoNovo';
      if Login.InitialLogin.User = '' then
        Login.InitialLogin.User := 'admin';
      if Login.InitialLogin.Password = '' then
        Login.InitialLogin.Password := '123mudar';
      if Login.InitialLogin.Email = '' then
        Login.InitialLogin.Email := 'usercontrol@usercontrol.net';

      FLoginMode := lmActive;
      FCriptografia := cStandard;
      FAutoStart := False;
      FUserProfile.Active := True;
      FLogControl.Active := True;
      FUser.UsePrivilegedField := False;
      FUser.ProtectAdministrator := True;
      FUsersLogged.Active := True;
      NotAllowedItems.MenuVisible := True;
      NotAllowedItems.ActionVisible := True;
    end
  else
    begin
      FControlList := TList.Create;
      FLoginMonitorList := TList.Create;
    end;

  uc_settings.IniSettings(UserSettings);
end;

procedure TUserControl.Loaded;
var
  I: integer;
  Str: string;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    begin
      if UpperCase(Owner.ClassParent.ClassName) = UpperCase('TDataModule') then
        //TODO: Translate or use ChangeLanguage function
        raise Exception.Create( 'O Componente "TUserControl" não pode ser definido em um "TDataModulo"');

      if not Assigned(DataConnector) then
        raise Exception.Create(ChangeLanguage(fLanguage, 'MsgExceptConnector'));

      if ApplicationID = '' then
        raise Exception.Create(ChangeLanguage(fLanguage, 'MsgExceptAppID'));

      if ((not Assigned(ControlRight.ActionList)) and
{$IFNDEF FPC}
        (not Assigned(ControlRight.ActionManager)) and
        (not Assigned(ControlRight.ActionMainMenuBar)) and
{$ENDIF}
        (not Assigned(ControlRight.MainMenu))) then
        raise Exception.Create(Format(ChangeLanguage(fLanguage, 'MsgExceptPropriedade'), ['ControlRight']));

      for I := 0 to Pred(Owner.ComponentCount) do
        if Owner.Components[I] is TUCSettings then
          begin
            Language := TUCSettings(Owner.Components[I]).Language;
            // torna a linguage do UCSETTINGS como padrão
            FUserSettings.BancoDados := TUCSettings(Owner.Components[I]).BancoDados;
            ApplySettings(TUCSettings(Owner.Components[I]));
          end;

      if Assigned(User.MenuItem)
        and (not Assigned(User.MenuItem.OnClick)) then
        User.MenuItem.OnClick := ActionCadUser;

      if Assigned(User.Action)
        and (not Assigned(User.Action.OnExecute)) then
        User.Action.OnExecute := ActionCadUser;

      if (not Assigned(User.Action))
        and (not Assigned(User.MenuItem)) then
        raise Exception.Create(Format(ChangeLanguage(fLanguage, 'MsgExceptPropriedade'), ['User']));

      if Assigned(UserPasswordChange.MenuItem)
        and (not Assigned(UserPasswordChange.MenuItem.OnClick)) then
        UserPasswordChange.MenuItem.OnClick := ActionTrocaSenha;

      if Assigned(UserPasswordChange.Action)
        and (not Assigned(UserPasswordChange.Action.OnExecute)) then
        UserPasswordChange.Action.OnExecute := ActionTrocaSenha;

      if Assigned(UsersLogoff.MenuItem)
        and (not Assigned(UsersLogoff.MenuItem.OnClick)) then
        UsersLogoff.MenuItem.OnClick := ActionLogoff;

      if Assigned(UsersLogoff.Action)
        and (not Assigned(UsersLogoff.Action.OnExecute)) then
        UsersLogoff.Action.OnExecute := ActionLogoff;

      if (not Assigned(UserPasswordChange.Action))
        and (not Assigned(UserPasswordChange.MenuItem)) then
        raise Exception.Create(Format(ChangeLanguage(fLanguage, 'MsgExceptPropriedade'), ['UserPasswordChange']));

      if (not Assigned(UsersLogoff.Action))
        and (not Assigned(UsersLogoff.MenuItem)) then
        raise Exception.Create(Format(ChangeLanguage(fLanguage, 'MsgExceptPropriedade'), ['UsersLogoff']));

      with TableUsers do
        begin
          Str := ChangeLanguage(fLanguage, 'MsgExceptUsersTable');
          if TableName = '' then
            Exception.Create(Str);
          if FieldUserID = '' then
            Exception.Create(Str + #13 + #10 + 'FieldUserID***');
          if FieldUserName = '' then
            Exception.Create(Str + #13 + #10 + 'FieldUserName***');
          if FieldLogin = '' then
            Exception.Create(Str + #13 + #10 + 'FieldLogin***');
          if FieldPassword = '' then
            Exception.Create(Str + #13 + #10 + 'FieldPassword***');
          if FieldEmail = '' then
            Exception.Create(Str + #13 + #10 + 'FieldEmail***');
          if FieldPrivileged = '' then
            Exception.Create(Str + #13 + #10 + 'FieldPrivileged***');
          if FieldTypeRec = '' then
            Exception.Create(Str + #13 + #10 + 'FieldTypeRec***');
          if FieldKey = '' then
            Exception.Create(Str + #13 + #10 + 'FieldKey***');
          if FieldProfile = '' then
            Exception.Create(Str + #13 + #10 + 'FieldProfile***');

          if FieldDateExpired = '' then
            Exception.Create(Str + #13 + #10 + 'FieldDateExpired***');

          if FieldUserExpired = '' then
            Exception.Create(Str + #13 + #10 + 'FieldUserExpired***');

          if FieldUserDaysSun = '' then
            Exception.Create(Str + #13 + #10 + 'FieldUserDaysSun***');

          if FieldUserInative = '' then
            Exception.Create(Str + #13 + #10 + 'FieldUserInative***');

        end;

      with TableRights do
        begin
          Str := ChangeLanguage(fLanguage, 'MsgExceptRightsTable');
          if TableName = '' then
            Exception.Create(Str);
          if FieldUserID = '' then
            Exception.Create(Str + #13 + #10 + 'FieldProfile***');
          if FieldModule = '' then
            Exception.Create(Str + #13 + #10 + 'FieldModule***');
          if FieldComponentName = '' then
            Exception.Create(Str + #13 + #10 + 'FieldComponentName***');
          if FieldFormName = '' then
            Exception.Create(Str + #13 + #10 + 'FieldFormName***');
          if FieldKey = '' then
            Exception.Create(Str + #13 + #10 + 'FieldKey***');
        end;

      if Assigned(OnStartApplication) then
        OnStartApplication(Self);

      // desviar para thread monitorando conexao ao banco qmd 30/01/2004
      if FAutoStart then
        begin
          FThUCRun := TUCExecuteThread.Create(True);
          FThUCRun.AOwner := Self;
          FThUCRun.FreeOnTerminate := True;
          FThUCRun.Resume;
        end;
    end;
end;

procedure TUserControl.ActionCadUser(Sender: TObject);
begin
  ShowNewConfig;
end;

procedure TUserControl.ActionEsqueceuSenha(Sender: TObject);
var
  FDataset: TDataSet;
  FDataPer: TDataSet;
begin
  FDataset := DataConnector.UCGetSQLDataset('Select * from ' +
    TableUsers.TableName + ' Where ' + TableUsers.FieldLogin + ' = ' +
    QuotedStr(TLoginForm(FLoginForm).EditUsuario.Text));

  FDataPer := DataConnector.UCGetSQLDataset('select ' + TableUsers.FieldUserName +
    ' from ' + TableUsers.TableName + ' Where ' + TableUsers.FieldUserID +
    ' = ' + FDataset.FieldByName(TableUsers.FieldProfile).AsString);
  try
    if not FDataset.IsEmpty then
    begin
      {$IFNDEF FPC}
      MailUserControl.EnviaEsqueceuSenha
      (FDataset.FieldByName(TableUsers.FieldUserID).AsInteger,
        FDataset.FieldByName(TableUsers.FieldUserName).AsString,
        FDataset.FieldByName(TableUsers.FieldLogin).AsString,
        FDataset.FieldByName(TableUsers.FieldPassword).AsString,
        FDataset.FieldByName(TableUsers.FieldEmail).AsString,
        FDataPer.FieldByName(TableUsers.FieldUserName).AsString);
      {$ENDIF}
    end
    else
      MessageDlg(UserSettings.CommonMessages.InvalidLogin, mtWarning,
        [mbOK], 0);
  finally
    FDataset.Close;
    FDataset.Free;
  end;
end;

procedure TUserControl.ActionTrocaSenha(Sender: TObject);
begin
  if Assigned(OnCustomChangePasswordForm) then
    OnCustomChangePasswordForm(Self, FChangePasswordForm);

  if FChangePasswordForm = nil then
    CriaFormTrocarSenha;

  FChangePasswordForm.ShowModal;
  FreeAndNil(FChangePasswordForm);
end;

function TUserControl.ExisteUsuario(Login: string): boolean;
var
  SQLstmt: string;
  DataSet: TDataSet;
begin
  SQLstmt := Format('SELECT %s.%s FROM %s WHERE %s.%s=%s',
    [Self.TableUsers.TableName, Self.TableUsers.FieldLogin,
    Self.TableUsers.TableName, Self.TableUsers.TableName,
    Self.TableUsers.FieldLogin, QuotedStr(Login)]);

  DataSet := Self.DataConnector.UCGetSQLDataset(SQLstmt);
  try
    Result := (DataSet.RecordCount > 0);
  finally
    SysUtils.FreeAndNil(DataSet);
  end;
end;

function TUserControl.GetAllUsers(Names: boolean): TStringList;
var
  FDataset: TDataSet;
begin
  Result := TStringList.Create;
  if Names then
    FDataset := DataConnector.UCGetSQLDataset('Select ' +
      TableUsers.FieldUserName + ' from ' + TableUsers.TableName +
      ' Where ' + TableUsers.FieldTypeRec + ' = ' + QuotedStr('U') +
      ' order by ' + TableUsers.FieldUserName)
  else
    FDataset := DataConnector.UCGetSQLDataset('Select ' +
      TableUsers.FieldLogin + ' from ' + TableUsers.TableName + ' Where ' +
      TableUsers.FieldTypeRec + ' = ' + QuotedStr('U') + ' order by ' +
      TableUsers.FieldUserName);
  if FDataset.IsEmpty = False then
  begin
    while FDataset.EOF = False do
    begin
      Result.Add(FDataset.Fields[0].AsString);
      FDataset.Next;
    end;
  end;
  FDataset.Close;
end;

function TUserControl.GetLocalComputerName: string;
{$IFDEF WINDOWS}
var
  Count: DWORD;
  Buffer: string;
begin
  Count := MAX_COMPUTERNAME_LENGTH + 1;
  SetLength(Buffer, Count);
  if GetComputerName(PChar(Buffer), Count) then
    SetLength(Buffer, StrLen(PChar(Buffer)))
  else
    Buffer := '';
  Result := Buffer;
{$ELSE}
begin
  Result := GetEnvironmentVariable('$HOSTNAME');
{$ENDIF}
end;

function TUserControl.GetLocalUserName: string;
{$IFDEF WINDOWS}
var
  Count: DWORD;
  Buffer: string;
begin
  Count := 254;
  SetLength(Buffer, Count);
  if GetUserName(PChar(Buffer), Count) then
    SetLength(Buffer, StrLen(PChar(Buffer)))
  else
    Buffer := '';
  Result := Buffer;
{$ELSE}
begin
  Result := GetEnvironmentVariable('$USER');
{$ENDIF}
end;

procedure TUserControl.CriaFormTrocarSenha;
begin
  FChangePasswordForm := TChangeUserPasswordForm.Create(Self);
  with Self.UserSettings.ChangePassword do
    begin
      TChangeUserPasswordForm(FChangePasswordForm).FUserControl := Self;
      TChangeUserPasswordForm(FChangePasswordForm).Caption := WindowCaption;
      TChangeUserPasswordForm(FChangePasswordForm).lbDescricao.Caption := LabelDescription;
      TChangeUserPasswordForm(FChangePasswordForm).lbSenhaAtu.Caption := LabelCurrentPassword;
      TChangeUserPasswordForm(FChangePasswordForm).lbNovaSenha.Caption := LabelNewPassword;
      TChangeUserPasswordForm(FChangePasswordForm).lbConfirma.Caption := LabelConfirm;
      TChangeUserPasswordForm(FChangePasswordForm).btGrava.Caption := BtSave;
      TChangeUserPasswordForm(FChangePasswordForm).btCancel.Caption := btCancel;
      TChangeUserPasswordForm(FChangePasswordForm).ForcarTroca := False;
    end;
  TChangeUserPasswordForm(FChangePasswordForm).Position := Self.UserSettings.WindowsPosition;

  TChangeUserPasswordForm(FChangePasswordForm).btGrava.OnClick := ActionTSBtGrava;
  if CurrentUser.Password = '' then
    TChangeUserPasswordForm(FChangePasswordForm).EditAtu.Enabled := False;
end;

procedure TUserControl.ActionTSBtGrava(Sender: TObject);
var
  AuxPass: string;
begin
  { Pelo que eu analizei, a gravação da senha no Banco de Dados e feita criptografada
    Qdo a criptografia e padrão, a funcao RegistraCurrentUser descriptografa a senha atual
    agora quando criptografia e MD5SUM, devemos criptografar a senha atual vinda do formulario de
    troca de senha para podemos comparar com a senha atual da classe TUCCurrentUser
    Modificação Feita por Vicente Barros Leonel
  }
  case Self.Criptografia of
    cStandard: AuxPass := TChangeUserPasswordForm(FChangePasswordForm).EditAtu.Text;
    cMD5:      AuxPass := MD5Sum(TChangeUserPasswordForm(FChangePasswordForm).EditAtu.Text);
  end;

  if CurrentUser.Password <> AuxPass then
    begin
      MessageDlg(UserSettings.CommonMessages.ChangePasswordError.
        InvalidCurrentPassword, mtWarning, [mbOK], 0);
      TChangeUserPasswordForm(FChangePasswordForm).EditAtu.SetFocus;
      Exit;
    end;

  if TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text <>
    TChangeUserPasswordForm(FChangePasswordForm).EditConfirma.Text then
    begin
      MessageDlg(UserSettings.CommonMessages.ChangePasswordError.InvalidNewPassword, mtWarning, [mbOK], 0);
      TChangeUserPasswordForm(FChangePasswordForm).EditNova.SetFocus;
      Exit;
    end;

  case Self.Criptografia of
    cStandard: AuxPass := TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text;
    cMD5:      AuxPass := MD5Sum(TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text);
  end;

  if AuxPass = CurrentUser.Password then
    begin
      MessageDlg(UserSettings.CommonMessages.ChangePasswordError.NewEqualCurrent, mtWarning, [mbOK], 0);
      TChangeUserPasswordForm(FChangePasswordForm).EditNova.SetFocus;
      Exit;
    end;

  if (UserPasswordChange.ForcePassword) and
    (TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text = '') then
    begin
      MessageDlg(UserSettings.CommonMessages.ChangePasswordError.PasswordRequired, mtWarning, [mbOK], 0);
      TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text;
      Exit;
    end;

  if Length(TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text) <
    UserPasswordChange.MinPasswordLength then
    begin
      MessageDlg(Format(UserSettings.CommonMessages.ChangePasswordError.
        MinPasswordLength, [UserPasswordChange.MinPasswordLength]), mtWarning, [mbOK], 0);
      TChangeUserPasswordForm(FChangePasswordForm).EditNova.SetFocus;
      Exit;
    end;

  if Pos(LowerCase(TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text),
    'abcdeasdfqwerzxcv1234567890321654987teste' + LowerCase(CurrentUser.UserName) +
    LowerCase(CurrentUser.UserLogin)) > 0 then
    begin
      MessageDlg(UserSettings.CommonMessages.ChangePasswordError.InvalidNewPassword, mtWarning, [mbOK], 0);
      TChangeUserPasswordForm(FChangePasswordForm).EditNova.SetFocus;
      Exit;
    end;

  if Assigned(OnChangePassword) then
    OnChangePassword(Self, CurrentUser.UserID, CurrentUser.UserLogin,
      CurrentUser.Password, TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text);

  ChangePassword(CurrentUser.UserID, TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text);

  case Self.Criptografia of
    cStandard:  CurrentUser.Password := TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text;
    cMD5:       CurrentUser.Password := MD5Sum(TChangeUserPasswordForm(FChangePasswordForm).EditNova.Text);
  end;

  if CurrentUser.Password = '' then
    MessageDlg(Format(UserSettings.CommonMessages.BlankPassword,
      [CurrentUser.UserLogin]), mtInformation, [mbOK], 0)
  else
    MessageDlg(UserSettings.CommonMessages.PasswordChanged, mtInformation,
      [mbOK], 0);

  if TChangeUserPasswordForm(FChangePasswordForm).ForcarTroca = True then
    TChangeUserPasswordForm(FChangePasswordForm).ForcarTroca := False;

{$IFNDEF FPC}
  if (Assigned(FMailUserControl)) and (FMailUserControl.SenhaTrocada.Ativo) then
    begin
      with CurrentUser do
        begin
          try
            FMailUserControl.EnviaEmailSenhaTrocada(UserName, CurrentUser.UserLogin,
              TTrocaSenha(FFormTrocarSenha).EditNova.Text, Email, '', EncryptKey);
          except
            on e: Exception do
              begin
                Log(e.Message, 2);
              end;
          end;
        end;
    end;
{$ENDIF}

  TChangeUserPasswordForm(FChangePasswordForm).Close;
end;

procedure TUserControl.SetUserSettings(const Value: TUCUserSettings);
begin
  UserSettings := Value;
end;

procedure TUserControl.SetfrmLoginWindow(Form: TCustomForm);
begin
  with UserSettings.Login, Form as TLoginForm do
    begin
      Caption := WindowCaption;
      LbUsuario.Caption := LabelUser;
      LbSenha.Caption := LabelPassword;
      btOK.Caption := UserSettings.Login.btOK;
      BtCancela.Caption := btCancel;

      if LeftImage <> nil then
        ImgLeft.Picture.Assign(LeftImage);
      if BottomImage <> nil then
        ImgBottom.Picture.Assign(BottomImage);
      if TopImage <> nil then
        ImgTop.Picture.Assign(TopImage);

{$IFNDEF FPC}
      if Assigned(FMailUserControl) then
        begin
          lbEsqueci.Visible := FMailUserControl.EsqueceuSenha.Ativo;
          lbEsqueci.Caption := FMailUserControl.EsqueceuSenha.LabelLoginForm;
        end;
{$ENDIF}

      StatusBar.Visible := Login.FMaxLoginAttempts > 0;
      StatusBar.Panels[1].Text := '0';
      StatusBar.Panels[3].Text := IntToStr(Login.FMaxLoginAttempts);
    end;
end;

procedure TUserControl.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  if (AOperation = opRemove) then
    begin
      if AComponent = User.MenuItem then
        User.MenuItem := nil;
      if AComponent = User.Action then
        User.Action := nil;
      if AComponent = UserPasswordChange.Action then
        UserPasswordChange.Action := nil;
      if AComponent = UserPasswordChange.MenuItem then
        UserPasswordChange.MenuItem := nil;

      if AComponent = UsersLogoff.Action then
        UsersLogoff.Action := nil;
      if AComponent = UsersLogoff.MenuItem then
        UsersLogoff.MenuItem := nil;

      if AComponent = ControlRight.MainMenu then
        ControlRight.MainMenu := nil;
      if AComponent = ControlRight.ActionList then
        ControlRight.ActionList := nil;
      {$IFNDEF FPC}
      { .$IFDEF UCACTMANAGER }
      if AComponent = ControlRight.ActionManager then
        ControlRight.ActionManager := nil;
      if AComponent = ControlRight.ActionMainMenuBar then
        ControlRight.ActionMainMenuBar := nil;
      { .$ENDIF }
      {$ENDIF}

      if AComponent = FDataConnector then
        begin
          if CurrentUser.UserID <> 0 then
            UsersLogged.DelCurrentUser;
          FDataConnector := nil;
        end;

      {$IFNDEF FPC}
      if AComponent = FMailUserControl then
        FMailUserControl := nil;
      {$ENDIF}
    end;
  inherited Notification(AComponent, AOperation);
end;

procedure TUserControl.ActionLogoff(Sender: TObject);
begin
  Self.Logoff;
end;

procedure TUserControl.Log(Msg: string; Level: integer);
begin
  // Adicionado ao log a identificação da Aplicação
  if not LogControl.Active then
    Exit;

  if Assigned(DataConnector) then
    DataConnector.UCExecSQL('INSERT INTO ' + LogControl.TableLog +
      '(APPLICATIONID, IDUSER, MSG, DATA, NIVEL) VALUES ( ' +
      QuotedStr(Self.ApplicationID) + ', ' + IntToStr(CurrentUser.UserID) +
      ', ' + QuotedStr(Copy(Msg, 1, 250)) + ', ' +
      QuotedStr(FormatDateTime('YYYYMMDDhhmmss', now)) + ', ' +
      IntToStr(Level) + ')');
end;

procedure TUserControl.RegistraCurrentUser(Dados: TDataSet); // Pass:String );
var
  SQLstmt: string;
begin
  with CurrentUser do
    begin
      UserID := Dados.FieldByName(TableUsers.FieldUserID).AsInteger;
      UserName := Dados.FieldByName(TableUsers.FieldUserName).AsString;
      UserLogin := Dados.FieldByName(TableUsers.FieldLogin).AsString;
      DateExpiration := StrToDateDef(Dados.FieldByName(
        TableUsers.FieldDateExpired).AsString, now);
      UserNotExpired := Dados.FieldByName(TableUsers.FieldUserExpired)
        .AsInteger = -1;
      UserDaysExpired := Dados.FieldByName(TableUsers.FieldUserDaysSun).AsInteger;
      // PassLivre       := Pass;
      case Self.Criptografia of
        cStandard: Password := Decrypt(Dados.FieldByName(TableUsers.FieldPassword).AsString, EncryptKey);
        cMD5:      Password := Dados.FieldByName(TableUsers.FieldPassword).AsString;
      end;

      Email := Dados.FieldByName(TableUsers.FieldEmail).AsString;
      Privileged := StrToBool(Dados.FieldByName(TableUsers.FieldPrivileged).AsString);
      Profile := Dados.FieldByName(TableUsers.FieldProfile).AsInteger;

      SQLstmt := Format('SELECT %s AS ObjName,' + ' %s AS UCKey,' +
        ' %s AS UserID' + ' FROM %s' + ' WHERE %s = %s AND %s = %s',
        [TableRights.FieldComponentName, TableRights.FieldKey,
        TableRights.FieldUserID, TableRights.TableName, TableRights.FieldUserID,
        IntToStr(UserID), TableRights.FieldModule, QuotedStr(ApplicationID)]);

      if Assigned(UserProfile) then
        UserProfile := nil;
      UserProfile := DataConnector.UCGetSQLDataset(SQLstmt);

      // Aplica Permissoes do Perfil do usuario
      if CurrentUser.Profile > 0 then
        begin
          SQLstmt := Format('SELECT %s AS ObjName,' + ' %s AS UCKey,' +
            ' %s AS UserID' + ' FROM %s' + ' WHERE %s = %s AND %s = %s',
            [TableRights.FieldComponentName, TableRights.FieldKey,
            TableRights.FieldUserID, TableRights.TableName, TableRights.FieldUserID,
            IntToStr(CurrentUser.Profile), TableRights.FieldModule,
            QuotedStr(ApplicationID)]);

          if Assigned(GroupProfile) then
            GroupProfile := nil;
          GroupProfile := DataConnector.UCGetSQLDataset(SQLstmt);

        end
      else
        GroupProfile := nil;

      if Assigned(OnLoginSucess) then
        OnLoginSucess(Self, UserID, UserLogin, UserName, Password, Email,
          Privileged);
    end;

  // Cesar: 13/07/2005
  if (CurrentUser.UserID <> 0) then
    UsersLogged.AddCurrentUser;

  ApplyRightsUCControlMonitor;
  NotificationLoginMonitor;

  if ((FLogin.fDateExpireActive = True) and (Date > CurrentUser.DateExpiration) and
    (CurrentUser.UserNotExpired = False)) then
    begin
      MessageDlg(UserSettings.CommonMessages.PasswordExpired, mtInformation, [mbOK], 0);

      if FChangePasswordForm = nil then
        CriaFormTrocarSenha;
      TChangeUserPasswordForm(FChangePasswordForm).ForcarTroca := True;
      FChangePasswordForm.ShowModal;
      FreeAndNil(FChangePasswordForm);
      { Incrementa a Data de Expiração em x dias após a troca de senha }
      CurrentUser.DateExpiration := CurrentUser.DateExpiration + CurrentUser.UserDaysExpired;
    end;
end;

procedure TUserControl.TryAutoLogon;
begin
  if VerificaLogin(Login.AutoLogin.User, Login.AutoLogin.Password) <> 0 then
    begin
      if Login.AutoLogin.MessageOnError then
        MessageDlg(UserSettings.CommonMessages.AutoLogonError, mtWarning, [mbOK], 0);
      ShowLogin;
    end;
end;

function TUserControl.VerificaLogin(User, Password: string;
  SoVerificarUsuarioAdmin: boolean = False): integer; // Boolean;
var
  APassword: string;
  Key: string;
  SQLstmt: string;
  ADataSet: TDataSet;
  VerifyKey: string;
begin
  case Self.Criptografia of
    cStandard: APassword := TableUsers.FieldPassword + ' = ' + QuotedStr(Encrypt(Password, EncryptKey));
    cMD5:      APassword := TableUsers.FieldPassword + ' = ' + QuotedStr(MD5Sum(Password));
  end;
  if SoVerificarUsuarioAdmin = False then
    SQLstmt := 'SELECT * FROM ' + TableUsers.TableName + ' WHERE ' +
      TableUsers.FieldLogin + ' = ' + QuotedStr(User) + ' AND ' + APassword
  else
    SQLstmt := 'SELECT * FROM ' + TableUsers.TableName + ' WHERE ' +
      TableUsers.FieldLogin + ' = ' + QuotedStr(User) + ' AND ' + APassword +
      ' AND ' + TableUsers.FieldPrivileged + ' = ' + BoolToStr(SoVerificarUsuarioAdmin);

  ADataSet := DataConnector.UCGetSQLDataset(SQLstmt);
  with ADataSet do
    try
      if not IsEmpty then
        begin
          case Self.Criptografia of
            cStandard:  begin
                          Key := Decrypt(ADataSet.FieldByName(TableUsers.FieldKey).AsString, EncryptKey);
                          VerifyKey := ADataSet.FieldByName(TableUsers.FieldUserID).AsString +
                            ADataSet.FieldByName(TableUsers.FieldLogin).AsString +
                            Decrypt(ADataSet.FieldByName(TableUsers.FieldPassword).AsString,
                            EncryptKey);
                        end;
            cMD5:       begin
                          Key := ADataSet.FieldByName(TableUsers.FieldKey).AsString;
                          VerifyKey := MD5Sum(ADataSet.FieldByName(TableUsers.FieldUserID)
                            .AsString + ADataSet.FieldByName(TableUsers.FieldLogin).AsString
                            + ADataSet.FieldByName(TableUsers.FieldPassword).AsString);
                        end;
          end;
          if Key <> VerifyKey then
            begin
              Result := 1;
              if Assigned(OnLoginError) then
                OnLoginError(Self, User, Password);
            end
          else
            begin
              if (ADataSet.FieldByName(TableUsers.FieldUserInative).AsInteger = 0) then
                begin
                  if SoVerificarUsuarioAdmin = False then
                    RegistraCurrentUser(ADataSet); // ,PassWord);
                  Result := 0;
                end
              else
                Result := 2;
            end;
        end
      else
        begin
          Result := 1;
          if Assigned(OnLoginError) then
            OnLoginError(Self, User, Password);
        end;
    finally
      Close;
      Free;
    end;
end;

procedure TUserControl.Logoff;
begin
  if Assigned(OnLogoff) then
    OnLogoff(Self, CurrentUser.UserID);

  LockControlsUCControlMonitor;
  UsersLogged.DelCurrentUser;
  CurrentUser.UserID := 0;
  if LoginMode = lmActive then
    ShowLogin;
  ApplyRights;
end;

function TUserControl.AddUser(Login, Password, Name, Mail: string;
  Profile, UserExpired, DaysExpired: integer; Privuser: boolean): integer;
var
  Key: string;
  SQLstmt: string;
  APassword: string;
begin
  case Self.Login.CharCasePass of
    ecNormal:    ;
    ecUpperCase: Password := UpperCase(Password);
    ecLowerCase: Password := LowerCase(Password);
  end;

  case Self.Login.CharCaseUser of
    ecNormal:    ;
    ecUpperCase: Login := UpperCase(Login);
    ecLowerCase: Login := LowerCase(Login);
  end;

  with DataConnector.UCGetSQLDataset('Select Max(' + TableUsers.FieldUserID +') as IdUser from ' + TableUsers.TableName) do
    begin
      Result := StrToIntDef(FieldByName('idUser').AsString, 0) + 1;
      Close;
      Free;
    end;

  case Self.Criptografia of
    cStandard:  begin
                  Key := Encrypt(IntToStr(Result) + Login + Password, EncryptKey);
                  APassword := Encrypt(Password, EncryptKey);
                end;
    cMD5:       begin
                  Key := MD5Sum(IntToStr(Result) + Login + MD5Sum(Password));
                  APassword := MD5Sum(Password);
                end;
  end;

  with TableUsers do
    begin
      SQLstmt := Format(
        'INSERT INTO %s( %s, %s, %s, %s, %s, %s, %s, %s, %s , %s , %s , %s , %s ) VALUES(%d, %s, %s, %s, %s, %s, %d, %s, %s , %s , %d , %d , %s )',
        [TableName, FieldUserID, FieldUserName, FieldLogin, FieldPassword,
        FieldEmail, FieldPrivileged, FieldProfile, FieldTypeRec, FieldKey,
        FieldDateExpired, FieldUserExpired, FieldUserDaysSun, FieldUserInative,
        Result, QuotedStr(Name), QuotedStr(Login), QuotedStr(APassword),
        QuotedStr(Mail), BoolToStr(Privuser), Profile, QuotedStr('U'),
        QuotedStr(Key), QuotedStr(FormatDateTime('dd/mm/yyyy', Date +
        FLogin.fDaysOfSunExpired)), UserExpired, DaysExpired, '0']);
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL(SQLstmt);
    end;

  if Assigned(OnAddUser) then
    OnAddUser(Self, Login, Password, Name, Mail, Profile, Privuser);
end;

procedure TUserControl.ChangePassword(IdUser: integer; NewPassword: string);
var
  Login: string;
  Senha: string;
  Key: string;
  SQLstmt: string;
begin
  inherited;

  case Self.Login.CharCasePass of
    ecNormal:    ;
    ecUpperCase: NewPassword := UpperCase(NewPassword);
    ecLowerCase: NewPassword := LowerCase(NewPassword);
  end;

  SQLstmt := 'Select ' + TableUsers.FieldLogin + ' as login, ' +
    TableUsers.FieldPassword + ' as senha from ' + TableUsers.TableName +
    ' ' + 'where ' + TableUsers.FieldUserID + ' = ' + IntToStr(IdUser);

  with DataConnector.UCGetSQLDataset(SQLstmt) do
    begin
      Login := FieldByName('Login').AsString;
      case Self.Criptografia of
        cStandard:  begin
                      Key := Encrypt(IntToStr(IdUser) + Login + NewPassword, EncryptKey);
                      Senha := Decrypt(FieldByName('Senha').AsString, EncryptKey);
                    end;
        cMD5:       begin
                      Key := MD5Sum(IntToStr(IdUser) + Login + MD5Sum(NewPassword));
                      Senha := FieldByName('Senha').AsString;
                    end;
      end;

      Close;
      Free;
    end;

  case Self.Criptografia of
    cStandard:  SQLstmt := 'Update ' + TableUsers.TableName + ' Set ' +
                  TableUsers.FieldPassword + ' = ' +
                  QuotedStr(Encrypt(NewPassword, EncryptKey)) + ', ' +
                  TableUsers.FieldKey + ' = ' + QuotedStr(Key) + ', ' +
                  TableUsers.FieldDateExpired + ' = ' +
                  QuotedStr(FormatDateTime('dd/mm/yyyy', Date +
                  FCurrentUser.UserDaysExpired)) + ' Where ' + TableUsers.FieldUserID +
                  ' = ' + IntToStr(IdUser);
    cMD5:       SQLstmt := 'Update ' + TableUsers.TableName + ' Set ' +
                  TableUsers.FieldPassword + ' = ' + QuotedStr(MD5Sum(NewPassword)) +
                  ', ' + TableUsers.FieldKey + ' = ' + QuotedStr(Key) + ', ' +
                  TableUsers.FieldDateExpired + ' = ' +
                  QuotedStr(FormatDateTime('dd/mm/yyyy', Date +
                  FCurrentUser.UserDaysExpired)) + ' Where ' + TableUsers.FieldUserID +
                  ' = ' + IntToStr(IdUser);
  end;

  if Assigned(DataConnector) then
    DataConnector.UCExecSQL(SQLstmt);

  if Assigned(OnChangePassword) then
    OnChangePassword(Self, IdUser, Login, Senha, NewPassword);
end;

procedure TUserControl.ChangeUser(IdUser: integer; Login, Name, Mail: string;
  Profile, UserExpired, UserDaysSun, Status: integer; Privuser: boolean);
var
  Key: string;
  Password: string;
  SQLstmt: string;
begin
  SQLstmt := 'SELECT ' + TableUsers.FieldPassword + ' AS SENHA FROM ' +
    TableUsers.TableName + ' WHERE ' + TableUsers.FieldUserID + ' = ' +
    IntToStr(IdUser);

  with DataConnector.UCGetSQLDataset(SQLstmt) do
    begin
      case Self.Criptografia of
        cStandard:  begin
                      Password := Decrypt(FieldByName('Senha').AsString, EncryptKey);
                      Key := Encrypt(IntToStr(IdUser) + Login + Password, EncryptKey);
                    end;
        cMD5:       begin
                      Password := FieldByName('Senha').AsString;
                      Key := MD5Sum(IntToStr(IdUser) + Login + Password);
                    end;
      end;
      Close;
      Free;
    end;

  with TableUsers do
    if Assigned(DataConnector) then
      DataConnector.UCExecSQL('Update ' + TableName + ' Set ' +
        FieldUserName + ' = ' + QuotedStr(Name) + ', ' + FieldLogin +
        ' = ' + QuotedStr(Login) + ', ' + FieldEmail + ' = ' +
        QuotedStr(Mail) + ', ' + FieldPrivileged + ' = ' + BoolToStr(Privuser) +
        ', ' + FieldProfile + ' = ' + IntToStr(Profile) + ', ' +
        FieldKey + ' = ' + QuotedStr(Key) + ', ' + FieldUserExpired +
        ' = ' + IntToStr(UserExpired) + ' , ' + FieldUserDaysSun +
        ' = ' + IntToStr(UserDaysSun) + ' , ' + FieldUserInative +
        ' = ' + IntToStr(Status) + ' where ' + FieldUserID + ' = ' + IntToStr(IdUser));
  if Assigned(OnChangeUser) then
    OnChangeUser(Self, IdUser, Login, Name, Mail, Profile, Privuser);
end;

procedure TUserControl.CriaTabelaMsgs(const TableName: string);
begin
  if Assigned(DataConnector) then
    DataConnector.UCExecSQL('CREATE TABLE ' + TableName + ' ( ' +
      'IdMsg   ' + UserSettings.Type_Int + ' , ' + 'UsrFrom ' +
      UserSettings.Type_Int + ' , ' + 'UsrTo   ' + UserSettings.Type_Int +
      ' , ' + 'Subject ' + UserSettings.Type_VarChar + '(50),' +
      'Msg     ' + UserSettings.Type_VarChar + '(255),' + 'DtSend  ' +
      UserSettings.Type_VarChar + '(12),' + 'DtReceive  ' +
      UserSettings.Type_VarChar + '(12) )');
end;

destructor TUserControl.Destroy;
begin
  if not (csDesigning in ComponentState) then
    FUsersLogged.DelCurrentUser;

  FCurrentUser.Free;
  FControlRight.Free;
  FLogin.Free;
  FLogControl.Free;
  FUser.Free;
  FUserProfile.Free;
  FUserPasswordChange.Free;
  FUsersLogoff.Free;
  FUsersLogged.Free;
  FUserSettings.Free;
  FNotAllowedItems.Free;
  FExtraRights.Free;
  FTableUsers.Free;
  FTableRights.Free;
  FTableUsersLogged.Free;

  if Assigned(FControlList) then
    FControlList.Free;

  if Assigned(FLoginMonitorList) then
    FLoginMonitorList.Free;

  inherited Destroy;
end;

procedure TUserControl.SetExtraRights(Value: TUCExtraRights);
begin

end;

procedure TUserControl.HideField(Sender: TField; var Text: string;
  DisplayText: boolean);
begin
  Text := '(Campo Bloqueado)';
end;

procedure TUserControl.StartLogin;
begin
  CurrentUser.UserID := 0;
  ShowLogin;
  ApplyRights;
end;

procedure TUserControl.Execute;
begin
  if Assigned(FThUCRun) then
    FThUCRun.Terminate;
  if not Assigned(DataConnector) then
    Exit;

  try
    if not DataConnector.UCFindTable(FTableRights.TableName) then
      CriaTabelaRights;

    if not DataConnector.UCFindTable(FTableRights.TableName + 'EX') then
      CriaTabelaRights(True); // extra rights table

    if not DataConnector.UCFindTable(TableUsersLogged.TableName) then
      UsersLogged.CriaTableUserLogado;

    if LogControl.Active then
      begin
        if not DataConnector.UCFindTable(LogControl.TableLog) then
          CriaTabelaLog;
      end;

    CriaTabelaUsuarios(DataConnector.UCFindTable(FTableUsers.TableName));

    // Atualizador de Versoes
    AtualizarVersao;

    // testa campo KEY qmd 28-02-2005
    if FCheckValidationKey then
      DoCheckValidationField;

  finally
    if LoginMode = lmActive then
      begin
        if not Login.AutoLogin.Active then
          ShowLogin
        else
          TryAutoLogon;
      end;
    ApplyRights;
  end;
end;

procedure TUserControl.AtualizarVersao;
var
  Sql: string;
  DataSet: TDataSet;
begin
  { Procura o campo FieldUserDaysSun na tabela de usuarios se o mesmo não existir cria }
  try
    Sql := Format('select * from %s', [FTableUsers.TableName]);
    DataSet := DataConnector.UCGetSQLDataset(Sql);

    if DataSet.FindField(FTableUsers.FieldDateExpired) = nil then
      begin
        Sql := Format('alter table %s add %s %s(10)',
          [FTableUsers.TableName, FTableUsers.FieldDateExpired,
          UserSettings.Type_Char]);

        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
        Sql := Format('update %s set %s = %s where %s = ''U''',
          [FTableUsers.TableName, FTableUsers.FieldDateExpired,
          QuotedStr(FormatDateTime('dd/mm/yyyy', Date + FLogin.fDaysOfSunExpired)),
          FTableUsers.FieldTypeRec]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
      end;

    if DataSet.FindField(FTableUsers.FieldUserExpired) = nil then
      begin
        Sql := Format('alter table %s add %s %s',
          [FTableUsers.TableName, FTableUsers.FieldUserExpired,
          UserSettings.Type_Int]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
        Sql := Format('update %s set %s = 1 where %s = ''U''',
          [FTableUsers.TableName, FTableUsers.FieldUserExpired,
          FTableUsers.FieldTypeRec]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
      end;

    if DataSet.FindField(FTableUsers.FieldUserDaysSun) = nil then
      begin // Cria campo  setado no FieldUserDaysSun na tabela de usuarios
        Sql := Format('alter table %s add %s %s',
          [FTableUsers.TableName, FTableUsers.FieldUserDaysSun,
          UserSettings.Type_Int]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
        Sql := Format('update %s set %s = 30 where %s = ''U''',
          [FTableUsers.TableName, FTableUsers.FieldUserDaysSun,
          FTableUsers.FieldTypeRec]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
      end;

    if DataSet.FindField(FTableUsers.FieldUserInative) = nil then
      begin // Cria campo  setado no FieldUserInative na tabela de usuarios
        Sql := Format('alter table %s add %s %s',
          [FTableUsers.TableName, FTableUsers.FieldUserInative,
          UserSettings.Type_Int]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);

        Sql := Format('update %s set %s = 0 where %s = ''U''',
          [FTableUsers.TableName, FTableUsers.FieldUserInative,
          FTableUsers.FieldTypeRec]);
        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(Sql);
      end;

  finally
    FreeAndNil(DataSet);
  end;

end;

procedure TUserControl.DoCheckValidationField;
var
  TempDS: TDataSet;
  Key: string;
  Login: string;
  Password: string;
  UserID: integer;
begin
  // verifica tabela de usuarios
  TempDS := DataConnector.UCGetSQLDataset('SELECT * FROM ' + TableUsers.TableName);

  if TempDS.FindField(TableUsers.FieldKey) = nil then
    begin
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL('ALTER TABLE ' + TableUsers.TableName +
          ' ADD ' + TableUsers.FieldKey + ' ' + UserSettings.Type_VarChar + ' (255)');
      TempDS.First;
      with TempDS do
        while not EOF do
          begin
            UserID := TempDS.FieldByName(TableUsers.FieldUserID).AsInteger;
            Login := TempDS.FieldByName(TableUsers.FieldLogin).AsString;
            case Self.Criptografia of
              cStandard:  begin
                            Password := Decrypt(TempDS.FieldByName(TableUsers.FieldPassword).AsString, EncryptKey);
                            Key := Encrypt(IntToStr(UserID) + Login + Password, EncryptKey);
                          end;
              cMD5:       begin
                            Password := TempDS.FieldByName(TableUsers.FieldPassword).AsString;
                            Key := MD5Sum(IntToStr(UserID) + Login + Password);
                          end;
            end;
            if Assigned(DataConnector) then
              DataConnector.UCExecSQL(Format('UPDATE %s SET %s = %s WHERE %s = %d',
                [TableUsers.TableName, TableUsers.FieldKey, QuotedStr(Key),
                TableUsers.FieldUserID, TempDS.FieldByName(TableUsers.FieldUserID).AsInteger]));
            Next;
          end;
    end;

  TempDS.Close;
  FreeAndNil(TempDS);

  // verifica tabela de permissoes
  TempDS := DataConnector.UCGetSQLDataset('SELECT * FROM ' + TableRights.TableName);

  if TempDS.FindField(TableRights.FieldKey) = nil then
    begin
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL('ALTER TABLE ' + TableRights.TableName +
          ' ADD ' + TableUsers.FieldKey + ' ' + UserSettings.Type_VarChar + ' (255)');
      TempDS.First;
      with TempDS do
        while not EOF do
          begin
            UserID := TempDS.FieldByName(TableRights.FieldUserID).AsInteger;
            Login := TempDS.FieldByName(TableRights.FieldComponentName).AsString;
            case Self.Criptografia of
              cStandard: Key := Encrypt(IntToStr(UserID) + Login, EncryptKey);
              cMD5:      Key := MD5Sum(IntToStr(UserID) + Login);
            end;
            if Assigned(DataConnector) then
              DataConnector.UCExecSQL
              (Format('UPDATE %s SET %s = %s where %s = %d and %s = %s and %s = %s',
                [TableRights.TableName, TableRights.FieldKey, QuotedStr(Key),
                TableRights.FieldUserID, TempDS.FieldByName(TableRights.FieldUserID)
                .AsInteger, TableRights.FieldModule, QuotedStr(ApplicationID),
                TableRights.FieldComponentName, QuotedStr(Login)]));
            Next;
          end;
    end;
  TempDS.Close;
  FreeAndNil(TempDS);

  // verifica tabela de permissoes extendidas
  TempDS := DataConnector.UCGetSQLDataset('SELECT * FROM ' +
    TableRights.TableName + 'EX');
  if TempDS.FindField(TableRights.FieldKey) = nil then
    begin
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL('ALTER TABLE ' + TableRights.TableName +
          'EX ADD ' + TableUsers.FieldKey + '' + UserSettings.Type_VarChar + ' (255)');
      TempDS.First;
      with TempDS do
        while not EOF do
          begin
            UserID := TempDS.FieldByName(TableRights.FieldUserID).AsInteger;
            Login := TempDS.FieldByName(TableRights.FieldComponentName).AsString;
            // componentname
            Password := TempDS.FieldByName(TableRights.FieldFormName).AsString;
            // formname
            case Self.Criptografia of
              cStandard: Key := Encrypt(IntToStr(UserID) + Login, EncryptKey);
              cMD5:      Key := MD5Sum(IntToStr(UserID) + Login);
            end;
            if Assigned(DataConnector) then
              DataConnector.UCExecSQL
              (Format('UPDATE %s SET %s = %s' + ' WHERE %s = %d AND' +
                ' %s = %s AND %s = %s AND' + ' %s = %s',
                [TableRights.TableName + 'EX', TableRights.FieldKey,
                QuotedStr(Key), TableRights.FieldUserID,
                TempDS.FieldByName(TableRights.FieldUserID).AsInteger,
                TableRights.FieldModule, QuotedStr(ApplicationID),
                TableRights.FieldComponentName, QuotedStr(Login), // componente name
                TableRights.FieldFormName, QuotedStr(Password)])); // formname
            Next;
          end;
    end;
  TempDS.Close;
  FreeAndNil(TempDS);
end;

procedure TUserControl.ShowChangePassword;
begin
  ActionTrocaSenha(Self);
end;

procedure TUserControl.ShowNewConfig;
begin
  FSettingsForm := TUserControlForm.Create(Self);
  with TUserControlForm(FSettingsForm) do
  begin
    Position := UserSettings.WindowsPosition;
    FUserControl := Self;
    ShowModal;
  end;
  FreeAndNil(FSettingsForm);
end;

procedure TUserControl.AddUCControlMonitor(UCControl: TUCControls);
begin
  FControlList.Add(UCControl);
end;

procedure TUserControl.ApplyRightsUCControlMonitor;
var
  I: integer;
begin
  for I := 0 to Pred(FControlList.Count) do
    TUCControls(FControlList.Items[I]).ApplyRights;
end;

procedure TUserControl.DeleteUCControlMonitor(UCControl: TUCControls);
var
  I: integer;
  SLControls: TStringList;
begin
  if not Assigned(FControlList) then
    Exit;
  SLControls := TStringList.Create;
  for I := 0 to Pred(FControlList.Count) do
    if TUCControls(FControlList.Items[I]) = UCControl then
      SLControls.Add(IntToStr(I));

  for I := 0 to Pred(SLControls.Count) do
    FControlList.Delete(StrToInt(SLControls[I]));

  FreeAndNil(SLControls);
end;

procedure TUserControl.LockControlsUCControlMonitor;
var
  I: integer;
begin
  for I := 0 to Pred(FControlList.Count) do
    TUCControls(FControlList.Items[I]).LockControls;
end;

procedure TUserControl.SetDataConnector(const Value: TUCDataConnector);
begin
  FDataConnector := Value;
  if Assigned(Value) then
    Value.FreeNotification(Self);
end;

procedure TUserControl.AddLoginMonitor(UCAppMessage: TUCApplicationMessage);
begin
  FLoginMonitorList.Add(UCAppMessage);
end;

procedure TUserControl.DeleteLoginMonitor(UCAppMessage: TUCApplicationMessage);
var
  I: integer;
  SLControls: TStringList;
begin
  SLControls := TStringList.Create;
  if Assigned(FLoginMonitorList) then
    for I := 0 to Pred(FLoginMonitorList.Count) do
      if TUCApplicationMessage(FLoginMonitorList.Items[I]) = UCAppMessage then
        SLControls.Add(IntToStr(I));
  if Assigned(SLControls) then
    for I := 0 to Pred(SLControls.Count) do
      FLoginMonitorList.Delete(StrToInt(SLControls[I]));
  SysUtils.FreeAndNil(SLControls);
end;

procedure TUserControl.NotificationLoginMonitor;
var
  I: integer;
begin
  for I := 0 to Pred(FLoginMonitorList.Count) do
    TUCApplicationMessage(FLoginMonitorList.Items[I]).CheckMessages;
end;

procedure TUserControl.ShowLogin;
begin
  FRetry := 0;
  if Assigned(OnCustomLoginForm) then
    OnCustomLoginForm(Self, FLoginForm);

  if FLoginForm = nil then
  begin
    FLoginForm := TLoginForm.Create(Self);
    with FLoginForm as TLoginForm do
    begin
      SetfrmLoginWindow(TLoginForm(FLoginForm));
      FUserControl := Self;
      btOK.OnClick := ActionOKLogin;
      onCloseQuery := TestaFecha;
      Position := Self.UserSettings.WindowsPosition;
      lbEsqueci.OnClick := ActionEsqueceuSenha;
    end;
  end;
  FLoginForm.ShowModal;

  FreeAndNil(FLoginForm);
end;

procedure TUserControl.ActionOKLogin(Sender: TObject);
var
  TempUser: string;
  TempPassword: string;
  retorno: integer;
begin
  TempUser := TLoginForm(FLoginForm).EditUsuario.Text;
  TempPassword := TLoginForm(FLoginForm).EditSenha.Text;

  if Assigned(OnLogin) then
    OnLogin(Self, TempUser, TempPassword);
  retorno := VerificaLogin(TempUser, TempPassword);

  if retorno = 0 then
    TLoginForm(FLoginForm).Close
  else
  begin
    if retorno = 1 then
      MessageDlg(UserSettings.CommonMessages.InvalidLogin, mtWarning, [mbOK], 0)
    else if retorno = 2 then
      MessageDlg(UserSettings.CommonMessages.InactiveLogin, mtWarning,
        [mbOK], 0);

    Inc(FRetry);
    if TLoginForm(FLoginForm).StatusBar.Visible then
      TLoginForm(FLoginForm).StatusBar.Panels[1].Text := IntToStr(FRetry);

    if (Login.MaxLoginAttempts > 0) and (FRetry = Login.MaxLoginAttempts) then
    begin
      MessageDlg(Format(UserSettings.CommonMessages.MaxLoginAttemptsError,
        [Login.MaxLoginAttempts]), mtError, [mbOK], 0);
      Application.Terminate;
    end;
  end;
end;

procedure TUserControl.TestaFecha(Sender: TObject; var CanClose: boolean);
begin
  if FLoginForm.ModalResult = mrOk then
    CanClose := (CurrentUser.UserID > 0)
  else
    CanClose := True;
end;

procedure TUserControl.ApplyRights;
begin
  if Self.CurrentUser.UserID <> 0 then
  begin
    ApplyRightsObj(Self.CurrentUser.UserProfile);

    // Aplica Permissoes do Perfil do usuario
    if CurrentUser.Profile > 0 then
      ApplyRightsObj(Self.CurrentUser.GroupProfile, True);

    if Assigned(FAfterLogin) then
      FAfterLogin(Self);
  end;
end;

procedure TUserControl.ApplyRightsObj(ADataset: TDataSet; FProfile: boolean = False);
var
  I: integer;
  Encontrado: boolean;
  KeyField: string;
  Temp: string;
  ObjetoAction: TObject;
  OwnerMenu: TComponent;
begin
  // Permissao de Menus QMD
  Encontrado := False;

  if ADataset.State = dsInactive then
    ADataset.Open;

  if Assigned(ControlRight.MainMenu) then
  begin
    OwnerMenu := ControlRight.MainMenu.Owner;
    for I := 0 to Pred(OwnerMenu.ComponentCount) do
      if (OwnerMenu.Components[I].ClassType = TMenuItem)
        and (TMenuItem(OwnerMenu.Components[I]).GetParentMenu = ControlRight.MainMenu) then
      begin
        if not FProfile then
          begin
            Encontrado := ADataset.Locate('ObjName', OwnerMenu.Components[I].Name, []);
            KeyField := ADataset.FindField('UCKey').AsString;
            // verifica key
            if Encontrado then
              case Self.Criptografia of
                cStandard:  Encontrado := (KeyField = Encrypt(ADataset.FieldByName('UserID').AsString +
                              ADataset.FieldByName('ObjName').AsString, EncryptKey));
                cMD5:       Encontrado := (KeyField = MD5Sum(ADataset.FieldByName('UserID').AsString +
                              ADataset.FieldByName('ObjName').AsString));
              end;
            TMenuItem(OwnerMenu.Components[I]).Enabled := Encontrado;
            if not Encontrado then
              TMenuItem(OwnerMenu.Components[I]).Visible := NotAllowedItems.MenuVisible
            else
              TMenuItem(OwnerMenu.Components[I]).Visible := True;
          end
        else if ADataset.Locate('ObjName', OwnerMenu.Components[I].Name, []) then
          begin
            KeyField := ADataset.FindField('UCKey').AsString;
            case Self.Criptografia of
              cStandard: Encontrado := (KeyField = Encrypt(ADataset.FieldByName('UserID').AsString +
                           ADataset.FieldByName('ObjName').AsString, EncryptKey));
              cMD5:      Encontrado := (KeyField = MD5Sum(ADataset.FieldByName('UserID').AsString +
                           ADataset.FieldByName('ObjName').AsString));
            end;
            TMenuItem(OwnerMenu.Components[I]).Enabled := Encontrado;
            TMenuItem(OwnerMenu.Components[I]).Visible := Encontrado;
          end;
        if Assigned(OnApplyRightsMenuIt) then
          OnApplyRightsMenuIt(Self, TMenuItem(OwnerMenu.Components[I]));
      end;
  end; // Fim do controle do MainMenu

  // Permissao de Actions
  if (Assigned(ControlRight.ActionList))
  {$IFNDEF FPC}
    { .$IFDEF UCACTMANAGER } or (Assigned(ControlRight.ActionManager))
  { .$ENDIF }
  {$ENDIF}
  then
    begin
      if Assigned(ControlRight.ActionList) then
        ObjetoAction := ControlRight.ActionList
      {$IFNDEF FPC}{ .$IFDEF UCACTMANAGER }
      else
        ObjetoAction := ControlRight.ActionManager
      { .$ENDIF }
      {$ENDIF}
      ;
      for I := 0 to TActionList(ObjetoAction).ActionCount - 1 do
        begin
          if not FProfile then
            begin
              Encontrado := ADataset.Locate('ObjName', TActionList(ObjetoAction).Actions[I].Name, []);
              KeyField := ADataset.FindField('UCKey').AsString;
              // verifica key
              if Encontrado then
                case Self.Criptografia of
                  cStandard: Encontrado := (KeyField = Encrypt(ADataset.FieldByName('UserID').AsString +
                               ADataset.FieldByName('ObjName').AsString, EncryptKey));
                  cMD5:      Encontrado := (KeyField = MD5Sum(ADataset.FieldByName('UserID').AsString +
                               ADataset.FieldByName('ObjName').AsString));
                end;

              TAction(TActionList(ObjetoAction).Actions[I]).Enabled := Encontrado;

              if not Encontrado then
                TAction(TActionList(ObjetoAction).Actions[I]).Visible := NotAllowedItems.ActionVisible
              else
                TAction(TActionList(ObjetoAction).Actions[I]).Visible := True;
            end
          else if ADataset.Locate('ObjName', TActionList(ObjetoAction)
            .Actions[I].Name, []) then
            begin
              KeyField := ADataset.FindField('UCKey').AsString;
              case Self.Criptografia of
                cStandard: Encontrado := (KeyField = Encrypt(ADataset.FieldByName('UserID').AsString +
                             ADataset.FieldByName('ObjName').AsString, EncryptKey));
                cMD5:      Encontrado := (KeyField = MD5Sum(ADataset.FieldByName('UserID').AsString +
                             ADataset.FieldByName('ObjName').AsString));
              end;
              TAction(TActionList(ObjetoAction).Actions[I]).Enabled := Encontrado;
              TAction(TActionList(ObjetoAction).Actions[I]).Visible := Encontrado;
            end;

          if Assigned(OnApplyRightsActionIt) then
            OnApplyRightsActionIt(Self, TAction(TActionList(ObjetoAction).Actions[I]));
        end;
    end; // Fim das permissões de Actions

{$IFNDEF FPC}
  { .$IFDEF UCACTMANAGER }
  if Assigned(ControlRight.ActionMainMenuBar) then
    for Contador := 0 to ControlRight.ActionMainMenuBar.ActionClient.Items.Count
      - 1 do
      begin
        Temp := IntToStr(Contador);
        if ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Items.Count > 0 then
          begin
            if Self.Criptografia = cPadrao then
              ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)
                ].Visible :=
                (ADataset.Locate('ObjName', #1 + 'G' +
                ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption,
                [])) and (ADataset.FieldByName('UCKey').AsString =
                Encrypt(ADataset.FieldByName('UserID').AsString +
                ADataset.FieldByName('ObjName').AsString, EncryptKey));

            if Self.Criptografia = cMD5 then
              ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)
                ].Visible :=
                (ADataset.Locate('ObjName', #1 + 'G' +
                ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption,
                [])) and (ADataset.FieldByName('UCKey').AsString =
                MD5Sum(ADataset.FieldByName('UserID').AsString +
                ADataset.FieldByName('ObjName').AsString));

            TrataActMenuBarIt(ControlRight.ActionMainMenuBar.ActionClient.Items
              [StrToInt(Temp)], ADataset);
          end;
      end;
  { .$ENDIF }
{$ENDIF}
end;

procedure TUserControl.UnlockEX(FormObj: TCustomForm; ObjName: string);
begin
  if FormObj.FindComponent(ObjName) = nil then
    Exit;

  if FormObj.FindComponent(ObjName) is TControl then
  begin
    TControl(FormObj.FindComponent(ObjName)).Enabled := True;
    TControl(FormObj.FindComponent(ObjName)).Visible := True;
  end;

  if FormObj.FindComponent(ObjName) is TMenuItem then // TMenuItem
  begin
    TMenuItem(FormObj.FindComponent(ObjName)).Enabled := True;
    TMenuItem(FormObj.FindComponent(ObjName)).Visible := True;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsMenuIt) then
      OnApplyRightsMenuIt(Self, FormObj.FindComponent(ObjName) as TMenuItem);
  end;

  if FormObj.FindComponent(ObjName) is TAction then // TAction
  begin
    TAction(FormObj.FindComponent(ObjName)).Enabled := True;
    TAction(FormObj.FindComponent(ObjName)).Visible := True;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsActionIt) then
      OnApplyRightsActionIt(Self, FormObj.FindComponent(ObjName) as TAction);
  end;

  if FormObj.FindComponent(ObjName) is TField then // TField
  begin
    TField(FormObj.FindComponent(ObjName)).ReadOnly := False;
    TField(FormObj.FindComponent(ObjName)).Visible := True;
    TField(FormObj.FindComponent(ObjName)).onGetText := nil;
  end;
end;

procedure TUserControl.LockEX(FormObj: TCustomForm; ObjName: string;
  naInvisible: boolean);
begin
  if FormObj.FindComponent(ObjName) = nil then
    Exit;

  if FormObj.FindComponent(ObjName) is TControl then
  begin
    TControl(FormObj.FindComponent(ObjName)).Enabled := False;
    TControl(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
  end;

  if FormObj.FindComponent(ObjName) is TMenuItem then // TMenuItem
  begin
    TMenuItem(FormObj.FindComponent(ObjName)).Enabled := False;
    TMenuItem(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsMenuIt) then
      OnApplyRightsMenuIt(Self, FormObj.FindComponent(ObjName) as TMenuItem);
  end;

  if FormObj.FindComponent(ObjName) is TAction then // TAction
  begin
    TAction(FormObj.FindComponent(ObjName)).Enabled := False;
    TAction(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsActionIt) then
      OnApplyRightsActionIt(Self, FormObj.FindComponent(ObjName) as TAction);
  end;

  if FormObj.FindComponent(ObjName) is TField then // TField
  begin
    TField(FormObj.FindComponent(ObjName)).ReadOnly := True;
    TField(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
    TField(FormObj.FindComponent(ObjName)).onGetText := HideField;
  end;
end;

{$IFNDEF FPC}
{ .$IFDEF UCACTMANAGER }
procedure TUserControl.TrataActMenuBarIt(IT: TActionClientItem; ADataset: TDataSet);
var
  Contador: integer;
begin
  for Contador := 0 to IT.Items.Count - 1 do
    if IT.Items[Contador].Caption <> '-' then
      if IT.Items[Contador].Items.Count > 0 then
      begin
        IT.Items[Contador].Visible :=
          (ADataset.Locate('ObjName', #1 + 'G' + IT.Items[Contador]
          .Caption, []));
        TrataActMenuBarIt(IT.Items[Contador], ADataset);
      end;
end;

{ .$ENDIF }
{$ENDIF}

procedure TUserControl.CriaTabelaRights(ExtraRights: boolean = False);
var
  SQLstmt: string;
  TipoCampo: string;
begin
  case Self.Criptografia of
    cStandard:
      TipoCampo := UserSettings.Type_VarChar + '(250)';
    cMD5:
      TipoCampo := UserSettings.Type_VarChar + '(32)';
  end;

  with TableRights do
    if not ExtraRights then
    begin
      SQLstmt := Format('CREATE TABLE %s( %s %s, %s %s(50), %s %s(50), %s %s )',
        [TableName, FieldUserID, UserSettings.Type_Int, FieldModule,
        UserSettings.Type_VarChar, FieldComponentName,
        UserSettings.Type_VarChar, FieldKey, TipoCampo]);
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL(SQLstmt);
    end
    else
    begin
      SQLstmt :=
        Format('CREATE TABLE %sEX( %s %s, %s %s(50), %s %s(50), %s %s(50), %s %s )',
        [TableName, FieldUserID, UserSettings.Type_Int, FieldModule,
        UserSettings.Type_VarChar, FieldComponentName,
        UserSettings.Type_VarChar, FieldFormName, UserSettings.Type_VarChar,
        FieldKey, TipoCampo]);
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL(SQLstmt);
    end;
end;

procedure TUserControl.AddRightEX(IdUser: integer; Module, FormName, ObjName: string);
var
  KeyField: string;
  SQLstmt: string;
begin
  case Self.Criptografia of
    cStandard:
      KeyField := Encrypt(IntToStr(IdUser) + ObjName, EncryptKey);
    cMD5:
      KeyField := MD5Sum(IntToStr(IdUser) + ObjName);
  end;

  with TableRights do
    SQLstmt :=
      Format('INSERT INTO %sEX( %s, %s, %s, %s, %s) VALUES (%d, %s, %s, %s, %s)',
      [TableName, FieldUserID, FieldModule, FieldFormName, FieldComponentName,
      FieldKey, IdUser, QuotedStr(Module), QuotedStr(FormName),
      QuotedStr(ObjName), QuotedStr(KeyField)]);

  if Assigned(DataConnector) then
    DataConnector.UCExecSQL(SQLstmt);
end;

procedure TUserControl.AddRight(IdUser: integer; ItemRight: string);
var
  KeyField: string;
  SQLstmt: string;
begin
  if ItemRight = '' then
    Exit;

  case Self.Criptografia of
    cStandard: KeyField := Encrypt(IntToStr(IdUser) + ItemRight, EncryptKey);
    cMD5:      KeyField := MD5Sum(IntToStr(IdUser) + ItemRight);
  end;

  SQLstmt := Format('Insert into %s( %s, %s, %s, %s) Values( %d, %s, %s, %s)',
    [TableRights.TableName, TableRights.FieldUserID, TableRights.FieldModule,
    TableRights.FieldComponentName, TableRights.FieldKey, IdUser,
    QuotedStr(ApplicationID), QuotedStr(ItemRight), QuotedStr(KeyField)]);

  if Assigned(DataConnector) then
    DataConnector.UCExecSQL(SQLstmt);
end;

procedure TUserControl.AddRight(IdUser: integer; ItemRight: TObject;
  FullPath: boolean = True);
var
  Obj: TObject;
begin
  if ItemRight = nil then
    Exit;

  Obj := ItemRight;

  if Obj.ClassType = TMenuItem then
    while Assigned(Obj) and (Obj.ClassType = TMenuItem) and
      (TComponent(Obj).Name <> '') do
      begin
        AddRight(IdUser, TComponent(Obj).Name);
        if FullPath then
          Obj := TMenuItem(Obj).Parent
        else
          Obj := nil;
      end
  else
    AddRight(IdUser, TComponent(Obj).Name);
end;

procedure TUserControl.CriaTabelaLog;
begin
  if Assigned(DataConnector) then
    DataConnector.UCExecSQL(
      Format('CREATE TABLE %S  (APPLICATIONID %s(250), IDUSER %s , MSG %s(250), DATA %s(14), NIVEL %s)',
      [LogControl.TableLog, UserSettings.Type_VarChar, UserSettings.Type_Int,
      UserSettings.Type_VarChar, UserSettings.Type_VarChar,
      UserSettings.Type_Int]));
end;

{$IFNDEF FPC}
{ .$IFDEF UCACTMANAGER }
procedure TUserControl.IncPermissActMenuBar(IdUser: integer; Act: TAction);
var
  Temp: TActionClientItem;
begin
  if Act = nil then
    Exit;

  Temp := ControlRight.ActionMainMenuBar.ActionManager.FindItemByAction(Act);
  while Temp <> nil do
  begin
    AddRight(IdUser, #1 + 'G' + Temp.Caption);
    Temp := (TActionClientItem(Temp).ParentItem as TActionClientItem);
  end;
end;
{ .$ENDIF }
{$ENDIF}

procedure TUserControl.CriaTabelaUsuarios(TableExists: boolean);
var
  Count: integer;
  UserID: integer;
  CustomForm: TCustomForm;
  Messages: TStrings;
  UsersDataset: TDataSet;
  PermissionsDataset: TDataSet;
  SQLstmt: string;
  TipoCampo: string;
  InitialUser: string;
  InitialPassword: string;
begin
  case Self.Criptografia of
    cStandard: TipoCampo := UserSettings.Type_VarChar + '(250)';
    cMD5:      TipoCampo := UserSettings.Type_VarChar + '(32)';
  end;

  if not TableExists then
    with TableUsers do
      begin
        SQLstmt := Format('Create Table %s ' + // TableName
          '( ' + '%s %s, ' + // FieldUserID
          '%s %s(30), ' + // FieldUserName
          '%s %s(30), ' + // FieldLogin
          '%s %s, ' + // FieldPassword
          '%s %s(10), ' + // FieldDateExpired
          '%s %s , ' + // FieldUserExpired
          '%s %s , ' + // FieldUserDaysSun
          '%s %s(150), ' + '%s %s, ' + '%s %s(1), ' + '%s %s, ' + '%s %s,' +
          // FieldKey
          '%s %s )', [TableName, FieldUserID, UserSettings.Type_Int,
          FieldUserName, UserSettings.Type_VarChar, FieldLogin,
          UserSettings.Type_VarChar, FieldPassword, TipoCampo,
          FieldDateExpired, UserSettings.Type_Char, FieldUserExpired,
          UserSettings.Type_Int, FieldUserDaysSun, UserSettings.Type_Int,
          FieldEmail, UserSettings.Type_VarChar, FieldPrivileged,
          UserSettings.Type_Int, FieldTypeRec, UserSettings.Type_Char,
          FieldProfile, UserSettings.Type_Int, FieldKey, TipoCampo,
          FieldUserInative, UserSettings.Type_Int]);

        if Assigned(DataConnector) then
          DataConnector.UCExecSQL(SQLstmt);
      end;

  case Self.Login.CharCaseUser of
    ecNormal:    InitialUser := Self.Login.InitialLogin.User;
    ecUpperCase: InitialUser := UpperCase(Self.Login.InitialLogin.User);
    ecLowerCase: InitialUser := LowerCase(Self.Login.InitialLogin.User);
  end;

  case Self.Login.CharCasePass of
    ecNormal:    InitialPassword := Self.Login.InitialLogin.Password;
    ecUpperCase: InitialPassword := UpperCase(Self.Login.InitialLogin.Password);
    ecLowerCase: InitialPassword := LowerCase(Self.Login.InitialLogin.Password);
  end;

  SQLstmt := 'SELECT ' + TableUsers.FieldUserID + ' as idUser ' +
    'FROM ' + TableUsers.TableName + ' ' + 'WHERE ' + TableUsers.FieldLogin +
    ' = ' + QuotedStr(InitialUser);

  try
    UsersDataset := DataConnector.UCGetSQLDataset(SQLstmt);

    // Inserir login inicial
    if UsersDataset.IsEmpty then
      UserID := AddUser(InitialUser, InitialPassword,
        Login.InitialLogin.User, Login.InitialLogin.Email, 0, 0,
        Login.DaysOfSunExpired, True)
    else
      UserID := UsersDataset.FieldByName('idUser').AsInteger;

  finally
    UsersDataset.Close;
    FreeAndNil(UsersDataset);
  end;

  SQLstmt := 'SELECT ' + TableRights.FieldUserID + ' AS IDUSER ' +
    'FROM ' + TableRights.TableName + ' ' + 'WHERE ' + TableRights.FieldUserID +
    ' = ' + IntToStr(UserID) + ' ' + 'AND ' + TableRights.FieldModule +
    ' = ' + QuotedStr(ApplicationID);

  try
    PermissionsDataset := DataConnector.UCGetSQLDataset(SQLstmt);

    if not PermissionsDataset.IsEmpty then
      Exit;

  finally
    PermissionsDataset.Close;
    FreeAndNil(PermissionsDataset);
  end;

  AddRight(UserID, User.MenuItem);
  AddRight(UserID, User.Action);

  AddRight(UserID, UserPasswordChange.MenuItem);
  AddRight(UserID, UserPasswordChange.Action);

  AddRight(UserID, UsersLogoff.MenuItem);
  AddRight(UserID, UsersLogoff.Action);

  {$IFNDEF FPC}
  { .$IFDEF UCACTMANAGER }
  if Assigned(ControlRight.ActionMainMenuBar) then
    IncPermissActMenuBar(IDUsuario, User.Action);

  if Assigned(ControlRight.ActionMainMenuBar) then
    IncPermissActMenuBar(IDUsuario, UserPasswordChange.Action);
  { .$ENDIF }
  {$ENDIF}

  for Count := 0 to Pred(Login.InitialLogin.InitialRights.Count) do
    if Owner.FindComponent(Login.InitialLogin.InitialRights[Count]) <> nil then
    begin
      AddRight(UserID, Owner.FindComponent(
        Login.InitialLogin.InitialRights[Count]));
      AddRightEX(UserID, ApplicationID, TCustomForm(Owner).Name,
        Login.InitialLogin.InitialRights[Count]);
    end;

  try
    Messages := TStringList.Create;
    Messages.Assign(UserSettings.CommonMessages.InitialMessage);
    Messages.Text := StringReplace(Messages.Text, ':user', InitialUser, [rfReplaceAll]);
    Messages.Text := StringReplace(Messages.Text, ':password', InitialPassword, [rfReplaceAll]);

    CustomForm := nil;

    if Assigned(OnCustomInitialMsg) then
      OnCustomInitialMsg(Self, CustomForm, Messages);

    try
      if CustomForm <> nil then
        CustomForm.ShowModal
      else
        MessageDlg(Messages.Text, mtInformation, [mbOK], 0);
    except
      MessageDlg(Messages.Text, mtInformation, [mbOK], 0);
    end;

  finally
    FreeAndNil(Messages);
  end;
end;

procedure TUserControl.SetLanguage(const Value: TUCLanguage);
begin
  fLanguage := Value;
  Self.UserSettings.Language := Value;
  uc_settings.AlterLanguage(Self.UserSettings);
end;

{$IFNDEF FPC}
procedure TUserControl.SetFMailUserControl(const Value: TMailUserControl);
begin
  FMailUserControl := Value;
  FMailUserControl.FUserControl := Self;
  if Value <> nil then
    Value.FreeNotification(Self);
end;
{$ENDIF}

procedure TUserControl.ApplySettings(SourceSettings: TUCSettings);
begin
  with UserSettings.CommonMessages do
    begin
      BlankPassword := SourceSettings.CommonMessages.BlankPassword;
      PasswordChanged := SourceSettings.CommonMessages.PasswordChanged;
      InitialMessage.Text := SourceSettings.CommonMessages.InitialMessage.Text;
      MaxLoginAttemptsError := SourceSettings.CommonMessages.MaxLoginAttemptsError;
      InvalidLogin := SourceSettings.CommonMessages.InvalidLogin;
      InactiveLogin := SourceSettings.CommonMessages.InactiveLogin;
      AutoLogonError := SourceSettings.CommonMessages.AutoLogonError;
      UsuarioExiste := SourceSettings.CommonMessages.UsuarioExiste;
      PasswordExpired := SourceSettings.CommonMessages.PasswordExpired;
      ForcaTrocaSenha := SourceSettings.CommonMessages.ForcaTrocaSenha;
    end;

  with UserSettings.Login do
    begin
      btCancel := SourceSettings.Login.btCancel;
      btOK := SourceSettings.Login.btOK;
      LabelPassword := SourceSettings.Login.LabelPassword;
      LabelUser := SourceSettings.Login.LabelUser;
      WindowCaption := SourceSettings.Login.WindowCaption;
      LabelTentativa := SourceSettings.Login.LabelTentativa;
      LabelTentativas := SourceSettings.Login.LabelTentativas;

      if Assigned(SourceSettings.Login.LeftImage.Bitmap) then
        LeftImage.Bitmap := SourceSettings.Login.LeftImage.Bitmap
      else
        LeftImage.Bitmap := nil;

      if Assigned(SourceSettings.Login.TopImage.Bitmap) then
        TopImage.Bitmap := SourceSettings.Login.TopImage.Bitmap
      else
        TopImage.Bitmap := nil;

      if Assigned(SourceSettings.Login.BottomImage.Bitmap) then
        BottomImage.Bitmap := SourceSettings.Login.BottomImage.Bitmap
      else
        BottomImage.Bitmap := nil;
    end;

  with UserSettings.UsersForm do
    begin
      WindowCaption := SourceSettings.UsersForm.WindowCaption;
      LabelDescription := SourceSettings.UsersForm.LabelDescription;
      ColName := SourceSettings.UsersForm.ColName;
      ColLogin := SourceSettings.UsersForm.ColLogin;
      ColEmail := SourceSettings.UsersForm.ColEmail;
      BtAdd := SourceSettings.UsersForm.BtAdd;
      BtChange := SourceSettings.UsersForm.BtChange;
      BtDelete := SourceSettings.UsersForm.BtDelete;
      BtRights := SourceSettings.UsersForm.BtRights;
      BtPassword := SourceSettings.UsersForm.BtPassword;
      BtClose := SourceSettings.UsersForm.BtClose;
      PromptDelete := SourceSettings.UsersForm.PromptDelete;
      PromptDelete_WindowCaption := SourceSettings.UsersForm.PromptDelete_WindowCaption; // added by fduenas
    end;

  with UserSettings.UsersProfile do
    begin
      WindowCaption := SourceSettings.UsersProfile.WindowCaption;
      LabelDescription := SourceSettings.UsersProfile.LabelDescription;
      ColProfile := SourceSettings.UsersProfile.ColProfile;
      BtAdd := SourceSettings.UsersProfile.BtAdd;
      BtChange := SourceSettings.UsersProfile.BtChange;
      BtDelete := SourceSettings.UsersProfile.BtDelete;
      BtRights := SourceSettings.UsersProfile.BtRights; // added by fduenas
      BtClose := SourceSettings.UsersProfile.BtClose;
      PromptDelete := SourceSettings.UsersProfile.PromptDelete;
      PromptDelete_WindowCaption := SourceSettings.UsersProfile.PromptDelete_WindowCaption;
      // added by fduenas
    end;

  with UserSettings.AddChangeUser do
    begin
      WindowCaption := SourceSettings.AddChangeUser.WindowCaption;
      LabelAdd := SourceSettings.AddChangeUser.LabelAdd;
      LabelChange := SourceSettings.AddChangeUser.LabelChange;
      LabelName := SourceSettings.AddChangeUser.LabelName;
      LabelLogin := SourceSettings.AddChangeUser.LabelLogin;
      LabelEmail := SourceSettings.AddChangeUser.LabelEmail;
      CheckPrivileged := SourceSettings.AddChangeUser.CheckPrivileged;
      BtSave := SourceSettings.AddChangeUser.BtSave;
      btCancel := SourceSettings.AddChangeUser.btCancel;
      CheckExpira := SourceSettings.AddChangeUser.CheckExpira;
      Day := SourceSettings.AddChangeUser.Day;
      ExpiredIn := SourceSettings.AddChangeUser.ExpiredIn;
    end;

  with UserSettings.AddChangeProfile do
    begin
      WindowCaption := SourceSettings.AddChangeProfile.WindowCaption;
      LabelAdd := SourceSettings.AddChangeProfile.LabelAdd;
      LabelChange := SourceSettings.AddChangeProfile.LabelChange;
      LabelName := SourceSettings.AddChangeProfile.LabelName;
      BtSave := SourceSettings.AddChangeProfile.BtSave;
      btCancel := SourceSettings.AddChangeProfile.btCancel;
    end;

  with UserSettings.Rights do
    begin
      WindowCaption := SourceSettings.Rights.WindowCaption;
      LabelUser := SourceSettings.Rights.LabelUser;
      LabelProfile := SourceSettings.Rights.LabelProfile;
      PageMenu := SourceSettings.Rights.PageMenu;
      PageActions := SourceSettings.Rights.PageActions;
      PageControls := SourceSettings.Rights.PageControls;
      BtUnlock := SourceSettings.Rights.BtUnlock;
      BtLock := SourceSettings.Rights.BtLock;
      BtSave := SourceSettings.Rights.BtSave;
      btCancel := SourceSettings.Rights.btCancel;
    end;

  with UserSettings.ChangePassword do
    begin
      WindowCaption := SourceSettings.ChangePassword.WindowCaption;
      LabelDescription := SourceSettings.ChangePassword.LabelDescription;
      LabelCurrentPassword := SourceSettings.ChangePassword.LabelCurrentPassword;
      LabelNewPassword := SourceSettings.ChangePassword.LabelNewPassword;
      LabelConfirm := SourceSettings.ChangePassword.LabelConfirm;
      BtSave := SourceSettings.ChangePassword.BtSave;
      btCancel := SourceSettings.ChangePassword.btCancel;
    end;

  with UserSettings.CommonMessages.ChangePasswordError do
    begin
      InvalidCurrentPassword := SourceSettings.CommonMessages.ChangePasswordError.InvalidCurrentPassword;
      NewPasswordError := SourceSettings.CommonMessages.ChangePasswordError.NewPasswordError;
      NewEqualCurrent := SourceSettings.CommonMessages.ChangePasswordError.NewEqualCurrent;
      PasswordRequired := SourceSettings.CommonMessages.ChangePasswordError.PasswordRequired;
      MinPasswordLength := SourceSettings.CommonMessages.ChangePasswordError.MinPasswordLength;
      InvalidNewPassword := SourceSettings.CommonMessages.ChangePasswordError.InvalidNewPassword;
    end;

  with UserSettings.ResetPassword do
  begin
    WindowCaption := SourceSettings.ResetPassword.WindowCaption;
    LabelPassword := SourceSettings.ResetPassword.LabelPassword;
  end;

  with UserSettings.Log do
    begin
      WindowCaption := SourceSettings.Log.WindowCaption;
      LabelDescription := SourceSettings.Log.LabelDescription;
      LabelUser := SourceSettings.Log.LabelUser;
      LabelDate := SourceSettings.Log.LabelDate;
      LabelLevel := SourceSettings.Log.LabelLevel;
      ColLevel := SourceSettings.Log.ColLevel;
      ColMessage := SourceSettings.Log.ColMessage;
      ColUser := SourceSettings.Log.ColUser;
      ColDate := SourceSettings.Log.ColDate;
      BtFilter := SourceSettings.Log.BtFilter;
      BtDelete := SourceSettings.Log.BtDelete;
      BtClose := SourceSettings.Log.BtClose;
      PromptDelete := SourceSettings.Log.PromptDelete;
      PromptDelete_WindowCaption := SourceSettings.Log.PromptDelete_WindowCaption;
      // added by fduenas
      OptionUserAll := SourceSettings.Log.OptionUserAll; // added by fduenas
      OptionLevelLow := SourceSettings.Log.OptionLevelLow; // added by fduenas
      OptionLevelNormal := SourceSettings.Log.OptionLevelNormal;
      // added by fduenas
      OptionLevelHigh := SourceSettings.Log.OptionLevelHigh; // added by fduenas
      OptionLevelCritic := SourceSettings.Log.OptionLevelCritic;
      // added by fduenas
      DeletePerformed := SourceSettings.Log.DeletePerformed; // added by fduenas
    end;

  with UserSettings.AppMessages do
    begin
      MsgsForm_BtNew := SourceSettings.AppMessages.MsgsForm_BtNew;
      MsgsForm_BtReplay := SourceSettings.AppMessages.MsgsForm_BtReplay;
      MsgsForm_BtForward := SourceSettings.AppMessages.MsgsForm_BtForward;
      MsgsForm_BtDelete := SourceSettings.AppMessages.MsgsForm_BtDelete;
      MsgsForm_BtClose := SourceSettings.AppMessages.MsgsForm_BtClose;
      // added by fduenas
      MsgsForm_WindowCaption := SourceSettings.AppMessages.MsgsForm_WindowCaption;
      MsgsForm_ColFrom := SourceSettings.AppMessages.MsgsForm_ColFrom;
      MsgsForm_ColSubject := SourceSettings.AppMessages.MsgsForm_ColSubject;
      MsgsForm_ColDate := SourceSettings.AppMessages.MsgsForm_ColDate;
      MsgsForm_PromptDelete := SourceSettings.AppMessages.MsgsForm_PromptDelete;
      MsgsForm_PromptDelete_WindowCaption :=
        SourceSettings.AppMessages.MsgsForm_PromptDelete_WindowCaption;
      // added by fduenas
      MsgsForm_NoMessagesSelected :=
        SourceSettings.AppMessages.MsgsForm_NoMessagesSelected;
      // added by fduenas
      MsgsForm_NoMessagesSelected_WindowCaption :=
        SourceSettings.AppMessages.MsgsForm_NoMessagesSelected_WindowCaption;
      // added by fduenas

      MsgRec_BtClose := SourceSettings.AppMessages.MsgRec_BtClose;
      MsgRec_WindowCaption := SourceSettings.AppMessages.MsgRec_WindowCaption;
      MsgRec_Title := SourceSettings.AppMessages.MsgRec_Title;
      MsgRec_LabelFrom := SourceSettings.AppMessages.MsgRec_LabelFrom;
      MsgRec_LabelDate := SourceSettings.AppMessages.MsgRec_LabelDate;
      MsgRec_LabelSubject := SourceSettings.AppMessages.MsgRec_LabelSubject;
      MsgRec_LabelMessage := SourceSettings.AppMessages.MsgRec_LabelMessage;
      MsgSend_BtSend := SourceSettings.AppMessages.MsgSend_BtSend;
      MsgSend_BtCancel := SourceSettings.AppMessages.MsgSend_BtCancel;
      MsgSend_WindowCaption := SourceSettings.AppMessages.MsgSend_WindowCaption;
      MsgSend_Title := SourceSettings.AppMessages.MsgSend_Title;
      MsgSend_GroupTo := SourceSettings.AppMessages.MsgSend_GroupTo;
      MsgSend_RadioUser := SourceSettings.AppMessages.MsgSend_RadioUser;
      MsgSend_RadioAll := SourceSettings.AppMessages.MsgSend_RadioAll;
      MsgSend_GroupMessage := SourceSettings.AppMessages.MsgSend_GroupMessage;
      MsgSend_LabelSubject := SourceSettings.AppMessages.MsgSend_LabelSubject;
      // added by fduenas
      MsgSend_LabelMessageText :=
        SourceSettings.AppMessages.MsgSend_LabelMessageText; // added by fduenas
    end;

  { with UserSettings.TypeFieldsDB do
    begin
    Type_VarChar   := SourceSettings.Type_VarChar;
    Type_Char      := SourceSettings.Type_Char;
    Type_Int       := SourceSettings.Type_Int;
    end;  atenção mudar aqui }

  UserSettings.WindowsPosition := SourceSettings.WindowsPosition;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'Criptografia'} {$ENDIF}

const
  Codes64 = '0A1B2C3D4E5F6G7H89IjKlMnOPqRsTuVWXyZabcdefghijkLmNopQrStUvwxYz+/';
  C1 = 52845;
  C2 = 22719;

function Decode(const S: ansistring): ansistring;
const
{$IFDEF DELPHI12_UP}
  Map: array [Ansichar] of byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 62, 0, 0, 0, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0,
    0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30, 31,
    32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
    51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
  Map: array [char] of byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 62, 0, 0, 0, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0, 0,
    0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    19, 20, 21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30, 31, 32,
    33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0);
{$ENDIF}
var
  I: longint;
begin
  case Length(S) of
    2:  begin
          I := Map[S[1]] + (Map[S[2]] shl 6);
          SetLength(Result, 1);
          Move(I, Result[1], Length(Result));
        end;
    3:  begin
          I := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12);
          SetLength(Result, 2);
          Move(I, Result[1], Length(Result));
        end;
    4:  begin
          I := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12) +
            (Map[S[4]] shl 18);
          SetLength(Result, 3);
          Move(I, Result[1], Length(Result));
        end
  end;
end;

function Encode(const S: ansistring): ansistring;
const
  Map: array [0 .. 63] of char =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  I: longint;
begin
  I := 0;
  Move(S[1], I, Length(S));
  case Length(S) of
    1: Result := Map[I mod 64] + Map[(I shr 6) mod 64];
    2: Result := Map[I mod 64] + Map[(I shr 6) mod 64] + Map[(I shr 12) mod 64];
    3: Result := Map[I mod 64] + Map[(I shr 6) mod 64] + Map[(I shr 12) mod 64] + Map[(I shr 18) mod 64];
  end;
end;

function InternalDecrypt(const S: ansistring; Key: word): ansistring;
var
  I: word;
  Seed: int64;
begin
  Result := S;
  Seed := Key;
  for I := 1 to Length(Result) do
    begin
      {$IFDEF DELPHI12_UP}
      Result[I] := Ansichar(byte(Result[I]) xor (Seed shr 8));
      {$ELSE}
      Result[I] := char(byte(Result[I]) xor (Seed shr 8));
      {$ENDIF}
      Seed := (byte(S[I]) + Seed) * word(C1) + word(C2);
    end;
end;

function PreProcess(const S: ansistring): ansistring;
var
  SS: ansistring;
begin
  SS := S;
  Result := '';
  while SS <> '' do
    begin
      Result := Result + Decode(Copy(SS, 1, 4));
      Delete(SS, 1, 4);
    end;
end;

function Decrypt(const S: ansistring; Key: word): ansistring;
begin
  Result := InternalDecrypt(PreProcess(S), Key);
end;

function PostProcess(const S: ansistring): ansistring;
var
  SS: ansistring;
begin
  SS := S;
  Result := '';
  while SS <> '' do
    begin
      Result := Result + Encode(Copy(SS, 1, 3));
      Delete(SS, 1, 3);
    end;
end;

function InternalEncrypt(const S: ansistring; Key: word): ansistring;
var
  I: word;
  Seed: int64;
begin
  Result := S;
  Seed := Key;
  for I := 1 to Length(Result) do
    begin
      {$IFDEF DELPHI12_UP}
      Result[I] := Ansichar(byte(Result[I]) xor (Seed shr 8));
      {$ELSE}
      Result[I] := char(byte(Result[I]) xor (Seed shr 8));
      {$ENDIF}
      ;
      Seed := (byte(Result[I]) + Seed) * word(C1) + word(C2);
    end;
end;

function Encrypt(const S: ansistring; Key: word): ansistring;
begin
  Result := PostProcess(InternalEncrypt(S, Key));
end;

function MD5Sum(strValor: string): string;
begin
  Result := md5.MD5Print(md5.MD5String(strValor));
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCAutoLogin'} {$ENDIF}
{ TUCAutoLogin }

procedure TUCAutoLogin.Assign(Source: TPersistent);
begin
  if Source is TUCAutoLogin then
    begin
      Self.Active := TUCAutoLogin(Source).Active;
      Self.User := TUCAutoLogin(Source).User;
      Self.Password := TUCAutoLogin(Source).Password;
    end
  else
    inherited;
end;

constructor TUCAutoLogin.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.Active := False;
  Self.MessageOnError := True;
end;

destructor TUCAutoLogin.Destroy;
begin
  inherited Destroy;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TNaoPermitidos'} {$ENDIF}
{ TNaoPermitidos }

procedure TUCNotAllowedItems.Assign(Source: TPersistent);
begin
  if Source is TUCNotAllowedItems then
    begin
      Self.MenuVisible := TUCNotAllowedItems(Source).MenuVisible;
      Self.ActionVisible := TUCNotAllowedItems(Source).ActionVisible;
      // Consertado Luiz Benvenuto
    end
  else
    inherited;
end;

constructor TUCNotAllowedItems.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.MenuVisible := True;
  Self.ActionVisible := True;
end;

destructor TUCNotAllowedItems.Destroy;
begin
  inherited Destroy;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TLogControl'} {$ENDIF}
{ TLogControl }

constructor TUCLogControl.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.Active := True;
end;

destructor TUCLogControl.Destroy;
begin
  inherited Destroy;
end;

procedure TUCLogControl.Assign(Source: TPersistent);
begin
  if Source is TUCLogControl then
    begin
      Self.Active := TUCLogControl(Source).Active;
      Self.TableLog := TUCLogControl(Source).TableLog;
    end
  else
    inherited;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TCadastroUsuarios'} {$ENDIF}
{ TCadastroUsuarios }

procedure TUCUser.Assign(Source: TPersistent);
begin
  if Source is TUCUser then
    begin
      Self.MenuItem := TUCUser(Source).MenuItem;
      Self.Action := TUCUser(Source).Action;
    end
  else
    inherited;
end;

constructor TUCUser.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.FProtectAdministrator := True;
  Self.FUsePrivilegedField := False;
end;

destructor TUCUser.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUser.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
    begin
      Self.FMenuItem := nil;
      Value.FreeNotification(Self.Action);
    end;
end;

procedure TUCUser.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
    begin
      Self.Action := nil;
      Value.FreeNotification(Self.MenuItem);
    end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TLogin'} {$ENDIF}
{ TLogin }

constructor TUCLogin.Create(AOwner: TComponent);
begin
  inherited Create;
  AutoLogin := TUCAutoLogin.Create(nil);
  InitialLogin := TUCInitialLogin.Create(nil);
  if not AutoLogin.MessageOnError then
    AutoLogin.MessageOnError := True;

  fDateExpireActive := False;
  fDaysOfSunExpired := 30;
end;

destructor TUCLogin.Destroy;
begin
  SysUtils.FreeAndNil(Self.FAutoLogin);
  SysUtils.FreeAndNil(Self.FInitialLogin);

  inherited Destroy;
end;

procedure TUCLogin.Assign(Source: TPersistent);
begin
  if Source is TUCLogin then
    Self.MaxLoginAttempts := TUCLogin(Source).MaxLoginAttempts
  else
    inherited;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TPerfilUsuarios'} {$ENDIF}
{ TPerfilUsuarios }

constructor TUCUserProfile.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.Active := True;
end;

destructor TUCUserProfile.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUserProfile.Assign(Source: TPersistent);
begin
  if Source is TUCUserProfile then
    Self.Active := TUCUserProfile(Source).Active
  else
    inherited;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TTrocarSenha'} {$ENDIF}
{ TTrocarSenha }

procedure TUCChangeUserPassword.Assign(Source: TPersistent);
begin
  if Source is TUCChangeUserPassword then
    begin
      Self.MenuItem := TUCChangeUserPassword(Source).MenuItem;
      Self.Action := TUCChangeUserPassword(Source).Action;
      Self.ForcePassword := TUCChangeUserPassword(Source).ForcePassword;
      Self.MinPasswordLength := TUCChangeUserPassword(Source).MinPasswordLength;
    end
  else
    inherited;
end;

constructor TUCChangeUserPassword.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.ForcePassword := False;
end;

destructor TUCChangeUserPassword.Destroy;
begin
  inherited Destroy;
end;

procedure TUCChangeUserPassword.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
    begin
      Self.MenuItem := nil;
      Value.FreeNotification(Self.Action);
    end;
end;

procedure TUCChangeUserPassword.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
    begin
      Self.Action := nil;
      Value.FreeNotification(Self.MenuItem);
    end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TInitialLogin'} {$ENDIF}
{ TInitialLogin }

procedure TUCInitialLogin.Assign(Source: TPersistent);
begin
  if Source is TUCInitialLogin then
    begin
      Self.User := TUCInitialLogin(Source).User;
      Self.Password := TUCInitialLogin(Source).Password;
    end
  else
    inherited;
end;

constructor TUCInitialLogin.Create(AOwner: TComponent);
begin
  inherited Create;
  FInitialRights := TStringList.Create;
end;

destructor TUCInitialLogin.Destroy;
begin
  if Assigned(Self.FInitialRights) then
    Self.InitialRights.Free;
  inherited Destroy;
end;

procedure TUCInitialLogin.SetInitialRights(const Value: TStrings);
begin
  FInitialRights.Assign(Value);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCControlRight'} {$ENDIF}
{ TUCControlRight }

procedure TUCControlRight.Assign(Source: TPersistent);
begin
  if Source is TUCControlRight then
    Self.ActionList := TUCControlRight(Source).ActionList
  { .$IFDEF UCACTMANAGER }
  { .$ENDIF }
  else
    inherited;
end;

constructor TUCControlRight.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCControlRight.Destroy;
begin
  inherited Destroy;
end;

procedure TUCControlRight.SetActionList(const Value: TActionList);
begin
  FActionList := Value;
  if Value <> nil then
    Value.FreeNotification(Self.ActionList);
end;

{$IFNDEF FPC}
{ .$IFDEF UCACTMANAGER }

procedure TUCControlRight.SetActionMainMenuBar(const Value: TActionMainMenuBar);
begin
  FActionMainMenuBar := Value;
  if Value <> nil then
    Value.FreeNotification(Self.ActionMainMenuBar);
end;

procedure TUCControlRight.SetActionManager(const Value: TActionManager);
begin
  FActionManager := Value;
  if Value <> nil then
    Value.FreeNotification(Self.ActionManager);
end;

{ .$ENDIF }
{$ENDIF}

procedure TUCControlRight.SetMainMenu(const Value: TMenu);
begin
  FMainMenu := Value;
  if Value <> nil then
    Value.FreeNotification(Self.MainMenu);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCAppMessage'} {$ENDIF}
{ TUCAppMessage }

procedure TUCApplicationMessage.CheckMessages;

  function __FormatDataHeader(dt: string): string;
  begin
    Result := Copy(dt, 7, 2) + '/' + Copy(dt, 5, 2) + '/' + Copy(dt, 1, 4) +
      ' ' + Copy(dt, 9, 2) + ':' + Copy(dt, 11, 2);
  end;

begin
  if not FReady then
    Exit;

  with Self.UserControl.DataConnector.UCGetSQLDataset('SELECT UCM.IdMsg, ' +
      'UCC.' + Self.UserControl.TableUsers.FieldUserName + ' AS De, ' +
      'UCC_1.' + Self.UserControl.TableUsers.FieldUserName + ' AS Para, ' +
      'UCM.Subject, ' + 'UCM.Msg, ' + 'UCM.DtSend, ' + 'UCM.DtReceive ' +
      'FROM (' + Self.TableMessages + ' UCM INNER JOIN ' +
      Self.UserControl.TableUsers.TableName + ' UCC ON UCM.UsrFrom = UCC.' +
      Self.UserControl.TableUsers.FieldUserID + ') INNER JOIN ' +
      Self.UserControl.TableUsers.TableName + ' UCC_1 ON UCM.UsrTo = UCC_1.' +
      Self.UserControl.TableUsers.FieldUserID +
      ' where UCM.DtReceive is NULL and  UCM.UsrTo = ' +
      IntToStr(Self.UserControl.CurrentUser.UserID)) do
    begin
      while not EOF do
        begin
          ReceivedMessageForm := TReceivedMessageForm.Create(Self);
          ReceivedMessageForm.stDe.Caption := FieldByName('De').AsString;
          ReceivedMessageForm.stData.Caption := __FormatDataHeader(FieldByName('DtSend').AsString);
          ReceivedMessageForm.stAssunto.Caption := FieldByName('Subject').AsString;
          ReceivedMessageForm.MemoMsg.Text := FieldByName('msg').AsString;
          if Assigned(Self.UserControl.DataConnector) then
            Self.UserControl.DataConnector.UCExecSQL('Update ' +
              Self.TableMessages + ' set DtReceive =  ' +
              QuotedStr(FormatDateTime('YYYYMMDDhhmm', now)) + ' Where  idMsg = ' +
              FieldByName('idMsg').AsString);
          ReceivedMessageForm.Show;
          Next;
        end;
      Close;
      Free;
    end;
end;

constructor TUCApplicationMessage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReady := False;
  if csDesigning in ComponentState then
    begin
      if Self.TableMessages = '' then
        Self.TableMessages := 'UCTABMESSAGES';
      Interval := 60000;
      Active := True;
    end;
  Self.FVerifThread := TUCVerificaMensagemThread.Create(False);
  Self.FVerifThread.AOwner := Self;
  Self.FVerifThread.FreeOnTerminate := True;
end;

destructor TUCApplicationMessage.Destroy;
begin

  if not (csDesigning in ComponentState) then
    if Assigned(UserControl) then
      UserControl.DeleteLoginMonitor(Self);

  Self.FVerifThread.Terminate;
  // FreeAndNil(FVerifThread);
  inherited Destroy;
end;

procedure TUCApplicationMessage.DeleteAppMessage(IdMsg: integer);
begin
  if MessageDlg(FUserControl.UserSettings.AppMessages.MsgsForm_PromptDelete,
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  if Assigned(UserControl.DataConnector) then
    UserControl.DataConnector.UCExecSQL('Delete from ' + TableMessages +
      ' where IdMsg = ' + IntToStr(IdMsg));
end;

procedure TUCApplicationMessage.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    begin
      if not Assigned(FUserControl) then
        raise Exception.Create('Component UserControl not defined!');
      UserControl.AddLoginMonitor(Self);
      if not FUserControl.DataConnector.UCFindTable(TableMessages) then
        FUserControl.CriaTabelaMsgs(TableMessages);
    end;
  FReady := True;
end;

procedure TUCApplicationMessage.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if AOperation = opRemove then
    if AComponent = FUserControl then
      FUserControl := nil;
  inherited Notification(AComponent, AOperation);
end;

procedure TUCApplicationMessage.SendAppMessage(ToUser: integer; Subject, Msg: string);
var
  UltId: integer;
begin
  with UserControl.DataConnector.UCGetSQLDataset('Select Max(idMsg) as nr from ' +
      TableMessages) do
    begin
      UltId := FieldByName('nr').AsInteger + 1;
      Close;
      Free;
    end;
  if Assigned(UserControl.DataConnector) then
    UserControl.DataConnector.UCExecSQL('Insert into ' + TableMessages +
      '( idMsg, UsrFrom, UsrTo, Subject, Msg, DtSend) Values (' +
      IntToStr(UltId) + ', ' + IntToStr(UserControl.CurrentUser.UserID) +
      ', ' + IntToStr(ToUser) + ', ' + QuotedStr(Subject) + ', ' +
      QuotedStr(Msg) + ', ' + QuotedStr(FormatDateTime('YYYYMMDDHHMM', now)) + ')');

end;

procedure TUCApplicationMessage.SetActive(const Value: boolean);
begin
  FActive := Value;
  if (csDesigning in ComponentState) then
    Exit;
  if FActive then
    FVerifThread.Resume
  else
    FVerifThread.Suspend;
end;

procedure TUCApplicationMessage.SetUserControl(const Value: TUserControl);
begin
  FUserControl := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

procedure TUCApplicationMessage.ShowMessages;
begin
  try
    SystemMessageForm := TSystemMessageForm.Create(Self);
    with FUserControl.UserSettings.AppMessages do
      begin
        SystemMessageForm.Caption := MsgsForm_WindowCaption;
        SystemMessageForm.btnova.Caption := MsgsForm_BtNew;
        SystemMessageForm.btResponder.Caption := MsgsForm_BtReplay;
        SystemMessageForm.btEncaminhar.Caption := MsgsForm_BtForward;
        SystemMessageForm.btExcluir.Caption := MsgsForm_BtDelete;
        SystemMessageForm.BtClose.Caption := MsgsForm_BtClose;

        SystemMessageForm.ListView1.Columns[0].Caption := MsgsForm_ColFrom;
        SystemMessageForm.ListView1.Columns[1].Caption := MsgsForm_ColSubject;
        SystemMessageForm.ListView1.Columns[2].Caption := MsgsForm_ColDate;
      end;

    SystemMessageForm.MessagesDataset := UserControl.DataConnector.UCGetSQLDataset
      ('SELECT UCM.IdMsg, UCM.UsrFrom, UCC.' +
      Self.UserControl.TableUsers.FieldUserName + ' AS De, UCC_1.' +
      Self.UserControl.TableUsers.FieldUserName +
      ' AS Para, UCM.Subject, UCM.Msg, UCM.DtSend, UCM.DtReceive ' +
      'FROM (' + TableMessages + ' UCM INNER JOIN ' + UserControl.TableUsers.TableName +
      ' UCC ON UCM.UsrFrom = UCC.' + Self.UserControl.TableUsers.FieldUserID +
      ') ' + ' INNER JOIN ' + UserControl.TableUsers.TableName +
      ' UCC_1 ON UCM.UsrTo = UCC_1.' + Self.UserControl.TableUsers.FieldUserID +
      ' WHERE UCM.UsrTo = ' + IntToStr(UserControl.CurrentUser.UserID) +
      ' ORDER BY UCM.DtReceive DESC');
    SystemMessageForm.MessagesDataset.Open;
    SystemMessageForm.UsersDataset := UserControl.DataConnector.UCGetSQLDataset
      ('SELECT ' + UserControl.TableUsers.FieldUserID + ' as idUser, ' +
      UserControl.TableUsers.FieldLogin + ' as Login, ' +
      UserControl.TableUsers.FieldUserName + ' as Nome, ' +
      UserControl.TableUsers.FieldPassword + ' as Senha, ' +
      UserControl.TableUsers.FieldEmail + ' as Email, ' +
      UserControl.TableUsers.FieldPrivileged + ' as Privilegiado, ' +
      UserControl.TableUsers.FieldTypeRec + ' as Tipo, ' +
      UserControl.TableUsers.FieldProfile + ' as Perfil ' + ' FROM ' +
      UserControl.TableUsers.TableName + ' WHERE ' +
      UserControl.TableUsers.FieldUserID + ' <> ' +
      IntToStr(UserControl.CurrentUser.UserID) + ' AND ' +
      UserControl.TableUsers.FieldTypeRec + ' = ' + QuotedStr('U') +
      ' ORDER BY ' + UserControl.TableUsers.FieldUserName);
    SystemMessageForm.UsersDataset.Open;

    SystemMessageForm.Position := Self.FUserControl.UserSettings.WindowsPosition;
    SystemMessageForm.ShowModal;
  finally
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TVerifThread'} {$ENDIF}
{ TVerifThread }

procedure TUCVerificaMensagemThread.Execute;
begin
  if (Assigned(TUCApplicationMessage(AOwner).UserControl)) and
    (TUCApplicationMessage(AOwner).UserControl.CurrentUser.UserID <> 0) then
    Synchronize(VerNovaMansagem);
  Sleep(TUCApplicationMessage(AOwner).Interval);
end;

procedure TUCVerificaMensagemThread.VerNovaMansagem;
begin
  TUCApplicationMessage(AOwner).CheckMessages;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCCollectionItem'} {$ENDIF}
{ TUCCollectionItem }

function TUCExtraRightsItem.GetDisplayName: string;
begin
  Result := FormName + '.' + CompName;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TUCExtraRightsItem.SetFormName(const Value: string);
begin
  if FFormName <> Value then
    FFormName := Value;
end;

procedure TUCExtraRightsItem.SetCompName(const Value: string);
begin
  if FCompName <> Value then
    FCompName := Value;
end;

procedure TUCExtraRightsItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
    FCaption := Value;
end;

procedure TUCExtraRightsItem.SetGroupName(const Value: string);
begin
  if FGroupName <> Value then
    FGroupName := Value;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCCollection'} {$ENDIF}
{ TUCCollection }

constructor TUCExtraRights.Create(UCBase: TUserControl);
begin
  inherited Create(TUCExtraRightsItem);
  FUCBase := UCBase;
end;

function TUCExtraRights.Add: TUCExtraRightsItem;
begin
  Result := TUCExtraRightsItem(inherited Add);
end;

function TUCExtraRights.GetItem(Index: integer): TUCExtraRightsItem;
begin
  Result := TUCExtraRightsItem(inherited GetItem(Index));
end;

procedure TUCExtraRights.SetItem(Index: integer; Value: TUCExtraRightsItem);
begin
  inherited SetItem(Index, Value);
end;

function TUCExtraRights.GetOwner: TPersistent;
begin
  Result := FUCBase;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCRun'} {$ENDIF}
{ TUCRun }

procedure TUCExecuteThread.Execute;
begin
  while not Self.Terminated do
    begin
      if TUserControl(AOwner).DataConnector.UCFindDataConnection then
        Synchronize(UCStart);
      Sleep(50);
    end;
end;

procedure TUCExecuteThread.UCStart;
begin
  TUserControl(AOwner).Execute;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUControls'} {$ENDIF}
{ TUCControls }

function TUCControls.GetActiveForm: string;
begin
  Result := Owner.Name;
end;

function TUCControls.GetAccessType: string;
begin
  if not Assigned(UserControl) then
    Result := ''
  else
    Result := UserControl.ClassName;
end;

procedure TUCControls.ListComponents(Form: string; List: TStringList);
var
  Contador: integer;
begin
  if not Assigned(List) then
    Exit;
  if not Assigned(UserControl) then
    Exit;
  List.Clear;
  for Contador := 0 to Pred(UserControl.ExtraRights.Count) do
    if UpperCase(UserControl.ExtraRights[Contador].FormName) = UpperCase(Form) then
      List.Add(UserControl.ExtraRights[Contador].CompName); // List.Append
end;

procedure TUCControls.ApplyRights;
var
  FListObj: TStringList;
  TempDS: TDataSet;
  Contador: integer;
  SQLstmt: string;
  ExisteObj: boolean;
  String1: string;
  String2: string;
begin
  // Apply Extra Rights

  if not Assigned(UserControl) then
    Exit;
  with UserControl do
    begin
      if (UserControl.LoginMode = lmActive) and (CurrentUser.UserID = 0) then
        Exit;

      FListObj := TStringList.Create;
      Self.ListComponents(Self.Owner.Name, FListObj);

      if UserControl.DataConnector.UCFindDataConnection then
        begin
          // permissoes do usuario
          SQLstmt := Format('SELECT %s AS UserID,' + '       %s AS ObjName,' +
            '       %s AS UCKey ' + 'FROM %sEX ' + 'WHERE %s = %d AND ' +
            '      %s = %s AND ' + '      %s = %s',
            [TableRights.FieldUserID, TableRights.FieldComponentName,
            TableRights.FieldKey, TableRights.TableName, TableRights.FieldUserID,
            CurrentUser.UserID, TableRights.FieldModule, QuotedStr(ApplicationID),
            TableRights.FieldFormName, QuotedStr(Self.Owner.Name)]);

          TempDS := DataConnector.UCGetSQLDataset(SQLstmt);

          for Contador := 0 to Pred(FListObj.Count) do
            begin
              UnlockEX(TCustomForm(Self.Owner), FListObj[Contador]);

              ExisteObj := (TempDS.Locate('ObjName', FListObj[Contador], []));

              case Self.UserControl.Criptografia of
                cStandard:  begin
                            String1 := Decrypt(TempDS.FieldByName('UCKey').AsString,
                              EncryptKey);
                            String2 := TempDS.FieldByName('UserID').AsString +
                              TempDS.FieldByName('ObjName').AsString;
                          end;
                cMD5:     begin
                            String1 := TempDS.FieldByName('UCKey').AsString;
                            String2 := MD5Sum(TempDS.FieldByName('UserID').AsString +
                              TempDS.FieldByName('ObjName').AsString);
                          end;
              end;

              if not ExisteObj or (String1 <> String2) then
                LockEX(TCustomForm(Self.Owner), FListObj[Contador],
                  NotAllowed = naInvisible);
            end;
          TempDS.Close;

          // permissoes do grupo
          SQLstmt := Format('SELECT' + '      %s AS UserID,' +
            '      %s AS ObjName,' + '      %s AS UCKey ' + 'FROM %sEX ' +
            'WHERE %s = %d AND ' + '      %s = %s AND ' + '      %s = %s',
            [TableRights.FieldUserID, TableRights.FieldComponentName,
            TableRights.FieldKey, TableRights.TableName, TableRights.FieldUserID,
            CurrentUser.Profile, TableRights.FieldModule, QuotedStr(ApplicationID),
            TableRights.FieldFormName, QuotedStr(Self.Owner.Name)]);

          TempDS := DataConnector.UCGetSQLDataset(SQLstmt);

          for Contador := 0 to Pred(FListObj.Count) do
            begin
              ExisteObj := (TempDS.Locate('ObjName', FListObj[Contador], []));

              case Self.UserControl.Criptografia of
                cStandard:  begin
                            String1 := Decrypt(TempDS.FieldByName('UCKey').AsString, EncryptKey);
                            String2 := TempDS.FieldByName('UserID').AsString +
                              TempDS.FieldByName('ObjName').AsString;
                          end;
                cMD5:     begin
                            String1 := TempDS.FieldByName('UCKey').AsString;
                            String2 := MD5Sum(TempDS.FieldByName('UserID').AsString +
                              TempDS.FieldByName('ObjName').AsString);
                          end;
              end;

              if ExisteObj and (String1 = String2) then
                UnlockEX(TCustomForm(Self.Owner), FListObj[Contador]);
            end;
          TempDS.Close;
        end
      else
        LockControls;
    end;

  FreeAndNil(FListObj);
end;

procedure TUCControls.LockControls;
var
  Contador: integer;
  FListObj: TStringList;
begin
  FListObj := TStringList.Create;
  Self.ListComponents(Self.Owner.Name, FListObj);
  for Contador := 0 to Pred(FListObj.Count) do
    UserControl.LockEX(TCustomForm(Self.Owner), FListObj[Contador],
      NotAllowed = naInvisible);
  FreeAndNil(FListObj);
end;

procedure TUCControls.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    begin
      ApplyRights;
      UserControl.AddUCControlMonitor(Self);
    end;
end;

procedure TUCControls.SetGroupName(const Value: string);
var
  Contador: integer;
begin
  if FGroupName = Value then
    Exit;
  FGroupName := Value;
  if Assigned(UserControl) then
    for Contador := 0 to Pred(UserControl.ExtraRights.Count) do
      if UpperCase(UserControl.ExtraRights[Contador].FormName) =
        UpperCase(Owner.Name) then
        UserControl.ExtraRights[Contador].GroupName := Value;
end;

destructor TUCControls.Destroy;
begin
  if not (csDesigning in ComponentState) then
    if Assigned(UserControl) then
      UserControl.DeleteUCControlMonitor(Self);

  inherited Destroy;
end;

procedure TUCControls.SetUserControl(const Value: TUserControl);
begin
  FUserControl := Value;
  if Value <> nil then
    Value.FreeNotification(Self.UserControl);
end;

procedure TUCControls.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  if AOperation = opRemove then
    if AComponent = FUserControl then
      FUserControl := nil;

  inherited Notification(AComponent, AOperation);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCGUID'} {$ENDIF}
{ TUCGUID }

class function TUCGUID.EmptyGUID: TGUID;
begin
  Result := FromString('{00000000-0000-0000-0000-000000000000}');
end;

class function TUCGUID.EqualGUIDs(GUID1, GUID2: TGUID): boolean;
begin
  Result := IsEqualGUID(GUID1, GUID2);
end;

class function TUCGUID.FromString(Value: string): TGUID;
begin
  Result := StringToGuid(Value);
end;

class function TUCGUID.IsEmptyGUID(GUID: TGUID): boolean;
begin
  Result := EqualGUIDs(GUID, EmptyGUID);
end;

class function TUCGUID.NovoGUID: TGUID;
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  Result := GUID;
end;

class function TUCGUID.NovoGUIDString: string;
begin
  Result := ToString(NovoGUID);
end;

class function TUCGUID.ToQuotedString(GUID: TGUID): string;
begin
  Result := QuotedStr(ToString(GUID));
end;

class function TUCGUID.ToString(GUID: TGUID): string;
begin
  Result := GuidToString(GUID);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUSERLOGGED'} {$ENDIF}
{ TUserLogged }

procedure TUCUsersLogged.AddCurrentUser;
var
  SQLstmt: string;
begin
  if not Active then
    Exit;

  with FUserControl do
    begin
      CurrentUser.LogonID := TUCGUID.NovoGUIDString;
      SQLstmt :=
        Format('INSERT INTO %s (%s, %s, %s, %s, %s) Values( %s, %d, %s, %s, %s)',
        [TableUsersLogged.TableName, TableUsersLogged.FieldLogonID,
        TableUsersLogged.FieldUserID, TableUsersLogged.FieldApplicationID,
        TableUsersLogged.FieldMachineName, TableUsersLogged.FieldData,
        QuotedStr(CurrentUser.LogonID), CurrentUser.UserID,
        QuotedStr(ApplicationID), QuotedStr(GetLocalComputerName),
        QuotedStr(FormatDateTime('dd/mm/yy hh:mm', now))]);
      if Assigned(DataConnector) then
        DataConnector.UCExecSQL(SQLstmt);
    end;
end;

procedure TUCUsersLogged.Assign(Source: TPersistent);
begin
  if Source is TUCUsersLogged then
    begin
      Self.Active := TUCUsersLogged(Source).Active;
    end
  else
    inherited;
end;

constructor TUCUsersLogged.Create(AOwner: TComponent);
begin
  inherited Create;
  FUserControl := TUserControl(AOwner);
  Self.FAtive := True;
end;

procedure TUCUsersLogged.CriaTableUserLogado;
var
  SQLstmt: string;
begin
  if not Active then
    Exit;

  with FUserControl.TableUsersLogged do
    SQLstmt :=
      Format('CREATE TABLE %s (%s %s(38), %s %s, %s %s(50), %s %s(50), %s %s(14))',
      [TableName, FieldLogonID, FUserControl.UserSettings.Type_Char,
      FieldUserID, FUserControl.UserSettings.Type_Int, FieldApplicationID,
      FUserControl.UserSettings.Type_VarChar, FieldMachineName,
      FUserControl.UserSettings.Type_VarChar, FieldData,
      FUserControl.UserSettings.Type_VarChar]);
  if Assigned(FUserControl.DataConnector) then
    FUserControl.DataConnector.UCExecSQL(SQLstmt);
end;

procedure TUCUsersLogged.DelCurrentUser;
var
  SQLstmt: string;
begin
  if not Active then
    Exit;

  if Assigned(FUserControl.DataConnector) = False then
    Exit;

  with FUserControl do
    begin
      SQLstmt := Format('DELETE FROM %s WHERE %s = %s',
        [TableUsersLogged.TableName, TableUsersLogged.FieldLogonID,
        QuotedStr(CurrentUser.LogonID)]);

      if Assigned(DataConnector) then
        DataConnector.UCExecSQL(SQLstmt);
    end;
end;

destructor TUCUsersLogged.Destroy;
begin
  inherited Destroy;
end;

function TUCUsersLogged.UsuarioJaLogado(ID: integer): boolean;
var
  SQLstmt: string;
  FDataset: TDataSet;
begin
  Result := False;
  if Assigned(FUserControl.DataConnector) = False then
    Exit;

  with FUserControl do
    begin
      SQLstmt := Format('SELECT * FROM %s WHERE %s = %s',
        [TableUsersLogged.TableName, TableUsersLogged.FieldUserID,
        QuotedStr(IntToStr(ID))]);

      if Assigned(DataConnector) then
        begin
          FDataset := DataConnector.UCGetSQLDataset(SQLstmt);
          Result := not (FDataset.IsEmpty);
        end;
    end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCUserLogoff'} {$ENDIF}
{ TUCUserLogoff }

procedure TUCUserLogoff.Assign(Source: TPersistent);
begin
  if Source is TUCUserLogoff then
    begin
      Self.MenuItem := TUCUserLogoff(Source).MenuItem;
      Self.Action := TUCUserLogoff(Source).Action;
    end
  else
    inherited;
end;

constructor TUCUserLogoff.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCUserLogoff.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUserLogoff.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
    begin
      Self.MenuItem := nil;
      Value.FreeNotification(Self.Action);
    end;
end;

procedure TUCUserLogoff.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
    begin
      Self.Action := nil;
      Value.FreeNotification(Self.MenuItem);
    end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCCurrentUser'} {$ENDIF}
{ TUCCurrentUser }

constructor TUCCurrentUser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TUCCurrentUser.Destroy;
begin
  if Assigned(FUserProfile) then
    SysUtils.FreeAndNil(FUserProfile);
  if Assigned(FGroupProfile) then
    SysUtils.FreeAndNil(FGroupProfile);
  inherited;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}

end.
