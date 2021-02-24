# Other useful configuration options
variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
  default     = "ap-south-1"
}

variable "bucket" {
  type = string
  description = "Name of the bucket containing munki repository"
}
