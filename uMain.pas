unit uMain;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Spin, TAGraph, TASeries;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Chart1: TChart;
    memoArrayMinMax: TMemo;
    Series2: TLineSeries;
    Series1: TLineSeries;
    Label3: TLabel;
    seRange: TSpinEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    memoArrayFull: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    seDelta: TSpinEdit;
    chkShowLabels: TCheckBox;
    chkLookForMax: TCheckBox;
    cmdGo: TButton;
    radioRandSeed: TRadioGroup;
    chkReverseScan: TCheckBox;
    Label2: TLabel;
    seNPoints: TSpinEdit;
    txtSeed: TComboBox;
    procedure chkLookForMaxChange(Sender: TObject);
    procedure chkReverseScanChange(Sender: TObject);
    procedure cmdGoClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure seDeltaChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkLookForMaxClick(Sender: TObject);
    procedure chkReverseScanClick(Sender: TObject);
    procedure radioRandSeedClick(Sender: TObject);
    procedure seNPointsChange(Sender: TObject);
    procedure txtSeedChange(Sender: TObject);
    procedure txtSeedKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses Math;

{$R *.lfm}

procedure FactoryReset(var aForm: TCustomForm);
var
  FClass: TCustomFormClass;
begin
  if not Assigned(aForm) then Exit;

  FClass := TCustomFormClass(aForm.ClassType);
  aForm.Release;
  aForm := nil; // Dangling pointer (boşa düşen işaretçi) olmaması için
  aForm := FClass.Create(Application);
  aForm.Show;
end;

procedure TfrmMain.cmdGoClick(Sender: TObject);
var
  x, y: array of double;
  nPoints, i, imax, imin: integer;
  tempMin, tempMax: double;
  tempMinPos, tempMaxPos: integer;
  maxTableVal, minTableVal: array of double;
  maxTablePos, minTablePos: array of integer;
  lookforMax: Boolean;
  thisValue, delta: double;
begin
  DecimalSeparator := '.';

  if radioRandSeed.ItemIndex = 1 then
  begin
    Randomize;
    RandSeed := abs(RandSeed);
    txtSeed.Text := IntToStr(RandSeed);
    if txtSeed.Items.IndexOf(txtSeed.Text) < 0 then
      txtSeed.Items.Add(txtSeed.Text);
  end
  else
  begin
    RandSeed := StrToInt64Def(trim(txtSeed.Text), StrToInt64(FormatDateTime('yyyymmdd', now)));
    txtSeed.Text := IntToStr(RandSeed);
  end;

  if trim(seNPoints.Text) = '' then exit;
  nPoints := StrToIntDef(seNPoints.Text, 50);

  if trim(seDelta.Text) = '' then exit;
  delta := StrToIntDef(seDelta.Text, 20);

  Series1.Clear;
  Series2.Clear;

  memoArrayFull.Clear;
  memoArrayMinMax.Clear;

  SetLength(y, nPoints+1);
  SetLength(x, nPoints+1);

  SetLength(maxTableVal, nPoints+1);
  SetLength(maxTablePos, nPoints+1);

  SetLength(minTableVal, nPoints+1);
  SetLength(minTablePos, nPoints+1);


  //Chart1.LeftAxis.Range.UseMin := True;
  //Chart1.LeftAxis.Range.UseMax := True;
  //
  //Chart1.LeftAxis.Range.Min := -1;
  //Chart1.LeftAxis.Range.Max := 250;

  for i:=0 to nPoints-1 do
  begin
    y[i] := Random(seRange.Value);
    Series1.AddXY(i, y[i], '', clGreen);
    memoArrayFull.Lines.Add(Format('y[%3.d]: %.0f', [ i, y[i] ]));
  end;

  tempMin := +Infinity; tempMinPos := -1;
  tempMax := -Infinity; tempMaxPos := -1;

  lookforMax := chkLookForMax.Checked;
  
  imax := 0;
  imin := 0;   // indexes

  if not chkReverseScan.Checked then
  for i:=0 to nPoints-1 do
  begin
    thisValue := y[i];

    Series2.AddXY(i, thisValue, '', clGray);  // ** x ekseni gorunsun diye
    
    if thisValue > tempMax then
    begin
      tempMax := thisValue;
      tempMaxPos := i;
    end;

    if thisValue < tempMin then
    begin
      tempMin := thisValue;
      tempMinPos := i;
    end;

    if lookforMax then
    begin
      if thisValue < tempMax - delta then
      //if abs(thisValue - tempMax) > delta then
      begin
        inc(imax);
        maxTableVal[imax] := tempMax;
        maxTablePos[imax] := tempMaxPos;

        tempMin := thisValue;
        tempMinPos := i;
        lookforMax := False;

        Series2.AddXY(maxTablePos[imax], maxTableVal[imax], Format('%d, %.f', [ maxTablePos[imax], maxTableVal[imax] ]), clRed);
        memoArrayMinMax.Lines.Add(Format('y[%3.d]: %.f max', [ maxTablePos[imax], maxTableVal[imax] ]));
      end;
    end
    else
    begin
      if thisValue > tempMin + delta then
      //if abs(thisValue - tempMin) > delta then
      begin
        inc(imin);
        minTableVal[imin] := tempMin;
        minTablePos[imin] := tempMinPos;

        tempMax := thisValue;
        tempMaxPos := i;
        lookforMax := True;

        Series2.AddXY(minTablePos[imin], minTableVal[imin], Format('%d, %.f', [ minTablePos[imin], minTableVal[imin] ]), clBlue);
        memoArrayMinMax.Lines.Add(Format('y[%3.d]: %.f min', [ minTablePos[imin], minTableVal[imin] ]));
      end;
    end;
  end; // loop

  if chkReverseScan.Checked then
  for i:=nPoints-1 downto 0 do
  begin
    thisValue := y[i];

    Series2.AddXY(i, thisValue, '', clGray);  // ** x ekseni gorunsun diye
    
    if thisValue > tempMax then
    begin
      tempMax := thisValue;
      tempMaxPos := i;
    end;

    if thisValue < tempMin then
    begin
      tempMin := thisValue;
      tempMinPos := i;
    end;

    if lookforMax then
    begin
      if thisValue < tempMax - delta then
      //if abs(thisValue - tempMax) > delta then
      begin
        inc(imax);
        maxTableVal[imax] := tempMax;
        maxTablePos[imax] := tempMaxPos;

        tempMin := thisValue;
        tempMinPos := i;
        lookforMax := False;

        Series2.AddXY(maxTablePos[imax], maxTableVal[imax], Format('%d, %.f', [ maxTablePos[imax], maxTableVal[imax] ]), clRed);
        memoArrayMinMax.Lines.Add(Format('y[%3.d]: %.f max', [ maxTablePos[imax], maxTableVal[imax] ]));
      end;
    end
    else
    begin
      if thisValue > tempMin + delta then
      //if abs(thisValue - tempMin) > delta then      
      begin
        inc(imin);
        minTableVal[imin] := tempMin;
        minTablePos[imin] := tempMinPos;

        tempMax := thisValue;
        tempMaxPos := i;
        lookforMax := True;

        Series2.AddXY(minTablePos[imin], minTableVal[imin], Format('%d, %.f', [ minTablePos[imin], minTableVal[imin] ]), clBlue);
        memoArrayMinMax.Lines.Add(Format('y[%3.d]: %.f min', [ minTablePos[imin], minTableVal[imin] ]));
      end;
    end;
  end; // loop
end;

procedure TfrmMain.chkLookForMaxChange(Sender: TObject);
begin
  cmdGoClick(Sender);
end;

procedure TfrmMain.chkReverseScanChange(Sender: TObject);
begin
  cmdGoClick(Sender);
end;

procedure TfrmMain.FormDblClick(Sender: TObject);
begin
  FactoryReset(TCustomForm(frmMain));
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key = VK_ESCAPE then Halt;
end;

procedure TfrmMain.seDeltaChange(Sender: TObject);
begin
  if trim(seDelta.Text) = '' then exit;

  cmdGoClick(Sender);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;

  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  DecimalSeparator := '.';
  
  txtSeed.Text := FormatDateTime('yyyymmdd', now);

  if txtSeed.Items.IndexOf(txtSeed.Text) < 0 then
    txtSeed.Items.Add(txtSeed.Text);

  Randomize;

  seNPoints.Value := 25;
  seDelta.Value := 25;

  PageControl1.ActivePageIndex := 0;

  //
end;

procedure TfrmMain.chkLookForMaxClick(Sender: TObject);
begin
  cmdGoClick(Sender);
end;

procedure TfrmMain.chkReverseScanClick(Sender: TObject);
begin
  cmdGoClick(Sender);
end;

procedure TfrmMain.radioRandSeedClick(Sender: TObject);
begin
  cmdGoClick(Sender);
end;

procedure TfrmMain.seNPointsChange(Sender: TObject);
begin
  if trim(seNPoints.Text) = '' then exit;

  cmdGoClick(Sender);
end;

procedure TfrmMain.txtSeedChange(Sender: TObject);
begin
  radioRandSeed.ItemIndex := 0;
  cmdGoClick(Sender);
end;

procedure TfrmMain.txtSeedKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    radioRandSeed.ItemIndex := 0;
    if txtSeed.Items.IndexOf(txtSeed.Text) < 0 then
      txtSeed.Items.Add(txtSeed.Text);
    cmdGoClick(Sender);
  end;

  if Key = Char(VK_ESCAPE) then
  begin
    radioRandSeed.ItemIndex := 0;
    txtSeed.Text := FormatDateTime('yyyymmddhh', now);
    cmdGoClick(Sender);
  end;
end;

end.
