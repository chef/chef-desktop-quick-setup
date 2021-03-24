cd ${repo_path}
inspec init profile ${inspec_profile_name}
cp -f ../inspec.yml ${inspec_profile_name}/inspec.yml
rm ${inspec_profile_name}/controls/example.rb