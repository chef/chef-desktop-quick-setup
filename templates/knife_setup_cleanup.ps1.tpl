Write-Host "Restoring local cofiguration.."
# Remove the desktop-config-lite cookbook from local.
Remove-Item C:\Users\$env:USERNAME\.chef\cookbooks\desktop-config-lite -Recurse -Force
<#
The following commands remove the added profile from credentials file by
finding a match using profile name. Then we select 4 lines including
the match after which we exclude that part from the complete content.
The resulting content is then written to the file.
#>
$CredentialsFileContent = Get-Content -Path C:\Users\$env:USERNAME\.chef\credentials
$PatternMatchLineNumber = ($CredentialsFileContent | Select-String -Pattern "[${profile_name}]").LineNumber - 1 # LineNumber is returned as 1 for line at index 0, so we subtract 1
$ContentToRemove = $CredentialsFileContent[$PatternMatchLineNumber..($PatternMatchLineNumber+3)]
$NewContent = Compare-Object $CredentialsFileContent $ContentToRemove | Select-Object -ExpandProperty InputObject
Set-Content -Path C:\Users\$env:USERNAME\.chef\credentials -Value $NewContent