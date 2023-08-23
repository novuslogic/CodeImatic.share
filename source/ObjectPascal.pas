unit ObjectPascal;

interface

uses dwsComp;

type
  tObjectPascal = class(Tobject)
  private
    fdws : TDelphiWebScript;
  protected
  public
    constructor Create;
    destructor Destroy;
  end;

implementation

constructor tObjectPascal.create;
begin
  fdws := TDelphiWebScript.Create(NIL);
end;

destructor tObjectPascal.destroy;
begin
  fdws.Free;
end;

end.
