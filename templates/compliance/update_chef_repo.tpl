echo "Setting up audit cookbook inside ${chef_repo_name}"
cd ${cache_path}/${chef_repo_name}
knife supermarket install audit --cookbook-path ./cookbooks
cp -f ${default_attributes_file} ./cookbook/audit/attributes/default.rb

echo "Updating policyfile.."
sed -i '' "/run_list 'desktop-config-lite::default'/ s/$/ ,'audit::default'/" Policyfile.rb
echo "cookbook 'audit', path: 'cookbooks/audit'" >> Policyfile.rb

# Update and push policy
chef update
chef push "${policy_group_name}" "Policyfile.rb"

echo "Successfully completed updating ${chef_repo_name} with audit cookbook in the run list."
