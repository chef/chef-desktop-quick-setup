#!/bin/bash -v

# Create etc/chef directory, otherwise cat command will fail.
mkdir -p /etc/chef

echo "Installing Chef Client.."
curl -L https://omnitruck.chef.io/install.sh | bash

echo "Creating first-boot.json.."
cat > "/etc/chef/first-boot.json" << EOF
{}
EOF

echo "Creating client.rb.."
cat > '/etc/chef/client.rb' << EOF
log_location            STDOUT
chef_server_url         '${chef_server_url}'
node_name               '${node_name}'
use_policyfile          true
policy_group 	          '${policy_group}'
policy_name 	          '${policy_name}'
ssl_verify_mode         :verify_none
chef_license            'accept'
EOF

cat > '/etc/chef/validation.pem' << EOF
${validator_key}
EOF

chmod 400 /etc/chef/validation.pem

# Run chef client
chef-client -j /etc/chef/first-boot.json

# Remove validation.pem from the node since it would have a client.pem after the first run to authenticate for subsequent runs.
rm /etc/chef/validation.pem
