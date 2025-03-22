unit ObjectPascalTest;

interface

uses
  DUnitX.TestFramework, CodeImatic.ObjectPascal, CodeImatic.Output,
  CodeImatic.RuntimeBase;

type
  [TestFixture]
  TCodeImaticShareTestObject = class
  public
    [Test]
     [TestCase('GetLastError function test','D:\Projects\CodeImatic.share\source\TestUnits\TestCode\GetLastError.pas, D:\Projects\CodeImatic.share\source\TestUnits\TestCode\')]
    [TestCase('wd function test','D:\Projects\CodeImatic.share\source\TestUnits\TestCode\wd.pas, D:\Projects\CodeImatic.share\source\TestUnits\TestCode\')]
    [TestCase('Class and Use test','D:\Projects\CodeImatic.share\source\TestUnits\TestCode\Main.pas, D:\Projects\CodeImatic.share\source\TestUnits\TestCode\')]
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
  fRuntime: tcimRuntimeBase;
  fObjectPascal: tcimObjectPascal;
  fOutput: tcimOutput;
begin
  Try
    fOutput := tcimOutput.Create(True, '');

    fRuntime := tcimRuntimeBase.Create(fOutput);

    fRuntime.WorkingDirectory := aWorkingdirectory;

    fObjectPascal := tcimObjectPascal.Create(fRuntime);

    var Script := fObjectPascal.LoadStringFromFile(aFilename);

    if not fObjectPascal.Compile(Script, aWorkingdirectory, aSearchPath, false, False) then
      Assert.IsTrue(False, 'This test intentionally fails');


  Finally
    fObjectPascal.Free;
    fRuntime.Free;
   // fOutput.Free;
  End;
end;

procedure TCodeImaticShareTestObject.CompleObjectPascalBasicText;
var
  fRuntime: tcimRuntimeBase;
  fObjectPascal: tcimObjectPascal;
  fOutput: tcimOutput;
begin
  Try
    fOutput := tcimOutput.Create(True, '');
    fRuntime := tcimRuntimeBase.Create(fOutput);

    fObjectPascal := tcimObjectPascal.Create(fRuntime);

    var Script :=
      'PrintLn("Hello from ObjectPascal!");' + sLineBreak +
      'PrintLn("Current Time: " + TimeToStr(Now));';

    if not fObjectPascal.Compile(Script, '', '', true, false) then
      Assert.IsTrue(False, 'This test intentionally fails');


  Finally
    fObjectPascal.Free;
    fRuntime.Free;
  //  fOutput.Free;
  End;
end;

procedure TCodeImaticShareTestObject.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TCodeImaticShareTestObject);

end.
