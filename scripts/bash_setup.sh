#!/bin/bash -v

echo "Updating validation key permissions.."
sudo chmod 400 /Users/ec2-user/validation.pem

# Run chef client
echo "Bootstrapping node.."
sudo /usr/local/bin/chef-client -j /etc/chef/first-boot.json

# Remove validation.pem from the node since it would have a client.pem after the first run to authenticate for subsequent runs.
echo "Removing validation key.."
sudo rm /Users/ec2-user/validation.pem
