# Admin username and password for automate server machine
variable "admin_username" {
  type        = string
  description = "Admin username for automate server"
}

variable "admin_password_win_node" {
  type        = string
  description = "Admin password for windows nodes"
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

variable "private_key_path" {
  type = string
  description = "Private key path (relative to terraform's path.root value)"
  default = "../keys/aws_terraform"
}

variable "private_ppk_key_path" {
  type = string
  description = "Private key path for PuTTY connection (relative to terraform's path.root value)"
  default = "../keys/aws_terraform.ppk"
}

variable "knife_profile_name" {
  type = string
  description = "Name of the profile for the server"
  default = "cdqs-profile"
}

variable "policy_group_name" {
  type = string
  description = "Name of the policy to create on server"
  default = "cdqs-policy-group"
}

variable "policy_name" {
  type = string
  description = "Name of the policy to create on server"
  default = "cdqs-policy"
}

variable "bucket_name" {
  type = string
  description = "Name of the bucket containing gorilla repository"
  default = "cdqs-app-mgmt"
}

variable "chef_repo_name" {
  type = string
  description = "Name of the local chef repo"
  default = "cdqs-chef-repo"
}

variable "macos_node_count" {
  type        = number
  description = "Number of macos nodes"
  default     = 0
}
