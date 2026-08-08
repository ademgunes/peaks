program peaks;

uses
  Forms, Interfaces,
  uMain in 'uMain.pas' {frmMain};

{$R *.res}

begin
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
