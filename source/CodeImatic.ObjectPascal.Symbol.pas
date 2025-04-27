unit CodeImatic.ObjectPascal.Symbol;

interface

Uses dwsSymbols, dwsDataContext, System.SysUtils, dwsUnitSymbols;

type
  TcimObjectPascalSymbol = class(TTypeSymbol)
  protected
//    function DoIsOfType(typSym: TTypeSymbol): Boolean; override;
    function DoIsCompatible(typSym: TTypeSymbol): Boolean; override;
    function GetUnAliasedType: TTypeSymbol; override;
//    function GetAsFuncSymbol: TFuncSymbol; override;
    function GetDescription: String; override;
    function GetCaption: String; override;

  public
    class procedure RegisterSymbol(aSystemTable: TSystemSymbolTable); virtual;

    function BaseType: TTypeSymbol; override;
    procedure InitDataContext(const data: IDataContext;
      offset: NativeInt); override;
    function IsPointerType: Boolean; override;

    function Taxonomy: TdwsSymbolTaxonomy; override;
  end;

implementation

class procedure TcimObjectPascalSymbol.RegisterSymbol(aSystemTable: TSystemSymbolTable);
begin

end;

function TcimObjectPascalSymbol.BaseType : TTypeSymbol;
begin
   Result:=Typ.BaseType;
end;

function TcimObjectPascalSymbol.GetUnAliasedType : TTypeSymbol;
begin
   Result:=Typ.UnAliasedType;
end;

procedure TcimObjectPascalSymbol.InitDataContext(const data : IDataContext; offset : NativeInt);
begin
   Typ.InitDataContext(data, offset);
end;

function TcimObjectPascalSymbol.DoIsCompatible(typSym : TTypeSymbol) : Boolean;
begin
   Result:=Typ.IsCompatible(typSym);
end;

function TcimObjectPascalSymbol.IsPointerType : Boolean;
begin
   Result:=Typ.IsPointerType;
end;

function TcimObjectPascalSymbol.Taxonomy : TdwsSymbolTaxonomy;
begin
   Result := [ stTypeSymbol, stAliasSymbol ];
end;

(*
function TtcimObjectPascalSymbol.DoIsOfType(typSym : TTypeSymbol) : Boolean;
begin
   Result:=Typ.DoIsOfType(typSym);
end;
*)

(*
function TtcimObjectPascalSymbol.GetAsFuncSymbol : TFuncSymbol;
begin
   Result:=Typ.GetAsFuncSymbol;
end;
 *)

function TcimObjectPascalSymbol.GetDescription : String;
begin
   Result := Name + ' = ' + Typ.Name;
end;

function TcimObjectPascalSymbol.GetCaption : String;
begin
   if Name <> '' then
      Result := Name
   else Result := Typ.Caption;
end;

end.
