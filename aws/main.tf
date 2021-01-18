terraform {
  # This module has been written with terraform v0.14.3. To allow future upgrades, setting the supported version to be this or higher.
  required_version = ">= 0.14.3"
}

module "automate" {
  source = "./modules/automate"
}

module "munki" {
  source = "./modules/munki"
}

module "gorilla" {
  source = "./modules/gorilla"
}
