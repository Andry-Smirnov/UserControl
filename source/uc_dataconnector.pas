unit uc_dataconnector;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

{$I 'usercontrol.inc'}

uses
  Classes,
  DB;

type
  TUCDataConnector = class(TComponent)
  public
    procedure UCExecSQL(FSQL: String); virtual; abstract;
    function UCGetSQLDataset(FSQL: String): TDataset; dynamic; abstract;
    function UCFindTable(const Tablename: String): Boolean; virtual; abstract;
    function UCFindDataConnection: Boolean; virtual; abstract;
    function GetDBObjectName: string; virtual; abstract;
    function GetTransObjectName: string; virtual; abstract;
  end;

implementation

end.
