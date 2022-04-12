#!/bin/bash -v

echo "Updating validation key permissions.."
sudo chmod 400 /home/ubuntu/validation.pem

# Run chef client
echo "Bootstrapping node.."
sudo /usr/bin/chef-client -j /etc/chef/first-boot.json

# Remove validation.pem from the node since it would have a client.pem after the first run to authenticate for subsequent runs.
echo "Removing validation key.."
sudo rm /home/ubuntu/validation.pem
