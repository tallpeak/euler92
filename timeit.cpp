// stolen from https://github.com/HPCE/hpce-2018-cw1/blob/master/src/mingw64-time.cpp
// Small changes, to convert from Mingw to Win32
// converted commandLine to unicode (LPWSTR), to match _tmain
#include "stdafx.h"

#include <windows.h>

#include <string>
#include <math.h>

double toSeconds(const FILETIME &f)
{
    double x=f.dwLowDateTime+ldexp(f.dwHighDateTime,32);
    return x*1e-7;
}

int _tmain(int argc, _TCHAR* argv[]) 
{
    if(argc<2){
        printf("Usage: timeit program [arg0 arg1 ...]\n");
        return 1;
    }

    std::wstring commandLine=argv[1];
    for(int i=2; i<argc; i++){
        commandLine+=L" ";
        commandLine+=argv[i];
    }

    STARTUPINFO si;
    PROCESS_INFORMATION pi;

    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );

    BOOL ret=CreateProcess(
        /*lpApplicationName*/ NULL,
        const_cast<LPWSTR>(commandLine.c_str()),
        /*lpProcessAttributes*/ NULL,
        /*lpThreadAttributes*/ NULL,
        /*bInheritHandles*/ TRUE,
        /*dwCreationFlags*/ 0,
        /*lpEnvironment*/ 0,
        /*lpCurrentDirectory*/ NULL,
        /*lpStartupInfo*/ &si,
        /*lpProcessInformation*/ &pi
      );
    if(!ret){
        printf( "CreateProcess failed (%d).\n", GetLastError() );
        return 1;
    }

    HANDLE hProcess=pi.hProcess;

    WaitForSingleObject( hProcess, INFINITE );

    FILETIME CreationTime;
    FILETIME ExitTime;
    FILETIME KernelTime;
    FILETIME UserTime;

    ret=GetProcessTimes(
        hProcess,
        &CreationTime,
        &ExitTime,
        &KernelTime,
        &UserTime
    );
    if(!ret){
        printf( "GetProcessTimes failed (%d).\n", GetLastError() );
        return 1;
    }

    double user=toSeconds(UserTime);
    double kernel=toSeconds(KernelTime);
    double real=toSeconds(ExitTime)-toSeconds(CreationTime);

    fprintf(stderr, "real %.3lf\n", real);
    fprintf(stderr, "user %.3lf\n", user);
    fprintf(stderr, "sys  %.3lf\n", kernel);

    CloseHandle(hProcess);

    return 0;
}
