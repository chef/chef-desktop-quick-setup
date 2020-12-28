terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Admin username and password for automate server machine
variable "admin_username" {
  type = string
  description = "Admin username for automate server"
}
variable "admin_password" {
  type = string
  description = "Admin password for automate server"
  sensitive = true
}
# Other useful configuration options
variable "resource_location" {
  type = string
  description = "Region/Location for the resources"
  default = "southindia"
}

# Desktop Flow resource group
resource "azurerm_resource_group" "rg" {
  name = "DesktopTerraformResourceGroup"
  location = var.resource_location
  tags = {
    Environment = "Chef Desktop flow"
    Team = "Chef Desktop"
  }
}

# DesktopTerraformResourceGroup Public IP
resource "azurerm_public_ip" "publicip" {
  name = "DesktopTerraformPublicIP"
  location = var.resource_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
}

# DesktopTerraformResourceGroup Virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "DesktopTerraformVirtualNetwork"
  address_space = ["10.0.0.0/16"]
  location = var.resource_location
  resource_group_name = azurerm_resource_group.rg.name
}

# DesktopTerraformResourceGroup Subnet
resource "azurerm_subnet" "subnet" {
  name = "DesktopTerraformSubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

# DesktopTerraformResourceGroup Network Interface
resource "azurerm_network_interface" "nic" {
  name = "DesktopNetworkInterface"
  location = var.resource_location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name = "DesktopNetworkInterfaceConfig"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

# Automate Server
resource "azurerm_linux_virtual_machine" "automate2" {
  name = "Automate2Server"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.resource_location
  network_interface_ids = [azurerm_network_interface.nic.id]
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
  # provisioner "file" {
  #   source = "./automate2/config.sh"
  #   destination = "~/config.sh"
  #   connection {
  #     type     = "ssh"
  #     user     = var.admin_username
  #     password = var.admin_password
  #     host     = azurerm_public_ip.publicip.ip_address
  #   }
  # }
  provisioner "file" {
    source = "./automate2/setup.sh"
    destination = "~/setup.sh"
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.publicip.ip_address
    }
  }
  provisioner "remote-exec" {
    inline = ["/bin/sh ~/setup.sh"]
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.publicip.ip_address
    }
  }
}

# Network security group and rules
resource "azurerm_network_security_group" "nsg" {
  name = "DesktopTerraformNetworkSecurityGroup"
  location = var.resource_location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_linux_virtual_machine.automate2.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.automate2]
}