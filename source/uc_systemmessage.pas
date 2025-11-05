unit uc_systemmessage;

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
  Classes,
  ComCtrls,
  Controls,
  DB,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  ImgList,
  Messages,
  StdCtrls,
  SysUtils,
  ToolWin;

type
  PPointMessage = ^TPointMessage;

  TPointMessage = record
    MessageID: Integer;
    Message: string;
  end;

  TSystemMessageForm = class(TForm)
    ImageList1: TImageList;
    ListView1: TListView;
    ToolBar1: TToolBar;
    btnova: TToolButton;
    ImageList2: TImageList;
    btResponder: TToolButton;
    btEncaminhar: TToolButton;
    btExcluir: TToolButton;
    Splitter1: TSplitter;
    btClose: TToolButton;
    MemoMsg: TMemo;
    procedure btCloseClick(Sender: TObject);
    procedure btnovaClick(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ListView1DblClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btEncaminharClick(Sender: TObject);
    procedure btResponderClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FColumn: Integer;
    FAsc: Boolean;
    FMessagesList: array of PPointMessage;

    procedure MontaTela;
  public
    MessagesDataset: TDataset;
    UsersDataset: TDataset;
  end;

var
  SystemMessageForm: TSystemMessageForm;

implementation

uses
  uc_newmessage,
  uc_receivedmessage,
  uc_base;

{$R *.lfm}

procedure TSystemMessageForm.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TSystemMessageForm.btnovaClick(Sender: TObject);
begin
  EnvMsgForm := TNewMessageForm.Create(Self.Owner);
  EnvMsgForm.DataSource1.DataSet := UsersDataset;
  EnvMsgForm.Showmodal;
  FreeAndNil(EnvMsgForm);
end;

function FmtDtHr(dt: String): string;
begin
  Result := Copy(dt, 7, 2) + '/' + Copy(dt, 5, 2) + '/' + Copy(dt, 1, 4) + ' ' +
    Copy(dt, 9, 2) + ':' + Copy(dt, 11, 2);
end;

procedure TSystemMessageForm.MontaTela;
var
  TempPoint: PPointMessage;
begin
  MessagesDataset.Open;
  while not MessagesDataset.EOF do
    begin
      with ListView1.Items.Add do
        begin
          ImageIndex := -1;
          StateIndex := -1;
          Caption := MessagesDataset.FieldByName('de').AsString;
          SubItems.Add(MessagesDataset.FieldByName('Subject').AsString);
          SubItems.Add(FmtDtHr(MessagesDataset.FieldByName('DtSend').AsString));
          New(TempPoint);
          SetLength(FMessagesList, Length(FMessagesList) + 1);
          FMessagesList[ High(FMessagesList)] := TempPoint;
          TempPoint.MessageID := MessagesDataset.FieldByName('idMsg').AsInteger;
          TempPoint.Message := MessagesDataset.FieldByName('Msg').AsString;
          Data := TempPoint;
        end;
      MessagesDataset.Next;
{$IFDEF DELPHI5}
      ListView1.Selected := nil;
{$ELSE}
      ListView1.ItemIndex := 0;
{$ENDIF}
    end;
  MessagesDataset.Close;
end;

procedure TSystemMessageForm.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if ListView1.SelCount > 1 then
    begin
      btResponder.Enabled := False;
      btEncaminhar.Enabled := False;
    end
  else
    begin
      btResponder.Enabled := True;
      btEncaminhar.Enabled := True;
    end;
  MemoMsg.Text := PPointMessage(Item.Data).Message;
end;

procedure TSystemMessageForm.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
begin
  if FColumn = Column.Index then
    begin
      FAsc := not FAsc;
      ListView1.Columns[FColumn].ImageIndex := Integer(FAsc);
    end
  else
    begin
      ListView1.Columns[FColumn].ImageIndex := -1;
      FColumn := Column.Index;
      FAsc := True;
      ListView1.Columns[FColumn].ImageIndex := Integer(FAsc);
    end;
  {$IFNDEF FPC}
  (Sender as TCustomListView).AlphaSort;
  {$ENDIF}
end;

procedure TSystemMessageForm.ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  ix: Integer;
begin
  if FColumn = 0 then
    begin
      if FAsc then
        Compare := CompareText(Item1.Caption, Item2.Caption)
      else
        Compare := CompareText(Item2.Caption, Item1.Caption);
    end
  else
    begin
      ix := FColumn - 1;
      if FAsc then
        Compare := CompareText(Item1.SubItems[ix], Item2.SubItems[ix])
      else
        Compare := CompareText(Item2.SubItems[ix], Item1.SubItems[ix]);
    end;
end;

procedure TSystemMessageForm.ListView1DblClick(Sender: TObject);
begin
  if ListView1.Selected = nil then
    exit; // added to prevent AV error {fduenas}
  ReceivedMessageForm := TReceivedMessageForm.Create(Self.Owner); // midifed by fduenas

  ReceivedMessageForm.MemoMsg.Text := PPointMessage(ListView1.Selected.Data).Message;
  ReceivedMessageForm.stDe.Caption := ListView1.Selected.Caption;
  ReceivedMessageForm.stAssunto.Caption := ListView1.Selected.SubItems[0];
  ReceivedMessageForm.stData.Caption := ListView1.Selected.SubItems[1];

  ReceivedMessageForm.Showmodal;
  FreeAndNil(ReceivedMessageForm);
end;

procedure TSystemMessageForm.btExcluirClick(Sender: TObject);
var
  I: Integer;
begin
{$IFDEF DELPHI5}
  if ListView1.Selected = nil then
    begin
      // Modfied by fduenas
      Application.MessageBox(PChar(TUCApplicationMessage(Owner)
        .UserControl.UserSettings.AppMessages.MsgsForm_NoMessagesSelected),
        PChar(TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages.
        MsgsForm_NoMessagesSelected_WindowCaption), MB_ICONINFORMATION + MB_OK);
      Exit;
    end;
{$ELSE}
  if ListView1.ItemIndex = -1 then
    begin
      // Modfied by fduenas
      Application.MessageBox(PChar(TUCApplicationMessage(Owner)
        .UserControl.UserSettings.AppMessages.MsgsForm_NoMessagesSelected),
        PChar(TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages.
        MsgsForm_NoMessagesSelected_WindowCaption), MB_ICONINFORMATION or MB_OK);
      Exit;
    end;
{$ENDIF}
  if ListView1.SelCount = 1 then
    begin
      TUCApplicationMessage(Owner).DeleteAppMessage(PPointMessage(ListView1.Selected.Data).MessageID);
{$IFDEF DELPHI5}
      ListView1.Selected.Delete;
{$ELSE}
      ListView1.DeleteSelected;
{$ENDIF}
    end
  else
    begin
      for I := 0 to ListView1.Items.Count - 1 do
        if ListView1.Items[I].Selected then
          TUCApplicationMessage(Owner).DeleteAppMessage(PPointMessage(ListView1.Items[I].Data).MessageID);
{$IFDEF DELPHI5}
      ListView1.Selected.Delete;
{$ELSE}
      ListView1.DeleteSelected;
{$ENDIF}
    end;

end;

procedure TSystemMessageForm.btEncaminharClick(Sender: TObject);
var
  I: Integer;
begin
{$IFDEF DELPHI5}
  if ListView1.Selected = nil then
    begin
      // Modfied by fduenas
      Application.MessageBox(PChar(TUCApplicationMessage(Owner)
        .UserControl.UserSettings.AppMessages.MsgsForm_NoMessagesSelected),
        PChar(TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages.
        MsgsForm_NoMessagesSelected_WindowCaption), MB_ICONINFORMATION or MB_OK);
      Exit;
    end;
{$ELSE}
  if ListView1.ItemIndex = -1 then
    begin
      // Modfied by fduenas
      Application.MessageBox(PChar(TUCApplicationMessage(Owner)
        .UserControl.UserSettings.AppMessages.MsgsForm_NoMessagesSelected),
        PChar(TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages.
        MsgsForm_NoMessagesSelected_WindowCaption), MB_ICONINFORMATION or MB_OK);
      Exit;
    end;
{$ENDIF}
  try
    EnvMsgForm := TNewMessageForm.Create(Self.Owner);
    EnvMsgForm.DataSource1.DataSet := UsersDataset;
    if EnvMsgForm.dbUsuario.Text <> '' then
      EnvMsgForm.dbUsuario.Enabled := False;
    EnvMsgForm.EditAssunto.Text := Copy('Enc: ' + ListView1.Selected.SubItems[0], 1, EnvMsgForm.EditAssunto.MaxLength);
    EnvMsgForm.MemoMsg.Text := PPointMessage(ListView1.Selected.Data).Message;
    for I := 0 to EnvMsgForm.MemoMsg.Lines.Count - 1 do
      EnvMsgForm.MemoMsg.Lines[I] := '>' + EnvMsgForm.MemoMsg.Lines[I];
    EnvMsgForm.MemoMsg.Lines.Insert(0, ListView1.Selected.Caption + ' ' + ListView1.Selected.SubItems[1]);
    EnvMsgForm.MemoMsg.Text := Copy(EnvMsgForm.MemoMsg.Text, 1, EnvMsgForm.MemoMsg.MaxLength);
    EnvMsgForm.Showmodal;
  finally
    FreeAndNil(EnvMsgForm);
  end;
end;

procedure TSystemMessageForm.btResponderClick(Sender: TObject);
begin
{$IFDEF DELPHI5}
  if ListView1.Selected = nil then
  begin
    // Modfied by fduenas
    Application.MessageBox(PChar(TUCApplicationMessage(Owner)
      .UserControl.UserSettings.AppMessages.MsgsForm_NoMessagesSelected),
      PChar(TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages.
      MsgsForm_NoMessagesSelected_WindowCaption), MB_ICONINFORMATION + MB_OK);
    exit;
  end;
{$ELSE}
  if ListView1.ItemIndex = -1 then
  begin
    // Modfied by fduenas
    Application.MessageBox(PChar(TUCApplicationMessage(Owner)
      .UserControl.UserSettings.AppMessages.MsgsForm_NoMessagesSelected),
      PChar(TUCApplicationMessage(Owner).UserControl.UserSettings.AppMessages.
      MsgsForm_NoMessagesSelected_WindowCaption), MB_ICONINFORMATION or MB_OK);
    exit;
  end;
{$ENDIF}
  try
    EnvMsgForm := TNewMessageForm.Create(Self.Owner);
    EnvMsgForm.rbUsuario.Checked := True;
    EnvMsgForm.rbTodos.Enabled := False;
    MessagesDataset.Open;
    MessagesDataset.Locate('idMsg', PPointMessage(ListView1.Selected.Data).MessageID, []);
    EnvMsgForm.DataSource1.DataSet := UsersDataset;
    EnvMsgForm.dbUsuario.KeyValue := MessagesDataset.FieldByName('UsrFrom').AsInteger;
    if EnvMsgForm.dbUsuario.Text <> '' then
      EnvMsgForm.dbUsuario.Enabled := False;
    EnvMsgForm.EditAssunto.Text := Copy('Re: ' + ListView1.Selected.SubItems[0],
      1, EnvMsgForm.EditAssunto.MaxLength);
    EnvMsgForm.Showmodal;
  finally
    MessagesDataset.Close;
    FreeAndNil(EnvMsgForm);
  end;
end;

procedure TSystemMessageForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
begin
  for I := 0 to High(FMessagesList) do
    Dispose(FMessagesList[I]);

  if Assigned(MessagesDataset) then
    SysUtils.FreeAndNil(MessagesDataset);

  if Assigned(UsersDataset) then
    SysUtils.FreeAndNil(UsersDataset);
end;

procedure TSystemMessageForm.FormCreate(Sender: TObject);
begin
  SetLength(FMessagesList, 0);
end;

procedure TSystemMessageForm.FormShow(Sender: TObject);
begin
  MontaTela;
end;

end.
