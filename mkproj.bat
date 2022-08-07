@echo off
setlocal

if %1.==. (
  echo Usage: mkproj [options] ^<project name^>
  echo. 
  echo Project type options:
  echo.  /c       - Generate a C/C++ project
  echo.  /py      - Generate a Python project
  echo.  If none of the above are specified, a generic project is created.
  echo. 
  echo Language-specific options:
  echo.  Python:
  echo.    /novenv - Do not create a virtual environment
  echo.  C:
  echo.    /cl    - Use cl.exe build script
  echo.    /clang - Use clang build script
  echo.    /gcc   - Use GCC build script
  echo.    If none of the above are specified, no build script is copied.
  echo. 
  echo Git-related options:
  echo.  /nogit   - Do not initialise Git repository for project
  echo. 
  echo License-related options:
  echo.  /bsd3    - Use the BSD 3-Clause license
  echo.  /mit     - Use the MIT license
  echo.  If none of the above are specified, no LICENSE file is created.
  echo. 
  echo Miscellaneous options:
  echo.  /force   - Override existing project on name conflict
  echo.  /verbose - Print additional information
  echo. 
  echo Some of these options may be provided by a config.txt file located in ^(ProgramData^)\qeaml\mkproj
  echo Your config.txt is located at:
  echo %ProgramData%\qeaml\mkproj\config.txt
  echo. 
  echo You are using mkproj v1.0
  echo.
  goto :Terminate
)

set name=
set type=

set license=none
set editor=

set git=yes
set edit=no

set force=no
set verbose=no

set venv=yes
set build=none

@REM Load default settings
if exist %ProgramData%\qeaml\mkproj\config.txt (
for /f "eol=# tokens=*" %%l in (%ProgramData%\qeaml\mkproj\config.txt) do (
  for /f "tokens=1 delims==" %%k in ("%%l") do (
  for /f "tokens=2 delims==" %%v in ("%%l") do (
    if %%k==editor (
      set editor=%%v
    ) else if %%k==license (
      set license=%%v
    ) else (
      echo Found unknown entry in configuration: %%k
    )
  ))
)
)

for %%a in (%*) do (
  @REM Project types
  if %%a==/c (
    set type=C
  ) else if %%a==/py (
    set type=Python
  
  @REM Git-related
  ) else if %%a==/nogit (
    set git=no

  @REM Language-specific
  ) else if %%a==/novenv (
    set venv=no
  ) else if %%a==/cl (
    set build=cl
  ) else if %%a==/clang (
    set build=clang
  ) else if %%a==/gcc (
    set build=gcc

  @REM Licenses
  ) else if %%a==/bsd3 (
    set license=bsd3
  ) else if %%a==/mit (
    set license=mit
  
  @REM Overrides
  ) else if %%a==/edit (
    set edit=yes
  ) else if %%a==/force (
    set force=yes
  ) else if %%a==/verbose (
    set verbose=yes
  
  @REM Editors
  ) else if %%a==/codium (
    set editor=codium
  ) else if %%a==/code (
    set editor=code
  
  @REM Default - project name
  ) else (
    set name=%%a
  )
)

if %verbose%==yes (
  echo Project Information
  echo ----------------------------------------
  echo Name: %name%
  echo Type: %type%
  echo License: %license%
  echo Overwrite existing project? %force%
  echo Create Git repository? %git%
  echo Edit after creating? %edit%
  echo Editor: %editor%
  if %type%==Python (
    echo Create venv? %venv%
  )
  if %type%==C (
    echo Build script: %build%
  )
  echo ----------------------------------------
)

if %name%.==. (
  echo No project name was specified. Terminating.
  goto :Terminate
)

if %type%.==. (
  echo No project type was specified. Using default.
  set type=Generic
)

if exist %name% (
  echo A project with the name `%name%` already exists.
  if %force%==yes (
    echo Removing it.
    rmdir /s/q %name%
  ) else (
    echo Terminating.
    goto :Terminate
  )
)

call :Base
call :Make%type%
call :Finish
goto :Terminate

:Base
if %git%==yes (
  git init %name% >NUL
) else (
  mkdir %name%
)
cd %name%
if %license%==none (
  echo.
) else (
  copy %ProgramData%\qeaml\mkproj\licenses\%license%.txt .\LICENSE >NUL
  echo Make sure to edit the LICENSE file to replace [year] and [name]!
)
echo # %name% >README.md
mkdir src target
echo target/* >.gitignore
exit /b 0

:MakeGeneric
exit /b 0

:MakeC
mkdir include
if %build%==none (
  echo.
) else (
  copy %ProgramData%\qeaml\mkproj\scripts\c\build-%build%.bat .\build.bat >NUL
  echo If you intended on using the provided build script, make sure to create a build.txt file to tell it what to build!
)
exit /b 0

:MakePython
echo # Put package requirements here! >requirements.txt
if %venv%==yes (
  echo Creating virtual environment. This may take a couple seconds.
  py -m venv venv
  echo Done.
)
exit /b 0

:Finish
if %edit%==yes (
  if %editor%.==. (
    echo The /edit option was provided, but no editor was specified. Specify an editor using an appropriate option or the config.txt file.
  ) else (
    %editor% .
  )
)
exit /b 0

:Log
if %verbose%==yes (
  echo %~1
)
exit /b 0

:Terminate
endlocal
