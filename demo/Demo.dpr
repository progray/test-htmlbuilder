program Demo;

uses
  Forms,
  uDemo in 'uDemo.pas' {frmDemo},
  uHTMLBuilder in '..\src\uHTMLBuilder.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmDemo, frmDemo);
  Application.Run;
end.
