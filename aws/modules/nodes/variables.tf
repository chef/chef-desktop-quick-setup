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

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "key_name" {
  type        = string
  description = "Key name for AWS"
}

variable "node_count" {
  type = number
  description = "Number of nodes"
}

variable "windows_node_instance_type" {
  default = "t3.large"
}