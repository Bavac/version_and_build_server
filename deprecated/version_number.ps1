# Will get build number, verify and set version number

## Example usage: check_version_number.ps1 -Version 4.1.1
param([Parameter(Mandatory=$true)][string]$Version);

$type = "application/json";
$body = @{ version_number = $Version } | ConvertTo-Json;
$uri = "http://localhost:3000";
$gamefile = "./Config/DefaultGame.ini"

# Get the build number
try {
    $Response = Invoke-WebRequest -URI $uri -UseBasicParsing -Method GET;

    $ResBuild = ($Response | ConvertFrom-Json).build;

    Write-Output "The build number is $ResBuild";
}
catch {
    Write-Output "Failed to get a response from the server";
    return;
}

# Check that the version number is valid
try {
    $Response = Invoke-WebRequest -URI $uri -UseBasicParsing -ContentType $type -Method POST -Body $body;

    $Json = $Response | ConvertFrom-Json;
    $ResVersion = $Json.version;
    $ResKey = $Json.key;

    Write-Output "The version number $ResVersion is valid with key $ResKey";
}
catch {
    # Will end up here if the webrequest fail either without contact or with a bad request response
    try {
        $Json = $_ | ConvertFrom-Json;
        $ResVersion = $Json.version;
        $ResKey = $Json.key;

        Write-Output "The version number $Version is not valid, the old version number is $ResVersion";
        return;
    }
    catch {
        Write-Output "Failed to get a response from the server";
        return;
    }
}

# Find the version of the engine and set the game version
try {
    $Engine = Get-Content -Path ((Get-Command UE4Editor-Cmd.Exe).Source | Split-Path -parent | Join-Path -ChildPath "UE4Editor.version") | ConvertFrom-Json;
    $EngineMajor = $Engine.MajorVersion;
    $EngineMinor = $Engine.MinorVersion;
    $EnginePatch = $Engine.PatchVersion;

    Write-Output "The engine version is $EngineMajor.$EngineMinor.$EnginePatch";

    $text = Get-Content -Path $gamefile;
    $text -replace '(?<=ProjectVersion=).*', "$Version-$ResBuild+$EngineMajor.$EngineMinor.$EnginePatch" | Set-Content -Path $gamefile;
    
    Write-Output "The version number was set to $Version-$ResBuild+$EngineMajor.$EngineMinor.$EnginePatch";
} catch {
    Write-Output "Failed to find the engine version or to set the version of the game";
    return;
}

$env:Version = $Version;
$env:Key = $ResKey;
