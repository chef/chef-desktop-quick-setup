Add-Content -Path C:\chef\client.rb -Value "data_collector['server_url'] = `"https://${automate_server_url}/data-collector/v0`""
Add-Content -Path C:\chef\client.rb -Value "data_collector['token'] = `"${api_token}`""
chef-client