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

variable "allow_ssh" {
  type        = string
  description = "Security group ID for allow_ssh rule"
}

variable "allow_rdp" {
  type        = string
  description = "Security group ID for allow_win_rdp_connection rule"
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
  default = "t2.micro"
}

variable "chef_server_url" {
  type = string
  description = "Public url of the automate server"
}

variable "node_depends_on" {
  type = any
  description = "Resource dependencies for nodes."
  default = []
}