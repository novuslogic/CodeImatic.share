unit CodeImatic.PluginInfo;

interface

Uses JvSimpleXml, NovusSimpleXML;

type
  tcimPluginInfo = class(Tobject)
   private
     fsPluginName: String;
     fsPluginFilename: string;
     fsPluginFilenamePathname: String;
     fbIsLoaded: Boolean;
   protected
   public
     constructor Create(aRootProperties: TJvSimpleXmlElem);
     destructor Destroy; override;
     property PluginName: String
       read fsPluginName
       write fsPluginName;
     property Pluginfilename: string
        read fsPluginfilename
        write fsPluginfilename;
     property PluginFilenamePathname: String
       read fsPluginFilenamePathname
       write fsPluginFilenamePathname;
     property IsLoaded: Boolean
       read fbIsLoaded
       write fbIsLoaded;
   end;


implementation

constructor tcimPluginInfo.Create;
begin
  fbIsLoaded := False;
end;


destructor tcimPluginInfo.Destroy;
begin
end;

end.
