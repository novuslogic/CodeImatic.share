program Main;

uses
  MyMathUnit;

var
  x, y, sum, product: Integer;

begin
  x := 5;
  y := 10;
  sum := Add(x, y);
  product := Multiply(x, y);
  WriteLn('Sum: ' + IntToStr(sum));
  WriteLn('Product: ' + IntToStr(product));
end.

