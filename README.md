# ponyc-windows-libs

Provides a tool to get some libraries needed by Pony on Windows.

The LLVM 3.7 prebuilt binaries for Windows do NOT include the LLVM development tools and libraries. 
Instead, you will have to build and install LLVM 3.7 from source. You will need to make sure that the 
path to LLVM/bin (location of llvm-config) is in your PATH variable.

LLVM recommends using the GnuWin32 unix tools; your mileage may vary using MSYS or Cygwin.

- Install GnuWin32 using the [GetGnuWin32](http://getgnuwin32.sourceforge.net/) tool.
- Install [Python](https://www.python.org/downloads/release/python-351/) (3.5 or 2.7).
- Install [CMake](https://cmake.org/download/).
- Get the LLVM source (currently [3.7.1](http://llvm.org/releases/3.7.1/llvm-3.7.1.src.tar.xz)).
- Make sure you have VS2015 with the C++ tools installed.
- Generate LLVM VS2015 configuration with CMake. You can use the GUI to configure and generate the VS projects; make sure you use the 64-bit generator (**Visual Studio 14 2015 Win64**), and set the `CMAKE_INSTALL_PREFIX` to where you want LLVM to live.
- Build the INSTALL project in the LLVM solution.

Building Pony requires [Premake 5](https://premake.github.io).

- Get the [PreMake 5](https://premake.github.io/download.html#v5) executable.
- Get the [PonyC source](https://github.com/ponylang/ponyc).
- Run `premake5.exe --with-tests --to=..\vs vs2015` to generate the PonyC solution.
- Change the **Character Set** property of each project in the PonyC solution to **Not Set**.
- Build ponyc.sln in Release mode.

In order to run the pony compiler, you'll need a few libraries in your environment (pcre2, libssl, libcrypto). 

There is a third-party utility that will get the libraries and set up your environment:

- Install [7-Zip](http://www.7-zip.org/a/7z1514-x64.exe), make sure it's in PATH.
- Open a **VS2015 x64 Native Tools Command Prompt** (things will not work correctly otherwise!) and run:

```
> git clone git@github.com:kulibali/ponyc-windows-libs.git
> cd ponyc-windows-libs
> .\getlibs.bat
> .\setenv.bat
```

Now you can run the pony compiler and tests:

```
> cd path_to_pony_source
> build\release\testc.exe
> build\release\testrt.exe
> build\release\ponyc.exe -d -s packages\stdlib
> .\stdlib
```
