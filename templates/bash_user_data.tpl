#!/bin/bash -v

# Create etc/chef directory, otherwise cat command will fail.
mkdir -p /etc/chef

echo "Installing Chef Client.."
curl -L https://omnitruck.chef.io/install.sh | bash

echo "Creating first-boot.json.."
sudo cat > "/etc/chef/first-boot.json" << EOF
{}
EOF

echo "Creating client.rb.."
sudo cat > '/etc/chef/client.rb' << EOF
log_location            STDOUT
chef_server_url         '${chef_server_url}'
node_name               '${node_name}'
validation_key          '${validation_key_path}/validation.pem'
use_policyfile          true
policy_group 	          '${policy_group}'
policy_name 	          '${policy_name}'
ssl_verify_mode         :verify_none
chef_license            'accept'
EOF
