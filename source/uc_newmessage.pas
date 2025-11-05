unit uc_newmessage;

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
  DB,
  DBCtrls,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Messages,
  StdCtrls,
  SysUtils,
  //
  uc_base;

type
  TNewMessageForm = class(TForm)
    Panel1: TPanel;
    lbTitulo: TLabel;
    Image1: TImage;
    gbPara: TGroupBox;
    rbUsuario: TRadioButton;
    rbTodos: TRadioButton;
    dbUsuario: TDBLookupComboBox;
    gbMensagem: TGroupBox;
    lbAssunto: TLabel;
    lbMensagem: TLabel;
    EditAssunto: TEdit;
    MemoMsg: TMemo;
    btEnvia: TBitBtn;
    btCancela: TBitBtn;
    DataSource1: TDataSource;
    procedure btCancelaClick(Sender: TObject);
    procedure dbUsuarioCloseUp(Sender: TObject);
    procedure rbUsuarioClick(Sender: TObject);
    procedure btEnviaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject); // added by fduenas
  private
  public
  end;

var
  EnvMsgForm: TNewMessageForm;

implementation

uses
  uc_systemmessage,
  uc_messages;

{$R *.lfm}

procedure TNewMessageForm.btCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TNewMessageForm.dbUsuarioCloseUp(Sender: TObject);
begin
  if dbUsuario.KeyValue <> null then
    rbUsuario.Checked := True;
end;

procedure TNewMessageForm.rbUsuarioClick(Sender: TObject);
begin
  if not rbUsuario.Checked then
    dbUsuario.KeyValue := null;
end;

procedure TNewMessageForm.btEnviaClick(Sender: TObject);
begin
  if rbUsuario.Checked then
    begin
      TUCApplicationMessage(SystemMessageForm.Owner)
        .SendAppMessage(SystemMessageForm.UsersDataset.FieldByName('IdUser').AsInteger,
        EditAssunto.Text, MemoMsg.Text)
    end
  else
    begin
      with SystemMessageForm.UsersDataset do
        begin
          First;
          while not EOF do
            begin
              TUCApplicationMessage(SystemMessageForm.Owner)
                .SendAppMessage(FieldByName('IdUser').AsInteger, EditAssunto.Text,
                MemoMsg.Text);
              Next;
            end;
        end;
    end;
  Close;
end;

procedure TNewMessageForm.FormCreate(Sender: TObject);
begin
  with TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages do
    begin
      Self.Caption := MsgSend_WindowCaption;
      lbTitulo.Caption := MsgSend_Title;
      gbPara.Caption := MsgSend_GroupTo;
      rbUsuario.Caption := MsgSend_RadioUser;
      rbTodos.Caption := MsgSend_RadioAll;
      gbMensagem.Caption := MsgSend_GroupMessage;
      lbAssunto.Caption := MsgSend_LabelSubject;
      lbMensagem.Caption := MsgSend_LabelMessageText;
      btCancela.Caption := MsgSend_BtCancel;
      btEnvia.Caption := MsgSend_BtSend;
    end;
end;

end.
