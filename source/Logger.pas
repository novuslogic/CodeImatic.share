unit Logger;

interface

Uses NovusObject, NovusLogger, NovusLogger.Provider.Console;

type
  tLogger = class(tNovusObject)
  private
    fLog : tNovusLogger;
    fbconsoleoutputonly: Boolean;
  protected
  public
    constructor Create(aConsoleoutputonly: boolean);
    destructor Destroy;

    property Consoleoutputonly: Boolean read fbconsoleoutputonly
      write fbconsoleoutputonly default false;

    property  Log: tNovusLogger read fLog write flog;
  end;

implementation

constructor tLogger.create(aConsoleoutputonly: boolean);
begin
  if aConsoleoutputonly then
    fLog := tNovusLogger.Create([TNovusLogger_Provider_Console.Create]);

end;

destructor tLogger.Destroy;
begin
  fLog.Free;
end;

end.
