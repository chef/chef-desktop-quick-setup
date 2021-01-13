USER_NAME='rishi'
FIRST_NAME='Rishi'
LAST_NAME='Chawda'
EMAIL='***REMOVED***'
PASSWORD='password'
ORG_SNAME='rchawda'
ORG_FNAME='RChawda Organisation'
CRED_FILE='rchawda-validator.pem'
echo "Updating system packages and installing unzip"
sudo apt-get -qq update
sudo apt-get install -y --no-install-recommends unzip
sudo apt-get clean
echo "Updating max count and dirty expiration limit"
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w vm.dirty_expire_centisecs=20000
echo "Fetching automate"
curl -fsSL https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip -o /tmp/chef-automate_linux_amd64.zip
echo "Preparing for installation"
sudo unzip /tmp/chef-automate_linux_amd64.zip
sudo mv chef-automate /usr/local/bin/
sudo chmod +x /usr/local/bin/chef-automate
echo "Installing automate and infra server"
sudo chef-automate deploy --product automate --product infra-server --product desktop --accept-terms-and-mlsa
echo "Server is up and running. Please log in using these credentials:"
cat /home/vagrant/automate-credentials.toml
echo "Creating user with name ${USER_NAME}"
sudo chef-server-ctl user-create $USER_NAME $FIRST_NAME $LAST_NAME $EMAIL "'$PASSWORD'" --filename $USER_NAME.pem
echo "Creating organisation with name ${ORG_SNAME}, full name - ${ORG_FNAME}"
sudo chef-server-ctl org-create $ORG_SNAME "'$ORG_FNAME'" --association_user $USER_NAME --filename $CRED_FILE
echo "Credentials saved to $CRED_FILE"
echo "Updating server fqdn"
sudo chef-automate config patch config.toml