unit CodeImatic.RuntimeBase;

interface

uses variants, NovusParser.Common, NovusObject,
     NovusCommandLine, CodeImatic.output;

type
   tcimRuntimeBase = class(tNovusObject)
   private
     fOutput: tcimOutput;
     fsProjectFileName: String;
     fbConsoleoutputonly: boolean;
     fsworkingdirectory: string;
     fTags: TNovusTemplateTags;
     fCommandLineResult: INovusCommandLineResult;
   protected
   public
     constructor Create; overload; virtual;
     constructor Create(aOutput: tcimOutput); overload; virtual;

     destructor Destroy; override;

     procedure AddTag(aTagName: String; aTagValue: variant);

     property Workingdirectory: string
       read fsworkingdirectory
       write fsworkingdirectory;

     property CommandLineResult: INovusCommandLineResult
       read fCommandLineResult
       write fCommandLineResult;

     property Consoleoutputonly: boolean
        read fbConsoleoutputonly
        write fbConsoleoutputonly;

     property ProjectFileName: String
        read fsProjectFileName
        write fsProjectFileName;

     property oOutput: tcimOutput
       read fOutput
       write fOutput;
   end;

implementation

constructor tcimRuntimeBase.Create;
begin
  fTags := TNovusTemplateTags.Create;
end;

constructor tcimRuntimeBase.Create(aOutput: tcimOutput);
begin
  foutput := aOutput;
  fTags := TNovusTemplateTags.Create;
end;


destructor tcimRuntimeBase.Destroy;
begin
  inherited Destroy;

  if Assigned(fOutput) then fOutput.Free;

  fTags.Free;
end;

procedure tcimRuntimeBase.AddTag(aTagName: String; aTagValue: variant);
begin
  fTags.AddTag(aTagName, aTagName);
end;


end.
