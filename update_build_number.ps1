## Updates the global build number, also returns the new build number

$uri = "http://localhost:3000";

$Response = Invoke-WebRequest -URI $uri -UseBasicParsing -Method GET;

$ResBuild = ($Response | ConvertFrom-Json).build;

Write-Output "The build number is $ResBuild";

[Environment]::SetEnvironmentVariable('BuildNumber',$ResBuild,'User')
