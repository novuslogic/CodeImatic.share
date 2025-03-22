program GetLastError;

begin
  WriteLn('SysErrorMessage:' + SysErrorMessage(GetLastError));

end.
