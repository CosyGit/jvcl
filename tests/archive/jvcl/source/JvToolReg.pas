{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvToolReg.PAS, released on 2002-07-04.

The Initial Developers of the Original Code are: Fedor Koshevnikov, Igor Pavluk and Serge Korolev
Copyright (c) 1997, 1998 Fedor Koshevnikov, Igor Pavluk and Serge Korolev
Copyright (c) 2001,2002 SGB Software
All Rights Reserved.

Last Modified: 2002-07-04

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}

{$I JVCL.INC}

unit JvToolReg;

interface

procedure Register;

implementation

{.$R *.Res}

uses
  Classes, SysUtils, Controls, TypInfo, Consts,
  {$IFDEF COMPILER6_UP}
  RTLConsts, DesignIntf, DesignEditors, VCLEditors,
  {$ELSE}
  LibIntf, DsgnIntf,
  {$ENDIF}
  {$IFDEF USE_JV_GIF}
  JvGIF, JvGIFCtrl,
  {$ENDIF}
  JvxCtrls,
  {$IFDEF COMPILER3_UP}
  {JvResExp, }
  {$ENDIF}
  JvMenus, JvMRUList,
  {$IFDEF WIN32}
  JvNotify, JvGrdCpt, JvGradEdit,
  {$ENDIF}
  JvPictEdit, JvWndProcHook, JvPicClip, JvPlacemnt, JvPresrDsn, JvMinMaxEd, JvDualList,
  JvClipView, JvSpeedbar, JvSbEdit, JvDataConv, JvCalc, JvPageMngr, JvPgMngrEd, JvMrgMngr,
  JvStrHlder, JvAppEvent, JvVCLUtils, JvTimerLst, JvTimLstEd, JvIcoList, JvIcoLEdit,
  JvDsgnEditors, JvxDConst;

//=== TJvStringsEditor =======================================================

type
  TJvStringsEditor = class(TDefaultEditor)
  public
    {$IFDEF COMPILER6_UP}
    procedure EditProperty(const PropertyEditor: IProperty;
      var Continue: Boolean); override;
    {$ELSE}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
    {$ENDIF}
  end;

{$IFDEF COMPILER6_UP}
procedure TJvStringsEditor.EditProperty(const PropertyEditor: IProperty;
  var Continue: Boolean);
{$ELSE}
procedure TJvStringsEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'STRINGS') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;

//=== TJvComponentFormProperty ===============================================

type
  TJvComponentFormProperty = class(TComponentProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

procedure TJvComponentFormProperty.GetValues(Proc: TGetStrProc);
var
  Form: TComponent;
begin
  inherited GetValues(Proc);
  Form := Designer.{$IFDEF COMPILER6_UP} Root {$ELSE} Form {$ENDIF};
  if (Form is GetTypeData(GetPropType)^.ClassType) and (Form.Name <> '') then
    Proc(Form.Name);
end;

procedure TJvComponentFormProperty.SetValue(const Value: string);
var
  Component: TComponent;
  Form: TComponent;
begin
  {$IFDEF WIN32}
  Component := Designer.GetComponent(Value);
  {$ELSE}
  Component := Designer.Root.FindComponent(Value);
  {$ENDIF}
  Form := Designer.{$IFDEF COMPILER6_UP} Root {$ELSE} Form {$ENDIF};
  if ((Component = nil) or not (Component is GetTypeData(GetPropType)^.ClassType)) and
    (CompareText(Form.Name, Value) = 0) then
  begin
    if not (Form is GetTypeData(GetPropType)^.ClassType) then
      raise EPropertyError.Create(ResStr(SInvalidPropertyValue));
    SetOrdValue(Longint(Form));
  end
  else
    inherited SetValue(Value);
end;

procedure Register;
begin
  RegisterComponents(srJvXToolsPalette, [TJvPicClip, TJvFormStorage,
    TJvFormPlacement, TJvWindowHook, TJvAppEvents, TJvSpeedBar, TJvCalculator,
      TJvTimerList, TJvPageManager, TJvMergeManager, TJvMRUManager, TJvSecretPanel,
      TJvStrHolder, TJvMainMenu, TJvPopupMenu,
      {$IFDEF WIN32} TJvFolderMonitor, {$ENDIF} TJvxClipboardViewer,
      {$IFDEF WIN32} TJvxGradientCaption, {$ENDIF} TJvDualListDialog
      {$IFNDEF COMPILER4_UP}, TJvConverter {$ENDIF}]);

  {$IFDEF COMPILER3_UP}
  RegisterNonActiveX([TJvPicClip, TJvFormPlacement, TJvFormStorage, TJvWindowHook,
    TJvDualListDialog, TJvSecretPanel, TJvSpeedBar, TJvxClipboardViewer,
      TJvPageManager, TJvMergeManager, TJvMRUManager, TJvAppEvents, TJvTimerList,
      TJvFolderMonitor, TJvxGradientCaption], axrComponentOnly);
  {$ENDIF COMPILER3_UP}

  RegisterComponentEditor(TJvPicClip, TJvGraphicsEditor);
  RegisterComponentEditor(TJvStrHolder, TJvStringsEditor);
  RegisterPropertyEditor(TypeInfo(TJvWinMinMaxInfo), TJvFormPlacement,
    'MinMaxInfo', TMinMaxProperty);
  RegisterComponentEditor(TJvFormStorage, TJvFormStorageEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), TJvFormStorage, 'StoredProps',
    TJvStoredPropsProperty);
  RegisterPropertyEditor(TypeInfo(TWinControl), TJvWindowHook,
    'WinControl', TJvComponentFormProperty);
  RegisterNoIcon([TJvSpeedItem, TJvSpeedbarSection]);
  RegisterComponentEditor(TJvSpeedBar, TJvSpeedbarCompEditor);
  RegisterPropertyEditor(TypeInfo(TCaption), TJvSpeedItem, 'BtnCaption', THintProperty);
  RegisterNoIcon([TJvPageProxy]);
  RegisterComponentEditor(TJvPageManager, TJvPageManagerEditor);
  RegisterPropertyEditor(TypeInfo(TList), TJvPageManager, 'PageProxies',
    TJvProxyListProperty);
  RegisterPropertyEditor(TypeInfo(string), TJvPageProxy, 'PageName', TJvPageNameProperty);
  RegisterPropertyEditor(TypeInfo(TControl), TJvPageManager, 'PriorBtn', TJvPageBtnProperty);
  RegisterPropertyEditor(TypeInfo(TControl), TJvPageManager, 'NextBtn', TJvPageBtnProperty);
  RegisterPropertyEditor(TypeInfo(TWinControl), TJvMergeManager, 'MergeFrame', TJvComponentFormProperty);
  RegisterNoIcon([TJvTimerEvent]);
  RegisterComponentEditor(TJvTimerList, TJvTimersCollectionEditor);
  RegisterPropertyEditor(TypeInfo(TList), TJvTimerList, 'Events', TJvTimersItemListProperty);
  RegisterPropertyEditor(TypeInfo(TJvIconList), nil, '', TIconListProperty);
  {$IFDEF COMPILER4_UP}
  RegisterPropertyEditor(TypeInfo(Boolean), TJvMainMenu, 'OwnerDraw', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TJvPopupMenu, 'OwnerDraw', nil);
  {$ENDIF}

  {$IFDEF USE_JV_GIF}
  RegisterComponentEditor(TJvGIFAnimator, TJvGraphicsEditor);
  {$ENDIF}

//  RegisterPropertyEditor(TypeInfo(TPicture), nil, '', TJvPictProperty);
//  RegisterPropertyEditor(TypeInfo(TGraphic), nil, '', TJvGraphicPropertyEditor);
//  RegisterComponentEditor(TImage, TJvGraphicsEditor);

  {$IFDEF WIN32}
  RegisterComponentEditor(TJvxGradientCaption, TGradientCaptionEditor);
  {$IFNDEF COMPILER3_UP}
  RegisterPropertyEditor(TypeInfo(TJvCaptionList), TJvxGradientCaption, '', TGradientCaptionsProperty);
  {$ENDIF}
  {$ENDIF}

  {$IFDEF COMPILER3_UP}
  { Project Resource Expert }
  //mb RegisterResourceExpert;
  {$ENDIF}
end;

end.

