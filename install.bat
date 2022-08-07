@echo off
setlocal

echo Make sure you're using a Command Prompt with administrative privilleges before continuing!
set /p confirm=Continue? (y/N) 
if %confirm%==y (
  echo.
) else (
  echo Cancelling.
  goto :Terminate
)

set data=%ProgramData%\qeaml\mkproj

copy /y mkproj.bat %SystemRoot%
mkdir %data%
echo # Enter your configuration here >%data%\config.txt
mkdir %data%\licenses
mkdir %data%\scripts\c
copy /y licenses\* %data%\licenses
copy /y scripts\c\* %data%\scripts\c

:Terminate
endlocal
