unit OutputBase;

interface

Uses NovusLog, SysUtils, NovusUtilities;

type
  TErrorTypes = (tETNone, tETOverflow_Error, tETUnderflow_Error, tETSyntax_Error, tETOutOfRangeBranch, tETLabelError, tETCommandUnknown, tETFatalError);

  tErrorTypesResults = record
    Result: Boolean;
    ErrorTypes: TErrorTypes;
  end;

  ToutputBase = class(TNovusLogFile)
  private
  protected
    fbErrors: Boolean;
    fbFailed: Boolean;
    fbconsoleoutputonly: Boolean;

    procedure InternalLogError(const aMsg: String);
  public
    procedure InitLog(AFilename: String; aOutputConsole: Boolean;
      aConsoleoutputonly: Boolean);

    procedure Log(const aMsg: string);
    procedure LogFormat(const aFormat: string; const Args: array of const);

    procedure LogError(const aMsg: String); overload;
    procedure LogError(const aMsg: String; aLineNo: Integer; aErrorType: TErrorTypes = tETNone); overload;
    procedure LogError(aLineNo: Integer; aErrorType: TErrorTypes = tETNone); overload;

    procedure InternalError;
    procedure LogException(AException: Exception);

    property Errors: Boolean read fbErrors write fbErrors;

    property Failed: Boolean read fbFailed write fbFailed;

    property Consoleoutputonly: Boolean read fbconsoleoutputonly
      write fbconsoleoutputonly default true;
  end;

implementation

procedure ToutputBase.InitLog(AFilename: String; aOutputConsole: Boolean;
  aConsoleoutputonly: Boolean);
begin
  OutputConsole := aOutputConsole;

  fbconsoleoutputonly := aConsoleoutputonly;

  Filename := AFilename;

  fbErrors := False;
end;

procedure ToutputBase.Log(const aMsg: string);
begin
  if fbconsoleoutputonly then
    Writeln(aMsg)
  else
    WriteLog(aMsg);
end;

procedure ToutputBase.InternalLogError(const aMsg: String);
begin
  Log(aMsg);

  Failed := true;
end;

procedure ToutputBase.LogError(const aMsg: String);
begin
  InternalLogError(aMsg);
end;

procedure ToutputBase.LogError(const aMsg: String; aLineNo: Integer; aErrorType: TErrorTypes = tETNone);
Var
  lsMsg: String;
begin
  case aErrorType of
    TErrorTypes.tETOverflow_error:
      lsMsg := SysUtils.format('[Overflow error] (%d): ' + Trim(aMsg), [aLineNo]);
    TErrorTypes.tETUnderflow_error:
      lsMsg := SysUtils.format('[Underflow error] (%d): ' + Trim(aMsg), [aLineNo]);
    TErrorTypes.tETSyntax_Error:
      lsMsg := SysUtils.format('[Syntax error] (%d): ' + Trim(aMsg), [aLineNo]);
    TErrorTypes.tETOutOfRangeBranch:
      lsMsg := SysUtils.format('[Out of Range Brach] (%d): ' + Trim(aMsg), [aLineNo]);
    TErrorTypes.tETLabelError:
      lsMsg := SysUtils.format('[Label Error] (%d): ' + Trim(aMsg), [aLineNo]);
    TErrorTypes.tETCommandUnknown:
      lsMsg := SysUtils.format('[Command Unknown] (%d): ' + Trim(aMsg), [aLineNo]);
    else
      lsMsg := SysUtils.format('[Error] (%d): ' + Trim(aMsg), [aLineNo]);
  end;

  InternalLogError(lsMsg);
end;

procedure ToutputBase.LogError(aLineNo: Integer; aErrorType: TErrorTypes = tETNone);
Var
  lsMsg: String;
begin
  case aErrorType of
    TErrorTypes.tETOverflow_error:
      lsMsg := SysUtils.format('[Overflow error] (%d)', [aLineNo]);
    TErrorTypes.tETUnderflow_error:
      lsMsg := SysUtils.format('[Underflow error] (%d)' , [aLineNo]);
    TErrorTypes.tETSyntax_Error:
      lsMsg := SysUtils.format('[Syntax error] (%d)', [aLineNo]);
    TErrorTypes.tETOutOfRangeBranch:
      lsMsg := SysUtils.format('[Out of Range Brach] (%d) ', [aLineNo]);
    TErrorTypes.tETLabelError:
      lsMsg := SysUtils.format('[Label Error] (%d)', [aLineNo]);
    TErrorTypes.tETCommandUnknown:
      lsMsg := SysUtils.format('[Command Unknown]', [aLineNo]);
    else
      lsMsg := SysUtils.format('[Error] (%d)', [aLineNo]);
  end;

  InternalLogError(lsMsg);
end;

procedure ToutputBase.LogFormat(const aFormat: string; const Args: array of const);
begin
  Log(SysUtils.format(aFormat, Args));
end;

procedure ToutputBase.InternalError;
begin
  if fbconsoleoutputonly then
     Writeln(TNovusUtilities.GetExceptMess)
  else
    WriteExceptLog;

  Failed := true;
end;

procedure ToutputBase.LogException(AException: Exception);
var
  lsMessage: String;
begin
  if Not Assigned(AException) then
    Exit;

  lsMessage := '[Exception Error] : ' + AException.Message;

  Log(lsMessage);

  Failed := true;
end;

end.
