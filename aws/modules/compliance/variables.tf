variable "inspec_profile_name" {
  type = string
  description = "Name of the inspec profile"
  default = "cdqs-inspec-profile"
}

variable "chef_repo_name" {
  type = string
  description = "Name of the local chef repo"
}

variable "automate_server_url" {
  type = string
  description = "Automate server URL"
}

variable "automate_server_public_ip" {
  type = string
  description = "Automate server public IP"
}

# Path to AWS private key.
variable "private_key_path" {
  type = string
  description = "Private key path"
}

variable "private_ppk_key_path" {
  type = string
  description = "Private key path for PuTTY connection (relative to terraform's path.root value)"
}

variable "policy_group_name" {
  type = string
  description = "Name of the policy to create on server"
}

# Admin username and password for automate server machine
variable "admin_username" {
  type        = string
  description = "Admin username for automate server"
}

variable "compliance_depends_on" {
 type = any
 description = "Dependency on automate server setup" 
}
