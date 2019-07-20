unit ZynTreeEngine;

interface
uses
	Winapi.ShellAPI, Winapi.Windows, Winapi.Messages, System.SysUtils,
    System.Variants, System.Classes, Vcl.Graphics, Vcl.ComCtrls,
    ExtCtrls,  FileCtrl, ImgList, Vcl.StdCtrls, Generics.Collections,
    UTreeData, VirtualFileSearch,


    FileUtils, VTreeConst,

    ZynTreeTypes, ZynTreeUtils
    ;


const
    ThousandSeparator = '.';

type
	TDataList = TList<TZynTreeNode>;

    TDataListChange = procedure(AList: TList<TZynTreeNode>) of Object;

	TZynTreeEngine = class(TObject)
    private
    	FCurrPath: String;
        FDirectory: String;
        FNodeDataList: TList<TZynTreeNode>;

        FTmpDataList: TDataList;

        function NewNode(ANodeType: TZynNodeType = ntUnset): TZynTreeNode;

        function ClearDataList(): TDataList;
        function GetDataList(): TList<TZynTreeNode>;

    public
    	constructor Create();
        destructor Destroy(); override;

		function Browse(FileMask: String; Attr: DWord): Boolean;
        function SetDirectory(ADir: String): Boolean;
        function GetNodeText(AData: PNodeInfoRec): String;

        //function GetDataList(AFilter: String = ''): TList<TZynTreeNode>;

        function GetDataDump(cliEcho: Boolean = false): TStringList;
        procedure DumpDataList();


    	{****************************
        * Properties
        ****************************}
        property CurrPath: String read FCurrPath write FCurrPath;
        property Directory: String read FDirectory;

        property DataList: TDataList read GetDataList;
    end;

implementation


function TZynTreeEngine.ClearDataList(): TDataList;
var
	treeNode: TZynTreeNode;
begin
	while FNodeDataList.Count > 0 do
    begin
		treeNode := FNodeDataList[0];
        FreeAndNil(treeNode);
        FNodeDataList.Delete(0);
    end;

    Result := FNodeDataList;
end;

constructor TZynTreeEngine.Create();
begin
	FNodeDataList := TDataList.Create; //TList<TZynTreeNode>.Create();
    FTmpDataList := TDataList.Create;
end;

destructor TZynTreeEngine.Destroy;
begin
	// -- //

    FreeAndNil(FTmpDataList);

    inherited Destroy;
end;


function TZynTreeEngine.GetDataDump(cliEcho: Boolean = false): TStringList;
var
	i: Integer;
    dataStr: String;
    tmpDataNode: TZynTreeNode;
begin
	Result := TStringList.Create;
    for i := 0 to FNodeDataList.Count-1 do
    begin
    	tmpDataNode:= FNodeDataList[i];
        dataStr := 'Type: ' + NodeTypeToStr(tmpDataNode.NodeType)
	        	+ ' | FFullFileName :: ' + tmpDataNode.FFullFileName;

        if cliEcho then WriteLn(dataStr);

        Result.Add(dataStr);
    end;

end;

procedure TZynTreeEngine.DumpDataList();
var
	i: Integer;
	strList: TStringList;
begin
	strList := GetDataDump(false);

    for i := 0 to strList.Count-1 do
    begin
		WriteLn(strList[i]);
    end;

    FreeAndNil(strList);
end;

//
// Get Data List
// Returns a "copy" copy of the data list in case
// there are filtering etc so we can skip entries...
//
function TZynTreeEngine.GetDataList(): TList<TZynTreeNode>;
var
	i: Integer;
    tmpDataNode: TZynTreeNode;
begin
    for i := 0 to FNodeDataList.Count-1 do
    begin
    	tmpDataNode:= FNodeDataList[i];
		FTmpDataList.Add(tmpDataNode);
    end;

    Result := FTmpDataList;
end;

function TZynTreeEngine.GetNodeText(AData: PNodeInfoRec): String;
var
	pathRec: PNodePathRec;
    fileRec: PNodeFileRec;
begin
	case AData.NodeType of
    	ntRoot: begin
        	Result := '';
        end;

        ntDirUp: begin
        	Result := '..';
        end;

        ntDir: begin
			pathRec := AData.NodeData;
            if (pathRec <> nil) then
            	Result := pathRec.Name;
        end;

        ntFile: begin
			fileRec := AData.NodeData;
            if (fileRec <> nil) then
            	Result := fileRec.Name;
        end;
    end;
//	if AD then

end;

//
// New Node, create a new node instance and add it to the node list
//
function TZynTreeEngine.NewNode(ANodeType: TZynNodeType = ntUnset): TZynTreeNode;
begin
	Result := TZynTreeNode.Create(ANodeType);
	FNodeDataList.Add(Result)
end;

function TZynTreeEngine.SetDirectory(ADir: string): Boolean;
begin
	FDirectory := IncludeTrailingPathDelimiter(ADir);
	Result := true;
end;


function TZynTreeEngine.Browse(FileMask: string; Attr: DWord): Boolean;
var
    ShInfo: TSHFileInfo;
    attributes: String;
    nodeDate: TDateTime;
    fileName, fullFileName: String;
    nodeSize: Integer;
    FI: TSearchRec;

    treeNode: TZynTreeNode;

    infoRec: PNodeInfoRec;
	pathRec: PNodePathRec;
    fileRec: PNodeFileRec;

    function AttrStr(Attr: Integer): string;
    begin
        Result:='';
        if (FILE_ATTRIBUTE_DIRECTORY and Attr) > 0 then
	        Result:=Result+'';
        if (FILE_ATTRIBUTE_ARCHIVE and Attr) > 0 then
    	    Result:=Result+'A';
        if (FILE_ATTRIBUTE_READONLY and Attr) > 0 then
        	Result:=Result+'R';
        if (FILE_ATTRIBUTE_HIDDEN and Attr) > 0 then
        	Result:=Result+'H';
        if (FILE_ATTRIBUTE_SYSTEM and Attr) > 0 then
        	Result:=Result+'S';
    end;

begin
	Result := true;

    if not SetCurrentDir(FDirectory) then
        Exit(false);

    ClearDataList();

    try
    	if FindFirst(FileMask, faAnyFile, FI)=0 then
    	try
            repeat
                {if ((Attr and FILE_ATTRIBUTE_DIRECTORY)=(FI.Attr and FILE_ATTRIBUTE_DIRECTORY)) and
                    ((Attr and FILE_ATTRIBUTE_READONLY)>=(FI.Attr and FILE_ATTRIBUTE_READONLY)) and
                    ((Attr and FILE_ATTRIBUTE_HIDDEN)>=(FI.Attr and FILE_ATTRIBUTE_HIDDEN)) and
                    ((Attr and FILE_ATTRIBUTE_SYSTEM)>=(FI.Attr and FILE_ATTRIBUTE_SYSTEM)) then }

                if (True) then
                begin
					if FI.Name = '.' then
                		Continue;

                    CurrPath := IncludeTrailingBackslash(FDirectory);

                    treeNode := TZynTreeNode.Create(ntUnset, FDirectory, FI.Name);
                    FNodeDataList.Add(treeNode);

	                if FI.Name = '..' then
                    begin
                     	treeNode.SetType(ntDirUp);
                    	Continue;
                    end;

                    fileName := treeNode.FileName;
                    fullFileName := treeNode.FullFileName;


                    Writeln('FileName :: ' + fileName);

                    // Duffman: We want to include parent dir
                    //if (FName='.') then
                    //    Continue;

                    nodeSize := FI.Size;
                    nodeDate := TFileUtils.FileTimeToDateTime(FI.FindData.ftLastWriteTime);

                    Attributes := AttrStr(FI.Attr);


                    if (FI.Attr and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
                    begin
                        Writeln('DIR');
                        treeNode.SetType(ntDir);
                    end
                    else  // if (FI.Attr and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_NORMAL then
                    begin
                        Writeln('FILE');
                    	treeNode.SetType(ntFile);
                    end;

                end;

        	until FindNext(FI) <> 0;

        finally
        	FindClose(FI);
        end;

    except
		Result := false;
    end;

end;



end.
