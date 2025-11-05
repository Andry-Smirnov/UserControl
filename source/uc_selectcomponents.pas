unit uc_selectcomponents;

{$MODE Delphi}

interface

{$I 'usercontrol.inc'}

uses
  {$IFDEF DELPHI5_UP}
  Variants,
  {$ENDIF}
  ActnList,
  Buttons,
  Classes,
  ComCtrls,
  Controls,
  DB,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Menus,
  Messages,
  StdCtrls,
  SysUtils,
  LCLIntf,
  LCLType,
  LMessages,
  uc_base,
  uc_language;

type
  TQControl = class(TControl)
  published
    property Caption;
  end;

  TUCObjSel = class(TForm)
    ListaCompsDisponiveis: TListView;
    ListaCompsSelecionados: TListView;
    Panel1: TPanel;
    lbForm: TLabel;
    Image1: TImage;
    lbTitle: TLabel;
    lbCompDisp: TLabel;
    lbCompSel: TLabel;
    btsellall: TSpeedButton;
    btsel: TSpeedButton;
    btunsel: TSpeedButton;
    btunselall: TSpeedButton;
    BtOK: TBitBtn;
    btCancel: TBitBtn;
    lbGrupo: TLabel;
    lbGroup: TLabel;
    cbFilter: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btsellallClick(Sender: TObject);
    procedure btunselallClick(Sender: TObject);
    procedure btselClick(Sender: TObject);
    procedure btunselClick(Sender: TObject);
    procedure ListaCompsDisponiveisDblClick(Sender: TObject);
    procedure ListaCompsSelecionadosDblClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbFilterClick(Sender: TObject);
    procedure cbFilterKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
  private
    FListaBotoes: TStringList;
    FListaLabelsEdits: TStringList;
    procedure MakeDispItems;
  public
    FForm: TCustomForm;
    FUserControl: TUserControl;
    FInitialObjs: TStringList;
  end;

implementation

{$R *.lfm}

procedure TUCObjSel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TUCObjSel.FormShow(Sender: TObject);
begin
  lbForm.Left := lbTitle.Left + lbTitle.Width + 10;
  // added by fduenas to adjust window name
  lbGroup.Left := lbGrupo.Left + lbGrupo.Width + 10;
  // added by fduenas to adjust window name
  lbForm.Caption := FForm.Name;
  FInitialObjs.Text := UpperCase(FInitialObjs.Text);
  ListaCompsSelecionados.Items.Clear;
  MakeDispItems;
end;

procedure TUCObjSel.MakeDispItems;
var
  AComponent: TComponent;
  AClass: string;
  I: integer;
begin
  {
    All       0
    Buttons   1
    Fields    2
    Edits     3
    Labels    4
    MenuItems 5
    Actions   6
  }
  ListaCompsDisponiveis.Items.Clear;
  for I := 0 to Pred(FForm.ComponentCount) do
    begin
      AComponent := FForm.Components[I];
      AClass := UpperCase(AComponent.ClassName);
      if (AComponent is TControl) or (AComponent is TMenuItem) or
        (AComponent is TField) or (AComponent is TAction) then
        if (cbFilter.ItemIndex <= 0) or ((cbFilter.ItemIndex = 1) and
          (AComponent is TButtonControl)
          { (FListaBotoes.IndexOf(AClass) > -1) }) or
          ((cbFilter.ItemIndex = 2) and (AComponent is TField)) or
          ((cbFilter.ItemIndex = 3) and (AComponent is TCustomEdit)
          { (FListaLabelsEdits.IndexOf(AClass) > -1) }) or
          ((cbFilter.ItemIndex = 4) and (AComponent is TCustomLabel)) or
          ((cbFilter.ItemIndex = 5) and (AComponent is TMenuItem)) or
          ((cbFilter.ItemIndex = 6) and (AComponent is TCustomAction)) then
          if FInitialObjs.IndexOf(UpperCase(AComponent.Name)) = -1 then
            with ListaCompsDisponiveis.Items.Add do
              begin
                Caption := AComponent.ClassName;
                SubItems.Add(AComponent.Name);
                if AComponent is TMenuItem then
                  SubItems.Add(StringReplace(TMenuItem(AComponent).Caption, '&', '', [rfReplaceAll]))
                else if AComponent is TAction then
                  SubItems.Add(StringReplace(TAction(AComponent).Caption, '&', '', [rfReplaceAll]))
                else if AComponent is TField then
                  SubItems.Add(TField(AComponent).DisplayName)
                else
                  begin
                    if length(trim(TQControl(FForm.Components[I]).Caption)) <>
                      0 then
                      SubItems.Add(StringReplace(TQControl(FForm.Components[I])
                        .Caption, '&', '', [rfReplaceAll]))
                    else
                      SubItems.Add(StringReplace(TQControl(FForm.Components[I])
                        .Hint, '&', '', [rfReplaceAll]));
                  end;
              end;
    end;
end;

procedure TUCObjSel.btsellallClick(Sender: TObject);
var
  I: integer;
begin
  for I := 0 to Pred(ListaCompsDisponiveis.Items.Count) do
    begin
      FInitialObjs.Add(ListaCompsDisponiveis.Items[I].SubItems[0]);
      with ListaCompsSelecionados.Items.Add do
        begin
          Caption := ListaCompsDisponiveis.Items[I].SubItems[1];
          SubItems.Add(ListaCompsDisponiveis.Items[I].SubItems[0]);
          SubItems.Add(ListaCompsDisponiveis.Items[I].Caption);
        end;
    end;
  ListaCompsDisponiveis.Items.Clear;
end;

procedure TUCObjSel.btunselallClick(Sender: TObject);
begin
  ListaCompsSelecionados.Items.Clear;
  FInitialObjs.Clear;
  MakeDispItems;
end;

procedure TUCObjSel.btselClick(Sender: TObject);
var
  I: integer;
begin
  for I := 0 to ListaCompsDisponiveis.Items.Count - 1 do
    if ListaCompsDisponiveis.Items.Item[I].Selected then
      begin
        FInitialObjs.Add(ListaCompsDisponiveis.Items[I].SubItems[0]);
        with ListaCompsSelecionados.Items.Add do
          begin
            Caption := ListaCompsDisponiveis.Items[I].SubItems[1];
            SubItems.Add(ListaCompsDisponiveis.Items[I].SubItems[0]);
            SubItems.Add(ListaCompsDisponiveis.Items[I].Caption);
          end;
      end;

  I := 0;
  while I <= Pred(ListaCompsDisponiveis.Items.Count) do
    if ListaCompsDisponiveis.Items[I].Selected then
      ListaCompsDisponiveis.Items[I].Delete
    else
      Inc(I);
end;

procedure TUCObjSel.btunselClick(Sender: TObject);
var
  I: integer;
  Obj: TComponent;
begin
  if ListaCompsSelecionados.SelCount = 0 then
    Exit;
  for I := 0 to Pred(ListaCompsSelecionados.Items.Count) do
    if ListaCompsSelecionados.Items.Item[I].Selected then
      begin
        if FInitialObjs.IndexOf(ListaCompsSelecionados.Items[I].SubItems[0]) > -1 then
          FInitialObjs.Delete(FInitialObjs.IndexOf(ListaCompsSelecionados.Items[I].SubItems[0]));

        if ListaCompsSelecionados.Items[I].SubItems.Count > 1 then
          with ListaCompsDisponiveis.Items.Add do
            begin
              if ListaCompsSelecionados.Items[I].SubItems.Count > 1 then
                Caption := ListaCompsSelecionados.Items[I].SubItems[1];
              SubItems.Add(ListaCompsSelecionados.Items[I].SubItems[0]);

              Obj := FForm.FindComponent(ListaCompsSelecionados.Items[I].SubItems[0]);
              if Obj is TMenuItem then
                SubItems.Add(TMenuItem(Obj).Caption)
              else if Obj is TAction then
                SubItems.Add(TMenuItem(Obj).Caption)
              else if Obj is TField then
                SubItems.Add(TField(Obj).DisplayName)
              else
                SubItems.Add(TQControl(Obj).Caption);
            end;
      end;

  I := 0;
  while I <= Pred(ListaCompsSelecionados.Items.Count) do
    if ListaCompsSelecionados.Items[I].Selected then
      ListaCompsSelecionados.Items[I].Delete
    else
      Inc(I);
end;

procedure TUCObjSel.ListaCompsDisponiveisDblClick(Sender: TObject);
begin
  btsel.Click;
end;

procedure TUCObjSel.ListaCompsSelecionadosDblClick(Sender: TObject);
begin
  if ListaCompsSelecionados.Items.Count = 0 then
    Exit;
{$IFNDEF FPC}
  if ListaCompsSelecionados.SelCount = 1 then
    ListaCompsSelecionados.Selected.EditCaption;
{$ELSE}
  ShowMessage('Entrar em contato. Estranho, nao exite a acao EditCaption. Investigar...');
{$ENDIF}
end;

procedure TUCObjSel.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TUCObjSel.BtOKClick(Sender: TObject);
var
  I: integer;
begin
  if FUserControl.ExtraRights.Count > 0 then
    begin
      I := 0;
      while I <= Pred(FUserControl.ExtraRights.Count) do
        if UpperCase(FUserControl.ExtraRights[I].FormName) = UpperCase(FForm.Name) then
          FUserControl.ExtraRights.Delete(I)
        else
          Inc(I);
    end;

  for I := 0 to Pred(ListaCompsSelecionados.Items.Count) do
    with FUserControl.ExtraRights.Add do
      begin
        Caption := ListaCompsSelecionados.Items[I].Caption;
        CompName := ListaCompsSelecionados.Items[I].SubItems[0];
        FormName := FForm.Name;
        GroupName := lbGroup.Caption;
      end;
  Close;
end;

procedure TUCObjSel.FormActivate(Sender: TObject);
var
  I: integer;
begin
  for I := 0 to Pred(FUserControl.ExtraRights.Count) do
    if UpperCase(FUserControl.ExtraRights[I].FormName) = UpperCase(FForm.Name) then
      if FForm.FindComponent(FUserControl.ExtraRights[I].CompName) <> nil then
        with ListaCompsSelecionados.Items.Add do
          begin
            Caption := FUserControl.ExtraRights[I].Caption;
            SubItems.Add(FUserControl.ExtraRights[I].CompName);
            if FForm.FindComponent(FUserControl.ExtraRights[I].CompName) <> nil then
              SubItems.Add(FForm.FindComponent(FUserControl.ExtraRights[I].CompName).ClassName);
          end;

  lbTitle.Caption := ChangeLanguage(FUserControl.Language, 'Const_Contr_TitleLabel');
  lbGrupo.Caption := ChangeLanguage(FUserControl.Language, 'Const_Contr_GroupLabel');
  lbCompDisp.Caption := ChangeLanguage(FUserControl.Language, 'Const_Contr_CompDispLabel');
  lbCompSel.Caption := ChangeLanguage(FUserControl.Language, 'Const_Contr_CompSelLabel');
  ListaCompsSelecionados.Columns[0].Caption := ChangeLanguage(FUserControl.Language, 'Const_Contr_DescCol');
  btCancel.Caption := ChangeLanguage(FUserControl.Language, 'Const_Contr_BTCancel');
  BtOK.Caption := ChangeLanguage(FUserControl.Language, 'Const_Inc_BtGravar');

  // Lines Bellow added by fduenas
  btsellall.Hint := ChangeLanguage(FUserControl.Language, 'Const_Contr_BtSellAllHint');
  btsel.Hint := ChangeLanguage(FUserControl.Language, 'Const_Contr_BtSelHint');
  btunsel.Hint := ChangeLanguage(FUserControl.Language, 'Const_Contr_BtUnSelHint');
  btunselall.Hint := ChangeLanguage(FUserControl.Language, 'Const_Contr_BtUnSelAllHint');

  lbForm.Left := lbTitle.Width + 66;
end;

procedure TUCObjSel.FormCreate(Sender: TObject);
begin
  cbFilter.ItemIndex := 0;
  FListaBotoes := TStringList.Create;
  FListaBotoes.CommaText := 'TButton,TSpeedButton,TBitBtn,TRxSpeedButton,' +
    'TRxSpinButton,TRxSwitch,TLMDButton,TLMDMMButton,TLMDShapeButton,' +
    'TLMD3DEffectButton,TLMDWndButtonShape,TJvHTButton,TJvBitBtn,TJvImgBtn,' +
    'TJvArrowButton,TJvTransparenftButton,TJvTransparentButton2,TJvSpeedButton';
  FListaBotoes.Text := UpperCase(FListaBotoes.Text);
  FListaLabelsEdits := TStringList.Create;
  FListaLabelsEdits.CommaText :=
    'TEdit,TLabel,TStaticText,TLabeledEdit,' +
    'TRxLabel,TComboEdit,TFileNamefEdit,TDirectoryEdit,TDateEdit,' +
    'TDateTimePicker,TRxCalcEdit,TCurrencyEdit,TRxSpinEdit';
  FListaLabelsEdits.Text := UpperCase(FListaLabelsEdits.Text);
end;

procedure TUCObjSel.cbFilterClick(Sender: TObject);
begin
  MakeDispItems;
end;

procedure TUCObjSel.cbFilterKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  MakeDispItems;
end;

end.
