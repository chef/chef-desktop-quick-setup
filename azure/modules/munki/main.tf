# Configure the Docker provider
terraform {
  required_version = "0.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.41.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.9.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a container
# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }

# resource "docker_network" "mdn" {
#   name = "MunkiDockerContainer"
# }

# resource "docker_container" "munki" {
#   image = "${docker_image.ubuntu.latest}"
#   name  = "Munki"
#   depends_on = [azurerm_storage_container.munki_container]
#   # networks_advanced {
#   #   name = docker_network.mdn.name
#   # }
#   # command = [
#   #   "tail",
#   #   "-f",
#   #   "/dev/null"
#   # ]
#   provisioner "remote-exec" {
#     inline = [
#       "git clone https://github.com/munki/munki",
#     ]
#     connection {
#       host = docker_container.munki.network_data[0].ip_address
#     }
#   }
# }

# Container for munki repository
resource "azurerm_storage_container" "munki_container" {
  name                  = "munki-repository"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}
