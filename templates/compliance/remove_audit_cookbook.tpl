cd ${cache_path}/${chef_repo_name}
rm -rf ./cookbooks/audit

echo "Updating policyfile.."
sed -i '' "s/,'audit::default'//g" Policyfile.rb
sed -i '' "s/cookbook 'audit', path: 'cookbooks\/audit'//g" Policyfile.rb

# Update and push policy
chef update
chef push "${policy_group_name}" "Policyfile.rb"

echo "Successfully completed updating ${chef_repo_name} and removed audit cookbook from the run list."
