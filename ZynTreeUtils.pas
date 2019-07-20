unit ZynTreeUtils;

interface
uses
	ZynTreeTypes;

function NodeTypeToStr(AValue: TZynNodeType): String;

implementation


function NodeTypeToStr(AValue: TZynNodeType): String;
begin
    case AValue of
        ntUnset   : Result := 'ntUnset';
        ntRoot    : Result := 'ntRoot';
        ntFile    : Result := 'ntFile';
        ntDir     : Result := 'ntDir';
        ntDirUp   : Result := 'ntDirUp';
    end;
end;

end.
