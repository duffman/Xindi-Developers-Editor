unit ZynTreeListing;

interface

type
	TZynTreeListing = class(TObject)
    	FRootDir: String;

	public
    	constructor Create(ARootDir: string = '');
        destructor Destroy; override;
    end;

implementation

{ TZynTreeListing }

constructor TZynTreeListing.Create(ARootDir: string);
begin

end;

destructor TZynTreeListing.Destroy;
begin
    // -- //
	inherited;
end;

end.

