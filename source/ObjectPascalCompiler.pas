unit ObjectPascalCompiler;

interface

uses
  System.SysUtils,  System.Classes, dwsCompiler,  NovusFileUtils,  dwsXPlatform,
  dwsComp, dwsExprs, dwsSymbols, dwsUtils, Logger, dwsUnitSymbols, System.IOUtils,
  dwsRTTIConnector, dwsRTTIFunctions, NovusObject, dwsDebugger, dwsInfo,
  dwsScriptSource;

type
  tObjectPascalCompiler = class(TNovusobject)
  private
  protected
    fLogger: tLogger;
    fCompiler: TDelphiWebScript;
    fProgram: IdwsProgram;
    fExecute: IdwsProgramExecution;
    fsWorkingdirectory: String;
    fsSearchPath: string;
    fDebugger: TdwsDebugger;

    procedure DoDebugEval(exec: TdwsExecution; expr: TExprBase);
    procedure DoDebugSuspended(sender : TObject);
    procedure DoDebugExceptionNotification(const exceptObj : IInfo);
    procedure DoDebugMessage(const msg : String);

    procedure dwsUnitFunctionsWritelnEval(Info: TProgramInfo);

    function GetUnitFilename(aUnitName: String): string;
    procedure AddCustomUnits;
    function DoNeedUnitEx(const unitName : String; var unitSource, unitLocation : String) : IdwsUnit;
    procedure DoIncludeEx(const scriptName: String; var scriptSource, scriptLocation : String);
  public
    constructor Create(aLogger: tLogger);
    destructor Destroy;

    function LoadStringFromFile(const FileName: string): string;

    function Compile(aScript: String; aWorkingdirectory, aSearchPath: string; aDebugger: Boolean): boolean;
  end;

implementation

function tObjectPascalCompiler.LoadStringFromFile(const FileName: string): string;
var
  Strings: TStringList;
begin
  Strings := TStringList.Create;
  try
    Strings.LoadFromFile(FileName);
    Result := Strings.Text;
  finally
    Strings.Free;
  end;
end;

constructor tObjectPascalCompiler.create(aLogger: tLogger);
begin
  fLogger:= aLogger;

  fCompiler := TDelphiWebScript.Create(nil);

  fDebugger := TdwsDebugger.Create(nil);

  fDebugger.OnDebug:=DoDebugEval;
  fDebugger.OnDebugMessage:=DoDebugMessage;
  fDebugger.OnNotifyException:=DoDebugExceptionNotification;
  fDebugger.OnDebugSuspended:=DoDebugSuspended;
end;

destructor tObjectPascalCompiler.destroy;
begin
  fDebugger.Free;
  fCompiler.Free;
end;

procedure tObjectPascalCompiler.AddCustomUnits;
Var
  FCustomUnit: tdwsUnit;
  FCustomFunction: TdwsFunction;
  FCustomParameter: TdwsParameter;
begin

  FCustomUnit := tdwsUnit.Create(NIl);

  FCustomUnit.UnitName := 'insternal';
  FCustomUnit.Script := fCompiler;

  FCustomFunction := FCustomUnit.Functions.Add;

  FCustomFunction.OnEval := dwsUnitFunctionsWritelnEval;

  FCustomFunction.Name := 'Writeln';
  FCustomParameter := FCustomFunction.Parameters.Add;
  FCustomParameter.Name := 'Msg';
  FCustomParameter.IsWritable := True;
  FCustomParameter.DataType := 'String';


end;


function tObjectPascalCompiler.Compile(aScript: String; aWorkingdirectory, aSearchPath: string; aDebugger: boolean): boolean;
begin
  Result := false;
  fsSearchPath := aSearchPath;
  fsWorkingdirectory := aWorkingdirectory;

  fCompiler.Config.OnNeedUnitEx := DoNeedUnitEx;
  fCompiler.Config.OnIncludeEx := DoIncludeEx;

  fCompiler.Config.ScriptPaths.Add(aWorkingdirectory);
  fCompiler.Config.ScriptPaths.Add(aSearchPath);

  AddCustomUnits;

  fProgram := fCompiler.Compile(aScript);

  if fProgram.Msgs.HasErrors then
    begin
      fLogger.Log.AddLogError(fProgram.Msgs.AsInfo);

      Exit;
    end;

  If Not aDebugger then
    fExecute := fProgram.Execute
  else
  begin
    fDebugger.Breakpoints.Add(11, FProgram.SourceList[0].SourceFile.Name);


    fExecute := FProgram.CreateNewExecution;



    FDebugger.BeginDebug(fExecute);



    FDebugger.EndDebug;

  end;



  if fExecute.Msgs.HasErrors then
    begin
      fLogger.Log.AddLogError(fExecute.Msgs.AsInfo);

      Exit;
    end
  else
     begin
       If Trim(fExecute.Result.ToString) <> '' then
         fLogger.Log.AddLogInformation(fExecute.Result.ToString);

       Result := True;
     end;
end;

function tObjectPascalCompiler.DoNeedUnitEx(const unitName : String; var unitSource, unitLocation : String) : IdwsUnit;
begin
  Result := NIL;
  DoIncludeEx(unitName, unitSource, unitLocation);
end;

procedure tObjectPascalCompiler.DoIncludeEx(const scriptName: String; var scriptSource, scriptLocation : String);
begin
  var fsFilename := GetUnitFilename(scriptName);

  if TFile.Exists(fsFilename) then
    begin
      scriptSource := LoadTextFromFile(fsFilename);





    end;
end;


procedure tObjectPascalCompiler.dwsUnitFunctionsWritelnEval(Info: TProgramInfo);
begin
  fLogger.Log.AddLogInformation(Info.ValueAsString['Msg']);
end;

function tObjectPascalCompiler.GetUnitFilename(aUnitName: String): string;
var
  lsUnitNameFilename: String;
begin
  lsUnitNameFilename := aUnitName;
  if lowercase(TNovusFileUtils.ExtractFileExtenion(aUnitName)) <> 'pas'  then
    lsUnitNameFilename := aUnitName + '.pas';

  var FullWorkingDirectory := trim(TNovusFileUtils.TrailingBackSlash(fsWorkingdirectory) +lsUnitNameFilename);
  var FullSearchPath := Trim(TNovusFileUtils.TrailingBackSlash(fsSearchPath)+ lsUnitNameFilename);

  if TFile.Exists(FullWorkingDirectory) then
    Result := FullWorkingDirectory
  else
  if TFile.Exists(FullSearchPath) then
    Result := FullSearchPath
  else
    result := lsUnitNameFilename;
end;

// DoDebugEval
procedure tObjectPascalCompiler.DoDebugEval(exec: TdwsExecution; expr: TExprBase);
var
  p: TScriptPos;
begin
  p:=expr.ScriptPos;

   (*
   p:=expr.ScriptPos;
   if p.Line=FDebugEvalAtLine then begin
      FDebugLastEvalResult := FDebugger.EvaluateAsString(FDebugEvalExpr, @p);
      FDebugLastEvalScriptPos := FDebugger.CurrentScriptPos;
   end;
   if FStepTest <> '' then begin
      FStepTest := FStepTest + expr.ScriptPos.AsInfo + ', ';
      TdwsDSCStepDetail.Create(FDebugger);
   end;
   *)
end;

// DoDebugMessage
procedure tObjectPascalCompiler.DoDebugMessage(const msg : String);
begin
  //FDebugLastMessage:=msg;
end;

// DoDebugExceptionNotification
procedure tObjectPascalCompiler.DoDebugExceptionNotification(const exceptObj : IInfo);
var
expr : TExprBase;
begin
  (*
   if exceptObj<>nil then
      expr:=exceptObj.Exec.GetLastScriptErrorExpr
   else expr:=nil;
   if expr<>nil then
      FDebugLastNotificationPos:=expr.ScriptPos
   else FDebugLastNotificationPos:=cNullPos;
   *)
end;

// DoDebugSuspended
procedure tObjectPascalCompiler.DoDebugSuspended(sender : TObject);
begin
  FDebugger.Watches.Update;
  FDebugger.Resume;
  (*
   Inc(FDebugResumed);
   FDebugger.Watches.Update;
   FDebugLastSuspendScriptPos := FDebugger.CurrentScriptPos;
   if FDebugSuspendEvalExpr <> '' then
      FDebugSuspendLastEvalResult := FDebugger.EvaluateAsString(FDebugSuspendEvalExpr);
   FDebugger.Resume;
  *)
end;



end.
