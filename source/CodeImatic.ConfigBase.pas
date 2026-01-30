unit CodeImatic.ConfigBase;

interface

Uses NovusXMLBO, NovusCommandLine, NovusFileUtils, NovusStringUtils,
     NovusEnvironment, System.SysUtils, System.IOUtils, NovusList,
     Codeimatic.PluginInfo;

Const
  csCODEIMATIC = 'CODEIMATIC';


type
  TcimConfigBase = Class(TNovusXMLBO)
  protected
  private
    fsRootPath: String;
    fsBinPath: String;
    fsPluginsPath: String;
    fPluginInfoList: tNovusList;
  public
    constructor Create; override;
    destructor  Destroy; override;

    function LoadConfig(aCommandLineResult: INovusCommandLineResult): Integer; virtual;

    procedure AddPluginInfo(aPluginInfo: tcimPluginInfo);

    property  RootPath: String
       read fsRootPath
       write fsRootPath;

    property PluginsPath: String
      read fsPluginsPath
      write fsPluginsPath;

    property BinPath: string
      read fsBinPath
      write fsBinPath;

    property PluginInfoList: tNovusList
      read fPluginInfoList
      write fPluginInfoList;


  End;



implementation

constructor TcimConfigBase.Create;
begin
  inherited Create;

  fPluginInfoList := tNovusList.Create(tcimPluginInfo);
end;

destructor  TcimConfigBase.Destroy;
begin
  fPluginInfoList.Free;

  inherited Destroy;
end;

procedure TcimConfigBase.AddPluginInfo(aPluginInfo: tcimPluginInfo);
begin
  fPluginInfoList.Add(aPluginInfo);
end;


function TcimConfigBase.LoadConfig(aCommandLineResult: INovusCommandLineResult): Integer;
begin
  Result := 0;

  if RootPath = '' then
    RootPath := TNovusFileUtils.TrailingBackSlash(GetEnvironmentVariable(csCODEIMATIC));

  if RootPath = '' then
   begin
     RootPath := TNovusFileUtils.TrailingBackSlash(TNovusStringUtils.RootDirectory);

     RootPath := TNovusStringUtils.ReplaceStr(lowercase(RootPath), '\bin', '');
   end;

  BinPath := TNovusFileUtils.TrailingBackSlash(RootPath + 'Bin');
  PluginsPath := TNovusFileUtils.TrailingBackSlash(RootPath + 'Plugins');
end;

end.
