variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
}

variable "bucket" {
  type        = string
  description = "Name of the bucket containing munki repository"
}

variable "macos_nodes" {
  type        = any
  description = "Elastic IPs for macos nodes for ssh connection."
  default     = []
}

# Path to AWS private key.
variable "private_key_path" {
  type        = string
  description = "Private key path"
}

variable "bucket_domain_name" {
  type        = string
  description = "URL to the bucket"
}

variable "munki_setup_depends_on" {
  type        = any
  description = "Resource dependencies for munki setup"
  default     = []
}
