variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
  default     = "ap-south-1"
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
