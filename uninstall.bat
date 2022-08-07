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

del /f/q %SystemRoot%\mkproj.bat
rmdir /s/q %ProgramData%\qeaml\mkproj

:Terminate
endlocal
