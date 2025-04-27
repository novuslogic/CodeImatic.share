unit Codeimatic.ProjectItemBase;

interface

type
  tcimProjectItemBase = class(tObject)
  protected
  private
  public
    function Execute: Boolean; virtual;
  end;


implementation

function tcimProjectItemBase.Execute: Boolean;
begin
  Result := False;
end;


end.
