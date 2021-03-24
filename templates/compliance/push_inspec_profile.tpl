cd ${repo_path}
inspec check ${inspec_profile_name}
echo "Authenticating.."
inspec compliance login "${automate_server_url}" --user='admin' --token=$(cat ${path_to_keys}/compliance-token) --insecure
echo "Uploading inspec profile: ${inspec_profile_name}"
inspec compliance upload ${inspec_profile_name}
