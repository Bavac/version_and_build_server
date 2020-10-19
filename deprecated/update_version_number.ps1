## Example usage: check_version_number.ps1 -Version 4.1.1
param([Parameter(Mandatory=$true)][string]$Version,[Parameter(Mandatory=$true)][string]$Key);

$type = "application/json";
$body = @{ version_number = $Version
           key = $key
        } | ConvertTo-Json;
$uri = "http://localhost:3000";

try {
    $Response = Invoke-WebRequest -URI $uri -UseBasicParsing -ContentType $type -Method PUT -Body $body;

    $ResVersion = ($Response | ConvertFrom-Json).version;

    Write-Output "The new version number is now set to $ResVersion";
}
catch {
    try {
        $ResVersion = ($_ | ConvertFrom-Json).version;

        Write-Output "Failed to set the new version number to $Version, the old version number is $ResVersion";

        exit 1;
    }
    catch {
        Write-Output "Failed to get a response from the server";

        exit 1;
    }
}
