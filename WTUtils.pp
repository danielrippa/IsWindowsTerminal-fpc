unit WTUtils;

{$mode delphi}

interface

  function GetParentProcessID(AProcessID: DWORD): DWORD;
  function GetProcessImageName(AProcessID: DWORD): String;

implementation

  uses
    Windows, JwaTlHelp32;

  function GetParentProcessID;
  var
    hSnapshot: THandle;
    pe32: tagPROCESSENTRY32;
  begin
    Result := 0;

    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if hSnapshot = INVALID_HANDLE_VALUE then Exit(0);

    pe32.dwSize := SizeOf(tagPROCESSENTRY32);
    if not Process32First(hSnapshot, pe32) then begin
      CloseHandle(hSnapshot);
      Exit(0);
    end;

    repeat

      if pe32.th32ProcessID = AProcessID then begin
        Result := pe32.th32ParentProcessID;
        Break;
      end;

    until not Process32Next(hSnapshot, pe32);

    CloseHandle(hSnapshot);
  end;

  function GetProcessImageName;
  var
    hProcess: THandle;
    szExeFile: array[0..MAX_PATH-1] of Char;
    dwSize: DWORD;
  begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, AProcessID);
    if hProcess = 0 then begin
      Exit('');
    end;

    dwSize := MAX_PATH;
    if QueryFullProcessImageName(hProcess, 0, szExeFile, @dwSize) then begin
      Result := szExeFile;
    end else begin
      Result := '';
    end;

    CloseHandle(hProcess);
  end;

end.