unit MyMathUnit;

interface

function Add(a, b: Integer): Integer;
function Multiply(a, b: Integer): Integer;

implementation

function Add(a, b: Integer): Integer;
begin
  Result := a + b;
end;

function Multiply(a, b: Integer): Integer;
begin
  Result := a * b;
end;

end.

