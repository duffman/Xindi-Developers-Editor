unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, VirtualTrees,
  VirtualExplorerTree;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
    value: Variant;
    tmpStr: String;
begin
    value := 234;
    tmpStr := Format('Test1 "%s"', [value]);
    Memo1.Lines.Add(tmpStr);

    value := 'Kalle Kula';
    tmpStr := Format('Test2 "%s"', [value]);
    Memo1.Lines.Add(tmpStr);

end;

end.
