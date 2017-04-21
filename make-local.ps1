Param (
  [Parameter(Mandatory=$True)] [string] $tag,
  [Parameter(Mandatory=$True)] [string] $gpgKey
)
$ErrorActionPreference = "Stop"

$pcre2 = "10.21"
$ssl = "2.5.0"

Push-Location -Path "$PSScriptRoot"

foreach ($llvm in ("4.0.0", "3.9.1", "3.8.1", "3.7.1"))
{
  foreach ($config in ("Debug", "Release"))
  {
    $workingDir = "$PSScriptRoot\build-llvm-${llvm}-${config}"
    if (-not (Test-Path $workingDir)) { mkdir $workingDir }

    & "$PSScriptRoot\build.ps1" -config $config -pcre2 $pcre2 -ssl $ssl -llvm $llvm -workingDir $workingDir -tag $tag  
    if ($LastExitCode -ne 0) { throw "error" }

    Move-Item "$workingDir\*.zip" $PSScriptRoot
  }
}

Set-Location -Path "$PSScriptRoot"
Get-ChildItem "$PSScriptRoot" -Filter *.zip |
Foreach-Object 
{
  gpg.exe -u "$gpgKey" --armor --detach-sig $_.FullName 
}

Pop-Location
