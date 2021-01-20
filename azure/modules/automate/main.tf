terraform {
  required_version = ">= 0.14.3"
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

# Automate server Public IP
resource "azurerm_public_ip" "automate_public_ip" {
  name                = "DesktopTerraformPublicIPAutomate"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.automate_dns_name_label
}

# Automate server Network Interface
resource "azurerm_network_interface" "automate_nic" {
  name                = "DesktopNetworkInterfaceAutomate"
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "DesktopNetworkInterfaceConfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.automate_public_ip.id
  }
}

# Automate Server
resource "azurerm_linux_virtual_machine" "automate" {
  name                  = "Automate2Server"
  resource_group_name   = var.resource_group_name
  location              = var.resource_location
  # 4vCPUs, 16GB RAM - Based on minimum requirements for Automate server.
  # For more details, visit https://docs.chef.io/automate/system_requirements/
  size                            = "Standard_D4s_v3"
  computer_name                   = "AutomateServer"

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false # Needs to be specified for admin password to work

  network_interface_ids = [azurerm_network_interface.automate_nic.id]

  # Changing public key path is currently disabled and limited to its default value /home/azureadmin/.ssh/authorized_keys due to a known issue in Linux provisioning agent.
  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
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
    Team        = "Chef Desktop"
  }

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_public_ip.automate_public_ip.ip_address
  }

  provisioner "file" {
    content     = templatefile("${path.root}/../templates/automate.config.toml.tpl", { automate_fqdn = azurerm_public_ip.automate_public_ip.fqdn })
    destination = "~/config.toml"
  }

  provisioner "file" {
    content = templatefile("${path.root}/../templates/automate.setup.sh.tpl", {
      user_name         = var.automate_credentials.user_name
      user_display_name = var.automate_credentials.user_display_name
      user_email        = var.automate_credentials.user_email
      user_password     = var.automate_credentials.user_password
      org_name          = var.automate_credentials.org_name
      org_display_name  = var.automate_credentials.org_display_name
      validator_path    = var.automate_credentials.validator_path
    })
    destination = "~/automate.setup.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash ~/automate.setup.sh"]
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.automate_public_ip.name
  resource_group_name = azurerm_linux_virtual_machine.automate.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.automate]
}
