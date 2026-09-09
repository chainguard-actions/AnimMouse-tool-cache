$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Write-Host ::group::Adding $env:folder_name tool cache folder to path
$safe_folder_name = $env:folder_name -replace '[\r\n]', ''
Add-Content $env:GITHUB_PATH "$env:RUNNER_TOOL_CACHE\$safe_folder_name"
Write-Host ::endgroup::
