#!/usr/bin/env pwsh
[CmdletBinding()]
Param(
    $ApiGatewayUrl = "https://cv-dev-api.az.macro-c.com/"
)

# Variables
$relativePathToJavascriptFile = "./website/script.js"

try{
    # Read Javascript file and replace the API Gateway URL
    $jsScript = (Get-Content -Path $relativePathToJavascriptFile) -replace "const url = '.*?'", "const url = '$($ApiGatewayUrl)'"
}
catch {
    Write-Host "An error occurred reading the file: $_"
}

try {
    # Modify the Javascript file
    $jsScript | Set-Content -Path $relativePathToJavascriptFile
}
catch {
    Write-Host "An error occurred writing to the file: $_"
}