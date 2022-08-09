@echo off
setlocal

if %1.==. (
  echo Usage: mkproj [options] ^<project name^>
  echo. 
  echo The slash ^(/^) can be replaced by a dash ^(-^), but they cannot be mixed.
  echo ^(All options must use either the slash or the dash^)
  echo.
  echo Project type options:
  echo.  /c       - Generate a C/C++ project
  echo.  /py      - Generate a Python project
  echo.  /js      - Generate a JavaScript project
  echo.  If none of the above are specified, a generic project is created.
  echo. 
  echo Language-specific options:
  echo.  Python:
  echo.    /novenv - Do not create a virtual environment
  echo.  JavaScript:
  echo.    /nonpm - Do not initialise a NPM package for the project
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
  echo.  /force  - Override existing project on name conflict
  echo.  /v      - Print additional information
  echo.  /update - Check for updates
  echo. 
  echo Some of these options may be provided by a config.txt file located in AppData\qeaml\mkproj
  echo Your config.txt is located at:
  echo %AppData%\qeaml\mkproj\config.txt
  echo. 
  echo You are using mkproj v1.0
  echo.
  goto :Terminate
)

set firstarg=%1
set switch=%firstarg:~0,1%

if %switch% NEQ / if %switch% NEQ - set switch=/

set name=
set type=

set license=none
set editor=

set git=yes
set edit=no

set force=no
set verbose=no
set update=no

set venv=yes
set npm=yes
set build=none

@REM Load default settings
if exist %AppData%\qeaml\mkproj\config.txt (
for /f "eol=# tokens=*" %%l in (%AppData%\qeaml\mkproj\config.txt) do (
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
  if %%a==%switch%c (
    set type=C
  ) else if %%a==%switch%py (
    set type=Python
  ) else if %%a==%switch%js (
    set type=JS
  
  @REM Git-related
  ) else if %%a==%switch%nogit (
    set git=no

  @REM Language-specific
  ) else if %%a==%switch%novenv (
    set venv=no
  ) else if %%a==%switch%nonpm (
    set npm=no
  ) else if %%a==%switch%cl (
    set build=cl
  ) else if %%a==%switch%clang (
    set build=clang
  ) else if %%a==%switch%gcc (
    set build=gcc

  @REM Licenses
  ) else if %%a==%switch%bsd3 (
    set license=bsd3
  ) else if %%a==%switch%mit (
    set license=mit
  
  @REM Overrides
  ) else if %%a==%switch%edit (
    set edit=yes
  ) else if %%a==%switch%force (
    set force=yes
  ) else if %%a==%switch%v (
    set verbose=yes
  ) else if %%a==%switch%update (
    set update=yes
  
  @REM Editors
  ) else if %%a==%switch%codium (
    set editor=codium
  ) else if %%a==%switch%code (
    set editor=code
  
  @REM Default - project name
  ) else (
    set name=%%a
  )
)

if %name%.==. (
  echo No project name was specified. Terminating.
  goto :Terminate
)

if %type%.==. (
  echo No project type was specified. Using default.
  set type=Generic
)

if %verbose%==yes (
  echo ----------------------------------------
  echo Project Information
  echo ----------------------------------------
  echo Name: %name%
  echo Type: %type%
  echo License: %license%
  echo Overwrite existing project? %force%
  echo Create Git repository? %git%
  echo Edit after creating? %edit%
  echo Editor: %editor%
  echo Check for updates? %update%
  if %type%==Python (
    echo Create venv? %venv%
  )
  if %type%==C (
    echo Build script: %build%
  )
  echo ----------------------------------------
)

if %update%==yes (
  call :CheckUpdate
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

if %git%==yes (
  git init %name% >NUL
) else (
  mkdir %name%
)

cd %name%

if %license%==none (
  echo.
) else (
  if exist %AppData%\qeaml\mkproj\licenses\%license%.txt (
    copy %AppData%\qeaml\mkproj\licenses\%license%.txt .\LICENSE >NUL
    echo Make sure to edit the LICENSE file to replace [year] and [name]!
  ) else (
    echo An inexistent license ^(%license%^) has been specified. Not creating the LICENSE file.
  )
)

echo # %name% >README.md
echo This project currently lacks a description >>README.md
echo. >>README.md
echo Generated using mkproj >>README.md

mkdir src target

echo target/* >.gitignore

call :Make%type%

goto :Finish

:MakeGeneric
exit /b 0

:MakeC
mkdir include
if %build%==none (
  echo.
) else (
  copy %AppData%\qeaml\mkproj\scripts\c\build-%build%.bat .\build.bat >NUL
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

:MakeJS
if %npm%==yes (
  echo node_modules/* >>.gitignore
  npm init
)
exit /b 0

:CheckUpdate
set outdated=no
for /f %%l in ('curl -f -s https://raw.githubusercontent.com/qeaml/mkproj/main/VERSION') do (
  for /f "tokens=1 delims=." %%v in ("%%l") do (
    if %%v GTR 1 (
      set outdated=yes
    )
  )
  for /f "tokens=2 delims=." %%v in ("%%l") do (
    if %%v GTR 0 (
      set outdated=yes
    )
)
)

if %outdated%==yes (
  echo A newer version of mkproj is available. Check https://github.com/qeaml/mkproj.
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

:Terminate
endlocal
