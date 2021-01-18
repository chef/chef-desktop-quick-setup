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

variable "automate_dns_name_label" {
  type = string
  description = "Automate DNS name label"
}

variable "azure_storage_account" {
  type = string
  description = "Azure storage account to create"
}