unit ObjectPascalTest;

interface

uses
  DUnitX.TestFramework, CodeImatic.ObjectPascal, CodeImatic.Output;

type
  [TestFixture]
  TCodeImaticShareTestObject = class
  public
    [Test]
    [TestCase('Test1','D:\Projects\CodeImatic.share\source\TestUnits\TestCode\Main.pas, D:\Projects\CodeImatic.share\source\TestUnits\TestCode\')]
    procedure CompleObjectPascalTest(aFilename: String; aWorkingdirectory: string; aSearchPath: String; aDebugger: Boolean);
    [Test]
    procedure CompleObjectPascalBasicText;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

procedure TCodeImaticShareTestObject.CompleObjectPascalTest(aFilename: String; aWorkingdirectory: string; aSearchPath: String; aDebugger: Boolean);
var
  fObjectPascal: tcimObjectPascal;
  fOutput: tcimOutput;
begin
  Try
    fOutput:= tcimOutput.Create(True, '');

    fObjectPascal := tcimObjectPascal.Create(fOutput);

    var Script := fObjectPascal.LoadStringFromFile(aFilename);

    if not fObjectPascal.Compile(Script, aWorkingdirectory, aSearchPath, True, False) then
      Assert.IsTrue(False, 'This test intentionally fails');


  Finally
    fObjectPascal.Free;
    fOutput.Free;
  End;
end;

procedure TCodeImaticShareTestObject.CompleObjectPascalBasicText;
var
  fObjectPascal: tcimObjectPascal;
  fOutput: tcimOutput;
begin
  Try
    fOutput:= tcimOutput.Create(True, '');

    fObjectPascal := tcimObjectPascal.Create(fOutput);

    var Script :=
      'PrintLn("Hello from ObjectPascal!");' + sLineBreak +
      'PrintLn("Current Time: " + TimeToStr(Now));';

    if not fObjectPascal.Compile(Script, '', '', true, false) then
      Assert.IsTrue(False, 'This test intentionally fails');


  Finally
    fObjectPascal.Free;
    fOutput.Free;
  End;
end;

procedure TCodeImaticShareTestObject.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TCodeImaticShareTestObject);

end.
