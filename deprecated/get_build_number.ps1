## Example usage: check_version_number.ps1

$uri = "http://localhost:3000";

try {
    $Response = Invoke-WebRequest -URI $uri -UseBasicParsing -Method GET;

    $ResVersion = ($Response | ConvertFrom-Json).build;

    Write-Output "The build number is $ResVersion";

    exit 0;
    return $ResVersion;
}
catch {
    Write-Output "Failed to get a response from the server";

    exit 1;
}