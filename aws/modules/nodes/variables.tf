# Other useful configuration options
variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
  default     = "ap-south-1"
}

variable "windows_ami_id" {
  type        = string
  description = "AMI ID for windows nodes"
}

variable "macos_ami_id" {
  type        = string
  description = "AMI ID for macos nodes"
}

variable "admin_password" {
  type        = string
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
  description = "Security group ID for allow_rdp rule"
}

variable "allow_winrm" {
  type        = string
  description = "Security group ID for allow_winrm rule"
}

variable "allow_all_outgoing_requests" {
  type        = string
  description = "Security group ID for allow_all_outgoing_requests rule"
}

variable "key_name" {
  type        = string
  description = "Key name for AWS"
}

variable "windows_node_count" {
  type        = number
  description = "Number of windows nodes"
  default     = 2
}

variable "macos_node_count" {
  type        = number
  description = "Number of macos nodes"
  default     = 1
}

variable "windows_node_instance_type" {
  default = "t2.micro"
}

variable "chef_server_url" {
  type        = string
  description = "Public url of the automate server"
}
variable "client_name" {
  type        = string
  description = "Client name for validation"
}

variable "node_depends_on" {
  type        = any
  description = "Resource dependencies for nodes."
  default     = []
}

variable "node_setup_depends_on" {
  type        = any
  description = "Resource dependencies for node setup."
  default     = []
}

variable "iam_instance_profile_name" {
  type        = string
  description = "S3 access IAM instance profile name"
}

variable "munki_repo_bucket_url" {
  type        = string
  description = "URL to munki repository/bucket-object"
}

variable "bucket_name" {
  type        = string
  description = "URL to bucket containing gorilla repository"
}

variable "create_macos_nodes" {
  type        = bool
  description = "Whether to create a macos node and connect it to the server"
  default     = false
}

variable "macdhost_id" {
  type        = string
  description = "mac dedicated host id"
}

variable "private_key_path" {
  type        = string
  description = "Private key path"
  default     = "../keys/aws_terraform"
}
