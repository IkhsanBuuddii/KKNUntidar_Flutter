@echo off
REM Copies drawable and mipmap resources from Android project into flutter assets
SET SRC=..\kknuntidar-app\src\main\res
SET DST=assets

IF NOT EXIST "%DST%" mkdir "%DST%"

for %%d in (drawable drawable-*) do (
  if exist "%SRC%\%%d" (
    xcopy /E /I ""%SRC%\%%d"" "%DST%\%%d\" > nul
  )
)

for %%m in (mipmap-* mipmap-anydpi) do (
  if exist "%SRC%\%%m" (
    xcopy /E /I ""%SRC%\%%m"" "%DST%\%%m\" > nul
  )
)

echo Asset copy finished. Review "%DST%" and update `pubspec.yaml` if needed.
pause
