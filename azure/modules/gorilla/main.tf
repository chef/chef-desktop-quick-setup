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

# Container for gorilla repository
resource "azurerm_storage_container" "gorilla_container" {
  name                  = "gorilla-repository"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "upload_catalog" {
  name                   = "catalogs/example.yaml"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.gorilla_container.name
  type                   = "Block"
  source                 = "${path.module}/catalog.yaml"
}
resource "azurerm_storage_blob" "upload_manifest" {
  name                   = "manifests/example.yaml"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.gorilla_container.name
  type                   = "Block"
  source                 = "${path.module}/manifest.yaml"
}
