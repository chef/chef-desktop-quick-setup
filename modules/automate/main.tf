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

# Automate Server
resource "azurerm_linux_virtual_machine" "automate2" {
  name = "Automate2Server"
  resource_group_name = var.resource_group_name
  location = var.resource_location
  network_interface_ids = [var.network_interface_id]
  # 4vCPUs, 16GB RAM - Based on minimum requirements for Automate server.
  # For more details, visit https://docs.chef.io/automate/system_requirements/
  size = "Standard_D4s_v3"
  admin_username = var.admin_username
  admin_password = var.admin_password
  computer_name = "AutomateServer"
  disable_password_authentication = false # Needs to be specified for admin password to work
  # Changing public key path is currently disabled and limited to its default value /home/azureadmin/.ssh/authorized_keys due to a known issue in Linux provisioning agent.
  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }
  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  tags = {
    Environment = "Chef Desktop flow"
    Team = "Chef Desktop"
  }
  provisioner "file" {
    source = "./modules/automate/setup.sh"
    destination = "~/setup.sh"
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = var.public_ip_address
    }
  }
  provisioner "remote-exec" {
    inline = ["/bin/sh ~/setup.sh"]
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = var.public_ip_address
    }
  }
}

data "azurerm_public_ip" "ip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_linux_virtual_machine.automate2.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.automate2]
}