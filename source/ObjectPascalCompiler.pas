unit ObjectPascalCompiler;

interface

uses
  System.SysUtils,  System.Classes, dwsCompiler,  NovusFileUtils,  dwsXPlatform,
  dwsComp, dwsExprs, dwsSymbols, dwsUtils, Logger, dwsUnitSymbols, System.IOUtils,
  dwsRTTIConnector, dwsRTTIFunctions, NovusObject;

type
  tObjectPascalCompiler = class(TNovusobject)
  private
  protected
    fLogger: tLogger;
    fCompiler: TDelphiWebScript;
    fProg: IdwsProgram;
    fExec: IdwsProgramExecution;
    fsWorkingdirectory: String;
    fsSearchPath: string;

    procedure dwsUnitFunctionsWritelnEval(Info: TProgramInfo);

    function GetUnitFilename(aUnitName: String): string;
    procedure AddCustomUnits;
    function DoNeedUnitEx(const unitName : String; var unitSource, unitLocation : String) : IdwsUnit;
    procedure DoIncludeEx(const scriptName: String; var scriptSource, scriptLocation : String);
  public
    constructor Create(aLogger: tLogger);
    destructor Destroy;

    function LoadStringFromFile(const FileName: string): string;

    function Compile(aScript: String; aWorkingdirectory, aSearchPath: string): boolean;
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
end;

destructor tObjectPascalCompiler.destroy;
begin
  fCompiler.Free;
end;

procedure tObjectPascalCompiler.AddCustomUnits;
Var
  FCustomUnit: tdwsUnit;
  FCustomFunction: TdwsFunction;
  FCustomParameter: TdwsParameter;
begin
  FCustomUnit := tdwsUnit.Create(NIl);

  FCustomUnit.UnitName := 'test';
  FCustomUnit.Script := fCompiler;

  FCustomFunction := FCustomUnit.Functions.Add;

  FCustomFunction.OnEval := dwsUnitFunctionsWritelnEval;

  FCustomFunction.Name := 'Writeln';
  FCustomParameter := FCustomFunction.Parameters.Add;
  FCustomParameter.Name := 'Msg';
  FCustomParameter.IsWritable := True;
  FCustomParameter.DataType := 'String';


end;


function tObjectPascalCompiler.Compile(aScript: String; aWorkingdirectory, aSearchPath: string): boolean;
begin
  Result := false;
  fsSearchPath := aSearchPath;
  fsWorkingdirectory := aWorkingdirectory;

  fCompiler.Config.OnNeedUnitEx := DoNeedUnitEx;
  fCompiler.Config.OnIncludeEx := DoIncludeEx;

  fCompiler.Config.ScriptPaths.Add(aWorkingdirectory);
  fCompiler.Config.ScriptPaths.Add(aSearchPath);

  AddCustomUnits;

  fProg := fCompiler.Compile(aScript);

  if fProg.Msgs.HasErrors then
    begin
      fLogger.Log.AddLogError(fProg.Msgs.AsInfo);

      Exit;
    end;

  fExec := fProg.Execute;

  if fExec.Msgs.HasErrors then
    begin
      fLogger.Log.AddLogError(fExec.Msgs.AsInfo);

      Exit;
    end
  else
     begin
       fLogger.Log.AddLogInformation(fExec.Result.ToString);

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

  var TmpInfo := Info;

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


end.
