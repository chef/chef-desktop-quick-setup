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

# Remove lines that introduce a bug on chef-client run for when desktop-config-lite is in run_list
# and remove files that are not required.
Remove-Item -Path .\cookbooks\desktop-config-lite\recipes\mac.yml
Remove-Item -Path .\cookbooks\desktop-config-lite\resources\mac_desktop_screensaver.rb
Set-Content -Path .\cookbooks\desktop-config-lite\recipes\macos.yml -Value (Get-Content -Path .\cookbooks\desktop-config-lite\recipes\macos.yml | Select-String -Pattern 'require_password' -NotMatch)
Set-Content -Path .\cookbooks\desktop-config-lite\recipes\macos.yml -Value (Get-Content -Path .\cookbooks\desktop-config-lite\recipes\macos.yml | Select-String -Pattern 'delay_before_password_prompt' -NotMatch)
Set-Content -Path .\cookbooks\desktop-config-lite\recipes\macos.yml -Value (Get-Content -Path .\cookbooks\desktop-config-lite\recipes\macos.yml | Select-String -Pattern 'action' -NotMatch)
git add .
git commit -m "cleanup code"

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
