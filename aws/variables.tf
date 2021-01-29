# Admin username and password for automate server machine
variable "admin_username" {
  type        = string
  description = "Admin username for automate server"
}

# Region
variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
}

# Availibility zone from the above region.
variable "availability_zone" {
  type        = string
  description = "Availability zone for the resources"
}

# Automate public dns name label.
variable "automate_dns_name_label" {
  type        = string
  description = "Automate DNS name label"
}

# Credentials for automate server. Used for creating user and organisation.
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

# Path to AWS public key.
variable "public_key_path" {
  type = string
  description = "Public key path (relative to terraform's path.root value)"
  default = "../keys/aws_terraform.pub"
}

# Path to AWS private key.
variable "private_key_path" {
  type = string
  description = "Private key path (relative to terraform's path.root value)"
  default = "../keys/aws_terraform"
}