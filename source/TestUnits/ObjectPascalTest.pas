unit ObjectPascalTest;

interface

uses
  DUnitX.TestFramework, ObjectPascalCompiler, Logger;

type
  [TestFixture]
  TCodeImaticShareTestObject = class
  public
    [Test]
    [TestCase('Test1','D:\Projects\CodeImatic.share\source\TestUnits\TestCode\Main.pas, D:\Projects\CodeImatic.share\source\TestUnits\TestCode\')]
    procedure CompleObjectPascalTest(aFilename: String; aWorkingdirectory: string; aSearchPath: String);
    [Test]
    procedure CompleObjectPascalBasicText;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

procedure TCodeImaticShareTestObject.CompleObjectPascalTest(aFilename: String; aWorkingdirectory: string; aSearchPath: String);
var
  fObjectPascalCompiler: tObjectPascalCompiler;
  fLogger: tLogger;
begin
  Try
    fLogger:= tLogger.Create(True);

    fObjectPascalCompiler := tObjectPascalCompiler.Create(fLogger);

    var Script := fObjectPascalCompiler.LoadStringFromFile(aFilename);

    if not fObjectPascalCompiler.Compile(Script, aWorkingdirectory, aSearchPath) then
      Assert.IsTrue(False, 'This test intentionally fails');


  Finally
    fObjectPascalCompiler.Free;
    fLogger.Free;
  End;
end;

procedure TCodeImaticShareTestObject.CompleObjectPascalBasicText;
var
  fObjectPascalCompiler: tObjectPascalCompiler;
  fLogger: tLogger;
begin
  Try
    fLogger:= tLogger.Create(True);

    fObjectPascalCompiler := tObjectPascalCompiler.Create(fLogger);

    var Script :=
      'PrintLn("Hello from ObjectPascal!");' + sLineBreak +
      'PrintLn("Current Time: " + TimeToStr(Now));';

    if not fObjectPascalCompiler.Compile(Script, '', '') then
      Assert.IsTrue(False, 'This test intentionally fails');


  Finally
    fObjectPascalCompiler.Free;
    fLogger.Free;
  End;
end;

procedure TCodeImaticShareTestObject.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TCodeImaticShareTestObject);

end.
