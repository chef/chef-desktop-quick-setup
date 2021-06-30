variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
}

variable "bucket" {
  type        = string
  description = "Name of the bucket containing gorilla repository"
}

variable "bucket_domain_name" {
  type        = string
  description = "URL to the bucket"
}

variable "windows_nodes" {
  type        = any
  description = "Windows nodes to configure with Gorilla client"
  default     = []
}

variable "admin_password" {
  type        = string
  description = "Administrator password for windows nodes"
}
