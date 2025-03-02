unit Plugins;

interface

uses NovusPlugin, Config, Output, Classes, SysUtils, PluginsMapFactory, Plugin,
  Project, NovusCommandLine, CommandsPlugin, AsmOutputModPlugin, CputypeBasePlugin,
  NovusTemplate2, PascalCompiler, uPSRuntime, uPSCompiler, NovusFileUtils,
  Loader;

type
  TPlugins = class(TObject)
  private
  protected
    foPascalCompiler: tPascalCompiler;
    foProject: tProject;
    foOutput: TOutput;
    FExternalPlugins: TNovusPlugins;
    fPluginsList: TList;
    fImp: TPSRuntimeClassImporter;
    function GetCount: Integer;
  public
    constructor Create(aOutput: TOutput; aProject: tProject;
      aPascalScript: tPascalCompiler);
    destructor Destroy; override;

    procedure LoadPlugins;
    procedure UnloadPlugins;

    procedure RegisterImports;

    procedure RegisterFunctions(aExec: TPSExec);
    function FindPlugin(aPluginName: String): TPlugin;

    function IsPluginNameExists(aPluginName: string): Boolean;
    function CustomOnUses(aCompiler: TPSPascalCompiler): Boolean;

    procedure SetVariantToClasses(aExec: TPSExec);

    function IsCommandLine(aResultCommands: INovusCommandLineResultCommands): Boolean;

    function FindAsmOutputModPlugin(aPluginName: String): TAsmOutputModPlugin;
    function FindCputypeBasePlugin(aPluginName: String): TCputypeBasePlugin;

    function BeforeCodeGen: Boolean;
    function AfterCodeGen: Boolean;

    property PluginsList: TList read fPluginsList write fPluginsList;

    property Count: Integer
       read GetCount;
  end;

implementation

Uses Runtime;

constructor TPlugins.Create;
begin
  foOutput := aOutput;

  foProject := aProject;

  foPascalCompiler := aPascalScript;

  fImp := foPascalCompiler.oImp;

  FExternalPlugins := TNovusPlugins.Create;

  fPluginsList := TList.Create;
end;

destructor TPlugins.Destroy;
begin
  Inherited;

 // UnloadPlugins;

  FExternalPlugins.Free;

  fPluginsList.Free;
end;

procedure TPlugins.UnloadPlugins;
Var
  I: Integer;
  loPlugin: tPlugin;
  fPluginInfo: TPluginInfo;
begin
  foOutput.Log('Unload Plugins');

  (*
  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);

    loPlugin.Free;
    loPlugin := nil;
  end;


  fPluginsList.Clear;
  *)

  for I := FExternalPlugins.PluginCount - 1 downto 0 do
    begin
      fPluginInfo := FExternalPlugins.GetPluginList(i);
      foOutput.Log('Unload: ' +fPluginInfo.PluginName);

      FExternalPlugins.UnloadPlugin(I);
    end;

  fPluginsList.Clear;
end;

procedure TPlugins.RegisterImports;
var
  loPlugin: TPlugin;
  I: Integer;
  FExternalPlugin: TExternalPlugin;
begin
  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);

    loPlugin := TPlugin(fPluginsList.Items[I]);
    if loPlugin is TPascalScriptPlugin then
    begin
      TPascalScriptPlugin(loPlugin).Initialize(fImp);
      TPascalScriptPlugin(loPlugin).RegisterImport;
    end;
  end;
end;

procedure TPlugins.SetVariantToClasses(aExec: TPSExec);
var
  loPlugin: TPlugin;
  I: Integer;
  FExternalPlugin: TExternalPlugin;
begin
  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);
    if loPlugin is TPascalScriptPlugin then
      TPascalScriptPlugin(loPlugin).SetVariantToClass(aExec);
  end;
end;

procedure TPlugins.RegisterFunctions(aExec: TPSExec);
var
  I: Integer;
  loPlugin: TPlugin;
  FExternalPlugin: TExternalPlugin;
begin
  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);
    if loPlugin is TPascalScriptPlugin then
      TPascalScriptPlugin(loPlugin).RegisterFunction(aExec);
  end;

  RegisterClassLibraryRuntime(aExec, fImp);
end;

function TPlugins.CustomOnUses(aCompiler: TPSPascalCompiler): Boolean;
Var
  I: Integer;
  loPlugin: TPlugin;
begin
  Try
    for I := 0 to fPluginsList.Count - 1 do
    begin
      loPlugin := TPlugin(fPluginsList.Items[I]);
      if loPlugin is TPascalScriptPlugin then
        TPascalScriptPlugin(loPlugin).CustomOnUses(aCompiler)
    end;

    Result := True;
  Except
    foOutput.WriteExceptLog;

    Result := False;
  End;

end;

procedure TPlugins.LoadPlugins;
Var
  I: Integer;
  FPlugin: TPlugin;
  FExternalPlugin: TExternalPlugin;
  loConfigPlugin: TConfigPlugin;
begin
  // External Plugin
  foOutput.Log('Loading plugins');

  if oConfig.oConfigPluginList.Count > 0 then
  begin
    for I := 0 to oConfig.oConfigPluginList.Count - 1 do
    begin
      loConfigPlugin := TConfigPlugin(oConfig.oConfigPluginList.Items[I]);

      if FileExists(loConfigPlugin.PluginFilenamePathname) then
      begin
        if FExternalPlugins.LoadPlugin(loConfigPlugin.PluginFilenamePathname)
        then
        begin
          FExternalPlugin :=
            TExternalPlugin(FExternalPlugins.Plugins
            [FExternalPlugins.PluginCount - 1]);

          fPluginsList.Add(FExternalPlugin.CreatePlugin(foOutput, foProject,
            loConfigPlugin));
          foOutput.Log('Loaded: ' + FExternalPlugin.PluginName);
        end;
      end
      else
        foOutput.Log('Missing: ' + loConfigPlugin.PluginFilenamePathname);
    end;

  end;
end;

function TPlugins.GetCount: Integer;
begin
  Result := PluginsList.Count;
end;

function TPlugins.IsCommandLine(aResultCommands: INovusCommandLineResultCommands): Boolean;
var
  loPlugin: TPlugin;
  I: Integer;

  function FindPluginname(aPluginName: String): INovusCommandLineResultCommand;
   var
      loResultCommand: INovusCommandLineResultCommand;
      loResultOption: INovusCommandLineResultOption;
     begin
       Result := NIL;

       if Assigned(aResultCommands) then
          begin
            loResultCommand := aResultCommands.FirstCommand;
            While( Assigned(loResultCommand)) do
              begin
                loResultOption := loResultCommand.Options.FindOptionByName('pluginname');

                if Assigned(loResultOption) then
                  begin
                    if uppercase(loResultOption.Value.AsString) = uppercase(aPluginName) then
                      begin
                        Result := loResultCommand;
                        break;
                      end;
                  end;

                loResultCommand := aResultCommands.NextCommand;
              end;
          end;
    end;

begin
  Result := True;

  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);

    Result := loPlugin.IsCommandLine(FindPluginname(loPlugin.PluginName));
    if Not Result then
      break;
  end;
end;

function TPlugins.BeforeCodeGen: Boolean;
var
  loPlugin: TPlugin;
  I: Integer;
begin
  Result := True;

  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);

    Result := loPlugin.BeforeCodeGen;
    if Not Result then
      break;
  end;
end;

function TPlugins.AfterCodeGen: Boolean;
var
  loPlugin: TPlugin;
  I: Integer;
begin
  Result := True;

  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);

    Result := loPlugin.AfterCodeGen;

    if NOt Result then
      break;
  end;
end;

function TPlugins.IsPluginNameExists(aPluginName: string): Boolean;
begin
  Result := False;

  if Assigned(FindPlugin(aPluginName)) then
    Result := True;
end;

function TPlugins.FindPlugin(aPluginName: String): TPlugin;
var
  loPlugin: TPlugin;
  I: Integer;
begin
  Result := NIL;

  for I := 0 to fPluginsList.Count - 1 do
  begin
    loPlugin := TPlugin(fPluginsList.Items[I]);
    if Uppercase(Trim(loPlugin.PluginName)) = Uppercase(Trim(aPluginName)) then
    begin
      Result := loPlugin;

      break;
    end;
  end;
end;


function TPlugins.FindAsmOutputModPlugin(aPluginName: String): TAsmOutputModPlugin;
Var
  I: Integer;
begin
  Result := nil;

  // PluginName
  if IsPluginNameExists(aPluginName) then
    begin
      var loPlugin := FindPlugin(aPluginName);

      if loPlugin is TAsmOutputModPlugin then
        Result := loPlugin as TAsmOutputModPlugin;

    end;
end;

function TPlugins.FindCputypeBasePlugin(aPluginName: String): TCputypeBasePlugin;
Var
  I: Integer;
begin
  Result := nil;

  // PluginName
  if IsPluginNameExists(aPluginName) then
    begin
      var loplugin := FindPlugin(aPluginName);

      if loplugin is TCputypeBasePlugin then
        Result := loplugin as TCputypeBasePlugin;

    end;
end;



end.
