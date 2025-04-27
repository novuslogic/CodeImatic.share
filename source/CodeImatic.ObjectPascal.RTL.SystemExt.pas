unit CodeImatic.ObjectPascal.RTL.SystemExt;

interface

Uses NovusObject, CodeImatic.ObjectPascal.UnitBase, dwsExprs, System.SysUtils;

type
  tcimObjectPascalRTLSystem = class(tcimObjectPascalUnitBase)
  protected
    function GetUnitName: string; override;
  private
    procedure WritelnFunctionEval(Info: TProgramInfo);
    procedure PrintlnFunctionEval(Info: TProgramInfo);
    procedure WDFunctionEval(Info: TProgramInfo);
    procedure GetLastErrorFunctionEval(Info: TProgramInfo);
    procedure SysErrorMessageFunctionEval(Info: TProgramInfo);
  public
    procedure Init(aParent: tobject); override;
  end;

implementation

function tcimObjectPascalRTLSystem.GetUnitName: string;
begin
  Result := 'SystemExt';
end;

procedure tcimObjectPascalRTLSystem.Init(aParent: tobject);
begin
  // Writeln
  var fWritelnFunction := AddFunction('Writeln', WritelnFunctionEval);
  with fWritelnFunction.Parameters.Add do
    begin
      Name := 'Msg';
      IsWritable := True;
      DataType := 'String';
    end;

  // Println
  var fPrintlnFunction := AddFunction('Println', PrintlnFunctionEval);
  with fPrintlnFunction.Parameters.Add do
    begin
      Name := 'Msg';
      IsWritable := True;
      DataType := 'String';
    end;

  // WD
  var fWDFunction := AddFunction('WD', WDFunctionEval);
  fWDFunction.ResultType := 'String';

  // GetLastError
  var fGetLastErrorFunction := AddFunction('GetLastError', GetLastErrorFunctionEval);
  fGetLastErrorFunction.ResultType := 'Integer';

  // SysErrorMessage
  var fSysErrorMessageFunction := AddFunction('SysErrorMessage', SysErrorMessageFunctionEval);
  with fSysErrorMessageFunction.Parameters.Add do
    begin
      Name := 'ErrorCode';
      IsWritable := True;
      DataType := 'Integer';
    end;
  fSysErrorMessageFunction.ResultType := 'String';


end;

procedure tcimObjectPascalRTLSystem.WritelnFunctionEval(Info: TProgramInfo);
begin
  oOutput.oLog.AddLogInformation(Info.ValueAsString['Msg']);
end;

procedure tcimObjectPascalRTLSystem.PrintlnFunctionEval(Info: TProgramInfo);
begin
  oOutput.oLog.AddLogInformation(Info.ValueAsString['Msg']);
end;

procedure tcimObjectPascalRTLSystem.WDFunctionEval(Info: TProgramInfo);
begin
  Info.ResultAsString := oRuntime.Workingdirectory;
end;

procedure tcimObjectPascalRTLSystem.GetLastErrorFunctionEval(Info: TProgramInfo);
begin
  Info.ResultAsInteger := GetLastError;
end;

procedure tcimObjectPascalRTLSystem.SysErrorMessageFunctionEval(Info: TProgramInfo);
begin
  Info.ResultAsString := SysErrorMessage(Info.ValueAsInteger['ErrorCode']);
end;






end.
