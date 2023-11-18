unit ObjectPascalCompiler;

interface

uses dwsComp, dwsExprs, System.Classes, NovusUtilities,
     System.SysUtils, dwsErrors;

type
  TdwsMessageHelper = class helper for TdwsMessage
  public
    function FormatedScriptMessage: String;
  end;

  tObjectPascalProgram = class(tobject)
  private
  protected
    fsLastErrorMessage: string;
    fprog : IdwsProgram;
    function GetHasMessages: Boolean;
    function GetMsgs : TdwsMessageList;
  public
    constructor Create;
    destructor Destroy; override;

    property HasMessages: boolean
      read GetHasMessages;

    property Msgs : TdwsMessageList read GetMsgs;

    property prog : IdwsProgram
       read  fprog
       write fprog;

    property LastErrorMessage: string
       read fsLastErrorMessage
       write fsLastErrorMessage;
  end;

  tObjectPascalCompiler = class(Tobject)
  private
  protected
    fdws : TDelphiWebScript;
    fLines: tStringList;
  public
    constructor Create;
    destructor Destroy; override;

    function Compile(aLine: String = ''): tObjectPascalProgram;


  end;

implementation

// tObjectPascalCompiler

constructor tObjectPascalCompiler.create;
begin
  fdws := TDelphiWebScript.Create(Nil);
  fLines:= tStringList.Create;
end;

destructor tObjectPascalCompiler.destroy;
begin
  fdws.Free;
  fLines.Free;

  inherited destroy;
end;

function tObjectPascalCompiler.Compile(aLine: String = ''): tObjectPascalProgram;
begin
  Result := tObjectPascalProgram.Create;

  Try
    if trim(aLine) = '' then aLine := flines.Text;
    Try
      result.prog := fdws.Compile(aLine);
    Except
      result.LastErrorMessage := TNovusUtilities.GetExceptMess;
    End;
  Finally

  End;



end;



// tObjectPascalProgram
constructor tObjectPascalProgram.create;
begin

end;

destructor tObjectPascalProgram.destroy;
begin
  fprog := Nil;

  inherited destroy;
end;


function tObjectPascalProgram.GetHasMessages: boolean;
begin
  result := (fprog.Msgs.Count <> 0 );
end;

function tObjectPascalProgram.GetMsgs : TdwsMessageList;
begin
  Result := fprog.Msgs;
end;

// TdwsMessageHelper

function TdwsMessageHelper.FormatedScriptMessage: String;
var
  msg: TScriptMessage;
begin
  // Example: [Error] Simple(9:44): Unknown identifier 'a'

  msg := Self as TScriptMessage;


  // msg.ScriptPos.SourceName
  (*
  var msgType := '';
  case msg.MessageType of
      TScriptMessageType.mtHint: msgType := 'Hint';
      TScriptMessageType.mtWarning: msgType := 'Warning';
      TScriptMessageType.mtError: msgType := 'Error';
  end;
  *)
  (*
  if SourceFile=nil then
      Result:=''
   else begin
      if not IsMainModule then
         if SourceFile.Location <> '' then
            Result:=Format(MSG_ScriptPosFileFull, [SourceFile.Name, SourceFile.Location])
         else Result:=Format(MSG_ScriptPosFile, [SourceFile.Name])
      else Result:='';
      if Col<>cNullPos.Col then begin
         if Result<>'' then
            Result:=', '+Result;
         Result:=Format(MSG_ScriptPosColumn, [Col])+Result;
      end;
      if Line<>cNullPos.Line then begin
         if Result<>'' then
            Result:=', '+Result;
         Result:=Format(MSG_ScriptPosLine, [Line])+Result;
      end;
      if Result<>'' then
         Result:=' ['+Result+']';
   end;
   *)

  If not Assigned(msg.ScriptPos.SourceFile) then
     Result := Format('(%d:%d): %s',
                     [ msg.ScriptPos.Line, msg.ScriptPos.Col, msg.Text])
  else
  begin
     if not msg.ScriptPos.IsMainModule then
       begin
         if (msg.ScriptPos.SourceFile.Location <> '') then
           begin
              Result := Format('(%d:%d): %s',
                     [ msg.ScriptPos.Line, msg.ScriptPos.Col, msg.Text])
           end;
       end
      else
        begin
          if msg.ScriptPos.SourceFile.name = '*MainModule*' then
            Result := Format(' %s(%d:%d): %s',
                     [ '*', msg.ScriptPos.Line, msg.ScriptPos.Col, msg.Text])



        end;

            (*
            Result:=Format(  [SourceFile.Name, SourceFile.Location])
         else Result:=Format(MSG_ScriptPosFile, [SourceFile.Name])
      else Result:='';
              *)







  end;



end;

end.
