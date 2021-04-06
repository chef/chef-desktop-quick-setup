Write-Host "Setting up audit cookbook inside ${chef_repo_name}"
Set-Location ${cache_path}/${chef_repo_name}
knife supermarket install audit --cookbook-path .\cookbooks
Copy-Item -Force ${default_attributes_file} .\cookbooks\audit\attributes\default.rb

Write-Host "Updating policyfile.."
$PolicyfileContent = Get-Content Policyfile.rb
$UpdatedfileContent = $PolicyfileContent | ForEach-Object {
  if($_ -match "run_list 'desktop-config-lite::default'") {
    $_.Insert($_.Length," ,'audit::default'")
  } else {
    $_
  }
}
Set-Content -Path Policyfile.rb -Value $UpdatedfileContent -Force
Add-Content -Path Policyfile.rb -Value "cookbook 'audit', path: 'cookbooks/audit'"

# Update and push policy
chef update
chef push "${policy_group_name}" "Policyfile.rb"

Write-Host "Successfully completed updating ${chef_repo_name} with audit cookbook in the run list."
