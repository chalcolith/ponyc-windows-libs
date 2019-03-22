Param (
  [Parameter(Mandatory=$True)] [string] $tag # e.g. v1.8.0
  #[Parameter(Mandatory=$True)] [string] $gpgKey,
  #[Parameter(Mandatory=$True)] [string] $gpgPass,
)
$ErrorActionPreference = "Stop"

$pcre2 = "10.32"
$ssl = "2.9.0"

Push-Location -Path "$PSScriptRoot"

foreach ($llvm in ("8.0.0", "7.0.1", "6.0.1", "3.9.1"))
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
# Get-ChildItem "$packageDir" -Filter *.zip | Foreach-Object
# {
#   gpg.exe -u "$gpgKey" --passphrase "$gpgPass" --armor --detach-sig $_.FullName
# }
