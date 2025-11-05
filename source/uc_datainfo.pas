unit uc_datainfo;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes;

type
  TUCUsersTable = class(TPersistent)
  private
    FEmail: string;
    FTypeRec: string;
    FUserID: string;
    FPrivileged: string;
    FUserName: string;
    FTable: string;
    FProfile: string;
    FLogin: string;
    FPassword: string;
    FKey: string;
    fDateExpired: string;
    fUserExpired: string;
    fFieldUserDaysSun: string;
    fFieldUserInative: string;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldUserID: String read FUserID write FUserID;
    property FieldUserName: String read FUserName write FUserName;
    property FieldLogin: String read FLogin write FLogin;
    property FieldPassword: String read FPassword write FPassword;
    property FieldEmail: String read FEmail write FEmail;
    property FieldPrivileged: String read FPrivileged write FPrivileged;
    property FieldTypeRec: String read FTypeRec write FTypeRec;
    property FieldProfile: String read FProfile write FProfile;
    property FieldKey: String read FKey write FKey;
    // By Vicente Barros Leonel
    property FieldDateExpired: String read fDateExpired write fDateExpired;
    // By vicente barros leonel
    property FieldUserExpired: String read fUserExpired write fUserExpired;
    // By vicente barros leonel
    property FieldUserDaysSun: String read fFieldUserDaysSun write fFieldUserDaysSun;
    // By vicente barros leonel
    property FieldUserInative: string read fFieldUserInative write fFieldUserInative;
    property TableName: String read FTable write FTable;
  end;

  TUCTableRights = class(TPersistent)
  private
    FUserID: string;
    FFormName: string;
    FModule: string;
    FTable: string;
    FComponentName: string;
    FKey: string;
  protected
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldUserID: String read FUserID write FUserID;
    property FieldModule: String read FModule write FModule;
    property FieldComponentName: String read FComponentName
      write FComponentName;
    property FieldFormName: String read FFormName write FFormName;
    property FieldKey: String read FKey write FKey;
    property TableName: String read FTable write FTable;
  end;

  TUCTableUsersLogged = class(TPersistent)
  private
    FTableName: string;
    FData: string;
    FApplicationID: string;
    FUserID: string;
    FLogonID: string;
    FMachineName: string;
  protected
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldLogonID: String read FLogonID write FLogonID;
    property FieldUserID: String read FUserID write FUserID;
    property FieldApplicationID: String read FApplicationID write FApplicationID;
    property FieldMachineName: String read FMachineName write FMachineName;
    property FieldData: String read FData write FData;
    property TableName: String read FTableName write FTableName;
  end;

  TUCTableHistorico = class(TPersistent)
  private
    FTable: string;
    FApplicationID: string;
    FUserID: string;
    fDateEvent: string;
    fFieldForm: string;
    fFieldEvent: string;
    fFieldObs: string;
    fCaptionForm: string;
    fEventTime: string;
    fFieldTableName: string;
  protected
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property TableName: String read FTable write FTable; // nome da tabela
    property FieldApplicationID: String read FApplicationID
      write FApplicationID;
    property FieldUserID: String read FUserID write FUserID;
    property FieldEventDate: String read fDateEvent write fDateEvent;
    property FieldEventTime: String read fEventTime Write fEventTime;
    property FieldForm: String read fFieldForm write fFieldForm;
    property FieldCaptionForm: string read fCaptionForm write fCaptionForm;
    Property FieldEvent: String read fFieldEvent write fFieldEvent;
    property FieldObs: String read fFieldObs write fFieldObs;
    property FieldTableName: String read fFieldTableName write fFieldTableName;
    // grava o nome da tabela monitorada
  end;

implementation

{ TUCTableRights }

procedure TUCTableRights.Assign(Source: TPersistent);
begin
  if Source is TUCTableRights then
    begin
      Self.FieldUserID := TUCTableRights(Source).FieldUserID;
      Self.FieldModule := TUCTableRights(Source).FieldModule;
      Self.FieldComponentName := TUCTableRights(Source).FieldComponentName;
      Self.FieldFormName := TUCTableRights(Source).FieldFormName;
      Self.FieldKey := TUCTableRights(Source).FieldKey;
    end
  else
    inherited;
end;

constructor TUCTableRights.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCTableRights.Destroy;
begin

  inherited;
end;

{ TUCUsersTable }

procedure TUCUsersTable.Assign(Source: TPersistent);
begin
  if Source is TUCUsersTable then
    begin
      Self.FieldUserID := TUCUsersTable(Source).FieldUserID;
      Self.FieldUserName := TUCUsersTable(Source).FieldUserName;
      Self.FieldLogin := TUCUsersTable(Source).FieldLogin;
      Self.FieldPassword := TUCUsersTable(Source).FieldPassword;
      Self.FieldEmail := TUCUsersTable(Source).FieldEmail;
      Self.FieldPrivileged := TUCUsersTable(Source).FieldPrivileged;
      Self.FieldProfile := TUCUsersTable(Source).FieldProfile;
      Self.FieldKey := TUCUsersTable(Source).FieldKey;
      Self.FieldDateExpired := TUCUsersTable(Source).FieldDateExpired;
      { By Vicente Barros Leonel }
      Self.FieldUserExpired := TUCUsersTable(Source).FieldUserExpired;
      { By Vicente Barros Leonel }
      Self.FieldUserDaysSun := TUCUsersTable(Source).FieldUserDaysSun;
      { By vicente barros leonel }
      Self.FieldUserInative := TUCUsersTable(Source).FieldUserInative;
      { By vicente barros leonel }
      Self.TableName := TUCUsersTable(Source).TableName;
    end
  else
    inherited;
end;

constructor TUCUsersTable.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCUsersTable.Destroy;
begin
  inherited;
end;

{ TUCTableUsersLogged }

procedure TUCTableUsersLogged.Assign(Source: TPersistent);
begin
  if Source is TUCTableUsersLogged then
    begin
      Self.FieldLogonID := TUCTableUsersLogged(Source).FieldLogonID;
      Self.FieldUserID := TUCTableUsersLogged(Source).FieldUserID;
      Self.FieldApplicationID := TUCTableUsersLogged(Source).FieldApplicationID;
      Self.FieldMachineName := TUCTableUsersLogged(Source).FieldMachineName;
      Self.FieldData := TUCTableUsersLogged(Source).FieldData;
      Self.TableName := TUCTableUsersLogged(Source).TableName;
    end
  else
    inherited;
end;

constructor TUCTableUsersLogged.Create(AOwner: TComponent);
begin

end;

destructor TUCTableUsersLogged.Destroy;
begin
  inherited;
end;

{ TUCTableHistorico }

procedure TUCTableHistorico.Assign(Source: TPersistent);
begin
  if Source is TUCTableHistorico then
    begin
      Self.FieldApplicationID := TUCTableHistorico(Source).FieldApplicationID;
      Self.FieldUserID := TUCTableHistorico(Source).FieldUserID;
      Self.FieldEventDate := TUCTableHistorico(Source).FieldEventDate;
      Self.TableName := TUCTableHistorico(Source).TableName;
      Self.FieldForm := TUCTableHistorico(Source).FieldForm;
      Self.FieldEvent := TUCTableHistorico(Source).FieldEvent;
      Self.FieldObs := TUCTableHistorico(Source).FieldObs;
      Self.FieldCaptionForm := TUCTableHistorico(Source).FieldCaptionForm;
      Self.FieldEventTime := TUCTableHistorico(Source).FieldEventTime;
      Self.FieldTableName := TUCTableHistorico(Source).FieldTableName;
    end
  else
    inherited;
end;

constructor TUCTableHistorico.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCTableHistorico.Destroy;
begin
  inherited;
end;

end.
