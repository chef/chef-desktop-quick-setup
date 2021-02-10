echo "Setting up knife profile.."
cat ${knife_profile} >> ~/.chef/credentials
knife config use-profile ${knife_profile_name}
knife ssl fetch

echo "Setting up policy.."
cd ~/.chef/cookbooks/desktop-config-lite
chef update
chef push ${policy_name} 'Policyfile.rb'

rm ${knife_profile}