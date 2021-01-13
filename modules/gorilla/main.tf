# Configure the Docker provider
terraform {
  required_version = ">= 0.14.3"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.41.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# Gorilla server Public IP
resource "azurerm_public_ip" "gorilla_public_ip" {
  name = "DesktopTerraformPublicIPGorilla"
  location = var.resource_location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
}

# Gorilla server Network Interface
resource "azurerm_network_interface" "gorilla_nic" {
  name = "DesktopNetworkInterfaceGorilla"
  location = var.resource_location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name = "DesktopNetworkInterfaceConfig"
    subnet_id = var.subnet_id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.gorilla_public_ip.id
  }
}

resource "azurerm_windows_virtual_machine" "gorilla" {
  name                = "GorillaServer"
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.gorilla_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.gorilla_public_ip.name
  resource_group_name = azurerm_windows_virtual_machine.gorilla.resource_group_name
  depends_on          = [azurerm_windows_virtual_machine.gorilla]
}