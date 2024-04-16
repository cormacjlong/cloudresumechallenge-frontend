#!/usr/bin/env pwsh
[CmdletBinding()]
Param(
    $ApiGatewayUrl = "https://domain.com/api/"
)

# Variables.
$relativePathToJavascriptFile = "../website/script.js"

try{
    # Read Javascript file and replace the API Gateway URL.
    $jsScript = (Get-Content -Path $relativePathToJavascriptFile) -replace "const url = '.*?'", "const url = '$($ApiGatewayUrl)'"
}
catch {
    Write-Output "An error occurred reading the file: $_"
}

try {
    # Modify the Javascript file.
    $jsScript | Set-Content -Path $relativePathToJavascriptFile
    Write-Output "Updated the API Gateway URL in the Javascript file to: $ApiGatewayUrl"
}
catch {
    Write-Output "An error occurred writing to the file: $_"
}