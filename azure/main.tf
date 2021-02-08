terraform {
  # This module has been written with terraform v0.14.6. To allow future upgrades, setting the supported version to be this or higher.
  required_version = "0.14.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.41.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "automate" {
  source                  = "./modules/automate"
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  resource_location       = var.resource_location
  resource_group_name     = azurerm_resource_group.rg.name
  subnet_id               = azurerm_subnet.subnet.id
  automate_dns_name_label = var.automate_dns_name_label
  automate_credentials    = var.automate_credentials
}

module "munki" {
  source               = "./modules/munki"
  resource_location    = var.resource_location
  storage_account_name = azurerm_storage_account.desktop_storage_account.name
}

module "gorilla" {
  source               = "./modules/gorilla"
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  resource_location    = var.resource_location
  resource_group_name  = azurerm_resource_group.rg.name
  subnet_id            = azurerm_subnet.subnet.id
  storage_account_name = azurerm_storage_account.desktop_storage_account.name
}

# Desktop Flow resource group
resource "azurerm_resource_group" "rg" {
  name     = "DesktopTerraformResourceGroup"
  location = var.resource_location
  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

# DesktopTerraformResourceGroup Virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "DesktopTerraformVirtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.rg.name
}

# DesktopTerraformResourceGroup Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "DesktopTerraformSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network security group and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "DesktopTerraformNetworkSecurityGroup"
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create azure storage account.
resource "azurerm_storage_account" "desktop_storage_account" {
  name                     = var.azure_storage_account
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
