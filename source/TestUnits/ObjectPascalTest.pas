unit ObjectPascalTest;

interface

uses
  DUnitX.TestFramework, ObjectPascal;

type
  [TestFixture]
  TCodeImaticShareTestObject = class
  public
    // Sample Methods
    // Simple single Test
    [Test]
    procedure CompleObjectPascalTest;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

procedure TCodeImaticShareTestObject.CompleObjectPascalTest;
begin
  //ObjectPascal








  Assert.IsTrue(False, 'This test intentionally fails');
end;

procedure TCodeImaticShareTestObject.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TCodeImaticShareTestObject);

end.
