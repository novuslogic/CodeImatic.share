program ObjectPascalTester1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ObjectPascalCompiler in '..\..\source\ObjectPascalCompiler.pas',
  NovusUtilities in 'D:\Delphi Components\NovuscodeLibrary\Source\Core\Utilities\NovusUtilities.pas';

var
  loObjectPascalCompiler: tObjectPascalCompiler;
  loObjectPascalProgram : tObjectPascalProgram;
begin
  try
    try
      loObjectPascalCompiler := tObjectPascalCompiler.Create;

      Try
        loObjectPascalProgram := loObjectPascalCompiler.Compile( 'var s : String = ''Hello World!'';'#13#10
                       +'ShowMessage(s);');

        if loObjectPascalProgram.HasMessages then
          begin
            for var I := 0 to loObjectPascalProgram.Msgs.Count - 1 do
             begin
               Writeln(loObjectPascalProgram.Msgs[i].FormatedScriptMessage);
             end;
          end;


      Finally
        loObjectPascalProgram.Free;
      End;


    finally
      loObjectPascalCompiler.Free;
    end;

    Readln;

    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
