unit CodeImatic.Output;

interface

Uses NovusObject, NovusLogger, NovusLogger.Provider.Console,  CodeImatic.ErrorTypes,
     NovusLogger.Provider.Files, uPSRuntime, uPSUtils,
     SysUtils;

type
  tcimOutput = class(tNovusObject)
  private
    fbconsoleoutputonly: Boolean;
    fsFilename: string;
    fbErrors: Boolean;
    fbFailed: Boolean;
    fLastExError: TPSError; // use for PascalScript
    fsLastExParam: tbtstring;
  protected
    foLog: tNovusLogger;
  public
    constructor Create(aConsoleoutputonly: boolean; aFilename: String = '');
    destructor Destroy;

    function OpenLog: Boolean;
    function CloseLog: boolean;

    property Consoleoutputonly: Boolean read fbconsoleoutputonly
      write fbconsoleoutputonly default false;

    property oLog: tNovusLogger read foLog write foLog;

    procedure AddLogFailed(const aMsg: String = '');
    procedure AddLogErrorType(const aMsg: String; aErrorType: TcimErrorTypes = tcimETNone);

    property Filename: string read fsFilename write fsFilename;

    property Errors: Boolean read fbErrors write fbErrors default false;

    property Failed: Boolean read fbFailed write fbFailed default false;

    property LastExError: TPSError read fLastExError write fLastExError;

    property LastExParam: tbtstring read fsLastExParam write fsLastExParam;
  end;

implementation

constructor tcimOutput.create(aConsoleoutputonly: boolean; aFilename: String = '');
begin
  fsFilename := aFilename;

  If (aFilename = '') or (aConsoleoutputonly = true) then
    foLog := tNovusLogger.Create([TNovusLogger_Provider_Console.Create])
  else
    foLog := tNovusLogger.Create([TNovusLogger_Provider_Console.Create,
              TNovusLogger_Provider_Files.Create(aFilename)]);

end;

destructor tcimOutput.Destroy;
begin
  foLog.Free;
end;

function tcimOutput.OpenLog: Boolean;
begin
  Result := foLog.OpenLog;
end;

function tcimOutput.CloseLog: boolean;
begin
  Result := foLog.CloseLog;
end;

procedure tcimOutput.AddLogFailed(const aMsg: String = '');
begin
  oLog.AddLogException(aMsg);
  fbFailed := True;
end;



procedure tcimOutput.AddLogErrorType(const aMsg: String; aErrorType: TcimErrorTypes = tcimETNone);
Var
  lsMsg: String;
begin
  case aErrorType of
    TcimErrorTypes.tcimETOverflow_error:
      lsMsg := SysUtils.format('[Overflow error] (%s)', [aMsg]);
    TcimErrorTypes.tcimETUnderflow_error:
      lsMsg := SysUtils.format('[Underflow error] (%s)' , [aMsg]);
    TcimErrorTypes.tcimETSyntax_Error:
      lsMsg := SysUtils.format('[Syntax error] (%s)', [aMsg]);
    TcimErrorTypes.tcimETOutOfRangeBranch:
      lsMsg := SysUtils.format('[Out of Range Brach] (%s) ', [aMsg]);
    TcimErrorTypes.tcimETLabelError:
      lsMsg := SysUtils.format('[Label Error] (%s)', [aMsg]);
    TcimErrorTypes.tcimETtagUnknown:
      lsMsg := SysUtils.format('[Tag Unknown] (%s)', [aMsg]);
    TcimErrorTypes.tcimETEqual_Error:
      lsMsg := SysUtils.format('[Equal Error] (%s)', [aMsg]);
    else
      lsMsg := SysUtils.format('[Error] (%s)', [aMsg]);
  end;

  oLog.AddLogError(lsMsg);

  fbErrors := True;
end;

end.
