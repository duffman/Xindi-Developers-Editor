unit FileUtils;

interface
uses
	Winapi.Windows, Winapi.ShellAPI, SysUtils,
    Vcl.Controls;

type
    TDiskSign = string[2];

type
    TFileUtils = class(TObject)
    private

    public
		class procedure GetSysImages(out LargeImages: TImageList; out SmallImages: TImageList);
		class function GetMediaPresent(Value: TDiskSign) :Boolean;
        class function FiletimeToDateTime(FT: FILETIME): TDateTime;

    end;



implementation

class procedure TFileUtils.GetSysImages(out LargeImages: TImageList; out SmallImages: TImageList);
var
  SysImageList: uint;
  SFI: TSHFileInfo;
begin
    Largeimages := TImageList.Create(nil);
    SysImageList := SHGetFileInfo('',0,SFI,SizeOf(TSHFileInfo),SHGFI_SYSICONINDEX or SHGFI_LARGEICON);

    if SysImageList<>0 then
    begin
        Largeimages.Handle := SysImageList;
        Largeimages.ShareImages := TRUE;
    end;

    Smallimages := TImageList.Create(nil);
    SysImageList := SHGetFileInfo('',0,SFI,SizeOf(TSHFileInfo),SHGFI_SYSICONINDEX or SHGFI_SMALLICON);

    if SysImageList<>0 then
    begin
        Smallimages.Handle:=SysImageList;
        Smallimages.ShareImages:=TRUE;
    end;
end;


class function TFileUtils.GetMediaPresent(Value: TDiskSign) :Boolean;
var
    ErrorMode: Word;
    bufRoot :pchar;
    a,b,c,d :dword;
begin
    bufRoot := stralloc(255);
    strpcopy(bufRoot,Value+'\');
    ErrorMode:=SetErrorMode(SEM_FailCriticalErrors);
    try
	    try
    		result:=GetDiskFreeSpace(bufRoot,a,b,c,d);
		except
		    result:=False;
	    end;
    finally
        strdispose(bufroot);
        SetErrorMode(ErrorMode);
    end;
end;

class function TFileUtils.FiletimeToDateTime(FT: FILETIME): TDateTime;
var
  st: SYSTEMTIME;
  dt1,dt2: TDateTime;
begin
  FileTimeToSystemTime(FT,st);
  try
    dt1:=EncodeTime(st.whour,st.wminute,st.wsecond,st.wMilliseconds);
  except
    dt1:=0;
  end;
  try
    dt2:=EncodeDate(st.wyear,st.wmonth,st.wday);
  except
    dt2:=0;
  end;
  Result:=dt1+dt2;
end;



end.
