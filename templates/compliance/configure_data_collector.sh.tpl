#!/bin/bash

echo "data_collector['server_url'] = \"https://${automate_server_url}/data-collector/v0\"" | sudo tee -a /etc/chef/client.rb
echo "data_collector['token'] = \"${api_token}\"" | sudo tee -a /etc/chef/client.rb
sudo /usr/local/bin/chef-client