## Example usage: test.ps1 -Version 4.1.1
param([Parameter(Mandatory=$true)][string]$Version);

$type = "application/json";
$body = @{ version_number = $Version } | ConvertTo-Json;

try {
    $Response = Invoke-WebRequest http://localhost:3000 -ContentType $type -Method POST -Body $body;

    $ResVersion = ($Response | ConvertFrom-Json).version;

    Write-Output "The new version number is now set to $ResVersion";

    exit 0;
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
