unit uc_emailsending;

{$MODE Delphi}

interface

{$I 'usercontrol.inc'}

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
  public
  end;

var
  EMailForm: TEMailForm;

implementation

{$R *.lfm}

end.
