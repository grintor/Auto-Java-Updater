@::-----UAC Prompt----------------------------------
@echo off
NET SESSION >nul 2>&1 && goto noUAC
title.
set n=%0 %*
set n=%n:"=" ^& Chr(34) ^& "%
echo Set objShell = CreateObject("Shell.Application")>"%tmp%\cmdUAC.vbs"
echo objShell.ShellExecute "cmd.exe", "/c start " ^& Chr(34) ^& "." ^& Chr(34) ^& " /d " ^& Chr(34) ^& "%CD%" ^& Chr(34) ^& " cmd /c %n%", "", "runas", ^1>>"%tmp%\cmdUAC.vbs"
echo Not Admin, Attempting to elevate...
cscript "%tmp%\cmdUAC.vbs" //Nologo
del "%tmp%\cmdUAC.vbs"
exit /b
:noUAC

setlocal enableextensions enabledelayedexpansion
color 17
title Java removal/update tool v0.9

echo.
echo This software is brought to you by Grintor.
echo ^<Grintor at Gmail dot Com^>
echo.
echo This program is free software.
echo This program IS PROVIDED WITHOUT WARRANTY, EITHER EXPRESSED OR IMPLIED.
echo This program is copyrighted under the terms of GPLv3:
echo see ^<http://www.gnu.org/licenses/^>.
echo.
FOR /L %%n IN (1,1,10) DO ping -n 2 127.0.0.1 > nul & <nul set /p =.
cls
echo.
echo If you find the program useful, please consider sending some Bitcoin my way:
echo 12iNFT3n6yXz95mYttMcXWjm8UaEHVSjjr
echo.
FOR /L %%n IN (1,1,10) DO ping -n 2 127.0.0.1 > nul & <nul set /p =.
cls

curl -V  >nul 2>&1 || echo Installing cURL... && start /wait msiexec /i https://s3.amazonaws.com/grintor-public/curl.msi /q

cls
echo.
echo Searching for latest version of Java...
ping -n 1 google.com > nul || goto error


::----------- Find the latest java version----------------------------------
FOR /F "tokens=2 delims=<	> " %%n IN ('curl.exe -s -L http://javadl-esd.sun.com/update/1.8.0/map-m-1.8.0.xml ^| find /i "https:"') DO set URL1=%%n
FOR /F "tokens=2 delims=<	> " %%n IN ('curl.exe -s -L -k %URL1% ^| find /i "<version>"') DO set RemoteJavaVersionFull=%%n
set RemoteJavaVersion=%RemoteJavaVersionFull:~0,8%
set RemoteJavaUrl=%RemoteJavaVersionFull:~6%
set RemoteJavaExe=%RemoteJavaVersionFull:~6,2%
REM Examle
REM https://edelivery.oracle.com/otn-pub/java/jdk/8u60-b27/jre-8u60-windows-x64.exe
REM https://edelivery.oracle.com/otn-pub/java/jdk/8u%RemoteJavaVersionFull:~6%/jre-8u%RemoteJavaVersionFull:~6,2%-windows-x64.exe
echo The latest version of java is %RemoteJavaVersion%.




::----------- Find the local Java version-----------------------------------
set LocalJavaVersion=None
REM FOR /F "tokens=1-15" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^& reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (
FOR /F "tokens=1-15" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (
REM x64
REM FOR /F "tokens=1-15" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (


   if '%%n'=='InstallSource' (
     set p=%%p%%q%%r%%s%%t%%u%%v%%w%%x%%y%%z
     set p=!p: =\!
     set p=!p:\= !
     for %%n in (!p!) do set c=%%n
   )

   if '%%n'=='DisplayName' (
      set p=%%p
      if "!p:~0,4!"=="Java" if not "%%q"=="Auto" if not '!LocalJavaVersion!'=='None' (set LocalJavaVersion=Multi) ELSE (set LocalJavaVersion=!c:~3!)
      if "!p:~0,4!"=="J2SE" if not '!LocalJavaVersion!'=='None' (set LocalJavaVersion=Multi) ELSE (set LocalJavaVersion=!c:~3!)
   )
)

set LocalJavax64Version=None
REM FOR /F "tokens=1-15" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^& reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (
FOR /F "tokens=1-15" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (


   if '%%n'=='InstallSource' (
     set p=%%p%%q%%r%%s%%t%%u%%v%%w%%x%%y%%z
     set p=!p: =\!
     set p=!p:\= !
     for %%n in (!p!) do set c=%%n
   )

   if '%%n'=='DisplayName' (
      set p=%%p
      if "!p:~0,4!"=="Java" if not "%%q"=="Auto" if not '!LocalJavax64Version!'=='None' (set LocalJavax64Version=Multi) ELSE (set LocalJavax64Version=!c:~3!)
      if "!p:~0,4!"=="J2SE" if not '!LocalJavax64Version!'=='None' (set LocalJavax64Version=Multi) ELSE (set LocalJavax64Version=!c:~3!)
   )
)
if '%LocalJavaVersion%'=='None' echo There is no local version of Java. & goto install
if '%LocalJavax64Version%'=='None' echo There is no local version of Java. & goto install
if '%LocalJavaVersion%'=='Multi' echo There are multiple local versions of Java installed. & goto uninstall
if '%LocalJavax64Version%'=='Multi' echo There are multiple local versions of Java x64 installed. & goto uninstall
if not '%LocalJavaVersion%'=='%RemoteJavaVersion%' echo There is older local versions of Java installed. & goto uninstall
if not '%LocalJavax64Version:~0,8%'=='%RemoteJavaVersion%' echo There is older local versions of Java x64 installed. & goto uninstall
echo The local version of Java is %LocalJavaVersion%.
echo The local version of Java is %LocalJavax64Version%.


::----------- If they match, skip to the end---------------------------------
if '%RemoteJavaVersion%'=='%LocalJavaVersion%' (goto finished) ELSE (echo The Local version of Java is out of date.)
if '%RemoteJavaVersion%'=='%LocalJavax64Version%' (goto finished) ELSE (echo The Local version of Java x64 is out of date.)




::----------- Uninstall all currently installed java versions----------------
:uninstall
if '%LocalJavaVersion%'=='Multi' (echo Uninstalling all local versions of Java...) ELSE (echo Uninstalling the local version of Java...)
FOR /F "tokens=1-4" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^& reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (

   if '%%n'=='UninstallString' (
     set c=%%q
     set c=!c:/I=/X!
   )

   if '%%n'=='DisplayName' (
      set d=%%p
      if "!d:~0,4!"=="Java" if not "%%q"=="Auto" msiexec.exe !c! /qn /norestart & ping -n 11 127.0.0.1 > nul
      if "!d:~0,4!"=="J2SE" msiexec.exe !c! /qn /norestart & ping -n 11 127.0.0.1 > nul
   )
)

if '%LocalJavax64Version%'=='Multi' (echo Uninstalling all local versions of Java...) ELSE (echo Uninstalling the local version of Java...)
FOR /F "tokens=1-4" %%n IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^& reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^> nul') DO (

   if '%%n'=='UninstallString' (
     set c=%%q
     set c=!c:/I=/X!
   )

   if '%%n'=='DisplayName' (
      set d=%%p
      if "!d:~0,4!"=="Java" if not "%%q"=="Auto" msiexec.exe !c! /qn /norestart & ping -n 11 127.0.0.1 > nul
      if "!d:~0,4!"=="J2SE" msiexec.exe !c! /qn /norestart & ping -n 11 127.0.0.1 > nul
   )
)



::----------- Download the latest java, install, delete the installer.-------
:install
echo Downloading latest version of Java...
set url2=http://javadl.sun.com/webapps/download/GetFile/%RemoteJavaVersionFull%/windows-i586/xpiinstall.exe
curl.exe -s -L -k -o %tmp%\java_inst.exe %url2%
echo Installing latest version of Java...
start /wait %tmp%\java_inst.exe /s REBOOT=Suppress
ping 127.0.0.1 > nul
del %tmp%\java_inst.exe
if not exist "%programfiles(x86)%" echo System is 32 bit. & goto regjava

echo Downloading latest version of Java x64...
set url2=https://edelivery.oracle.com/otn-pub/java/jdk/8u%RemoteJavaVersionFull:~6%/jre-8u%RemoteJavaVersionFull:~6,2%-windows-x64.exe
curl -s -L -H "Cookie: oraclelicense=accept-securebackup-cookie" -k -o %tmp%\java_inst.exe %url2%
echo Installing latest version of Java x64...
start /wait %tmp%\java_inst.exe /s REBOOT=Suppress
ping 127.0.0.1 > nul
del %tmp%\java_inst.exe

:regjava
Reg.exe add "HKLM\SOFTWARE\JavaSoft" /v "SPONSORS" /t REG_SZ /d "DISABLE" /f
Reg.exe add "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v "EnableJavaUpdate" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v "NotifyDownload" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v "EnableAutoUpdateCheck" /t REG_DWORD /d "0" /f
if not exist "%programfiles(x86)%" echo System is 32 bit. & goto finished
Reg.exe add "HKLM\SOFTWARE\Wow6432Node\JavaSoft" /v "SPONSORS" /t REG_SZ /d "DISABLE" /f
Reg.exe add "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" /v "EnableJavaUpdate" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" /v "NotifyDownload" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" /v "EnableAutoUpdateCheck" /t REG_DWORD /d "0" /f

::----------- Up to date ----------------------------------------------------
:finished
echo Your Java is up to date.
echo.


::----------- There was an error---------------------------------------------
goto noerror
:error
echo There was a network error. Please try again.
:noerror

endlocal
FOR /L %%n IN (1,1,10) DO ping -n 2 127.0.0.1 > nul & <nul set /p =.
