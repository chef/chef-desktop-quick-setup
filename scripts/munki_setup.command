#!/bin/bash

COMMAND_SCRIPT_PATH="`dirname $0`"

configure_munki_repository() {
  echo "Resuming munki repository setup.."
  # Clean up auto launch
  sudo rm /var/run/resume-munkitools-configuration
  # sed -i "Users/rchawda/chef/desktop-dev-setup-terraform/scripts/munki_setup.sh" ~/.zshrc
  # sed -i "Users/rchawda/chef/desktop-dev-setup-terraform/scripts/munki_setup.sh" ~/.bashrc

  echo "Serving local munki repository through apache.."
  chmod -R a+rX $COMMAND_SCRIPT_PATH/../files/munki-repository
  sudo ln -s $COMMAND_SCRIPT_PATH/../files/munki-repository /Library/WebServer/Documents
  sudo apachectl stop
  sudo apachectl start

  echo "Configuring munki repository.."
  /usr/local/munki/munkiimport --configure

  echo "Importing application into munki repository.."
  /usr/local/munki/munkiimport $COMMAND_SCRIPT_PATH/../files/googlechrome.dmg
  echo "Generating a manifest file.."
  /usr/local/munki/manifestutil

  echo "Stopping apache server and performing clean up.."
  sudo apachectl stop
  sudo rm /Library/WebServer/Documents/munki-repository
}

download_and_install_munkitools() {
  echo "Fetching and installing munkitools.."
  # Download munkitools from github releases
  curl -fsSL https://github.com/munki/munki/releases/download/v5.2.2/munkitools-5.2.2.4287.pkg -o /tmp/munkitools.pkg
  # Install munki tools to Macintosh HD
  sudo installer -pkg /tmp/munkitools.pkg -target /

  # echo "System will restart soon.. Setting up runs for post restart.."
  # Creating a flag file. We will check wether this exists on restart.
  sudo touch /var/run/resume-munkitools-configuration
  # echo "Users/rchawda/chef/desktop-dev-setup-terraform/scripts/munki_setup.sh" >> ~/.zshrc
  # echo "Users/rchawda/chef/desktop-dev-setup-terraform/scripts/munki_setup.sh" >> ~/.bashrc

  # echo "Restarting machine.."
  # sudo shutdown -r now

  echo "Munkitools has been installed. Please restart the machine and run the script again to continue the setup."
}

uninstall_munkitools_and_remove_cache() {
  sudo sh -c '
  launchctl unload /Library/LaunchDaemons/com.googlecode.munki.*
  rm -rf "/Applications/Utilities/Managed Software Update.app"
  rm -rf "/Applications/Managed Software Center.app"
  rm -f /Library/LaunchDaemons/com.googlecode.munki.*
  rm -f /Library/LaunchAgents/com.googlecode.munki.*
  rm -rf "/Library/Managed Installs"
  rm -f /Library/Preferences/ManagedInstalls.plist
  rm -rf /usr/local/munki
  rm /etc/paths.d/munki
  pkgutil --forget com.googlecode.munki.admin
  pkgutil --forget com.googlecode.munki.app
  pkgutil --forget com.googlecode.munki.core
  pkgutil --forget com.googlecode.munki.launchd
  pkgutil --forget com.googlecode.munki.app_usage
  pkgutil --forget com.googlecode.munki.python
  '
}

start_munki_repository_setup() {
  if [ ! -f /var/run/resume-munkitools-configuration ]; then
    download_and_install_munkitools
  else
    configure_munki_repository
  fi
}

start_munki_repository_setup
# uninstall_munkitools_and_remove_cache