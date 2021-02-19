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

variable "ami_id" {
  type = string
  description = "AMI ID for windows nodes"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "key_name" {
  type        = string
  description = "Key name for AWS"
}

variable "macdhost_id" {
  type = string
  description = "mac dedicated host id"
}

variable "munki_depends_on" {
  type = any
  description = "Dependencies for munki module"
}