# Install chef client
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install

# Create first-boot.json
Set-Content -Path C:\chef\first-boot.json -Value @"
{}
"@

# Create client.rb
Set-Content -Path c:\chef\client.rb -Value @"
log_location            STDOUT
chef_server_url         '${chef_server_url}'
node_name               '${node_name}'
validation_key          'C:\chef\validation.pem'
use_policyfile          true
policy_group 	          '${policy_group}'
policy_name 	          '${policy_name}'
ssl_verify_mode         :verify_none
chef_license            'accept'
"@
