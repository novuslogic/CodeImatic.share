unit CodeImatic.ProjectTemplate;

interface

Uses NovusTemplate2;

type
  tcimProjectTemplate = class(tNovusTemplate2)
  protected
  private
    fsTemplateName: String;
  public
    class function CreateProjectTemplate: tcimProjectTemplate;

    property TemplateName: string
      read fsTemplateName
      write fsTemplateName;
  end;

implementation

class function tcimProjectTemplate.CreateProjectTemplate: tcimProjectTemplate;
begin
  Result :=  tcimProjectTemplate.Create;
  Result.StartToken := '<';
  Result.EndToken := '>';
  Result.SecondToken := '%';
  Result.SwapTagNameBlankValue := true;
end;

end.
