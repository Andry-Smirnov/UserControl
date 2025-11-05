unit uc_userpermissions;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

{$I 'usercontrol.inc'}

uses
{$IFNDEF FPC}
  {.$IFDEF UCACTMANAGER}
  ActnMan,
  ActnMenus,
  {.$ENDIF}
{$ENDIF}
{$IFDEF DELPHI5_UP}
  Variants,
{$ENDIF}
  Buttons,
  Classes,
  ComCtrls,
  Controls,
  DB,
  ExtCtrls,
  Forms,
  Graphics,
  ImgList,
  Menus,
  StdCtrls,
  //
  uc_base
  ;

type
  PTreeMenu = ^TTreeMenu;

  TTreeMenu = record
    Selected: Integer;
    MenuName: string;
  end;

  PTreeAction = ^TTreeAction;

  TTreeAction = record
    Group: Boolean;
    Selected: Integer;
    MenuName: string;
  end;

  PTreeControl = ^TTreeControl;

  TTreeControl = record
    Group: Boolean;
    Selected: Integer;
    CompName: string;
    FormName: string;
  end;

  { TUserPermissions }

  TUserPermissions = class(TForm)
    Panel1: TPanel;
    LbDescricao: TLabel;
    Image1: TImage;
    Panel3: TPanel;
    BtLibera: TBitBtn;
    BtBloqueia: TBitBtn;
    BtGrava: TBitBtn;
    lbUser: TLabel;
    ImageList1: TImageList;
    BtCancel: TBitBtn;
    PC: TPageControl;
    PageMenu: TTabSheet;
    PageAction: TTabSheet;
    TreeMenu: TTreeView;
    TreeAction: TTreeView;
    PageControls: TTabSheet;
    TreeControls: TTreeView;
    procedure BtGravaClick(Sender: TObject);
    procedure TreeMenuClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtLiberaClick(Sender: TObject);
    procedure BtBloqueiaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeActionClick(Sender: TObject);
    procedure TreeControlsClick(Sender: TObject);
    procedure TreeMenuCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure TreeMenuKeyPress(Sender: TObject; var Key: char);
    procedure TreeMenuMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    FMenu: TMenu;
    FActions: TObject;
    FChangingTree: Boolean;
    FTempMenuPointer: PTreeMenu;
    FTempActionPointer: PTreeAction;
    FTempControlPointer: PTreeControl;
    FExtraRights: TUCExtraRights;
    FTempList: TStringList;
    FActionList: array of PTreeAction;
    FMenuList: array of PTreeMenu;
    FControlList: array of PTreeControl;

    {$IFNDEF FPC}
    { .$IFDEF UCACTMANAGER }
    FActionMainMenuBar: TActionMainMenuBar;
    procedure TrataItem(IT: TActionClientItem; Node: TTreeNode); overload;
    { .$ENDIF }
    {$ENDIF}
    procedure TrataItem(IT: TMenuItem; Node: TTreeNode); overload;
    procedure TreeMenuItem(marca: Boolean);
    procedure Atualiza(Selec: Boolean);
    procedure TreeActionItem(marca: Boolean);
    procedure UnCheckChild(Node: TTreeNode);
    procedure TreeControlItem(marca: Boolean);
    procedure CarregaTreeviews;
  public
    FTempUserID: Integer;
    FUserControl: TUserControl;
    PermissionsDataset: TDataset;
    PermissionsDatasetEx: TDataset;
    ProfilesDataset: TDataset;
    ProfilesDatasetEx: TDataset;
  end;

var
  UserPermissions: TUserPermissions;

implementation

uses
  ActnList,
  Messages,
  {$IFDEF WINDOWS}LCLIntf, LCLType, LMessages,{$ELSE}LCLType,{$ENDIF}
  SysUtils;

{$R *.lfm}

procedure TUserPermissions.BtGravaClick(Sender: TObject);
var
  I: Integer;
begin
  with FUserControl.TableRights do
  begin
    FUserControl.DataConnector.UCExecSQL('Delete from ' + TableName + ' Where '
      + FieldUserID + ' = ' + IntToStr(FTempUserID) + ' and ' + FieldModule +
      ' = ' + QuotedStr(FUserControl.ApplicationID));
    FUserControl.DataConnector.UCExecSQL('Delete from ' + TableName +
      'EX Where ' + FieldUserID + ' = ' + IntToStr(FTempUserID) + ' and ' +
      FieldModule + ' = ' + QuotedStr(FUserControl.ApplicationID));
  end;

  for I := 0 to TreeMenu.Items.Count - 1 do
    if PTreeMenu(TreeMenu.Items[I].Data).Selected = 1 then
      FUserControl.AddRight(FTempUserID,
        PTreeMenu(TreeMenu.Items[I].Data).MenuName);

  for I := 0 to TreeAction.Items.Count - 1 do
    if PTreeAction(TreeAction.Items[I].Data).Selected = 1 then
      FUserControl.AddRight(FTempUserID,
        PTreeAction(TreeAction.Items[I].Data).MenuName);

  // Extra Rights
  for I := 0 to Pred(TreeControls.Items.Count) do
    if PTreeControl(TreeControls.Items[I].Data).Selected = 1 then
      FUserControl.AddRightEX(FTempUserID, FUserControl.ApplicationID,
        PTreeControl(TreeControls.Items[I].Data).FormName,
        PTreeControl(TreeControls.Items[I].Data).CompName);

  Close;
end;

procedure TUserPermissions.TrataItem(IT: TMenuItem; Node: TTreeNode);
var
  I: Integer;
  TempNode: TTreeNode;
begin
  for I := 0 to IT.Count - 1 do
    if IT.Items[I].Caption <> '-' then
      if IT.Items[I].Count > 0 then
        begin
          New(FTempMenuPointer);
          SetLength(FMenuList, Length(FMenuList) + 1);
          // Adicionado por Luiz 18/01/06
          FMenuList[ High(FMenuList)] := FTempMenuPointer;
          // Adicionado por Luiz 18/01/06
          FTempMenuPointer.Selected := 0;
          FTempMenuPointer.MenuName := IT.Items[I].Name;
          TempNode := TreeMenu.Items.AddChildObject(Node,
            StringReplace(IT.Items[I].Caption, '&', '', [rfReplaceAll]),
            FTempMenuPointer);
          TrataItem(IT.Items[I], TempNode);
        end
      else
        begin
          New(FTempMenuPointer);
          SetLength(FMenuList, Length(FMenuList) + 1);
          // Adicionado por Luiz 18/01/06
          FMenuList[ High(FMenuList)] := FTempMenuPointer;
          // Adicionado por Luiz 18/01/06
          FTempMenuPointer.Selected := 0;
          FTempMenuPointer.MenuName := IT.Items[I].Name;
          TreeMenu.Items.AddChildObject(Node,
            StringReplace(IT.Items[I].Caption, '&', '', [rfReplaceAll]),
            FTempMenuPointer);
        end;
end;

{$IFNDEF FPC}
{ .$IFDEF UCACTMANAGER }
procedure TUserPermis.TrataItem(IT: TActionClientItem; Node: TTreeNode);
var
  Contador: Integer;
  TempNode: TTreeNode;
begin
  for Contador := 0 to IT.Items.Count - 1 do
    if IT.Items[Contador].Caption <> '-' then
      if IT.Items[Contador].Items.Count > 0 then
        begin
          New(FTempMPointer);
          SetLength(FListaMenu, Length(FListaMenu) + 1);
          // Adicionado por Luiz 18/01/06
          FListaMenu[ High(FListaMenu)] := FTempMPointer;
          // Adicionado por Luiz 18/01/06
          FTempMPointer.Selecionado := 0;
          FTempMPointer.MenuName := #1 + 'G' + IT.Items[Contador].Caption;
          TempNode := TreeMenu.Items.AddChildObject(Node,
            StringReplace(IT.Items[Contador].Caption, '&', '', [rfReplaceAll]),
            FTempMPointer);
          TrataItem(IT.Items[Contador], TempNode);
        end
      else
        begin
          New(FTempMPointer);
          SetLength(FListaMenu, Length(FListaMenu) + 1);
          // Adicionado por Luiz 18/01/06
          FListaMenu[ High(FListaMenu)] := FTempMPointer;
          // Adicionado por Luiz 18/01/06
          FTempMPointer.Selecionado := 0;
          FTempMPointer.MenuName := IT.Items[Contador].Action.Name;
          TreeMenu.Items.AddChildObject(Node,
            StringReplace(IT.Items[Contador].Caption, '&', '', [rfReplaceAll]),
            FTempMPointer);
        end;
end;
{ .$ENDIF }
{$ENDIF}

procedure TUserPermissions.CarregaTreeviews;
var
  I: Integer;
  TempNode: TTreeNode;
  Temp: string;
  Temp2: string;
  Desc: string;
begin
  FChangingTree := False;
  PC.ActivePage := PageMenu;

  { Self.FMenu              := FUserControl.ControlRight.MainMenu;
    Self.FActionMainMenuBar := FUserControl.ControlRight.ActionMainMenuBar;
    if Assigned(FUserControl.ControlRight.ActionList) then
      Self.FActions := FUserControl.ControlRight.ActionList
    else
      Self.FActions := FUserControl.ControlRight.ActionManager; }

  Self.FMenu := FUserControl.ControlRight.MainMenu;
{$IFNDEF FPC}
  Self.FActionMainMenuBar := FUserControl.ControlRight.ActionMainMenuBar;
  if Assigned(FUserControl.ControlRight.ActionList) then
    Self.FActions := FUserControl.ControlRight.ActionList
  else
    Self.FActions := FUserControl.ControlRight.ActionManager;
{$ELSE}
  if Assigned(FUserControl.ControlRight.ActionList) then
    Self.FActions := FUserControl.ControlRight.ActionList;
{$ENDIF}
  Self.FExtraRights := FUserControl.ExtraRights;

  (* if (not Assigned(FMenu)) and (not Assigned(FUserControl.ControlRight.ActionList))
    {.$IFDEF UCACTMANAGER} and (not Assigned(FUserControl.ControlRight.ActionManager)) and
    (not Assigned(FUserControl.ControlRight.ActionMainMenuBar))
    {.$ENDIF} then
    begin
    if (Assigned(FMenu))
    {.$IFDEF UCACTMANAGER} and (not Assigned(FUserControl.ControlRight.ActionMainMenuBar))
    {.$ENDIF} then *)

  // TempNode := nil;
  if Assigned(FMenu) then
    begin
      TreeMenu.Items.Clear;
      for I := 0 to FMenu.Items.Count - 1 do
        if FMenu.Items[I].Count > 0 then
          begin
            New(FTempMenuPointer);
            SetLength(FMenuList, Length(FMenuList) + 1);
            // Adicionado por Luiz 18/01/06
            FMenuList[ High(FMenuList)] := FTempMenuPointer;
            // Adicionado por Luiz 18/01/06
            FTempMenuPointer.Selected := 0;
            FTempMenuPointer.MenuName := FMenu.Items[I].Name;
            TempNode := TreeMenu.Items.AddObject(nil,
              StringReplace(FMenu.Items[I].Caption, '&', '', [rfReplaceAll]),
              FTempMenuPointer);
            TrataItem(FMenu.Items[I], TempNode);
          end
        else if FMenu.Items[I].Caption <> '-' then
          begin
            New(FTempMenuPointer);
            SetLength(FMenuList, Length(FMenuList) + 1);
            // Adicionado por Luiz 18/01/06
            FMenuList[ High(FMenuList)] := FTempMenuPointer;
            // Adicionado por Luiz 18/01/06
            FTempMenuPointer.Selected := 0;
            FTempMenuPointer.MenuName := FMenu.Items[I].Name;
            TreeMenu.Items.AddObject(nil,
              StringReplace(FMenu.Items[I].Caption, '&', '', [rfReplaceAll]),
              FTempMenuPointer);
          end;
      TreeMenu.FullExpand;
      TreeMenu.Perform(WM_VSCROLL, SB_TOP, 0);
    end;

  {$IFNDEF FPC}
  { .$IFDEF UCACTMANAGER }
  // TempNode := nil;
  if Assigned(FActionMainMenuBar) then
    begin
      TreeMenu.Items.Clear;
      for Contador := 0 to FActionMainMenuBar.ActionClient.Items.Count - 1 do
        begin
          Temp := IntToStr(Contador);
          if FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)
            ].Items.Count > 0 then
            begin
              New(FTempMPointer);
              SetLength(FListaMenu, Length(FListaMenu) + 1);
              // Adicionado por Luiz 18/01/06
              FListaMenu[ High(FListaMenu)] := FTempMPointer;
              // Adicionado por Luiz 18/01/06
              FTempMPointer.Selecionado := 0;
              FTempMPointer.MenuName := #1 + 'G' + FActionMainMenuBar.ActionClient.
                Items[StrToInt(Temp)].Caption;
              TempNode := TreeMenu.Items.AddObject(nil,
                StringReplace(FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)
                ].Caption, '&', '', [rfReplaceAll]), FTempMPointer);
              TrataItem(FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)],
                TempNode);
            end
          else
            begin
              New(FTempMPointer);
              SetLength(FListaMenu, Length(FListaMenu) + 1);
              // Adicionado por Luiz 18/01/06
              FListaMenu[ High(FListaMenu)] := FTempMPointer;
              // Adicionado por Luiz 18/01/06
              FTempMPointer.Selecionado := 0;
              FTempMPointer.MenuName := FActionMainMenuBar.ActionClient.Items
                [StrToInt(Temp)].Action.Name;
              TreeMenu.Items.AddObject(nil,
                StringReplace(FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)
                ].Action.Name, '&', '', [rfReplaceAll]), FTempMPointer);
            end;
          TreeMenu.FullExpand;
          TreeMenu.Perform(WM_VSCROLL, SB_TOP, 0);
        end;
    end;
  { .$ENDIF }
  {$ENDIF}

  (* if (Assigned(FUserControl.ControlRight.ActionList))
    {.$IFDEF UCACTMANAGER} or (Assigned(FUserControl.ControlRight.ActionManager))
    {.$ENDIF} then *)

  TempNode := nil;
  if Assigned(FActions) then
    begin
      TreeAction.Items.Clear;
      if Assigned(FTempList) then
        FreeAndNil(FTempList);
      FTempList := TStringList.Create;
      for I := 0 to TActionList(FActions).ActionCount - 1 do
        FTempList.Append(TActionList(FActions).Actions[I].Category + #1 +
          TActionList(FActions).Actions[I].Name + #2 +
          TAction(TActionList(FActions).Actions[I]).Caption);
      FTempList.Sort;
      Temp := #1;
      for I := 0 to FTempList.Count - 1 do
        begin
          if Temp <> Copy(FTempList[I], 1,
            Pos(#1, FTempList[I]) - 1) then
            begin
              New(FTempActionPointer);
              SetLength(FActionList, Length(FActionList) + 1);
              // Adicionado por Luiz 18/01/06
              FActionList[ High(FActionList)] := FTempActionPointer;
              // Adicionado por Luiz 18/01/06
              FTempActionPointer.Group := True;
              FTempActionPointer.Selected := 0;
              FTempActionPointer.MenuName := 'Grupo';
              TempNode := TreeAction.Items.AddObject(nil,
                StringReplace(Copy(FTempList[I], 1,
                Pos(#1, FTempList[I]) - 1), '&', '', [rfReplaceAll]),
                FTempActionPointer);
              TempNode.ImageIndex := 2;
              TempNode.SelectedIndex := 2;
              Temp := Copy(FTempList[I], 1,
                Pos(#1, FTempList[I]) - 1);
            end;
          Temp2 := FTempList[I];
          Delete(Temp2, 1, Pos(#1, Temp2));
          New(FTempActionPointer);
          SetLength(FActionList, Length(FActionList) + 1);
          // Adicionado por Luiz 18/01/06
          FActionList[ High(FActionList)] := FTempActionPointer;
          // Adicionado por Luiz 18/01/06
          FTempActionPointer.Group := False;
          FTempActionPointer.Selected := 0;
          FTempActionPointer.MenuName := Copy(Temp2, 1, Pos(#2, Temp2) - 1);
          Delete(Temp2, 1, Pos(#2, Temp2));
          TreeAction.Items.AddChildObject(TempNode, StringReplace(Temp2, '&', '',
            [rfReplaceAll]), FTempActionPointer);
        end;
      TreeAction.FullExpand;
      TreeAction.Perform(WM_VSCROLL, SB_TOP, 0);
    end;

  // ExtraRights
  TempNode := nil;
  if Self.FExtraRights.Count > 0 then
    begin
      TreeControls.Items.Clear;
      if Assigned(FTempList) then
        FreeAndNil(FTempList);
      FTempList := TStringList.Create;
      for I := 0 to Pred(FExtraRights.Count) do
        FTempList.Append(FExtraRights[I].GroupName + #1 + FExtraRights
          [I].Caption + #2 + FExtraRights[I].FormName + #3 +
          FExtraRights[I].CompName);
      FTempList.Sort;
      Temp := #1;
      for I := 0 to Pred(FTempList.Count) do
        begin
          if Temp <> Copy(FTempList[I], 1,
            Pos(#1, FTempList[I]) - 1) then
            begin
              New(FTempControlPointer);
              SetLength(FControlList, Length(FControlList) + 1);
              // Adicionado por Luiz 18/01/06
              FControlList[ High(FControlList)] := FTempControlPointer;
              // Adicionado por Luiz 18/01/06
              FTempControlPointer.Group := True;
              FTempControlPointer.Selected := 0;
              FTempControlPointer.FormName := 'Grupo';
              FTempControlPointer.CompName := 'Grupo';
              TempNode := TreeControls.Items.AddObject(nil,
                Copy(FTempList[I], 1, Pos(#1, FTempList[I]) - 1),
                FTempControlPointer);
              TempNode.ImageIndex := 2;
              TempNode.SelectedIndex := 2;
              Temp := Copy(FTempList[I], 1,
                Pos(#1, FTempList[I]) - 1);
            end;
          Temp2 := FTempList[I];
          Delete(Temp2, 1, Pos(#1, Temp2));
          New(FTempControlPointer);
          SetLength(FControlList, Length(FControlList) + 1);
          // Adicionado por Luiz 18/01/06
          FControlList[ High(FControlList)] := FTempControlPointer;
          // Adicionado por Luiz 18/01/06
          FTempControlPointer.Group := False;
          FTempControlPointer.Selected := 0;
          Desc := Copy(Temp2, 1, Pos(#2, Temp2) - 1); // descricao do objeto
          Delete(Temp2, 1, Pos(#2, Temp2));

          FTempControlPointer.FormName := Copy(Temp2, 1, Pos(#3, Temp2) - 1);
          Delete(Temp2, 1, Pos(#3, Temp2));
          FTempControlPointer.CompName := Temp2;
          TreeControls.Items.AddChildObject(TempNode, Desc, FTempControlPointer);
          FTempControlPointer := nil;
        end;
      TreeControls.FullExpand;
      TreeControls.Perform(WM_VSCROLL, SB_TOP, 0);
    end;

  PageMenu.TabVisible := Assigned(FMenu);

  PageAction.TabVisible := Assigned(FActions);

  PageControls.TabVisible := (Assigned(FExtraRights) and
    (FExtraRights.Count > 0));
end;

procedure TUserPermissions.UnCheckChild(Node: TTreeNode);
var
  Child: TTreeNode;
begin
  PTreeMenu(Node.Data).Selected := 0;
  Node.ImageIndex := 0;
  Node.SelectedIndex := 0;
  Child := Node.GetFirstChild;
  repeat
    if Child.HasChildren then
      UnCheckChild(Child)
    else
      begin
        PTreeMenu(Child.Data).Selected := 0;
        Child.ImageIndex := 0;
        Child.SelectedIndex := 0;
      end;
    Child := Node.GetNextChild(Child);
  until Child = nil;
end;

procedure TUserPermissions.TreeMenuItem(marca: Boolean);
var
  AbsIdx: Integer;
begin
  if TreeMenu.Selected = nil then
    Exit;

  if marca then
    if PTreeMenu(TreeMenu.Selected.Data).Selected < 2 then
      begin
        if PTreeMenu(TreeMenu.Selected.Data).Selected = 0 then // marcar
          begin
            AbsIdx := TreeMenu.Selected.AbsoluteIndex;
            while AbsIdx > -1 do
              begin
                PTreeMenu(TreeMenu.Items.Item[AbsIdx].Data).Selected := 1;
                TreeMenu.Items.Item[AbsIdx].ImageIndex := 1;
                TreeMenu.Items.Item[AbsIdx].SelectedIndex := 1;
                if TreeMenu.Items.Item[AbsIdx].Parent <> nil then
                  begin
                    AbsIdx := TreeMenu.Items.Item[AbsIdx].Parent.AbsoluteIndex;
                    if PTreeMenu(TreeMenu.Items.Item[AbsIdx].Data).Selected = 2 then
                      AbsIdx := -1;
                  end
                else
                  AbsIdx := -1;
              end;
          end
        else if TreeMenu.Selected.HasChildren then
          UnCheckChild(TreeMenu.Selected)
        else
          begin
            PTreeMenu(TreeMenu.Selected.Data).Selected := 0;
            TreeMenu.Selected.ImageIndex := 0;
            TreeMenu.Selected.SelectedIndex := 0;
          end; // desmarcar
        TreeMenu.Repaint;
      end;
end;

procedure TUserPermissions.TreeActionItem(marca: Boolean);
begin
  if not Assigned(FActions) then
    Exit;

  if PTreeAction(TreeAction.Selected.Data).Group then
    Exit;

  if marca then
    begin
      if PTreeAction(TreeAction.Selected.Data).Selected < 2 then
        if PTreeAction(TreeAction.Selected.Data).Selected = 0 then
          PTreeAction(TreeAction.Selected.Data).Selected := 1
        else
          PTreeAction(TreeAction.Selected.Data).Selected := 0;
      TreeAction.Selected.ImageIndex := PTreeAction(TreeAction.Selected.Data).Selected;
      TreeAction.Selected.SelectedIndex := PTreeAction(TreeAction.Selected.Data).Selected;
    end;
  TreeAction.Repaint;
end;

procedure TUserPermissions.TreeControlItem(marca: Boolean);
begin
  if TreeControls.Selected = nil then
    Exit;

  if PTreeControl(TreeControls.Selected.Data).Group then
    Exit;

  if marca then
    begin
      if PTreeControl(TreeControls.Selected.Data).Selected < 2 then
        if PTreeControl(TreeControls.Selected.Data).Selected = 0 then
          PTreeControl(TreeControls.Selected.Data).Selected := 1
        else
          PTreeControl(TreeControls.Selected.Data).Selected := 0;
      TreeControls.Selected.ImageIndex := PTreeControl(TreeControls.Selected.Data).Selected;
      TreeControls.Selected.SelectedIndex := PTreeAction(TreeControls.Selected.Data).Selected;
    end;
  TreeControls.Repaint;
end;

procedure TUserPermissions.TreeMenuClick(Sender: TObject);
begin
  if not FChangingTree then
    TreeMenuItem(True);
end;

procedure TUserPermissions.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TUserPermissions.BtLiberaClick(Sender: TObject);
begin
  Atualiza(True);
end;

procedure TUserPermissions.Atualiza(Selec: Boolean);
var
  I: Integer;
  Temp: Integer;
begin
  if Selec then
    Temp := 1
  else
    Temp := 0;

  if PC.ActivePage = PageMenu then
    begin
      for I := 0 to TreeMenu.Items.Count - 1 do
        if PTreeMenu(TreeMenu.Items[I].Data).Selected < 2 then
          begin
            PTreeMenu(TreeMenu.Items[I].Data).Selected := Temp;
            TreeMenu.Items[I].ImageIndex := Temp;
            TreeMenu.Items[I].SelectedIndex := Temp;
          end;
      TreeMenu.Repaint;
    end
  else if PC.ActivePage = PageAction then
    begin
      for I := 0 to TreeAction.Items.Count - 1 do
        if not PTreeAction(TreeAction.Items[I].Data).Group then
          if PTreeAction(TreeAction.Items[I].Data).Selected < 2 then
            begin
              PTreeAction(TreeAction.Items[I].Data).Selected := Temp;
              TreeAction.Items[I].ImageIndex := Temp;
              TreeAction.Items[I].SelectedIndex := Temp;
            end;
      TreeAction.Repaint;
    end
  else
    begin // tabContols
      for I := 0 to TreeControls.Items.Count - 1 do
        if not PTreeControl(TreeControls.Items[I].Data).Group then
          if PTreeControl(TreeControls.Items[I].Data).Selected < 2 then
            begin
              PTreeControl(TreeControls.Items[I].Data).Selected := Temp;
              TreeControls.Items[I].ImageIndex := Temp;
              TreeControls.Items[I].SelectedIndex := Temp;
            end;
      TreeControls.Repaint;
    end;
end;

procedure TUserPermissions.BtBloqueiaClick(Sender: TObject);
begin
  Atualiza(False);
end;

procedure TUserPermissions.FormShow(Sender: TObject);
var
  I: Integer;
  Selec: Integer;
begin
  // Adcionado por Luiz
  SetLength(FActionList, 0);
  SetLength(FMenuList, 0);
  SetLength(FControlList, 0);

  // carrega itens do menu, actions e controles
  CarregaTreeviews;

  // Exibe Permissoes do Usuario
  for I := 0 to TreeAction.Items.Count - 1 do
    begin
      PermissionsDataset.First;
      if PermissionsDataset.Locate('ObjName', PTreeAction(TreeAction.Items[I].Data).MenuName, []) then
        Selec := 1
      else
        Selec := 0;

      PTreeAction(TreeAction.Items[I].Data).Selected := Selec;
      if not PTreeAction(TreeAction.Items[I].Data).Group then
        begin
          TreeAction.Items[I].ImageIndex := Selec;
          TreeAction.Items[I].SelectedIndex := Selec;
        end;
    end;

  for I := 0 to TreeMenu.Items.Count - 1 do
    begin
      PermissionsDataset.First;
      if PermissionsDataset.Locate('ObjName', PTreeMenu(TreeMenu.Items[I].Data)
        .MenuName, []) then
        Selec := 1
      else
        Selec := 0;

      PTreeMenu(TreeMenu.Items[I].Data).Selected := Selec;
      TreeMenu.Items[I].ImageIndex := Selec;
      TreeMenu.Items[I].SelectedIndex := Selec;
    end;

  // Extra Rights
  for I := 0 to Pred(TreeControls.Items.Count) do
    begin
      PermissionsDatasetEx.First;
      if PermissionsDatasetEx.Locate('FormName;ObjName',
        VarArrayOf([PTreeControl(TreeControls.Items[I].Data).FormName,
        PTreeControl(TreeControls.Items[I].Data).CompName]), []) then
        Selec := 1
      else
        Selec := 0;

      PTreeControl(TreeControls.Items[I].Data).Selected := Selec;
      if not PTreeControl(TreeControls.Items[I].Data).Group then
        begin
          TreeControls.Items[I].ImageIndex := Selec;
          TreeControls.Items[I].SelectedIndex := Selec;
        end;
    end;

  // Exibe Permissoes do Perfil
  if ProfilesDataset.Active then
    begin
      for I := 0 to TreeAction.Items.Count - 1 do
        begin
          ProfilesDataset.First;
          if ProfilesDataset.Locate('ObjName', PTreeAction(TreeAction.Items[I].Data)
            .MenuName, []) then
            begin
              Selec := 2;
              PTreeAction(TreeAction.Items[I].Data).Selected := Selec;
              if not PTreeAction(TreeAction.Items[I].Data).Group then
                begin
                  TreeAction.Items[I].ImageIndex := Selec;
                  TreeAction.Items[I].SelectedIndex := Selec;
                end;
            end;
        end;

      for I := 0 to TreeMenu.Items.Count - 1 do
        begin
          ProfilesDataset.First;
          if ProfilesDataset.Locate('ObjName', PTreeMenu(TreeMenu.Items[I].Data)
            .MenuName, []) then
            begin
              Selec := 2;
              PTreeMenu(TreeMenu.Items[I].Data).Selected := Selec;
              TreeMenu.Items[I].ImageIndex := Selec;
              TreeMenu.Items[I].SelectedIndex := Selec;
            end;
        end;

      // Extra Rights
      for I := 0 to Pred(TreeControls.Items.Count) do
        begin
          ProfilesDatasetEx.First;
          if ProfilesDatasetEx.Locate('FormName;ObjName',
            VarArrayOf([PTreeControl(TreeControls.Items[I].Data).FormName,
            PTreeControl(TreeControls.Items[I].Data).CompName]), []) then
            begin
              Selec := 2;
              PTreeControl(TreeControls.Items[I].Data).Selected := Selec;
              if not PTreeControl(TreeControls.Items[I].Data).Group then
                begin
                  TreeControls.Items[I].ImageIndex := Selec;
                  TreeControls.Items[I].SelectedIndex := Selec;
                end;
            end;
        end;
    end;

  TreeAction.Repaint;
  TreeMenu.Repaint;
  FChangingTree := False;
end;

procedure TUserPermissions.TreeActionClick(Sender: TObject);
begin
  if not FChangingTree then
    TreeActionItem(True);
end;

procedure TUserPermissions.TreeControlsClick(Sender: TObject);
begin
  if not FChangingTree then
    TreeControlItem(True);
end;

procedure TUserPermissions.TreeMenuCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  if (Self.Showing) and (TTreeView(Sender).Focused) then
    FChangingTree := True;
end;

procedure TUserPermissions.TreeMenuKeyPress(Sender: TObject; var Key: char);
begin
  if Key = ' ' then
    begin
      TTreeView(Sender).OnClick(Sender);
      Key := #0;
    end;
end;

procedure TUserPermissions.TreeMenuMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FChangingTree := False;
end;

procedure TUserPermissions.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  // Adicionado por Luiz 18/01/06
  if Assigned(PermissionsDataset) then
    FreeAndNil(PermissionsDataset);
  if Assigned(PermissionsDatasetEx) then
    FreeAndNil(PermissionsDatasetEx);
  if Assigned(ProfilesDataset) then
    FreeAndNil(ProfilesDataset);
  if Assigned(ProfilesDatasetEx) then
    FreeAndNil(ProfilesDatasetEx);
  if Assigned(FTempList) then
    FreeAndNil(FTempList);
  for I := 0 to High(FMenuList) do
    Dispose(FMenuList[I]);
  for I := 0 to High(FActionList) do
    Dispose(FActionList[I]);
  for I := 0 to High(FControlList) do
    Dispose(FControlList[I]);
end;

end.
