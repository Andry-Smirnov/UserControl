{ -----------------------------------------------------------------------------
  Unit Name: UCMail
  Author:    QmD
  Date:      09-nov-2004
  Purpose: Send Mail messages (forget password, user add/change/password force/etc)
  History: included indy 10 support
  ----------------------------------------------------------------------------- }

unit uc_mail;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

{$I 'UserControl.inc'}

uses
  Classes,
  StdCtrls,
  Dialogs,
  SysUtils,
  //
{$IFNDEF FPC}
  UCALSMTPClient,
{$ENDIF}
  uc_language;

type
  TUCMailMessage = class(TPersistent)
  private
    FAtctive: boolean;
    FTitle: string;
    FLines: TStrings;

    procedure SetLines(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: boolean read FAtctive write FAtctive;
    property Title: string read FTitle write FTitle;
    property MessageText: TStrings read FLines write SetLines;
  end;

  TUCMPasswordForgotten = class(TUCMailMessage)
  private
    FLabelLoginForm: string;
    FMessageEmailSent: string;
  published
    property LabelLoginForm: string read FLabelLoginForm write FLabelLoginForm;
    property MessageEmailSent: string read FMessageEmailSent write FMessageEmailSent;
  end;

  TMessageTag = procedure(Tag: string; var ReplaceText: string) of object;

  TMailUserControl = class(TComponent)
  private
    FPort: integer;
    FEmailSender: string;
    FUser: string;
    FSenderName: string;
    FPassword: string;
    FSMTPServer: string;
    FUserAdded: TUCMailMessage;
    FPasswordChanged: TUCMailMessage;
    FSendEmailUserChanged: TUCMailMessage;
    FPasswordForced: TUCMailMessage;
    FPasswordForgotten: TUCMPasswordForgotten;
    {$IFNDEF FPC}
    fAuthType: TAlSmtpClientAuthType;
    {$ENDIF}
    function ParseMailMessage(Name, Login, Password, Email, Profile, txt: string): string;
    procedure onStatus(Status: string);
    function TreatPassword(Password: string; Key: word; GenerateNew: boolean; UserID: integer): string;
  protected
    function SendEmailTp(Name, Login, Password, Email, Profile: string; UCMessage: TUCMailMessage): boolean;
  public
    FUserControl: TComponent;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SendEmailAddUser(Name, Login, Password, Email, Profile: string; Key: word);
    procedure EnviaEmailAlteraUsuario(Name, Login, Password, Email, Profile: string; Key: word);
    procedure SendEmailPasswordForced(Name, Login, Password, Email, Profile: string);
    procedure SendEmailPasswordForgotten(ID: integer; Name, Login, Password, Email, Profile: string); // Key: Word
    procedure SendEmailPasswordChanged(Name, Login, Password, Email, Profile: string; Key: word);
  published
    {$IFNDEF FPC}
    property AuthType: TAlSmtpClientAuthType read fAuthType write fAuthType;
    {$ENDIF}
    property SMTPServer: string read FSMTPServer write FSMTPServer;
    property User: string read FUser write FUser;
    property Password: string read FPassword write FPassword;
    property Port: integer read FPort write FPort default 0;
    property SenderName: string read FSenderName write FSenderName;
    property EmailSender: string read FEmailSender write FEmailSender;
    property UserAdded: TUCMailMessage read FUserAdded write FUserAdded;
    property SendEmailUserChanged: TUCMailMessage read FSendEmailUserChanged write FSendEmailUserChanged;
    property PasswordForgotten: TUCMPasswordForgotten read FPasswordForgotten write FPasswordForgotten;
    property PasswordForced: TUCMailMessage read FPasswordForced write FPasswordForced;
    property PasswordChanged: TUCMailMessage read FPasswordChanged write FPasswordChanged;
  end;

implementation

uses
  uc_base,
  uc_emailsending;

function GeneratePassword(Digitos: integer; Min: boolean; Mai: boolean; Num: boolean): string;
const
  MinC = 'abcdef';
  MaiC = 'ABCDEF';
  NumC = '1234567890';
var
  p: integer;
  q: integer;
  AChar: string;
  Password: string;
begin
  AChar := '';
  if Min then
    AChar := AChar + MinC;
  if Mai then
    AChar := AChar + MaiC;
  if Num then
    AChar := AChar + NumC;
  for p := 1 to Digitos do
    begin
      Randomize;
      q := Random(Length(AChar)) + 1;
      Password := Password + AChar[q];
    end;
  Result := Password;
end;

{ TMailAdicUsuario }

procedure TUCMailMessage.Assign(Source: TPersistent);
begin
  if Source is TUCMailMessage then
    begin
      Self.Active := TUCMailMessage(Source).Active;
      Self.Title := TUCMailMessage(Source).Title;
      Self.MessageText.Assign(TUCMailMessage(Source).MessageText);
    end
  else
    inherited;
end;

constructor TUCMailMessage.Create(AOwner: TComponent);
begin
  FLines := TStringList.Create;
end;

destructor TUCMailMessage.Destroy;
begin
  SysUtils.FreeAndNil(FLines);
  inherited;
end;

procedure TUCMailMessage.SetLines(const Value: TStrings);
begin
  FLines.Assign(Value);
end;

{ TMailUserControl }

constructor TMailUserControl.Create(AOwner: TComponent);
begin
  inherited;
  UserAdded := TUCMailMessage.Create(Self);
  UserAdded.FLines.Add
  ('<html> <head> <title>Inclusão de Senha</title> <style type="text/css"> <!-- body { 	margin-left: 0px; '
    + #13#10 + 'margin-top: 0px; 	margin-right: 0px; 	margin-bottom: 0px; } --> </style></head>'
    + #13#10 + '<body> <p>Atenção: <br>Senha criada com sucesso:</p>' +
    #13#10 + '<table width="100%" border="0" cellspacing="2" cellpadding="0"> ' +
    #13#10 + '<tr> ' + #13#10 +
    ' <td width="10%" align="right"><strong>Nome ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:nome</td> ' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    '  <td align="right"><strong>Login ..:&nbsp;</strong></td>' +
    #13#10 + '  <td>:login</td>' + #13#10 + '</tr>' + #13#10 +
    '  <tr> ' + #13#10 + '    <td align="right"><strong>Nova Senha ..:&nbsp;</strong></td>'
    + #13#10 + '    <td>:senha</td>' + #13#10 + '  </tr> ' + #13#10 +
    '<tr> ' + #13#10 + '<td align="right"><strong>Email ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:email</td>' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    #13#10 + '<td align="right"><strong>Perfil ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:perfil</td> ' + #13#10 + '</tr>' + #13#10 + '</table>' +
    #13#10 + '<p>Atenciosamente,</p>' + #13#10 +
    '<p>Administrador do sistema</p></body></html>');
  UserAdded.FTitle := 'Inclusão de usuário';

  SendEmailUserChanged := TUCMailMessage.Create(Self);
  SendEmailUserChanged.FLines.Add
  ('<html> <head> <title>Alteração de Senha</title> <style type="text/css"> <!-- body { 	margin-left: 0px; '
    + #13#10 + 'margin-top: 0px; 	margin-right: 0px; 	margin-bottom: 0px; } --> </style></head>'
    + #13#10 +
    '<body> <p>Atenção: <br> Você solicitou uma alteração de senha do sistema, sua senha foi alterada para a senha abaixo:</p>'
    + #13#10 + '<table width="100%" border="0" cellspacing="2" cellpadding="0"> ' +
    #13#10 + '<tr> ' + #13#10 +
    ' <td width="10%" align="right"><strong>Nome ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:nome</td> ' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    '  <td align="right"><strong>Login ..:&nbsp;</strong></td>' +
    #13#10 + '  <td>:login</td>' + #13#10 + '</tr>' + #13#10 +
    '  <tr> ' + #13#10 + '    <td align="right"><strong>Nova Senha ..:&nbsp;</strong></td>'
    + #13#10 + '    <td>:senha</td>' + #13#10 + '  </tr> ' + #13#10 +
    '<tr> ' + #13#10 + '<td align="right"><strong>Email ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:email</td>' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    #13#10 + '<td align="right"><strong>Perfil ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:perfil</td> ' + #13#10 + '</tr>' + #13#10 + '</table>' +
    #13#10 + '<p>Atenciosamente,</p>' + #13#10 +
    '<p>Administrador do sistema</p></body></html>');
  SendEmailUserChanged.FTitle := 'Alteração de usuário';

  PasswordForgotten := TUCMPasswordForgotten.Create(Self);
  PasswordForgotten.FLines.Add
  ('<html> <head> <title>Alteração de Senha</title> <style type="text/css"> <!-- body { 	margin-left: 0px; '
    + #13#10 + 'margin-top: 0px; 	margin-right: 0px; 	margin-bottom: 0px; } --> </style></head>'
    + #13#10 +
    '<body> <p>Atenção: <br> Você solicitou um lembrete de senha do sistema, sua senha foi alterada para a senha abaixo:</p>'
    + #13#10 + '<table width="100%" border="0" cellspacing="2" cellpadding="0"> ' +
    #13#10 + '<tr> ' + #13#10 +
    ' <td width="10%" align="right"><strong>Nome ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:nome</td> ' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    '  <td align="right"><strong>Login ..:&nbsp;</strong></td>' +
    #13#10 + '  <td>:login</td>' + #13#10 + '</tr>' + #13#10 +
    '  <tr> ' + #13#10 + '    <td align="right"><strong>Nova Senha ..:&nbsp;</strong></td>'
    + #13#10 + '    <td>:senha</td>' + #13#10 + '  </tr> ' + #13#10 +
    '<tr> ' + #13#10 + '<td align="right"><strong>Email ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:email</td>' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    #13#10 + '<td align="right"><strong>Perfil ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:perfil</td> ' + #13#10 + '</tr>' + #13#10 + '</table>' +
    #13#10 + '<p>Atenciosamente,</p>' + #13#10 +
    '<p>Administrador do sistema</p></body></html>');
  PasswordForgotten.FTitle := 'Alteração de Senha';

  PasswordForced := TUCMailMessage.Create(Self);
  PasswordForced.FLines.Add
  ('<html> <head> <title>Alteração de Senha Forçada</title> <style type="text/css"> <!-- body { 	margin-left: 0px; '
    + #13#10 + 'margin-top: 0px; 	margin-right: 0px; 	margin-bottom: 0px; } --> </style></head>'
    + #13#10 +
    '<body> <p>Atenção: <br> Você ou um administrador forçou a troca de sua senha do sistema, sua senha foi alterada para a senha abaixo:</p>' + #13#10 + '<table width="100%" border="0" cellspacing="2" cellpadding="0"> ' + #13#10 + '<tr> ' + #13#10 + ' <td width="10%" align="right"><strong>Nome ..:&nbsp;</strong></td>' + #13#10 + '<td>:nome</td> ' + #13#10 + '</tr> ' + #13#10 + '<tr>' + '  <td align="right"><strong>Login ..:&nbsp;</strong></td>' + #13#10 + '  <td>:login</td>' + #13#10 + '</tr>' + #13#10 + '  <tr> ' + #13#10 + '    <td align="right"><strong>Nova Senha ..:&nbsp;</strong></td>' + #13#10 + '    <td>:senha</td>' + #13#10 + '  </tr> ' + #13#10 + '<tr> ' + #13#10 + '<td align="right"><strong>Email ..:&nbsp;</strong></td>' + #13#10 + '<td>:email</td>' + #13#10 + '</tr> ' + #13#10 + '<tr>' + #13#10 + '<td align="right"><strong>Perfil ..:&nbsp;</strong></td>' + #13#10 + '<td>:perfil</td> ' + #13#10 + '</tr>' + #13#10 + '</table>' + #13#10 + '<p>Atenciosamente,</p>' + #13#10 + '<p>Administrador do sistema</p></body></html>');
  PasswordForced.FTitle := 'Troca de senha forçada';

  PasswordChanged := TUCMailMessage.Create(Self);
  PasswordChanged.FLines.Add
  ('<html> <head> <title>Alteração de Senha</title> <style type="text/css"> <!-- body { 	margin-left: 0px; '
    + #13#10 + 'margin-top: 0px; 	margin-right: 0px; 	margin-bottom: 0px; } --> </style></head>'
    + #13#10 +
    '<body> <p>Atenção: <br> Você alterou sua senha do sistema, sua senha foi alterada para a senha abaixo:</p>'
    + #13#10 + '<table width="100%" border="0" cellspacing="2" cellpadding="0"> ' +
    #13#10 + '<tr> ' + #13#10 +
    ' <td width="10%" align="right"><strong>Nome ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:nome</td> ' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    '  <td align="right"><strong>Login ..:&nbsp;</strong></td>' +
    #13#10 + '  <td>:login</td>' + #13#10 + '</tr>' + #13#10 +
    '  <tr> ' + #13#10 + '    <td align="right"><strong>Nova Senha ..:&nbsp;</strong></td>'
    + #13#10 + '    <td>:senha</td>' + #13#10 + '  </tr> ' + #13#10 +
    '<tr> ' + #13#10 + '<td align="right"><strong>Email ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:email</td>' + #13#10 + '</tr> ' + #13#10 + '<tr>' +
    #13#10 + '<td align="right"><strong>Perfil ..:&nbsp;</strong></td>' +
    #13#10 + '<td>:perfil</td> ' + #13#10 + '</tr>' + #13#10 + '</table>' +
    #13#10 + '<p>Atenciosamente,</p>' + #13#10 +
    '<p>Administrador do sistema</p></body></html>');
  PasswordChanged.FTitle := 'Alteração de senha';

  {$IFNDEF FPC}
  fAuthType := alsmtpClientAuthPlain;
  {$ENDIF}
  if csDesigning in ComponentState then
    begin
      Port := 25;
      UserAdded.Active := True;
      SendEmailUserChanged.Active := True;
      PasswordForgotten.Active := True;
      PasswordForced.Active := True;
      PasswordChanged.Active := True;
      PasswordForgotten.LabelLoginForm := ChangeLanguage(ucPortuguesBr, 'Const_Log_LbEsqueciSenha');
      PasswordForgotten.MessageEmailSent := ChangeLanguage(ucPortuguesBr, 'Const_Log_MsgMailSend');
    end;
end;

destructor TMailUserControl.Destroy;
begin
  SysUtils.FreeAndNil(FUserAdded);
  SysUtils.FreeAndNil(FSendEmailUserChanged);
  SysUtils.FreeAndNil(FPasswordForgotten);
  SysUtils.FreeAndNil(FPasswordForced);
  SysUtils.FreeAndNil(FPasswordChanged);

  inherited;
end;

procedure TMailUserControl.SendEmailAddUser(Name, Login, Password, Email, Profile: string; Key: word);
begin
  Password := TreatPassword(Password, Key, False, 0);
  SendEmailTp(Name, Login, Password, Email, Profile, UserAdded);
end;

procedure TMailUserControl.EnviaEmailAlteraUsuario(Name, Login, Password, Email, Profile: string; Key: word);
begin
  Password := TreatPassword(Password, Key, False, 0);
  SendEmailTp(Name, Login, Password, Email, Profile, SendEmailUserChanged);
end;

procedure TMailUserControl.SendEmailPasswordForced(Name, Login, Password, Email, Profile: string);
begin
  SendEmailTp(Name, Login, Password, Email, Profile, PasswordForced);
end;

procedure TMailUserControl.SendEmailPasswordChanged(Name, Login, Password, Email, Profile: string; Key: word);
begin
  SendEmailTp(Name, Login, Password, Email, Profile, PasswordChanged);
end;

function TMailUserControl.ParseMailMessage(Name, Login, Password, Email, Profile, txt: string): string;
begin
  txt := StringReplace(txt, ':nome', Name, [rfReplaceAll]);
  txt := StringReplace(txt, ':login', Login, [rfReplaceAll]);
  txt := StringReplace(txt, ':senha', Password, [rfReplaceAll]);
  txt := StringReplace(txt, ':email', Email, [rfReplaceAll]);
  txt := StringReplace(txt, ':perfil', Profile, [rfReplaceAll]);
  Result := txt;
end;

procedure TMailUserControl.onStatus(Status: string);
begin
  if not Assigned(UCEMailForm) then
    Exit;
  UCEMailForm.lbStatus.Caption := Status;
  UCEMailForm.Update;
end;

function TMailUserControl.SendEmailTp(Name, Login, Password, Email, Profile: string;
  UCMessage: TUCMailMessage): boolean;
var
  {$IFNDEF FPC}
  MailMsg: TAlSmtpClient;
  MailHeader: TALSMTPClientHeader;
  {$ENDIF}
  MailRecipients: TStringList;
begin
  Result := False;
  if Trim(Email) = '' then
    Exit;
  {$IFNDEF FPC}
  MailMsg := TAlSmtpClient.Create;
  MailMsg.onStatus := onStatus;
  {$ENDIF}
  MailRecipients := TStringList.Create;
  {$IFNDEF FPC}
  MailHeader := TALSMTPClientHeader.Create;
  MailHeader.From := EmailRemetente;
  MailHeader.SendTo := Email;
  MailHeader.ContentType := 'text/html';
  MailHeader.Subject := UCMSG.Titulo;
  {$ENDIF}
  MailRecipients.Append(Email);

  try
    try
      UCEMailForm := TEMailForm.Create(Self);
      UCEMailForm.lbStatus.Caption := '';
      UCEMailForm.Show;
      UCEMailForm.Update;

{$IFNDEF FPC}
      MailMsg.SendMail(ServidorSMTP, FPorta, EmailRemetente, MailRecipients,
        Usuario, Senha, fAuthType, MailHeader.RawHeaderText,
        ParseMailMSG(Nome, Login, USenha, Email, Perfil, UCMSG.Mensagem.Text));
{$ENDIF}

      UCEMailForm.Update;
      Result := True;
    except
      on e: Exception do
        begin
          Beep;
          UCEMailForm.Close;
          MessageDlg(e.Message, mtWarning, [mbOK], 0);
          raise;
        end;
    end;
  finally
{$IFNDEF FPC}
    FreeAndNil(MailMsg);
    FreeAndNil(MailHeader);
{$ENDIF}
    FreeAndNil(MailRecipients);
    FreeAndNil(UCEMailForm);
  end;
end;

procedure TMailUserControl.SendEmailPasswordForgotten(ID: integer;
  Name, Login, Password, Email, Profile: string);
var
  NewPassword: string;
begin
  if Length(Trim(Email)) <> 0 then
    begin
      try
        NewPassword := TreatPassword(Password, 0, True, ID);
        if SendEmailTp(Name, Login, NewPassword, Email, Profile, PasswordForgotten) = True then
          begin
            TUserControl(FUserControl).ChangePassword(ID, NewPassword);
            MessageDlg(PasswordForgotten.MessageEmailSent, mtInformation, [mbOK], 0);
          end
        else
          MessageDlg('Não foi possivel enviar nova senha', mtInformation, [mbOK], 0);
      except
      end;
    end;
end;

function TMailUserControl.TreatPassword(Password: string; Key: word;
  GenerateNew: boolean; UserID: integer): string;
var
  Min: boolean;
  Mai: boolean;
begin
  Min := True;
  Mai := True;
  if TUserControl(FUserControl).Login.CharCasePass = ecLowerCase then
    Mai := False
  else if TUserControl(FUserControl).Login.CharCasePass = ecUpperCase then
    Min := False;

  if TUserControl(FUserControl).Criptografia = cStandard then
    begin
      if GenerateNew = True then
        begin
          // Aqui o componente irar gerar uma nova Password e enviar para o User
          Password := GeneratePassword(10, Min, Mai, True);
          Result := Password;
        end
      else
        Result := Decrypt(Password, Key);
    end
  else
    begin
      if GenerateNew = True then
        begin
          // Aqui o componente irar gerar uma nova Password e enviar para o User
          Password := GeneratePassword(10, Min, Mai, True);
          Result := Password;
        end
      else
        Result := '';
    end;
end;

end.
