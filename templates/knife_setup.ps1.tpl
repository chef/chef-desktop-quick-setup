Write-Host "Setting up knife profile.."
$CredentialsFilePath = "C:\Users\$env:USERNAME\.chef\credentials"

# Keep the -Raw flag to avoid invalid character/encoding errors in Windows.
# If not added, it includes a byte order mark in the file which will make the knife commands fail.
$KnifeProfileContent = Get-Content -Path ${knife_profile} -Raw
Add-Content -Path $CredentialsFilePath -Value $KnifeProfileContent

knife config use-profile ${knife_profile_name}
knife ssl fetch

powershell -ExecutionPolicy Bypass -File ${cookbook_setup_script}

Write-Host "Setting up policy.."
Set-Location C:\Users\$env:USERNAME\.chef\cookbooks\desktop-config-lite
chef update
chef push ${policy_name} 'Policyfile.rb'

Remove-Item ${knife_profile}