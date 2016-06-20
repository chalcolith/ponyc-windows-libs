@echo off
echo This script requires GnuWin32 and CMake in your PATH.

if not exist lib mkdir lib

:from_source
if not exist src mkdir src
pushd src

if exist ..\lib\pcre2-8.lib goto ssl
echo ------------------------- PCRE2 -------------------------
:pcre2
set PCRE2=pcre2-10.20
set PCRE2_SRC=%PCRE2%.tar.gz
set PCRE2_BUILD=%PCRE2%.build

if not exist %PCRE2_SRC% wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/%PCRE2_SRC%
if errorlevel 1 goto error

gunzip --stdout %PCRE2_SRC% | tar xf -
if errorlevel 1 goto error

if not exist %PCRE2_BUILD% mkdir %PCRE2_BUILD%
pushd %PCRE2_BUILD%
cmake ..\%PCRE2% -G "Visual Studio 14 2015 Win64"
if errorlevel 1 goto error_pop2

devenv PCRE2.sln /build Release /project pcre2-8.vcxproj /projectconfig Release
if errorlevel 1 goto error_pop2

copy /y Release\pcre2-8.lib ..\..\lib
if errorlevel 1 goto error_pop2
popd

if not exist ..\lib\libssl-32.lib goto ssl
if not exist ..\lib\libcrypto-32.lib goto ssl
goto done
echo ------------------------- LibreSSL ------------------------- 
:ssl
set SSL=libressl-2.1.4-windows
set SSL_BIN=%SSL%.zip

if not exist %SSL_BIN% wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/%SSL_BIN%
if errorlevel 1 goto error

if exist %SSL% goto ssl_copy
unzip -o %SSL_BIN%
if errorlevel 1 goto error

:ssl_copy
copy /y %SSL%\x64\libssl-32.* ..\lib
copy /y %SSL%\x64\libcrypto-32.* ..\lib
if errorlevel 1 goto error

goto done

echo ------------------------- errors -------------------------
:error_pop2
popd
:error
echo aborting!

rem ------------------------- done -------------------------
:done
popd

if not exist lib\pcre2-8.lib echo Failed to build PCRE2-8.LIB
if not exist lib\libssl-32.lib echo Failed to get LIBSSL-32.LIB
if not exist lib\libcrypto-32.lib echo Failed to get LIBCRYPTO-32.LIB

