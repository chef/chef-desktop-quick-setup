echo "Adding to known hosts.."
ssh-keyscan ${server_ip} >> ~/.ssh/known_hosts
echo "Fetching client key.."
scp -i ${ssh_key} ${user_name}@${server_ip}:/home/${user_name}/${client_name}.pem ${local_path}/${client_name}.pem
echo "Fetching validator key.."
scp -i ${ssh_key} ${user_name}@${server_ip}:/home/${user_name}/validator.pem ${local_path}/validator.pem