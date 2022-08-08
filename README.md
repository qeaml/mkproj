# mkproj

**mkproj** is a Batch script for quickly creating new projects based on various
templates.

## Usage

```console
> mkproj
Usage: mkproj [options] <project name>

Project type options:
  /c       - Generate a C/C++ project
  /py      - Generate a Python project
  /js      - Generate a JavaScript project
  If none of the above are specified, a generic project is created.

Language-specific options:
  Python:
    /novenv - Do not create a virtual environment
  JavaScript:
    /nonpm - Do not initialise a NPM package for the project
  C:
    /cl    - Use cl.exe build script
    /clang - Use clang build script
    /gcc   - Use GCC build script
    If none of the above are specified, no build script is copied.

Git-related options:
  /nogit   - Do not initialise Git repository for project

License-related options:
  /bsd3    - Use the BSD 3-Clause license
  /mit     - Use the MIT license
  If none of the above are specified, no LICENSE file is created.

Miscellaneous options:
  /force  - Override existing project on name conflict
  /v      - Print additional information
  /update - Check for updates

Some of these options may be provided by a config.txt file located in AppData\qeaml\mkproj
Your config.txt is located at:
C:\Users\USER\AppData\Roaming\qeaml\mkproj\config.txt

You are using mkproj v1.0

```

## Configuration

mkproj will use some defaults provided by the `%AppData%\qeaml\mkproj\config.txt`
file. Below is an example file with explanations:

```ini
# editor - The editor to use by default. This can be any executable that can
#          accept a directory as an argument. In this example that's VSCodium.
editor=codium
# license - The license to use by default. This has to be one of the provided
#           licenses (from the licensed directory)
license=bsd3
```

## Build Scripts

When using the `/cl`, `/clang` or `/gcc` option, a `build.bat` file is copied
into the root directory of your newly created project.

### Usage

```console
> build [options]
Where options can be any combination of:
  /clean - Clear target directory before building.
  /debug - Compile with the following differences:
    The DEBUG macro is defined.
    Optimizations are disabled.
    Extra warning are emitted.
    Warnings are treated as errors.
```

### `build.txt`

The list of objects and executables to compile is in the `build.txt` file. The
build script will exit early if it doesn't exist.

Below in an example of a `build.txt` file, assuming `cl.exe` is used:

```build.txt
obj src\state.c
obj src\console.c
exe src\main.c target\state.obj target\console.obj
```

This will compile `src\state.c` and `src\console.c` into object files
`target\state.obj` and `target\console.obj` respectively.

Keep in mind that all the text after the `obj`/`exe` are actually compiler
arguments. Therefore, if a specific object or executable needs some option,
whereas others don't, simply specify that option after the source files, as if
you're invoking the compile manually.

For `/clang` and `/gcc` it is preferred to explicitly specify the `-o` option
for each object and executable:

```build.txt
obj src/state.c -o target/state.o
obj src/console.c -o target/console.o
exe src/main.c target/state.o target/console.o -o target/main
```
