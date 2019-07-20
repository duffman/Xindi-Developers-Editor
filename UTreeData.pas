unit UTreeData;

interface

//===========================================

type
  // declare common node class
  TBasicNodeData = class
  protected
    cName: ShortString;
    cImageIndex: Integer;
  public
    constructor Create; overload;
    constructor Create(vName: ShortString; vIIndex: Integer = 0); overload;

    property Name: ShortString read cName write cName;
    property ImageIndex: Integer read cImageIndex write cImageIndex;
  end;

  // declare new structure for node data
  rTreeData = record
    BasicND: TBasicNodeData;
  end;

implementation

constructor TBasicNodeData.Create;
begin
   { not necessary
   cName := '';
   cImageIndex := 0;
   }
end;

constructor TBasicNodeData.Create(vName: ShortString; vIIndex: Integer = 0);
begin
  cName := vName;
  cImageIndex := vIIndex;
end;

end.
