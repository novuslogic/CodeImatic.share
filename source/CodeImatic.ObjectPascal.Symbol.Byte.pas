unit CodeImatic.ObjectPascal.Symbol.Byte;

interface

uses
  CodeImatic.ObjectPascal.Symbol, dwsConstExprs,
  dwsSymbols, dwsDataContext, System.SysUtils, dwsUnitSymbols;

type
  TcimObjectPascalSymbolByte = class(TcimObjectPascalSymbol)
  public
    class procedure RegisterSymbol(aSystemTable: TSystemSymbolTable); override;
    procedure InitDataContext(const data: IDataContext;
      offset: NativeInt); override;
    procedure ValidateValue(const value: Int64);
  end;

implementation

{ TcimObjectPascalSymbolByte }

class procedure TcimObjectPascalSymbolByte.RegisterSymbol
  (aSystemTable: TSystemSymbolTable);
var
  byteTypeSym: TTypeSymbol;
begin
  // Check if Byte type already exists
  var
  byteSymbol := aSystemTable.FindTypeLocal('Byte');
  if byteSymbol = nil then
  begin
    // Create a new alias type to Integer
    byteTypeSym := TcimObjectPascalSymbolByte.Create('Byte',
      aSystemTable.TypInteger);

    // Optionally, you can later enhance this to enforce 0-255 range with custom casting
    aSystemTable.AddSymbol(byteTypeSym);
  end;
end;

procedure TcimObjectPascalSymbolByte.InitDataContext(const data: IDataContext;
  offset: NativeInt);
begin
  data.SetZeroInt64(offset);
end;

procedure TcimObjectPascalSymbolByte.ValidateValue(const value: Int64);
begin
  if (value < 0) or (value > 255) then
    raise Exception.CreateFmt('Value out of range for Byte (%d)', [value]);
end;


end.
