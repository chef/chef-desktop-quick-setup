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

variable "macdhost_public_key_path" {
  type = string
  description = "Public key path (relative to terraform's path.root value)"
  default = "../keys/aws_terraform_macdhost.pub"
}

# Path to AWS private key.
variable "private_key_path" {
  type = string
  description = "Private key path (relative to terraform's path.root value)"
  default = "../keys/aws_terraform"
}
variable "macdhost_private_key_path" {
  type = string
  description = "Private key path (relative to terraform's path.root value)"
  default = "../keys/aws_terraform_macdhost"
}

variable "knife_profile_name" {
  type = string
  description = "Name of the profile for the server"
  default = "cdqs-profile"
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

variable "macdhost_vpc_region" {
  type = string
  description = "VPC region for mac metal instances"
  validation {
    condition = contains(["us-east-1", "us-east-2", "us-west-2", "eu-west-1", "ap-southeast-1"], var.macdhost_vpc_region)
    error_message = "Unsupported region for mac instances."
  }
}

variable "macdhost_availability_zone" {
  type = string
  description = "Availability zone for mac metal instances"
}

variable "macdhost_id" {
  type = string
  description = "mac dedicated host id"
}