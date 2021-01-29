# Configure the Docker provider
terraform {
  required_version = "0.14.3"
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

# Container for gorilla repository
resource "azurerm_storage_container" "gorilla_container" {
  name                  = "gorilla-repository"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "upload_files" {
  for_each               = fileset("${path.root}/../files/gorilla-repository", "**/*")
  name                   = each.value
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.gorilla_container.name
  type                   = "Block"
  source                 = "${path.root}/../files/gorilla-repository/${each.value}"
}
