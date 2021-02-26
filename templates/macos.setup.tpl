#!/bin/bash -v

# Create etc/chef directory, otherwise cat command will fail.
mkdir -p /etc/chef

echo "Installing Chef Client.."
curl -L https://omnitruck.chef.io/install.sh | bash

echo "Creating first-boot.json.."
cat > "/etc/chef/first-boot.json" << EOF
{
  "run_list": ["desktop-config-lite::default"]
}
EOF

echo "Creating client.rb.."
cat > '/etc/chef/client.rb' << EOF
log_location            STDOUT
chef_server_url         '${chef_server_url}'
node_name               '${node_name}'
ssl_verify_mode         :verify_none
chef_license            'accept'
EOF

cat > '/etc/chef/validation.pem' << EOF
${validator_key}
EOF

# Run chef client
chef-client -j /etc/chef/first-boot.json

# Remove validation.pem from the node since it would have a client.pem after the first run to authenticate for subsequent runs.
rm /etc/chef/validation.pem

# ===================================================================================== #
# Set up munki client ================================================================= #
# ===================================================================================== #

echo "Fetching and installing munkitools.."
# Download munkitools from github releases
curl -fsSL https://github.com/munki/munki/releases/download/v5.2.2/munkitools-5.2.2.4287.pkg -o /tmp/munkitools.pkg

# Install munki tools to Macintosh HD
installer -pkg /tmp/munkitools.pkg -target /

echo "Configuring munki client.."
defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "${munki_repo_url}"
# The bucket object URL seems to have redirection, so we configure munki client to follow https redirects.
defaults write /Library/Preferences/ManagedInstalls FollowHTTPRedirects "https"

echo "Running munki client.."
echo "Checking and downloading updates from remote repository.."
/usr/local/munki/managedsoftwareupdate
# Need to run the command again because the first time runs it only downloads packages.
echo "Installing software updates.."
/usr/local/munki/managedsoftwareupdate --installonly