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

variable "resource_group_name" {
  type = string
  description = "Resource group name"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID"
}