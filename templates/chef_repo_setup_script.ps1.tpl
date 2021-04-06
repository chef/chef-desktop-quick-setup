Write-Host "Setting up local chef repo: ${chef_repo_name}"
Set-Location ${cache_path}
chef generate repo ${chef_repo_name}
Set-Location ${chef_repo_name}
git add .
git commit -m "initial commit"

# Install desktop-config-lite cookbook and add default recipe
knife supermarket install desktop-config-lite --cookbook-path .\cookbooks

New-Item -ItemType File -Path .\cookbooks\desktop-config-lite\recipes\default.rb
Add-Content -Path .\cookbooks\desktop-config-lite\recipes\default.rb -Value "include_recipe 'desktop-config-lite::macos' if macos?"
Add-Content -Path .\cookbooks\desktop-config-lite\recipes\default.rb -Value "include_recipe 'desktop-config-lite::windows' if windows?"

# Set up policy
New-Item -ItemType File -Path Policyfile.rb
Add-Content -Path Policyfile.rb -Value @"
name '${policy_name}'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'desktop-config-lite::default'

# Specify a custom source for a single cookbook:
cookbook 'desktop-config-lite', path: 'cookbooks/desktop-config-lite'
"@

chef install Policyfile.rb

# Push policy to server
chef update
chef push "${policy_group_name}" "Policyfile.rb"

Write-Host "Successfully completed setting up ${chef_repo_name} with desktop-config-lite cookbook in the run list."
