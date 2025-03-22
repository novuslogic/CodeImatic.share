unit CodeImatic.ObjectPascal.UnitBase;

interface

Uses NovusObject, dwsComp, CodeImatic.Output, NovusList, CodeImatic.RuntimeBase;

type
   tcimObjectPascalUnitBase = class(tNovusObject)
   protected
     function GetUnitName: string; virtual;
   private
     fCustomUnit: tdwsUnit;
     fCompiler: TDelphiWebScript;
     fOutput: tcimOutput;
     fRuntime: tcimRuntimeBase;
   public
     constructor Create(aCompiler: TDelphiWebScript;aRuntime:tcimRuntimeBase);
     destructor Destroy;

     property UnitName: String
         read GetUnitName;

     property oOutput: tcimOutput
       read fOutput;

     property oRuntime: tcimRuntimeBase
       read fRuntime;

     procedure Init; virtual;

     function AddFunction(aName: string; aOnEval : TFuncEvalEvent = nil): TdwsFunction;
   end;

   tcimCustomUnitList = class(tNovuslist)
   public
     procedure AddUnit(aUnit: tcimObjectPascalUnitBase);
   end;



implementation

// tcimObjectPascalUnitBase

constructor tcimObjectPascalUnitBase.Create(aCompiler: TDelphiWebScript;aRuntime: tcimRuntimeBase);
begin
  fCompiler := aCompiler;
  fOutput:= aRuntime.oOutput;

  fRuntime := aRuntime;

  FCustomUnit := tdwsUnit.Create(NIl);
  FCustomUnit.UnitName := Self.UnitName;

  FCustomUnit.Script := fCompiler;

  Init;
end;

destructor tcimObjectPascalUnitBase.Destroy;
begin
  fCustomUnit.Free;

  fCompiler := Nil;
  fOutput := Nil;
end;

function tcimObjectPascalUnitBase.GetUnitName: string;
begin
  Result := '';
end;

procedure tcimObjectPascalUnitBase.Init;
begin
end;

function tcimObjectPascalUnitBase.AddFunction(aName: string; aOnEval : TFuncEvalEvent = nil): TdwsFunction;
begin
  result := FCustomUnit.Functions.Add;

  result.OnEval := aOnEval;
  Result.Name := aName;
end;


// tcimCustomUnitList
procedure tcimCustomUnitList.AddUnit(aUnit: tcimObjectPascalUnitBase);
begin
  Self.Add(aUnit);
end;



end.
