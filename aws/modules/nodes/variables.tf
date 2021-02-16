# Other useful configuration options
variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
  default     = "ap-south-1"
}

variable "ami_id" {
  type = string
  description = "AMI ID for windows nodes"
}

variable "admin_password" {
  type = string
  description = "Administrator password for windows nodes"
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
variable "client_name" {
  type = string
  description = "Client name for validation"
}

variable "node_depends_on" {
  type = any
  description = "Resource dependencies for nodes."
  default = []
}

variable "node_setup_depends_on" {
  type = any
  description = "Resource dependencies for node setup."
  default = []
}

variable "iam_instance_profile_name" {
  type = string
  description = "S3 access IAM instance profile name"
}

variable "gorilla_repo_bucket_url" {
  type = string
  description = "URL to gorilla repository/bucket"
}

variable "bucket_name" {
  type = string
  description = "URL to bucket containing gorilla repository"
}

variable "gorilla_binary_s3_object_key" {
  type = string
  description = "s3 bucket object key for gorilla binary"
}