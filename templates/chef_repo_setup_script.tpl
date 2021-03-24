#!/bin/bash

echo "Setting up local chef repo: ${chef_repo_name}"
cd ${cache_path}
chef generate repo ${chef_repo_name}
cd ${chef_repo_name}
git add . && git commit -m "initial commit"

# Install desktop-config-lite cookbook and add default recipe
knife supermarket install desktop-config-lite --cookbook-path ./cookbooks
cat <<-EOF > cookbooks/desktop-config-lite/recipes/default.rb
include_recipe 'desktop-config-lite::macos' if macos?
include_recipe 'desktop-config-lite::windows' if windows?
EOF

# Set up policy
echo "name '${policy_name}'" > Policyfile.rb
cat <<-EOF >> Policyfile.rb

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'desktop-config-lite::default'

# Specify a custom source for a single cookbook:
cookbook 'desktop-config-lite', path: 'cookbooks/desktop-config-lite'
EOF
chef install Policyfile.rb

# Push policy to server
chef update
chef push "${policy_group_name}" "Policyfile.rb"

echo "Successfully completed setting up ${chef_repo_name} with desktop-config-lite cookbook in the run list."
