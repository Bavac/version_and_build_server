# Updates the global version number
# This scripts expect the version_number script to have been run, as that sets the enviroment variables

$type = "application/json";
$body = @{ version_number = [Environment]::GetEnvironmentVariable('Version', 'User')
           key = [Environment]::GetEnvironmentVariable('Key', 'User')
        } | ConvertTo-Json;
$uri = "http://localhost:3000";

try {
    $Response = Invoke-WebRequest -URI $uri -UseBasicParsing -ContentType $type -Method PUT -Body $body;

    $ResVersion = ($Response | ConvertFrom-Json).version;

    Write-Output "The new version number is now set to $ResVersion";
}
catch {
    $ResVersion = ($_ | ConvertFrom-Json).version;

    Write-Output "Failed to set the new version number to $Version, the old version number is $ResVersion";
    Throw "Failed to set new version number"
}
