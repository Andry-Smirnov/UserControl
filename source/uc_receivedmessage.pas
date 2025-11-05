unit uc_receivedmessage;

{$MODE Delphi}

interface

{$I 'usercontrol.inc'}

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
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Messages,
  StdCtrls,
  SysUtils,
  uc_base;

type
  TReceivedMessageForm = class(TForm)
    Panel1: TPanel;
    lbTitulo: TLabel;
    Image1: TImage;
    lbDE: TLabel;
    stDe: TStaticText;
    lbAssunto: TLabel;
    stAssunto: TStaticText;
    lbMensagem: TLabel;
    MemoMsg: TMemo;
    btFechar: TBitBtn;
    lbData: TLabel;
    stData: TStaticText;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject); // added by fduenas
  private
  public
  end;

var
  ReceivedMessageForm: TReceivedMessageForm;

implementation

uses
  uc_messages;

{$R *.lfm}

procedure TReceivedMessageForm.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TReceivedMessageForm.FormCreate(Sender: TObject);
begin
  // added by fduenas
  if not(Self.Owner is TUCApplicationMessage) then
    Exit;
  with TUCApplicationMessage(Self.Owner).UserControl.UserSettings.AppMessages do
  begin
    Self.Caption := MsgRec_WindowCaption;
    lbTitulo.Caption := MsgRec_Title;
    lbDE.Caption := MsgRec_LabelFrom;
    lbData.Caption := MsgRec_LabelDate;
    lbAssunto.Caption := MsgRec_LabelSubject;
    lbMensagem.Caption := MsgRec_LabelMessage;
    btFechar.Caption := MsgRec_BtClose;
  end;
end;

end.
