rem @echo off
rem echo This script requires GnuWin32 and CMake in your PATH.

if not exist src mkdir src
pushd src

:pcre2
set PCRE2=pcre2-10.20
set PCRE2_SRC=%PCRE2%.tar.gz
set PCRE2_BUILD=%PCRE2%.build

if exist %PCRE2% goto pcre_unzip
echo wget %PCRE2_SRC%

:pcre_unzip
if not exist %PCRE2_SRC% wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/%PCRE2_SRC%
if errorlevel 1 goto error

gunzip --stdout %PCRE2_SRC% | tar xf -
if errorlevel 1 goto error

if not exist %PCRE2_BUILD% mkdir %PCRE2_BUILD%
pushd %PCRE2_BUILD%
cmake ..\%PCRE2% -G "Visual Studio 14 2015 Win64"
if errorlevel 1 goto error_pcre2
devenv PCRE2.sln /build Release /project pcre2-8.vcxproj /projectconfig Release
if errorlevel 1 goto error_pcre2
copy /y Release\pcre2-8.lib ..\..\lib 
popd

goto done
:error_pcre2
popd
:error
echo aborting

:done
popd
