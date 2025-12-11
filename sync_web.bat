@echo off
rem Sync built Flutter web from flutter_app/build/web to flutter-web
set SCRIPT_DIR=%~dp0
set DEST=%SCRIPT_DIR%flutter-web

rem Prefer the built web output if it exists, otherwise copy the source `web` folder.
set BUILD_SOURCE=%SCRIPT_DIR%flutter_app\build\web
set SRC_SOURCE=%SCRIPT_DIR%flutter_app\web

if exist "%BUILD_SOURCE%" (
  set SOURCE=%BUILD_SOURCE%
) else if exist "%SRC_SOURCE%" (
  set SOURCE=%SRC_SOURCE%
) else (
  echo Neither "%BUILD_SOURCE%" nor "%SRC_SOURCE%" were found.
  exit /b 1
)

rem Create destination if missing
if not exist "%DEST%" mkdir "%DEST%"

rem Use robocopy to mirror. Suppress extra log lines for brevity.
robocopy "%SOURCE%" "%DEST%" /MIR /MT:16 /NFL /NDL /NJH /NJS
if %ERRORLEVEL% GEQ 8 (
  echo Robocopy failed with errorlevel %ERRORLEVEL%.
  exit /b %ERRORLEVEL%
)
echo Sync complete from "%SOURCE%" to "%DEST%".
