## Example usage: check_version_number.ps1 -Version 4.1.1
param([Parameter(Mandatory=$true)][string]$Version);

$type = "application/json";
$body = @{ version_number = $Version } | ConvertTo-Json;
$uri = "http://localhost:3000";

try {
    $Response = Invoke-WebRequest -URI $uri -UseBasicParsing -ContentType $type -Method POST -Body $body;

    $Json = $Response | ConvertFrom-Json;
    $ResVersion = $Json.version;
    $ResKey = $Json.key;

    # Write-Output "The version number $ResVersion is valid with key $ResKey";

    return $ResVersion, $ResKey;
}
catch {
    # Will end up here if the webrequest fail either without contact or with a bad request response
    try {
        $Json = $_ | ConvertFrom-Json;
        $ResVersion = $Json.version;
        $ResKey = $Json.key;

        # Write-Output "The version number $Version is not valid, the old version number is $ResVersion";

        return $ResVersion, $ResKey;
    }
    catch {
        # Give some return if the webserver did not respond
        # Write-Output "Failed to get a response from the server";

        return -1, -1;
    }
}
