unit CodeImatic.ObjectPascal;

interface

uses
  System.SysUtils,  System.Classes, dwsCompiler,  NovusFileUtils,  dwsXPlatform,
  dwsComp, dwsExprs, dwsSymbols, dwsUtils, CodeImatic.Output, dwsUnitSymbols, System.IOUtils,
  NovusObject, dwsDebugger, dwsDebugFunctions, dwsInfo,
  dwsRTTIConnector, dwsRTTIFunctions, dwsScriptSource ,  CodeImatic.RuntimeBase,
  dwsStringFunctions, dwsFunctions, CodeImatic.ObjectPascal.UnitBase,
  dwsResultFunctions, dwsMathFunctions, dwsMathComplexFunctions, dwsFileFunctions,
  CodeImatic.ObjectPascal.RTL.SystemExt;

type
  tcimObjectPascal = class(TNovusobject)
  private
  protected
    fRuntime: tcimRuntimeBase;
    fOutput: tcimOutput;
    fCompiler: TDelphiWebScript;
    fProgram: IdwsProgram;
    fExecute: IdwsProgramExecution;
    fsWorkingdirectory: String;
    fsSearchPath: string;
    fDebugger: TdwsDebugger;
    fUnitList: tcimCustomUnitList;

    procedure DoDebugEval(exec: TdwsExecution; expr: TExprBase);
    procedure DoDebugSuspended(sender : TObject);
    procedure DoDebugExceptionNotification(const exceptObj : IInfo);
    procedure DoDebugMessage(const msg : String);

    function GetUnitFilename(aUnitName: String): string;
    procedure AddUnits;
    function DoNeedUnitEx(const unitName : String; var unitSource, unitLocation : String) : IdwsUnit;
    procedure DoIncludeEx(const scriptName: String; var scriptSource, scriptLocation : String);
  public
    constructor Create(aRuntime: tcimRuntimeBase);
    destructor Destroy;

    function LoadStringFromFile(const FileName: string): string;

    procedure AddUnit(aUnit: tcimObjectPascalUnitBase);

    function Compile(aScript: String; aWorkingdirectory, aSearchPath: string; aCompileOnly: Boolean;aDebugger: boolean): boolean;

    property oCompiler: TDelphiWebScript
      read fCompiler;
  end;

implementation

function tcimObjectPascal.LoadStringFromFile(const FileName: string): string;
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

constructor tcimObjectPascal.create(aRuntime: tcimRuntimeBase);
begin
  fRuntime := aRuntime;

  fOutput:= fRuntime.oOutput;

  fCompiler := TDelphiWebScript.Create(nil);

  fDebugger := TdwsDebugger.Create(nil);

  fDebugger.OnDebug:=DoDebugEval;
  fDebugger.OnDebugMessage:=DoDebugMessage;
  fDebugger.OnNotifyException:=DoDebugExceptionNotification;
  fDebugger.OnDebugSuspended:=DoDebugSuspended;

  fUnitList:= tcimCustomUnitList.Create(tcimObjectPascalUnitBase);

  AddUnits;
end;

destructor tcimObjectPascal.destroy;
begin
  fUnitList.Free;

  fDebugger.Free;
  fCompiler.Free;
end;

procedure tcimObjectPascal.AddUnit(aUnit: tcimObjectPascalUnitBase);
begin
  fUnitList.AddUnit(aUnit);
end;

procedure tcimObjectPascal.AddUnits;
Var
  FCustomUnit: tdwsUnit;
  FCustomFunction: TdwsFunction;
  FCustomParameter: TdwsParameter;
begin
  AddUnit(tcimObjectPascalRTLSystem.Create(fCompiler, fRuntime));

end;


function tcimObjectPascal.Compile(aScript: String; aWorkingdirectory, aSearchPath: string; aCompileOnly: Boolean;aDebugger: boolean): boolean;
begin
  Result := false;
  fsSearchPath := aSearchPath;
  fsWorkingdirectory := aWorkingdirectory;

  fCompiler.Config.OnNeedUnitEx := DoNeedUnitEx;
  fCompiler.Config.OnIncludeEx := DoIncludeEx;

  fCompiler.Config.ScriptPaths.Add(aWorkingdirectory);
  fCompiler.Config.ScriptPaths.Add(aSearchPath);

  fProgram := fCompiler.Compile(aScript);

  if fProgram.Msgs.HasErrors then
    begin
      fOutput.oLog.AddLogError(Trim(fProgram.Msgs.AsInfo));

      Exit;
    end;

  If aCompileOnly then
    begin
      Result := true;

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
      fOutput.oLog.AddLogError(fExecute.Msgs.AsInfo);

      Exit;
    end
  else
     begin
       If Trim(fExecute.Result.ToString) <> '' then
         fOutput.oLog.AddLogInformation(fExecute.Result.ToString);

       Result := True;
     end;
end;

function tcimObjectPascal.DoNeedUnitEx(const unitName : String; var unitSource, unitLocation : String) : IdwsUnit;
begin
  Result := NIL;
  DoIncludeEx(unitName, unitSource, unitLocation);
end;

procedure tcimObjectPascal.DoIncludeEx(const scriptName: String; var scriptSource, scriptLocation : String);
begin
  var fsFilename := GetUnitFilename(scriptName);

  if TFile.Exists(fsFilename) then
    begin
      scriptSource := LoadTextFromFile(fsFilename);
    end;
end;

function tcimObjectPascal.GetUnitFilename(aUnitName: String): string;
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
procedure tcimObjectPascal.DoDebugEval(exec: TdwsExecution; expr: TExprBase);
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
procedure tcimObjectPascal.DoDebugMessage(const msg : String);
begin
  //FDebugLastMessage:=msg;
end;

// DoDebugExceptionNotification
procedure tcimObjectPascal.DoDebugExceptionNotification(const exceptObj : IInfo);
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
procedure tcimObjectPascal.DoDebugSuspended(sender : TObject);
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
