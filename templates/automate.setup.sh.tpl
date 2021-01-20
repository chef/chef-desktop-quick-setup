#!/bin/sh

init_system() {
  # Update system packages and install unzip
  echo "Updating system packages and installing unzip"
  sudo apt-get -qq update
  sudo apt-get install -y --no-install-recommends unzip
  sudo apt-get clean

  echo "Updating max count and dirty expiration limit"
  sudo sysctl -w vm.max_map_count=262144
  sudo sysctl -w vm.dirty_expire_centisecs=20000
}

start_automate2_with_desktop() {
  # Fetch automate package and install.
  echo "Fetching automate"
  curl -fsSL https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip -o /tmp/chef-automate_linux_amd64.zip

  echo "Preparing for installation"
  sudo unzip /tmp/chef-automate_linux_amd64.zip
  sudo mv chef-automate /usr/local/bin/
  sudo chmod +x /usr/local/bin/chef-automate

  echo "Installing automate and infra server"
  sudo chef-automate deploy --product automate --product infra-server --product desktop --accept-terms-and-mlsa
}

setup_automate_server() {
  init_system
  start_automate2_with_desktop

  local first_name last_name
  read first_name last_name <<< $(echo ${user_display_name} | awk '{print $1; print $NF}')

  # Create user and organisation in the automate server
  echo "Creating user with name ${user_name}"
  sudo chef-server-ctl user-create ${user_name} $first_name $last_name ${user_email} "${user_password}" --filename "${user_name}.pem"
  echo "Creating organisation with name ${org_name}, full name - ${org_display_name}"
  sudo chef-server-ctl org-create ${org_name} "${org_display_name}" --association_user ${user_name} --filename ${validator_path}
  echo "Credentials saved to ${validator_path}"

  # Patch automate server and update the fqdn to be the same as public url of the server.
  sudo chef-automate config patch config.toml

  echo "Server is up and running. Please log in using these credentials:"
  sudo cat ~/automate-credentials.toml
}

setup_automate_server