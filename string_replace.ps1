## Example usage: string_replace.ps1 -Version 4.1.1
param([Parameter(Mandatory=$true)][string]$Version);

$gamefile = "../Config/DefaultGame.ini"

$text = Get-Content -Path $gamefile
$text -replace '(?<=ProjectVersion=).*', $Version | Set-Content -Path $gamefile
