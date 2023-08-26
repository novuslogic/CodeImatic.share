unit ObjectPascal;

interface

uses OutputBase;

type
  tObjectPascal = class(Tobject)
  private
    foOutput: tOutputBase;
  protected
  public
    constructor Create(aOutput: tOutputBase);
    destructor Destroy;
  end;

implementation

constructor tObjectPascal.create(aOutput: tOutputBase);
begin
  foOutput := aOutput;
end;

destructor tObjectPascal.destroy;
begin
end;

end.
