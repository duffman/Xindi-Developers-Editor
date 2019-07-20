program VTHack_1;



uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  ZynDialog in 'ZynDialog.pas' {frmZynDialog},
  FileUtils in 'FileUtils.pas',
  UTreeData in 'UTreeData.pas',
  ZynTreeEngine in 'ZynTreeEngine.pas',
  ZynTreeTypes in 'ZynTreeTypes.pas',
  ZynTreeListing in 'ZynTreeListing.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmZynDialog, frmZynDialog);
  Application.Run;
end.
