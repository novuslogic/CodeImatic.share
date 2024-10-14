unit RuntimeBase;

interface

uses variants, NovusParser.Common;

type
   TRuntimeBase = class(tObject)
   private
      fTags: TNovusTemplateTags;
   protected
   public
     constructor Create; virtual;
     destructor Destroy; override;

     procedure AddTag(aTagName: String; aTagValue: variant);
   end;

implementation

constructor TRuntimeBase.Create;
begin
  fTags := TNovusTemplateTags.Create;
end;

destructor TRuntimeBase.Destroy;
begin
  inherited Destroy;

  fTags.Free;
end;

procedure TRuntimeBase.AddTag(aTagName: String; aTagValue: variant);
begin
  fTags.AddTag(aTagName, aTagName);
end;


end.
