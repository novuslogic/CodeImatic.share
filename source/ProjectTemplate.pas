unit ProjectTemplate;

interface

Uses NovusTemplate2;

type
  tProjectTemplate = class(tNovusTemplate2)
  protected
  private
    fsTemplateName: String;
  public
    class function CreateProjectTemplate: tProjectTemplate;

    property TemplateName: string
      read fsTemplateName
      write fsTemplateName;
  end;

implementation

class function TProjectTemplate.CreateProjectTemplate: tProjectTemplate;
begin
  Result :=  tProjectTemplate.Create;
  Result.StartToken := '<';
  Result.EndToken := '>';
  Result.SecondToken := '%';
  Result.SwapTagNameBlankValue := true;
end;

end.
