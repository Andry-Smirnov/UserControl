unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  IBConnection,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  Menus, ZConnection,
  sqldb,
  sqlite3conn,
  uc_base,
  uc_settings,
  ucsqldbconn
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    SQLite3Connection1: TSQLite3Connection;
    SQLTransaction1: TSQLTransaction;
    UCSettings1: TUCSettings;
    UCSQLdbConn1: TUCSQLdbConn;
    UserControl1: TUserControl;
    ZConnection1: TZConnection;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

uses
  uc_language
  ;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  SQLite3Connection1.DatabaseName := '..\db\demo.db';
  SQLite3Connection1.Connected := True;

  UserControl1.Language := ucRussian;
  UserControl1.Execute;
end;


end.
