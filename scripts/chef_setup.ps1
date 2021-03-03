Write-Host "Setting up cookbook in local.."

# Download desktop-config-lite cookbook from remote and extract contents.
function Get-Cookbook-From-Remote {
  $CookbookURL="https://supermarket.chef.io/cookbooks/desktop-config-lite/download"

  # Resolve redirects and download from URL
  Invoke-WebRequest -Uri $CookbookURL -OutFile $env:TEMP/desktop-config-lite.tgz
  # Extract contents
  tar -xvf $env:TEMP/desktop-config-lite.tgz
  Remove-Item -Path $env:TEMP/desktop-config-lite.tgz
}

function Invoke-Cookbook-Setup {
  Set-Location C:\Users\$env:USERNAME\.chef\cookbooks\desktop-config-lite
  New-Item -Path . -Name Policyfile.rb -ItemType File -Force -Value @"
name 'desktop-config-lite'
run_list 'desktop-config-lite::default'
cookbook 'desktop-config-lite', path: '.'
"@
  New-Item -Path recipes -Name default.rb -ItemType File -Force -Value @"
include_recipe 'desktop-config-lite::macos' if macos?
include_recipe 'desktop-config-lite::windows' if windows?
"@
  chef install Policyfile.rb
}

Set-Location C:\Users\$env:USERNAME\.chef\cookbooks

Get-Cookbook-From-Remote
Invoke-Cookbook-Setup