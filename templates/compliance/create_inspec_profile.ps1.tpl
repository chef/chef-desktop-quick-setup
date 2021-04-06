Set-Location ${repo_path}
inspec init profile ${inspec_profile_name}
Copy-Item -Force ..\inspec.yml ${inspec_profile_name}\inspec.yml
Remove-Item ${inspec_profile_name}\controls\example.rb
