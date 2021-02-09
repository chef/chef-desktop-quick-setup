echo "Adding to known hosts.." #Bypass the user interaction required if we skip this step.
ssh-keyscan ${server_ip} >> ~/.ssh/known_hosts
echo "Fetching automate credentials file.." #Since credential file is not accessible through default user, try ssh to capture in local.
ssh -i ${ssh_key} ${user_name}@${server_ip} "sudo cat ~/automate-credentials.toml" > ${local_path}/automate-credentials.toml
#Get client and validator keys from the server.
echo "Fetching client key.."
scp -i ${ssh_key} ${user_name}@${server_ip}:/home/${user_name}/${client_name}.pem ${local_path}/${client_name}.pem
echo "Fetching validator key.."
scp -i ${ssh_key} ${user_name}@${server_ip}:/home/${user_name}/validator.pem ${local_path}/validator.pem