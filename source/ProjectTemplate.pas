unit ProjectTemplate;

interface

Uses NovusTemplate2, RuntimeBase;

type
  tProjectTemplate = class(tNovusTemplate2)
  protected
  private
    fsTemplateFilename: String;
    foRuntime: tRuntimeBase;
  public
    function Execute: boolean;

    class function CreateProjectTemplate(aRuntime:tRuntimeBase): tProjectTemplate;

    property TemplateFilename: string
      read fsTemplateFilename
      write fsTemplateFilename;

    property oRuntime: tRuntimeBase
      read foRuntime
      write foRuntime;

  end;

implementation

class function TProjectTemplate.CreateProjectTemplate(aRuntime:tRuntimeBase): tProjectTemplate;
begin
  Result :=  tProjectTemplate.Create;
  Result.StartToken := '<';
  Result.EndToken := '>';
  Result.SecondToken := '%';
  Result.SwapTagNameBlankValue := true;
  result.oRuntime := aRuntime;
end;

function TProjectTemplate.Execute: boolean;
begin
  Result := false;




end;

end.
