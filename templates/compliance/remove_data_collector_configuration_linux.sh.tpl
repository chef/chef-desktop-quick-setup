#!/bin/bash

echo "Updating client configuration.."
sudo sed -i '' '/data_collector/d' /etc/chef/client.rb
echo "Successfully completed client configuration update." 
sudo /usr/bin/chef-client
