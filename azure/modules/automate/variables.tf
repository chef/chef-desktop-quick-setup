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

variable "automate_dns_name_label" {
  type = string
  description = "Automate DNS name label"
}

variable "automate_credentials" {
  type = object({
    user_name          = string
    user_display_name  = string
    user_email         = string
    user_password      = string
    org_name           = string
    org_display_name   = string
    validator_path     = string
  })
  sensitive = true
  description = "Automate server credentials configuration"
}
