Set-Location ${cache_path}\${chef_repo_name}
Remove-Item -Recurse -Force .\cookbooks\audit

Write-Host "Updating policyfile.."
$PolicyfileContent = Get-Content Policyfile.rb
$UpdatedContent = $PolicyfileContent | ForEach-Object {$_ -replace " ,'audit::default'", ""}
$UpdatedContent = $UpdatedContent | ForEach-Object {$_ -replace "cookbook 'audit', path: 'cookbooks/audit'", ""}
Set-Content -Path Policyfile.rb -Value $UpdatedContent

# Update and push policy
chef update
chef push "${policy_group_name}" "Policyfile.rb"

Write-Host "Successfully completed updating ${chef_repo_name} and removed audit cookbook from the run list."
