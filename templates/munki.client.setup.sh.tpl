echo "Fetching and installing munkitools.."
# Download munkitools from github releases
curl -fsSL https://github.com/munki/munki/releases/download/v5.2.2/munkitools-5.2.2.4287.pkg -o /tmp/munkitools.pkg

# Install munki tools to Macintosh HD
sudo installer -pkg /tmp/munkitools.pkg -target /

echo "Configuring munki client.."
sudo defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "${munki_repo_url}"
# The bucket object URL seems to have redirection, so we configure munki client to follow https redirects.
sudo defaults write /Library/Preferences/ManagedInstalls FollowHTTPRedirects "https"

echo "Running munki client.."
echo "Checking and downloading updates from remote repository.."
sudo /usr/local/munki/managedsoftwareupdate
# Need to run the command again because the first time runs it only downloads packages.
echo "Installing software updates.."
sudo /usr/local/munki/managedsoftwareupdate --installonly
