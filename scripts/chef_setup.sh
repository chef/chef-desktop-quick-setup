#!/bin/bash

install_chef_client() {
  curl -L https://omnitruck.chef.io/install.sh | sudo bash
}

# Download desktop-config-lite cookbook from remote and extract contents inside files/desktop-content-lite.
download_cookbook() {
  local url="https://supermarket.chef.io/cookbooks/desktop-config-lite/download"

  # Resolve redirects and download from URL
  local finalurl=$(curl --silent --location --head --output /dev/null --write-out '%{url_effective}' -- "$url")
  curl --silent $finalurl -o desktop-config-lite.tgz
  # Extract contents
  tar -xvzf ./desktop-config-lite.tgz
  rm ./desktop-config-lite.tgz
}

install_chef_client
cd ~/.chef/cookbooks && download_cookbook
knife cookbook upload desktop-config-lite
