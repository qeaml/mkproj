@echo off
setlocal

if not exist build.txt (
  echo build.txt does not exist, not building.
)

set cc=clang -Iinclude

set debug=no
set clean=no

for %%a in (%*) do (
  if %%a==/debug (
    set debug=yes
  ) else if %%a==/clean (
    set clean=yes
  )
)

if %debug%==yes (
  set cc=%cc% -DDEBUG -Wall -Wpedantic
) else (
  set cc=%cc% -O2
)

if %clean%==yes (
  del /q/f target\*
)

for /f "tokens=*" %%l in (build.txt) do (
  for /f "tokens=1" %%a in ("%%l") do (
  for /f "tokens=1*" %%b in ("%%l") do (
    if %%a==obj (
      %cc% -c %%c
    ) else if %%a==exe (
      %cc% %%c
    ) else (
      echo Unknown compilation type: %%a
    )
  )
  )
)

:Terminate
endlocal