echo "Setting up knife profile.."
cat ${knife_profile} >> ~/.chef/credentials
knife config use-profile ${knife_profile_name}
knife ssl fetch
