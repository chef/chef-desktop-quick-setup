terraform {
  # This module has been written with terraform v0.14.3. To allow future upgrades, setting the supported version to be this or higher.
  required_version = ">= 0.14.3"
}

module "automate" {
  source = "./modules/automate"
  admin_username = var.admin_username
  admin_password = var.admin_password
  resource_location = var.resource_location
}

module "munki" {
  source = "./modules/munki"
  resource_location = var.resource_location
}