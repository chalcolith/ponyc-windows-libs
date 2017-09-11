Param (
  [Parameter(Mandatory=$True)] [string] $tag
#  ,[Parameter(Mandatory=$True)] [string] $gpgKey
)
$ErrorActionPreference = "Stop"

$pcre2 = "10.30"
$ssl = "2.6.1"

Push-Location -Path "$PSScriptRoot"

foreach ($llvm in ("5.0.0", "4.0.1", "3.9.1", "3.8.1", "3.7.1"))
{
  foreach ($config in ("Debug", "Release"))
  {
    $workingDir = "$PSScriptRoot\build-llvm-${llvm}-${config}"
    if (-not (Test-Path $workingDir)) { mkdir $workingDir }

    & "$PSScriptRoot\build.ps1" -config $config -pcre2 $pcre2 -ssl $ssl -llvm $llvm -workingDir $workingDir -tag $tag
    if ($LastExitCode -ne 0) { throw "error" }

    $packageDir = "$PSScriptRoot\packages"
    if (-not (Test-Path $packageDir))
    {
      mkdir $packageDir
    }
    Move-Item "$workingDir\*.zip" $packageDir
  }
}

Set-Location -Path "$PSScriptRoot"
# Get-ChildItem "$PSScriptRoot" -Filter *.zip |
# Foreach-Object
# {
#   gpg.exe -u "$gpgKey" --armor --detach-sig $_.FullName
# }

# Pop-Location
