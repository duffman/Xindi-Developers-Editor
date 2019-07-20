unit ZynDialog;

// Virtual Treeview sample form demonstrating following features:
//   - Property page like string tree with individual node editors.
//   - Incremental search.
// Written by Mike Lischke.
{$WARN UNSAFE_CODE OFF} // Prevent warnins that are not applicable 

interface

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    StdCtrls, VirtualTrees, ImgList, ExtCtrls, UITypes, System.ImageList,
    Vcl.ComCtrls, FileCtrl, ShellAPI, System.Variants,
    FileUtils, VTreeConst, UTreeData,

    ZynTreeTypes, ZynTreeListing, ZynTreeEngine, Vcl.ToolWin, VirtualFileSearch

    ;

const
    // Helper message to decouple node change handling from edit handling.
    WM_STARTEDITING = WM_USER + 778;


type
  TfrmZynDialog = class(TForm)
    VST: TVirtualStringTree;
    Label9: TLabel;
    Label10: TLabel;
    TreeImages: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    pnlBottom: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    VirtualFileSearch: TVirtualFileSearch;
    mmoLog: TMemo;
    Button4: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure VSTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VSTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure VSTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure VSTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
    procedure VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: TImageIndex);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VSTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure VSTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure VSTPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure VSTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode; const SearchText: string;
      var Result: Integer);
    procedure RadioGroup1Click(Sender: TObject);
    procedure VSTStateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
    procedure VSTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VSTKeyPress(Sender: TObject; var Key: Char);
    procedure VSTKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure VSTExpanding(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var Allowed: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
  	FTreeEngine: TZynTreeEngine;

    procedure UpdateTree();

    procedure DoLog(AValue: String);

    procedure WMStartEditing(var Message: TMessage); message WM_STARTEDITING;

  end;

var
  frmZynDialog: TfrmZynDialog;

//----------------------------------------------------------------------------------------------------------------------
{
ADD NODE
                    SHGetFileInfo(PChar(FileName),0,ShInfo,SizeOf(ShInfo),SHGFI_TYPENAME
	                    or SHGFI_SYSICONINDEX or SHGFI_DISPLAYNAME);

                        }

{
type

    PComNodeData = ^TComNodeData;
    TComNodeData = record
        ValueType: TValueType;
        Value: UnicodeString;      // This value can actually be a date or a number too.
        ParentIndex: Integer;
        NodeIndex: Integer;
        ChildCount: Integer;
        Changed: Boolean;
        Expanded: Boolean;
    end;
}

implementation

uses
	Math, Main;
	//Editors, States;

{$R *.DFM}

procedure TfrmZynDialog.DoLog(AValue: String);
begin
	mmoLog.Lines.Add('> ' + AValue);
end;

//----------------- TXindiFileDialog -------------------------------------------


procedure TfrmZynDialog.Button3Click(Sender: TObject);
var
	i: Integer;
    nodeData: TZynTreeNode;
begin
	mmoLog.Clear;
	FTreeEngine.SetDirectory('C:\Development');

	if FTreeEngine.Browse('*.*', 0) then
    begin
    	for i := 0 to FTreeEngine.DataList.Count-1 do
        begin
        	nodeData := FTreeEngine.DataList[i];
			DoLog(nodeData.FileName);
        end;
    end;
end;

procedure TfrmZynDialog.Button4Click(Sender: TObject);
var
	i: Integer;
	strList: TStringList;
begin
	mmoLog.Clear;
	strList := FTreeEngine.GetDataDump(true);

    for i := 0 to strList.Count-1 do
    begin
	    DoLog(strList[i]);
    end;

    FreeAndNil(strList);
end;

procedure TfrmZynDialog.Button5Click(Sender: TObject);
begin
	mmoLog.Clear;
end;

procedure TfrmZynDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FTreeEngine.Free;
end;

procedure TfrmZynDialog.FormCreate(Sender: TObject);
var
	Data: PNodeInfoRec; //PComNodeData;
    Node: PVirtualNode;
    Child: PVirtualNode;
begin
  	FTreeEngine := TZynTreeEngine.Create();


  // We assign these handlers manually to keep the demo source code compatible
  // with older Delphi versions after using UnicodeString instead of WideString.
  //VST3.OnGetText := VST3GetText;
  //VST3.OnGetHint := VST3GetHint;
  //VST3.OnIncrementalSearch := VST3IncrementalSearch;

  // Always tell the tree how much data space per node it must allocated for us. We can do this here, in the
  // object inspector or in the OnGetNodeDataSize event.


  	with VST3 do
    begin
    	NodeDataSize := SizeOf(TNodeInfoRec); // Duffman :: TPropertyData
    	Node := AddChild(nil); // adds a top level node

        {
        Data := GetNodeData(Node);
        Data.ChildCount := 6;

        Child := AddChild(Node);
        Data := GetNodeData(Child);
        Data.ChildCount := 2;
        }
	end;


  // The VCL (D7 and lower) still uses 16 color image lists. We create a high color version explicitely because it
  // looks so much nicer.
  //ConvertToHighColor(TreeImages);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
	Data: PNodeInfoRec;
begin
    ChildCount := 5;
	with VST3 do
		Data := GetNodeData(Node);

	if Assigned(Data) then
	    ChildCount := Data.ChildCount;




    {
    case Node.Index of
    0:
    ChildCount := 5;
    1:
    ChildCount := 8;
    end;
    }
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);

var
  Data: PNodeInfoRec;

begin
  if ParentNode = nil then
    InitialStates := InitialStates + [ivsHasChildren] // Duffman, ivsExpanded]
  else
  begin
    Data := Sender.GetNodeData(Node);

    Data.ParentIndex := ParentNode.Index;
    Data.NodeIndex := Node.Index;

    {
    if Data.ValueType = vtDate then
	    Data.Value := DateToStr(Now)
    else
    	Data.Value := DefaultValue[ParentNode.Index, Node.Index];
     }
  end;
end;

procedure TfrmZynDialog.VSTKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
    Node: PVirtualNode;
	Data: PNodeInfoRec;
begin
    Label9.Caption := 'KEY: ' + IntToStr(Key);

	with VST3 do
    begin
        if Key = 13 then
        begin
			Node := VST3.GetFirstSelected;
          	if Node = nil then Exit;

		    if not HasChildren[Node] then
				 Exit;


            Expanded[Node] := not Expanded[Node];
        end;


    end;

    //Selected[Node];

	//ShowMessage('balle');

end;

procedure TfrmZynDialog.VSTKeyPress(Sender: TObject; var Key: Char);
begin
//    ShowMessage('hårdpung');

end;

//----------------------------------------------------------------------------------------------------------------------



procedure TfrmZynDialog.VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);

var
	Data: PNodeInfoRec;

begin
    if TextType = ttNormal then
    case Column of 0:
    	if Sender.NodeParent[Node] = nil then
    	begin
            // root nodes
            if Node.Index = 0 then
	            CellText := 'Description'
            else
			    CellText := 'Origin';
		    end else
			    CellText := 'WTF'; //PropertyTexts[Sender.NodeParent[Node].Index, Node.Index, ptkText];
        1: begin
            Data := Sender.GetNodeData(Node);
            CellText := FTreeEngine.GetNodeText(Data);
	    end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
     Data: PNodeInfoRec;
begin
  // Add a dummy hint to the normal hint to demonstrate multiline hints.
  if (Column = 0) and (Sender.NodeParent[Node] <> nil) then
  begin

    Data := Sender.GetNodeData(Node);


    HintText := FTreeEngine.GetNodeText(Data);  //PropertyTexts[Sender.NodeParent[Node].Index, Node.Index, ptkHint];
    { Related to #Issue 623
      Observed when solving issue #623. For hmToolTip, the multi-line mode
      depends on the node's multi-lin emode. Hence, append a line only
      if not hmToolTip. Otherwise, if you must append lines, force the
      lineBreakStyle := hlbForceMultiLine for hmToolTip.
    }
    if (Sender as TVirtualStringTree).Hintmode <> hmTooltip then
       HintText := HintText
          + #13 + '(Multiline hints are supported too).'
          ;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var Index: TImageIndex);

var
	Data: PNodeInfoRec;

begin
    if (Kind in [ikNormal, ikSelected]) and (Column = 0) then
    begin
        if Sender.NodeParent[Node] = nil then
        	Index := 12 // root nodes, this is an open folder
        else begin
	        Index := 14
            {

            Data := Sender.GetNodeData(Node);
            if Data.ValueType <> vtNone then
            Index := 14
            else
            Index := 13;
            }
    	end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);

var
  Data: PNodeInfoRec;

begin
  with Sender do
  begin
    Data := GetNodeData(Node);
    Allowed := false; //(Sender.NodeParent[Node] <> nil) and (Column = 1) and (Data.ValueType <> vtNone);
  end;
end;

procedure TfrmZynDialog.VSTExpanding(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
begin
	// Browse data...
end;

//----------------------------------------------------------------------------------------------------------------------


procedure TfrmZynDialog.VSTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);

begin
  with Sender do
  begin
    // Start immediate editing as soon as another node gets focused.
    if Assigned(Node) and (Sender.NodeParent[Node] <> nil) and not (tsIncrementalSearching in TreeStates) then
    begin
      // We want to start editing the currently selected node. However it might well happen that this change event
      // here is caused by the node editor if another node is currently being edited. It causes trouble
      // to start a new edit operation if the last one is still in progress. So we post us a special message and
      // in the message handler we then can start editing the new node. This works because the posted message
      // is first executed *after* this event and the message, which triggered it is finished.
      PostMessage(Self.Handle, WM_STARTEDITING, WPARAM(Node), 0);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  out EditLink: IVTEditLink);
  
// This is the callback of the tree control to ask for an application defined edit link. Providing one here allows
// us to control the editing process up to which actual control will be created.
// TPropertyEditLink implements an interface and hence benefits from reference counting. We don't need to keep a
// reference to free it. As soon as the tree finished editing the class will be destroyed automatically.

begin
// Duffman  EditLink := TPropertyEditLink.Create;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType);

var
  Data: PNodeInfoRec;

begin
    // Make the root nodes underlined and draw changed nodes in bold style.
    if Sender.NodeParent[Node] = nil then
    	TargetCanvas.Font.Style := [fsUnderline]

    else begin
        Data := Sender.GetNodeData(Node);
        if Data.Changed then
        TargetCanvas.Font.Style := [fsBold]
    else
	    TargetCanvas.Font.Style := [];
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode; const SearchText: string;
  var Result: Integer);

var
    S,
    PropText: string;

begin
    S := SearchText;
    // Duffman SetStatusbarText('Searching for: ' + S);

    if Sender.NodeParent[Node] = nil then
    begin
	    // root nodes
	    if Node.Index = 0 then
		    PropText := 'Description'
	    else
		    PropText := 'Origin';

    end else
    begin
        // Duffman PropText := PropertyTexts[Sender.NodeParent[Node].Index, Node.Index, ptkText];
    end;

    // By using StrLIComp we can specify a maximum length to compare. This allows us to find also nodes
    // which match only partially. Don't forget to specify the shorter string length as search length.
    Result := StrLIComp(PChar(S), PChar(PropText), Min(Length(S), Length(PropText)))
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.FormShow(Sender: TObject);
var
	Node: PVirtualNode;
begin
	VST.SetFocus;
    Node := VST3.GetFirst();

    VST.Selected[Node] := true;
end;

procedure TfrmZynDialog.RadioGroup1Click(Sender: TObject);

begin
  with Sender as TRadioGroup do
    if ItemIndex = 0 then
      VST.IncrementalSearchDirection := sdForward
    else
      VST.IncrementalSearchDirection := sdBackward;
end;

procedure TfrmZynDialog.UpdateTree();
var
	i: Integer;
begin
   //	for i := 0 to FTree do



	//DateTime
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTStateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);

begin
  if tsIncrementalSearching in Enter then
    // Note: Unicode will be converted to ANSI here, but for demonstration purposes we accept that for now.
    // Duffman SetStatusbarText('Searching for: ' + Sender.SearchBuffer);
  if tsIncrementalSearching in Leave then
    // Duffman SetStatusbarText('');

  if not (csDestroying in ComponentState) then
    // Duffman UpdateStateDisplay(Sender.TreeStates, Enter, Leave);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.WMStartEditing(var Message: TMessage);

// This message was posted by ourselves from the node change handler above to decouple that change event and our
// intention to start editing a node. This is necessary to avoid interferences between nodes editors potentially created
// for an old edit action and the new one we start here.

var
  Node: PVirtualNode;

begin
  Node := Pointer(Message.WParam);
  // Note: the test whether a node can really be edited is done in the OnEditing event.
  VST.EditNode(Node, 1);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmZynDialog.VSTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
    Data: PNodeInfoRec;

//var  Data: PTreeData;

begin

	Data := VST.GetNodeData(Node);
    if not Assigned(Data) then    exit;

	Data.FObject.Free


    Data := Sender.GetNodeData(Node);
    Finalize(Data^);
end;

end.
