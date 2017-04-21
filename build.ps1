Param (
	[Parameter(Mandatory=$True)] [string] $config,
  [Parameter(Mandatory=$True)] [string] $pcre2,
  [Parameter(Mandatory=$True)] [string] $ssl,
  [Parameter(Mandatory=$True)] [string] $llvm,
  [Parameter(Mandatory=$True)] [string] $workingDir,
  [Parameter(Mandatory=$True)] [string] $tag
)
$ErrorActionPreference = "Stop"

$srcDir = "$workingDir\..\build\src"
$bldDir = "$workingDir\src"
$libDir = "$workingDir\lib"

if (-not (Test-Path $srcDir)) { mkdir $srcDir }
if (-not (Test-Path $bldDir)) { mkdir $bldDir }
if (-not (Test-Path $libDir)) { mkdir $libDir }

# LLVM
$llvmLibDir = "${libDir}\LLVM-${llvm}-${config}"

if (-not (Test-Path $llvmLibDir))
{
  $llvmSrc = "${srcDir}\llvm-${llvm}.src"
  $llvmBuild = "${bldDir}\llvm-${llvm}.build.${config}"

  if (-not (Test-Path $llvmSrc))
  {
    Write-Output "Obtaining LLVM $llvm"
    $llvmTar = "${srcDir}\LLVM-${llvm}.tar"
    $llvmZip = "$llvmTar.xz"
    if (-not (Test-Path $llvmZip)) { Invoke-WebRequest -TimeoutSec 300 -Uri "http://releases.llvm.org/${llvm}/llvm-${llvm}.src.tar.xz" -OutFile $llvmZip }
    7z.exe x -y $llvmZip "-o$srcDir"
    if ($LastExitCode -ne 0) { throw "error" }
    7z.exe x -y $llvmTar "-o$srcDir"
    if ($LastExitCode -ne 0) { throw "error" }
  }

  Write-Output "Building LLVM $llvm $config in $llvmBuild"
  if (-not (Test-Path $llvmBuild)) { mkdir $llvmBuild }
  Set-Location -Path $llvmBuild
  
  cmake.exe $llvmSrc -G "Visual Studio 14 2015 Win64" -DCMAKE_INSTALL_PREFIX="${llvmLibDir}" -DCMAKE_BUILD_TYPE="$config" -DCMAKE_CXX_FLAGS="/MP" -DCMAKE_C_FLAGS="/MP"
  if ($LastExitCode -ne 0) { throw "error" }
  cmake.exe --build . --target install --config "$config"
  if ($LastExitCode -ne 0) { throw "error" }
}

Set-Location -Path $workingDir

# LibreSSL
$sslLibDir = "${libDir}\libressl-${ssl}"

if (-not (Test-Path $sslLibDir))
{
  $sslSrc = "${srcDir}\libressl-${ssl}"
  $sslBuild = "${bldDir}\libressl-${ssl}.build"

  if (-not (Test-Path $sslSrc))
  {
    Write-Output "Obtaining LibreSSL ${ssl}"
    $sslZip = "${srcDir}\libressl-${ssl}.tar.gz"
    if (-not (Test-Path $sslZip)) { Invoke-WebRequest -TimeoutSec 300 -Uri "http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${ssl}.tar.gz" -OutFile $sslZip }
    7z.exe x -y $sslZip "-o$srcDir"
    if ($LastExitCode -ne 0) { throw "error" }
    7z.exe x -y "${srcDir}\libressl-${ssl}.tar" "-o$srcDir"
    if ($LastExitCode -ne 0) { throw "error" }
  }

  Write-Output "Building LibreSSL $ssl"
  if (-not (Test-Path $sslBuild)) { mkdir $sslBuild }
  Set-Location -Path $sslBuild
  (Get-Content "${sslSrc}\CMakeLists.txt").replace('add_definitions(-Dinline=__inline)', "add_definitions(-Dinline=__inline)`nadd_definitions(-DPATH_MAX=255)") | Set-Content "${sslSrc}\CMakeLists.txt"

  cmake.exe $sslSrc -G "Visual Studio 14 2015 Win64" -DCMAKE_INSTALL_PREFIX="${sslLibDir}"
  if ($LastExitCode -ne 0) { throw "error" }
  cmake.exe --build . --target install --config "$config"
  if ($LastExitCode -ne 0) { throw "error" }
}

Set-Location -Path $workingDir

# PCRE2
$pcreLibDir = "${libDir}\pcre2-${pcre2}"

if (-not (Test-Path $pcreLibDir))
{
  $pcreSrc = "${srcDir}\pcre2-${pcre2}"
  $pcreBuild = "${bldDir}\pcre2-${pcre2}.build"

  if (-not (Test-Path $pcreSrc))
  {
    Write-Output "Obtaining PCRE2 ${pcre2}"
    $pcreZip = "${srcDir}\pcre2-${pcre2}.zip"
    if (-not (Test-Path $pcreZip)) { Invoke-WebRequest -TimeoutSec 300 -Uri "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-${pcre2}.zip" -OutFile $pcreZip }
    7z.exe x -y $pcreZip "-o$srcDir"
    if ($LastExitCode -ne 0) { throw "error" }
  }

  Write-Output "Building PCRE2"
  if (-not (Test-Path $pcreBuild)) { mkdir $pcreBuild }
  Set-Location -Path $pcreBuild
  
  cmake.exe $pcreSrc -G "Visual Studio 14 2015 Win64"
  if ($LastExitCode -ne 0) { throw "error" }
  cmake.exe --build . --target pcre2-8 --config "$config"
  if ($LastExitCode -ne 0) { throw "error" }

  mkdir $pcreLibDir
  Copy-Item "${config}\pcre2-8*.lib" -Destination $pcreLibDir
}

Set-Location -Path $workingDir

$ponyWinLibs = "PonyWinLibs-LLVM-${llvm}-LibreSSL-${ssl}-PCRE2-${pcre2}-${tag}-${config}.zip"
7z.exe a -y -tzip $ponyWinLibs $libDir
if ($LastExitCode -ne 0) { throw "error" }
