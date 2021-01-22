# Admin username and password for automate server machine
variable "admin_username" {
  type        = string
  description = "Admin username for automate server"
}
# Other useful configuration options
variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
  default     = "ap-south-1"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "automate_credentials" {
  type = object({
    user_name         = string
    user_display_name = string
    user_email        = string
    user_password     = string
    org_name          = string
    org_display_name  = string
    validator_path    = string
  })
  sensitive   = true
  description = "Automate server credentials configuration"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "private_key_path" {
  type        = string
  description = "Path to AWS private key pair"
}

variable "key_name" {
  type        = string
  description = "Key name for AWS"
}
