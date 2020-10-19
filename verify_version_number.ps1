# Will get build number, verify and set version number in the local file

## Example usage: check_version_number.ps1 -Version 4.1.1
param([Parameter(Mandatory=$true)][string]$Version);

$ErrorActionPreference = "Stop";

$type = "application/json";
$body = @{ version_number = $Version } | ConvertTo-Json;
$uri = "http://localhost:3000";
$gamefile = "./Config/DefaultGame.ini"

# Get the build number
$BuildResponse = Invoke-WebRequest -URI $uri -UseBasicParsing -Method GET;

$ResBuild = ($BuildResponse | ConvertFrom-Json).build;

Write-Output "The build number is $ResBuild";

# Check that the version number is valid
try {
    $VersionResponse = Invoke-WebRequest -URI $uri -UseBasicParsing -ContentType $type -Method POST -Body $body;

    $Json = $VersionResponse | ConvertFrom-Json;
    $ResVersion = $Json.version;
    $ResKey = $Json.key;

    Write-Output "The version number $ResVersion is valid with key $ResKey";
}
catch {
    $Json = $_ | ConvertFrom-Json;
    $ResVersion = $Json.version;
    $ResKey = $Json.key;

    Write-Output "The version number $Version is not valid, the old version number is $ResVersion";
    throw "Invalid version number"
}

# Find the version of the engine and set the game version
$Engine = Get-Content -Path ((Get-Command UE4Editor-Cmd.Exe).Source | Split-Path -parent | Join-Path -ChildPath "UE4Editor.version") | ConvertFrom-Json;
$EngineMajor = $Engine.MajorVersion;
$EngineMinor = $Engine.MinorVersion;
$EnginePatch = $Engine.PatchVersion;

Write-Output "The engine version is $EngineMajor.$EngineMinor.$EnginePatch";

$text = Get-Content -Path $gamefile;
$text -replace '(?<=ProjectVersion=).*', "$Version-$ResBuild+$EngineMajor.$EngineMinor.$EnginePatch" | Set-Content -Path $gamefile;

Write-Output "The version number was set to $Version-$ResBuild+$EngineMajor.$EngineMinor.$EnginePatch";

[Environment]::SetEnvironmentVariable('Version',$Version,'User')
[Environment]::SetEnvironmentVariable('Key',$ResKey,'User')

exit 0;