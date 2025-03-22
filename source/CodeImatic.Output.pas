unit CodeImatic.Output;

interface

Uses NovusObject, NovusLogger, NovusLogger.Provider.Console,
     NovusLogger.Provider.Files, uPSRuntime, uPSUtils;

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

end.
