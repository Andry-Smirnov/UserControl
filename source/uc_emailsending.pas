unit uc_emailsending;

{$MODE Delphi}

interface

{$I 'UserControl.inc'}

uses
  Classes,
  Controls,
  ExtCtrls,
  Forms,
  Graphics,
  StdCtrls;

type
  TEMailForm = class(TForm)
    Panel1: TPanel;
    img: TImage;
    lbStatus: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UCEMailForm: TEMailForm;

implementation

{$R *.lfm}

end.
